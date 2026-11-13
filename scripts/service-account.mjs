/**
 * scripts/service-account.mjs — shared Firebase service-account loader.
 *
 * The Firebase project is NEVER hardcoded: the project id is read from the
 * service account JSON's `project_id` field, so swapping the file swaps the
 * project the scripts talk to.
 *
 * Resolution order:
 *   1. SERVICE_ACCOUNT_PATH env var (absolute or relative to cwd)
 *   2. scripts/serviceAccount.json (next to this file)
 *
 * Exits the process with clear instructions when the file is missing or
 * invalid — every script (seed / watch / reset) starts with this.
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const SCRIPTS_DIR = path.dirname(fileURLToPath(import.meta.url));

/** Path the loader will look at (no I/O). */
export function resolveServiceAccountPath() {
  if (process.env.SERVICE_ACCOUNT_PATH && process.env.SERVICE_ACCOUNT_PATH.trim() !== '') {
    return path.resolve(process.env.SERVICE_ACCOUNT_PATH.trim());
  }
  return path.join(SCRIPTS_DIR, 'serviceAccount.json');
}

function printMissingAccountError(lookedAt) {
  console.error(`
============================================================
 ERROR: Firebase service account JSON not found.
============================================================

Looked in:
  1. SERVICE_ACCOUNT_PATH env var -> ${lookedAt.envPath || '(not set)'}
  2. default location             -> ${lookedAt.defaultPath}

Fix:
  1. Firebase Console -> Project settings -> Service accounts
     -> "Generate new private key" and download the JSON.
  2. Save it as:
         scripts/serviceAccount.json
     (or anywhere, then set SERVICE_ACCOUNT_PATH=/path/to/the.json)
  3. IMPORTANT: the JSON's "project_id" must be the SAME Firebase
     project the Flutter app uses (lib/firebase_options.dart /
     android/app/google-services.json). The scripts derive the
     project from the file, so the wrong file talks to the wrong
     project (e.g. an old/scratch project).
============================================================
`);
}

/**
 * Loads and validates the service account.
 * @returns {{ path: string, credentials: object, projectId: string }}
 *   Exits the process (code 1) with printed instructions on failure.
 */
export function loadServiceAccount() {
  const envPath = process.env.SERVICE_ACCOUNT_PATH
    ? path.resolve(process.env.SERVICE_ACCOUNT_PATH.trim())
    : null;
  const defaultPath = path.join(SCRIPTS_DIR, 'serviceAccount.json');

  let filePath = null;
  if (envPath && fs.existsSync(envPath)) {
    filePath = envPath;
  } else if (fs.existsSync(defaultPath)) {
    filePath = defaultPath;
  }

  if (!filePath) {
    printMissingAccountError({ envPath, defaultPath });
    process.exit(1);
  }

  let credentials;
  try {
    credentials = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (err) {
    console.error(`\nERROR: could not parse service account JSON at ${filePath}: ${err.message}\n`);
    process.exit(1);
  }

  const projectId = credentials.project_id;
  if (!projectId) {
    console.error(
      `\nERROR: service account JSON at ${filePath} has no "project_id" field.\n` +
      'Download a fresh private key from Firebase Console -> Project settings -> Service accounts.\n',
    );
    process.exit(1);
  }

  return { path: filePath, credentials, projectId };
}

/** Standard console prefix per script. */
export function log(tag, message) {
  console.log(`[${tag} ${new Date().toISOString()}] ${message}`);
}
