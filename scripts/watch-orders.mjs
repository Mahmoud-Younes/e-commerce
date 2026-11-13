#!/usr/bin/env node
/**
 * scripts/watch-orders.mjs — `npm run watch`
 *
 * Watches the Firestore `orders` collection of the service account's project
 * and, when an order's `status` FIELD CHANGES (never on cold start / creation),
 * does two things:
 *
 *   1. Sends an FCM v1 push to the order's user via firebase-admin
 *      messaging.send(), using the scalar `fcmToken` field on users/{uid}
 *      (falls back to the `fcmTokens` map form `{ "<token>": true }` that the
 *      Flutter app writes).
 *   2. Writes the in-app notification record into `notifications/{autoId}`:
 *      { userId, title, body, orderId, isRead: false, createdAt: serverTimestamp }
 *      — the Admin SDK bypasses security rules, so ONLY this watcher (never
 *      the client app) may write this collection for order updates.
 *
 * Idempotency: scripts/.watch-checkpoint.json stores orderId ->
 * lastNotifiedStatus; a transition already recorded there is skipped on
 * restart. On cold start the current statuses are recorded WITHOUT notifying,
 * so no history replay.
 *
 * Bounded catch-up (restart outage): if a checkpoint-known order's LIVE
 * status differs from its last-notified status at cold start, the missed
 * transition is notified exactly once (current status only — intermediate
 * statuses crossed during the outage are not replayed; the checkpoint then
 * moves to the live status). Orders created while the watcher was down are
 * recorded silently: creation never pushes, so their baseline is correct.
 *
 * Liveness: `node scripts/watch-orders.mjs probe` (npm run probe) loads the
 * service account, reaches Firestore once (15s budget) and exits 0, or logs
 * probe FAIL and exits 1 — run it before a demo to prove the dependency.
 *
 * DEVICE SCENARIO: the first app launch shows the notification permission
 * prompt — grant it. Denial does not block the in-app notification records
 * (they come from Firestore), but pushes are silently dropped by the OS and
 * the device looks dead while the watcher logs SENT; grant before demoing.
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { loadServiceAccount, log } from './service-account.mjs';

const TAG = 'watch';

const SCRIPTS_DIR = path.dirname(fileURLToPath(import.meta.url));
const CHECKPOINT_PATH = path.join(SCRIPTS_DIR, '.watch-checkpoint.json');

/** Bilingual push copy. `pending` intentionally has no body (creation, not an update). */
const PUSH_TITLE = 'Order Update · تحديث الطلب';
const STATUS_BODIES = {
  confirmed: 'Your order is confirmed · تم تأكيد طلبك',
  preparing: 'Your order is being prepared · جاري تجهيز طلبك',
  shipped: 'Your order is shipped · تم شحن طلبك',
  delivered: 'Your order is delivered · تم توصيل طلبك',
  cancelled: 'Your order was cancelled · تم إلغاء طلبك',
};

// ============================== CHECKPOINT =================================

function loadCheckpoint() {
  try {
    const raw = fs.readFileSync(CHECKPOINT_PATH, 'utf8');
    const parsed = JSON.parse(raw);
    if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
      return parsed;
    }
    log(TAG, `WARNING: ${CHECKPOINT_PATH} is not an object; starting with an empty checkpoint.`);
    return {};
  } catch (err) {
    if (err.code !== 'ENOENT') {
      log(TAG, `WARNING: could not read checkpoint (${err.message}); starting with an empty checkpoint.`);
    }
    return {};
  }
}

function saveCheckpoint(checkpoint) {
  try {
    fs.writeFileSync(CHECKPOINT_PATH, JSON.stringify(checkpoint, null, 2));
  } catch (err) {
    log(TAG, `WARNING: could not write checkpoint (${err.message}); dedupe may not survive a restart.`);
  }
}

// ============================== FCM TOKENS =================================

/**
 * Collects FCM registration tokens from a users/{uid} doc. Supports BOTH
 * shapes seen in this codebase:
 *   - scalar `fcmToken: "<token>"`            (watcher contract)
 *   - map `fcmTokens: { "<token>": true }`    (what the Flutter app writes)
 * @returns {string[]} de-duplicated, non-empty tokens
 */
