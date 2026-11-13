#!/usr/bin/env node
/**
 * scripts/bootstrap-admin.mjs — `npm run admin`
 *
 * Creates (or repairs) the demo admin account the app's role-based routing
 * and the admin e2e spec depend on:
 *   email    admin@sahety.app
 *   password Admin@123456
 *   users/{uid}.role = 'admin' (plus name/email/phone/address)
 *
 * Idempotent: an existing Auth account is reused (password left untouched —
 * re-running never overwrites a password someone may have changed), and the
 * Firestore doc is upserted with merge so the role is always repaired.
 *
 * Run AFTER the service account is in place (see scripts/README.md §1) and
 * before the admin e2e spec or the demo itself.
 */

import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { loadServiceAccount, log } from './service-account.mjs';

const TAG = 'admin';

// Demo admin credentials — a mockup/demo account, not a production secret.
// Change the password in Firebase Console (or via Admin SDK) before ever
// pointing this project at real users.
const ADMIN_EMAIL = 'admin@sahety.app';
const ADMIN_PASSWORD = 'Admin@123456';
const ADMIN_NAME = 'Store Admin';

const { credentials, projectId } = loadServiceAccount();
log(TAG, `Firebase project: ${projectId}`);

initializeApp({ credential: cert(credentials) }, 'bootstrap-admin');

const auth = getAuth();
const db = getFirestore();

let uid;
try {
  const user = await auth.getUserByEmail(ADMIN_EMAIL);
  uid = user.uid;
  log(TAG, `Auth account already exists (uid ${uid}) — reusing it.`);
} catch (err) {
  if (err.code !== 'auth/user-not-found') throw err;
  const user = await auth.createUser({
    email: ADMIN_EMAIL,
    password: ADMIN_PASSWORD,
    displayName: ADMIN_NAME,
    emailVerified: true,
  });
  uid = user.uid;
  log(TAG, `Created Auth account (uid ${uid}).`);
}

// users/{uid} doc — same shape RegisterRepo writes for customers, but with
// the admin role. Merge so a manual profile edit is never clobbered.
const doc = {
  name: ADMIN_NAME,
  email: ADMIN_EMAIL,
  phone: '',
  address: '',
  role: 'admin',
};
await db.collection('users').doc(uid).set(doc, { merge: true });
log(TAG, `users/${uid} upserted (role=admin, merge).`);

log(TAG, 'Done. Login with admin@sahety.app / Admin@123456 → admin dashboard.');
