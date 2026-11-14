# scripts/ — Local Ops Tooling

Node.js tooling for the e-commerce demo (run from this `scripts/` directory):

| Command               | What it does |
| --------------------- | ------------ |
| `npm run seed`        | Generates 30 placeholder product images (pure-JS PNG encoder, no ffmpeg/ImageMagick), uploads them to Supabase Storage, and upserts 30 bilingual products into Firestore `products` with deterministic ids `seed_<slug>` (idempotent: set + merge). |
| `npm run admin`       | Creates (or repairs) the demo admin account `admin@sahety.app` / `Admin@123456` with `users/{uid}.role = 'admin'` (idempotent: reuses an existing Auth account, upserts the doc with merge, never overwrites a changed password). **⚠️ `Admin@123456` is a DEMO-ONLY credential for this scratch project — never reuse it in a real deployment.** |
| `npm run watch`       | Long-running watcher: on every order `status` change it sends an FCM v1 push to the customer AND writes the in-app `notifications/{autoId}` record (Admin SDK bypasses security rules — this must come from here, never the app). Also proves its own dependencies with `npm run probe`. |
| `npm run probe`       | Liveness check for the watcher's dependencies: loads the service account, reaches Firestore once (15 s budget), prints `probe OK` (exit 0) or `probe FAIL` (exit 1). Run it before a demo. |
| `npm run test:rules`  | Firestore security-rules unit tests against the LOCAL emulator only (see "Rules unit tests" below). Demoted from any CI hard gate: run it after changing `firestore.rules` and before a demo. |
| `npm run reset`       | Deletes all `products` docs whose id starts with `seed_` (nothing else). Pass `--images` to also delete the `seed/` objects in Supabase, `--dry-run` to preview. |

## Prerequisites

- Node.js >= 20 (developed on v24) and npm.
- A Firebase **service account JSON** for the project the Flutter app uses.
- A Supabase project with a public `product-images` bucket (one-time setup below).

### Rules unit tests (`npm run test:rules`, optional)

The suite (`rules-test.mjs`) runs against the **local Firestore emulator only**
(`127.0.0.1:8080`) — it never touches the real project. Extra prerequisites:

- **JDK 17+** — the emulator is Java-based (`java -version` must resolve).
- **firebase-tools** — `npx firebase-tools` works without a global install.
- **`@firebase/rules-unit-testing`** — already in `devDependencies`.

ESM caveat: this directory runs `"type": "module"` and the suite is authored
ESM-first (`rules-test.mjs`). If you ever need CommonJS interop, keep the
`.mjs` extension — do not flip the package's `type` field.

One-shot invocation (starts the emulator, runs the suite, stops it):

```bash
npx firebase emulators:exec --only firestore "npm run test:rules"
```

or keep `npx firebase emulators:start --only firestore` running in another
terminal and `npm run test:rules` against it. With the emulator down, the
suite prints these instructions and exits non-zero instead of stack-tracing.
Fixture ids are documented in `rules-test.mjs`'s header (stable
`users/alice-customer`-style names, seeded rules-disabled like the real first
admin is).

## 1. Firebase service account

The Firebase project is **never hardcoded** — it is read from the service
account file's `project_id`, so swapping the file swaps the project.

1. Firebase Console -> Project settings -> Service accounts -> **Generate new private key**.
2. Save the downloaded JSON as `scripts/serviceAccount.json`
   (or anywhere and point `SERVICE_ACCOUNT_PATH=/path/to/the.json` at it).

The `project_id` in that file MUST be the same project the Flutter app talks
to (`lib/firebase_options.dart` / `android/app/google-services.json`) — the
watcher reads `orders` and writes `notifications` there, and the seed writes
`products` there. `serviceAccount*.json` is gitignored; never commit it.

## 2. Supabase bucket (one-time)

Product images live in Supabase (Firebase Storage needs the Blaze plan).

1. Supabase Dashboard -> Storage -> **New bucket**:
   - Name: `product-images`
   - **Public bucket: ON** (public read access — the app loads images by URL).
2. Supabase Dashboard -> SQL Editor -> run:

   ```sql
   create policy "public upload to product-images"
   on storage.objects for insert to anon, authenticated
   with check (
     bucket_id = 'product-images'
     and (name like 'seed/%' or name like 'products/%')
   );
   ```

That insert policy is all `npm run seed` needs on a fresh bucket. Two optional
extras (needed when re-seeding over existing objects / using `reset --images`):

```sql
create policy "public update to product-images"
on storage.objects for update to anon, authenticated
with check (
  bucket_id = 'product-images'
  and (name like 'seed/%' or name like 'products/%')
);

create policy "public delete from product-images"
on storage.objects for delete to anon, authenticated
using (
  bucket_id = 'product-images'
  and (name like 'seed/%' or name like 'products/%')
);
```

