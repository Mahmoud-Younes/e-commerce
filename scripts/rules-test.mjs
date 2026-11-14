#!/usr/bin/env node
/**
 * scripts/rules-test.mjs — `npm run test:rules`
 *
 * Firestore security-rules unit tests for firestore.rules, run against the
 * LOCAL Firestore emulator ONLY (127.0.0.1:8080) — this suite never touches
 * the real sahety-ba784 project; the projectId below is a scratch id the
 * emulator provisions on the fly.
 *
 * Covered assertions (PRD §5/§9 security criteria + review M15):
 *   1. customers CANNOT create notifications/{id} (watcher/admin only)
 *   2. admins CAN create notifications/{id} (harness control — proves the
 *      suite is not over-blocking)
 *   3. notifications owner-read allowed; cross-user read denied
 *   4. orders owner-read allowed; cross-user read denied; signed-out denied
 *   5. an HONEST order create succeeds (control: valid prices + recomputed
 *      total — guards the denial tests below against false positives)
 *   6. order create with a manipulated line price is DENIED (PRD §9: prices
 *      re-checked against live products/{productId})
 *   7. order create with a tampered totalPrice is DENIED (PRD §9: total
 *      recomputed by the rules, never trusted from the client)
 *   8. customer order-status update DENIED; admin update ALLOWED
 *      (PRD §5: admin-only status transitions)
 *   9. users/{uid} self-promotion to 'admin' DENIED
 *
 * Fixture-name contract: ids are stable and documented here —
 * users/alice-customer, users/bob-customer, users/admin-user (role 'admin'),
 * products/prod-1 (price 100), orders/order-alice-1 (pending, one line of
 * 2 × prod-1, totalPrice 200). Rules cannot create the admin role doc
 * (users create requires role == 'customer'), so fixtures are seeded through
 * withSecurityRulesDisabled — exactly how the real world gets its first
 * admin too (scripts/bootstrap-admin.mjs via the Admin SDK).
 *
 * Prerequisites + one-shot invocation are documented in scripts/README.md
 * (JDK 17+, firebase-tools via npx, @firebase/rules-unit-testing).
 */

import assert from 'node:assert/strict';
import fs from 'node:fs';
import net from 'node:net';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { after, afterEach, before, describe, it } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';

const SCRIPTS_DIR = path.dirname(fileURLToPath(import.meta.url));
const RULES_PATH = path.resolve(SCRIPTS_DIR, '..', 'firestore.rules');
const EMULATOR_HOST = '127.0.0.1';
const EMULATOR_PORT = 8080;
const SCRATCH_PROJECT_ID = 'rules-test-scratch';

/** One-line TCP reachability check so a cold run prints setup help, not a stack trace. */
function isEmulatorUp(host, port, timeoutMs = 1500) {
  return new Promise((resolve) => {
    const socket = net.connect({ host, port });
    const done = (up) => {
      socket.destroy();
      resolve(up);
    };
    socket.setTimeout(timeoutMs);
    socket.once('connect', () => done(true));
    socket.once('timeout', () => done(false));
    socket.once('error', () => done(false));
  });
}

// ============================ TEST DATA ====================================

const ALICE = 'alice-customer';
const BOB = 'bob-customer';
const ADMIN = 'admin-user';
const ORDER_ALICE = 'order-alice-1';

const orderFixture = {
  userId: ALICE,
  status: 'pending',
  items: [{ productId: 'prod-1', price: 100, quantity: 2 }],
  totalPrice: 200,
};

// ============================== HARNESS ====================================

/** @type {import('@firebase/rules-unit-testing').TestEnvironment} */
let testEnv;

function customerDb(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

function adminDb() {
  return testEnv.authenticatedContext(ADMIN).firestore();
}

function signedOutDb() {
  return testEnv.unauthenticatedContext().firestore();
}

/** Seeds the fixture set (fixture-name contract above) with rules disabled. */
async function seedFixtures() {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await Promise.all([
      db.doc(`users/${ALICE}`).set({ role: 'customer' }),
      db.doc(`users/${BOB}`).set({ role: 'customer' }),
      db.doc(`users/${ADMIN}`).set({ role: 'admin' }),
      db.doc('products/prod-1').set({ name: 'Fixture Product', price: 100 }),
      db.doc(`orders/${ORDER_ALICE}`).set(orderFixture),
    ]);
  });
}

// ============================== TESTS ======================================