function collectFcmTokens(userData) {
  const tokens = [];
  const scalar = userData?.fcmToken;
  if (typeof scalar === 'string' && scalar.trim() !== '') {
    tokens.push(scalar.trim());
  }
  const map = userData?.fcmTokens;
  if (map && typeof map === 'object' && !Array.isArray(map)) {
    for (const [token, enabled] of Object.entries(map)) {
      if (typeof token === 'string' && token.trim() !== '' && enabled !== false) {
        tokens.push(token.trim());
      }
    }
  }
  return [...new Set(tokens)];
}

// ================================ PROBE ====================================

/** Probe verb: prove the watcher's dependencies are reachable, then exit. */
async function probe() {
  const PROBE_TIMEOUT_MS = 15_000;
  try {
    const account = loadServiceAccount();
    log(TAG, `probe: service account ${account.path} (project ${account.projectId})`);

    const result = await Promise.race([
      (async () => {
        initializeApp({ credential: cert(account.credentials) });
        const db = getFirestore();
        const ordersSnap = await db.collection('orders').limit(1).get();
        const checkpoint = loadCheckpoint();
        return { size: ordersSnap.size, checkpointSize: Object.keys(checkpoint).length };
      })(),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error(`no Firestore response within ${PROBE_TIMEOUT_MS / 1000}s`)), PROBE_TIMEOUT_MS),
      ),
    ]);

    log(TAG, `probe OK: Firestore reachable (${result.size} order doc(s) sampled); checkpoint holds ${result.checkpointSize} order(s)`);
  } catch (err) {
    log(TAG, `probe FAIL: ${err?.message ?? err}`);
    process.exit(1);
  }
}

// ================================ MAIN =====================================

if (process.argv[2] === 'probe') {
  await probe();
  process.exit(0);
}