The policies are **prefix-scoped to the two real object prefixes** —
`seed/<slug>.png` (what `npm run seed` writes, `SEED_IMAGE_PREFIX` in
`scripts/config.mjs`) and `products/<timestamp>_<fileName>` (what the admin
app writes, `admin_image_uploader.dart`). Anonymous writers can therefore not
touch any other path in the bucket.

Accepted risk (demo-scoped): the publishable key is public, so anyone can
still overwrite or delete objects under `seed/` and `products/`. Fine for a
demo dataset on a scratch project — tighten the policies to authenticated
writers only (and rotate the key) if this project outlives the demo, or
delete the bucket/policies after demo day.

Supabase URL/key/bucket name are constants in `scripts/config.mjs`. The
publishable key there is safe to expose; writes are gated by the policies
above.

## 3. Install deps

```bash
cd scripts
npm install
```

## Commands

```bash
npm run seed            # seed 30 products + images (safe to re-run)
npm run admin           # create/repair the demo admin account (run once)
npm run probe           # liveness check: service account + Firestore reachable
npm run watch           # watch orders -> FCM push + in-app notification
npm run test:rules      # firestore.rules unit tests (local emulator only)
npm run reset           # delete seed_ products
npm run reset -- --images --dry-run   # preview storage cleanup too
```

Notes:

- `seed` doubles as a health check: if the bucket is missing or the insert
  policy is absent it prints the exact bucket-creation + SQL instructions and
  exits non-zero. It writes no Firestore docs when images fail, so you never
  get a catalog full of broken image links.
- Product doc contract (frozen — the Flutter app parses it):
  `name`, `nameAr`, `description`, `descriptionAr`, `category` (canonical
  English key), `categoryAr`, `price` (number, EGP), `imageUrl`, `stock`
  (int), `isAvailable` (true). Doc ids: `seed_<english-name-slug>`.
- `watch` only reacts to `status` FIELD changes. On cold start it records the
  current statuses WITHOUT notifying for history — except the bounded
  catch-up: a checkpoint-known order whose live status moved past its
  last-notified status is notified once, for the current status only (status
  changes missed during watcher downtime are no longer silently lost; orders
  created while it was down stay silent — creation is not a status change).
  `pending` has no push body by design — the five notify-worthy statuses are
  `confirmed`, `preparing`, `shipped`, `delivered`, `cancelled`.
- Push copy is bilingual ("Order Update · تحديث الطلب" + a per-status body),
  with a data payload `{ orderId, status }` alongside the notification block.
- The customer's token is read from `users/{uid}`: the scalar `fcmToken`
  field (what the app writes) first, with the legacy `fcmTokens` map
  (`{ "<token>": true }`) as a tolerated fallback. Missing/empty token ->
  the push is skipped with a log line (the in-app record is still written
  so the notification center stays correct).
- `watch` deduplicates via `scripts/.watch-checkpoint.json`
  (orderId -> lastNotifiedStatus); a transition already recorded there is
  skipped after a restart. The file is gitignored local state — delete it if
  you want to force-replay notifications.

## Demo-day checklist

- [ ] `npm run seed` at least once beforehand and open the app catalog — the
      images come straight from Supabase URLs cached by the CDN.
- [ ] **Start `npm run watch` BEFORE the demo** (keep the terminal open). A
      watcher started late catches up on missed transitions for orders it
      already checkpointed — but a customer device that was granted push
      permission after a missed send still misses that push (the in-app
      record does arrive); rehearse the flow rather than relying on catch-up.
- [ ] `npm run probe` right before showtime — `probe OK` proves the service
      account and Firestore are reachable (the demo's most fragile
      dependency).
- [ ] On the customer device, GRANT the notification permission on first
      launch. Denial doesn't block the in-app records (they come from
      Firestore), but pushes are dropped by the OS while the watcher still
      logs SENT.
- [ ] Supabase free-tier note: projects **pause after about a week of
      inactivity**. Open the Supabase dashboard the morning of the demo to
      wake it (and re-run `npm run seed` if the bucket was purged), or the
      product grid renders with broken images.
- [ ] Log in on a real device/emulator build that has registered its FCM
      token, then change an order's status from the admin side and watch the
      push + notification center entry land.
- [ ] Firebase/Google projects also idle-pause on the Spark plan similarly
      rarely, but confirm the Firebase project is the one in
      `serviceAccount.json` (`watch` prints it at startup).

## Troubleshooting

| Symptom | Fix |
| ------- | --- |
| `service account JSON not found` | Put the file at `scripts/serviceAccount.json` or set `SERVICE_ACCOUNT_PATH`. |
| `no "project_id" field` | Re-download the private key from Firebase Console. |
| Seed exits with bucket instructions | Create the `product-images` public bucket + run the insert policy SQL (section 2). |
| Upload fails with row-level security | The insert policy is missing or scoped to another bucket id. |
| Watch exits / `permission denied` on Firestore | The service account's project differs from the app's, or Firestore is not enabled there. |
| Push sent, phone silent | Device token stale (`messaging/registration-token-not-registered` is logged) — reopen the app to re-register and re-trigger a status change. |