before(async () => {
  if (!(await isEmulatorUp(EMULATOR_HOST, EMULATOR_PORT))) {
    console.error(`
============================================================
 ERROR: Firestore emulator not reachable at ${EMULATOR_HOST}:${EMULATOR_PORT}.
============================================================

The rules suite runs against the LOCAL emulator only. Start it, then re-run:

  # one-shot (starts emulator, runs the suite, stops it):
  npx firebase emulators:exec --only firestore "npm run test:rules"

  # or keep it running in another terminal:
  npx firebase emulators:start --only firestore

Requires JDK 17+ (the emulator is Java-based) and firebase-tools via npx —
see scripts/README.md ("Rules unit tests").
============================================================`);
    process.exit(1);
  }

  testEnv = await initializeTestEnvironment({
    projectId: SCRATCH_PROJECT_ID,
    firestore: {
      rules: fs.readFileSync(RULES_PATH, 'utf8'),
      host: EMULATOR_HOST,
      port: EMULATOR_PORT,
    },
  });
});

afterEach(async () => {
  await testEnv.clearFirestore();
});

after(async () => {
  await testEnv.cleanup();
});

describe('firestore.rules — notifications', () => {
  it('customer cannot create a notification record (watcher/admin only)', async () => {
    await seedFixtures();
    await assertFails(
      customerDb(ALICE).collection('notifications').add({
        userId: ALICE,
        title: 'fake',
        body: 'client-side forgery attempt',
        orderId: ORDER_ALICE,
        isRead: false,
      }),
    );
  });

  it('admin can create a notification record (harness control)', async () => {
    await seedFixtures();
    await assertSucceeds(
      adminDb().collection('notifications').add({
        userId: ALICE,
        title: 'Order Update',
        body: 'Your order is confirmed',
        orderId: ORDER_ALICE,
        isRead: false,
      }),
    );
  });

  it('owner reads own notifications; cross-user read is denied', async () => {
    await seedFixtures();
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx
        .firestore()
        .collection('notifications')
        .doc('notif-alice-1')
        .set({ userId: ALICE, title: 't', body: 'b', orderId: ORDER_ALICE, isRead: false });
    });
    await assertSucceeds(customerDb(ALICE).doc('notifications/notif-alice-1').get());
    await assertFails(customerDb(BOB).doc('notifications/notif-alice-1').get());
  });
});

describe('firestore.rules — orders (PRD §5/§9)', () => {
  it('owner reads own order; cross-user and signed-out reads are denied', async () => {
    await seedFixtures();
    await assertSucceeds(customerDb(ALICE).doc(`orders/${ORDER_ALICE}`).get());
    await assertFails(customerDb(BOB).doc(`orders/${ORDER_ALICE}`).get());
    await assertFails(signedOutDb().doc(`orders/${ORDER_ALICE}`).get());
  });

  it('an honest order create succeeds (control for the denial tests)', async () => {
    await seedFixtures();
    await assertSucceeds(
      customerDb(ALICE).collection('orders').add({
        ...orderFixture,
        userId: ALICE,
      }),
    );
  });

  it('order create with a manipulated line price is denied (PRD §9)', async () => {
    await seedFixtures();
    // Catalog price is 100 (products/prod-1); the client claims 50 per line
    // with the SAME recomputed-looking total — the rules re-price every line
    // against the live product doc, so the whole write must fail.
    await assertFails(
      customerDb(ALICE).collection('orders').add({
        userId: ALICE,
        status: 'pending',
        items: [{ productId: 'prod-1', price: 50, quantity: 2 }],
        totalPrice: 100,
      }),
    );
  });

  it('order create with a tampered totalPrice is denied (PRD §9)', async () => {
    await seedFixtures();
    // Lines are honest (100 × 2 = 200) but the client submits 1 — the rules
    // recompute the total and never trust the request's own.
    await assertFails(
      customerDb(ALICE).collection('orders').add({
        userId: ALICE,
        status: 'pending',
        items: [{ productId: 'prod-1', price: 100, quantity: 2 }],
        totalPrice: 1,
      }),
    );
  });

  it('customer cannot advance order status; admin can (PRD §5)', async () => {
    await seedFixtures();
    await assertFails(
      customerDb(ALICE).doc(`orders/${ORDER_ALICE}`).update({ status: 'confirmed' }),
    );
    await assertSucceeds(
      adminDb().doc(`orders/${ORDER_ALICE}`).update({ status: 'confirmed' }),
    );
  });
});

describe('firestore.rules — users (role lock)', () => {
  it('a customer cannot self-promote to admin', async () => {
    await seedFixtures();
    await assertFails(
      customerDb(ALICE).doc(`users/${ALICE}`).update({ role: 'admin' }),
    );
    // The update must keep the role unchanged even for an honest field edit.
    await assertSucceeds(
      customerDb(ALICE).doc(`users/${ALICE}`).update({ role: 'customer' }),
    );
  });
});