function main() {
  const account = loadServiceAccount();
  log(TAG, `Using service account: ${account.path}`);
  log(TAG, `Firebase project (from project_id): ${account.projectId}`);
  log(TAG, `Checkpoint file: ${CHECKPOINT_PATH}`);

  initializeApp({ credential: cert(account.credentials) });
  const db = getFirestore();
  const messaging = getMessaging();

  const checkpoint = loadCheckpoint();

  /** orderId -> last seen status (in-memory mirror of the collection). */
  const lastStatuses = new Map();
  /** False until the first snapshot is consumed (cold start = record only). */
  let warm = false;
  /** Serializes async transition handling so one order never races itself. */
  let queue = Promise.resolve();

  async function processTransition(orderId, orderData, previousStatus, newStatus) {
    try {
      if (!newStatus) {
        log(TAG, `SKIP ${orderId}: status field is missing/null (was '${previousStatus}')`);
        return;
      }
      const body = STATUS_BODIES[newStatus];
      if (!body) {
        log(TAG, `SKIP ${orderId}: no push template for status '${newStatus}' (from '${previousStatus}')`);
        return;
      }
      if (checkpoint[orderId] === newStatus) {
        log(TAG, `SKIP ${orderId}: transition to '${newStatus}' already notified (checkpoint)`);
        return;
      }

      const userId = typeof orderData?.userId === 'string' ? orderData.userId.trim() : '';
      if (!userId) {
        log(TAG, `SKIP ${orderId}: order doc has no userId field`);
        return;
      }

      const userSnap = await db.collection('users').doc(userId).get();
      if (!userSnap.exists) {
        log(TAG, `SKIP ${orderId}: users/${userId} does not exist`);
        return;
      }
      const tokens = collectFcmTokens(userSnap.data());
      if (tokens.length === 0) {
        log(
          TAG,
          `SKIP push ${orderId} -> users/${userId}: fcmToken missing/empty ` +
            '(device has not registered for push); still writing the in-app record',
        );
      }

      // 1. FCM v1 push (best-effort per token; a stale token must not block
      //    the in-app record below).
      let pushOk = tokens.length > 0;
      for (const token of tokens) {
        try {
          const messageId = await messaging.send({
            token,
            notification: { title: PUSH_TITLE, body },
            data: { orderId, status: newStatus },
          });
          log(TAG, `SENT ${orderId} -> users/${userId} status='${newStatus}' token=...${token.slice(-8)} messageId=${messageId}`);
        } catch (err) {
          pushOk = false;
          const code = err?.errorInfo?.code ?? err?.code ?? 'unknown';
          log(TAG, `SEND FAILED ${orderId} -> users/${userId} token=...${token.slice(-8)} code=${code}: ${err?.message}`);
        }
      }

      // 2. In-app notification record (Admin SDK bypasses security rules —
      //    this must come from the watcher, never the client app).
      const notifRef = await db.collection('notifications').add({
        userId,
        title: PUSH_TITLE,
        body,
        orderId,
        isRead: false,
        createdAt: FieldValue.serverTimestamp(),
      });
      log(TAG, `RECORDED notifications/${notifRef.id} for ${orderId} (userId=${userId}, status='${newStatus}')`);

      // 3. Checkpoint AFTER both actions succeeded/attempted.
      checkpoint[orderId] = newStatus;
      saveCheckpoint(checkpoint);
      log(TAG, `DONE ${orderId}: '${previousStatus}' -> '${newStatus}' (push ${pushOk ? 'ok' : 'had failures'})`);
    } catch (err) {
      log(TAG, `ERROR processing ${orderId}: ${err?.message ?? err}`);
    }
  }

  const ordersRef = db.collection('orders');

  const unsubscribe = ordersRef.onSnapshot(
    (snapshot) => {
      if (!warm) {
        // Cold start: record current statuses WITHOUT notifying for history —
        // EXCEPT the bounded catch-up: a checkpoint-known order whose live
        // status moved past its last-notified status missed a transition
        // while the watcher was down; it is notified exactly once, for the
        // current status only. Orders unknown to the checkpoint (created
        // during the outage, or before the checkpoint existed) have no
        // notified history to catch up from — creation never pushes, so
        // recording them silently is their correct baseline.
        for (const doc of snapshot.docs) {
          const status = typeof doc.data()?.status === 'string' ? doc.data().status : null;
          lastStatuses.set(doc.id, status);

          const notified = checkpoint[doc.id];
          if (
            typeof notified === 'string' &&
            notified !== status &&
            STATUS_BODIES[status]
          ) {
            log(TAG, `catch-up: ${doc.id} checkpointed as '${notified}' but live status is '${status}' (missed while watcher was down)`);
            queue = queue
              .then(() => processTransition(doc.id, doc.data() ?? {}, notified, status))
              .catch((err) => log(TAG, `unhandled catch-up error for ${doc.id}: ${err?.message ?? err}`));
          }
        }
        warm = true;
        log(TAG, `cold start: recorded ${snapshot.size} existing order(s); no notifications for history, catch-up queued for checkpoint-known regressions/moves`);
        return;
      }

      for (const change of snapshot.docChanges()) {
        const orderId = change.doc.id;
        const data = change.doc.data() ?? {};
        const newStatus = typeof data.status === 'string' ? data.status : null;

        if (change.type === 'removed') {
          lastStatuses.delete(orderId);
          log(TAG, `order ${orderId} removed; dropped from tracker`);
          continue;
        }

        const previousStatus = lastStatuses.has(orderId) ? lastStatuses.get(orderId) : null;
        lastStatuses.set(orderId, newStatus);

        if (previousStatus === newStatus) continue; // no-op write, not a change

        if (previousStatus === null) {
          log(TAG, `order ${orderId} created with status '${newStatus}' — creation, not a status change; no push`);
          continue;
        }

        log(TAG, `order ${orderId} status change: '${previousStatus}' -> '${newStatus}'`);
        queue = queue
          .then(() => processTransition(orderId, data, previousStatus, newStatus))
          .catch((err) => log(TAG, `unhandled error for ${orderId}: ${err?.message ?? err}`));
      }
    },
    (error) => {
      // The SDK does not auto-retry after surfacing an error to this
      // callback — a dead listener must not sit silently on demo day.
      log(TAG, `FATAL: orders snapshot stream error: ${error.message}`);
      unsubscribe();
      process.exit(1);
    },
  );

  log(TAG, `watching collection: ${account.projectId}.orders — Ctrl+C to stop`);

  const shutdown = (signal) => {
    log(TAG, `${signal} received; stopping watcher (checkpoint already up to date)...`);
    unsubscribe();
    process.exit(0);
  };
  process.on('SIGINT', () => shutdown('SIGINT'));
  process.on('SIGTERM', () => shutdown('SIGTERM'));
}

main();
