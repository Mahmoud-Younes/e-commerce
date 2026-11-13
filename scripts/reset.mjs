#!/usr/bin/env node
/**
 * scripts/reset.mjs — `npm run reset`
 *
 * Deletes every Firestore `products` doc whose id starts with `seed_`
 * (the docs written by `npm run seed`), so `npm run seed` afterwards is a
 * clean slate. NEVER touches non-seed docs — deletion is scoped to the doc-id
 * range [seed_, seed_\uf8ff].
 *
 * Flags:
 *   --images       also delete the `seed/` objects from the Supabase bucket
 *   --dry-run      print what would be deleted without deleting anything
 *
 * Firebase project is derived from the service account JSON's `project_id`.
 */

import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore, FieldPath } from 'firebase-admin/firestore';
import { createClient } from '@supabase/supabase-js';
import { loadServiceAccount, log } from './service-account.mjs';
import {
  SUPABASE_URL,
  SUPABASE_PUBLISHABLE_KEY,
  SUPABASE_BUCKET,
  SEED_ID_PREFIX,
  SEED_IMAGE_PREFIX,
} from './config.mjs';

const TAG = 'reset';

async function main() {
  const args = process.argv.slice(2);
  const withImages = args.includes('--images') || args.includes('--with-images');
  const dryRun = args.includes('--dry-run');

  if (dryRun) log(TAG, 'DRY RUN: nothing will actually be deleted');

  // -------------------------------------------------------------------------
  // 1. Firestore: delete products whose doc id is in the seed_ range.
  //    A document-id range query guarantees non-seed docs are never matched.
  // -------------------------------------------------------------------------
  const account = loadServiceAccount();
  log(TAG, `Using service account: ${account.path}`);
  log(TAG, `Firebase project (from project_id): ${account.projectId}`);
  initializeApp({ credential: cert(account.credentials) });
  const db = getFirestore();

  const rangeStart = SEED_ID_PREFIX;
  const rangeEnd = `${SEED_ID_PREFIX}\uf8ff`; // sorts after any seed_<suffix> id

  const snapshot = await db
    .collection('products')
    .where(FieldPath.documentId(), '>=', rangeStart)
    .where(FieldPath.documentId(), '<=', rangeEnd)
    .get();

  log(TAG, `found ${snapshot.size} seed product doc(s) in range [${rangeStart} .. ${rangeEnd}]`);

  let deletedDocs = 0;
  if (!dryRun && snapshot.size > 0) {
    let batch = db.batch();
    let ops = 0;
    for (const doc of snapshot.docs) {
      log(TAG, `deleting products/${doc.id}`);
      batch.delete(doc.ref);
      ops++;
      if (ops === 400) {
        await batch.commit();
        deletedDocs += ops;
        batch = db.batch();
        ops = 0;
      }
    }
    if (ops > 0) {
      await batch.commit();
      deletedDocs += ops;
    }
  } else {
    for (const doc of snapshot.docs) log(TAG, `(dry run) would delete products/${doc.id}`);
  }

  // -------------------------------------------------------------------------
  // 2. Optional: delete the seed/ image objects from Supabase.
  // -------------------------------------------------------------------------
  let deletedImages = 0;
  let imageFailures = 0;

  if (withImages) {
    const supabase = createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
      auth: { persistSession: false },
    });
    const { data: objects, error } = await supabase.storage
      .from(SUPABASE_BUCKET)
      .list(SEED_IMAGE_PREFIX, { limit: 1000, sortBy: { column: 'name', order: 'asc' } });

    if (error) {
      log(TAG, `could not list seed images: ${error.message}`);
      imageFailures++;
    } else {
      const paths = (objects ?? [])
        .filter((obj) => obj.name?.endsWith('.png'))
        .map((obj) => `${SEED_IMAGE_PREFIX}${obj.name}`);
      log(TAG, `found ${paths.length} seed image object(s) in bucket "${SUPABASE_BUCKET}"`);
      for (const objectPath of paths) {
        if (dryRun) {
          log(TAG, `(dry run) would delete ${objectPath}`);
          continue;
        }
        const { error: removeError } = await supabase.storage.from(SUPABASE_BUCKET).remove([objectPath]);
        if (removeError) {
          log(TAG, `FAILED deleting ${objectPath}: ${removeError.message}`);
          imageFailures++;
        } else {
          deletedImages++;
          log(TAG, `deleted ${objectPath}`);
        }
      }
    }
    if (!dryRun && imageFailures > 0) {
      log(
        TAG,
        'hint: deleting storage objects with the publishable key needs a DELETE policy on ' +
          `storage.objects for bucket_id = '${SUPABASE_BUCKET}' (see scripts/README.md)`,
      );
    }
  } else if (!dryRun) {
    log(TAG, 'skipping Supabase images (pass --images to also delete seed/ storage objects)');
  }

  // -------------------------------------------------------------------------
  // Summary
  // -------------------------------------------------------------------------
  console.log(`\n=== reset summary ===`);
  console.log(`products deleted : ${dryRun ? 'dry run' : deletedDocs}/${snapshot.size}`);
  if (withImages) {
    console.log(
      `images deleted   : ${dryRun ? 'dry run' : deletedImages}${imageFailures ? ` (${imageFailures} failures)` : ''}`,
    );
  }
  console.log(`non-seed docs    : untouched by design\n`);

  if (!dryRun && imageFailures > 0) process.exit(1);
}

main().catch((err) => {
  console.error(`[${TAG}] fatal: ${err?.message ?? err}`);
  console.error(
    'Check that the service account is valid, belongs to the right project, and that Firestore is enabled there.\n',
  );
  process.exit(1);
});
