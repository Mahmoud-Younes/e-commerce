# scripts/ — Local Ops Tooling

Node.js tooling for the e-commerce demo (run from this `scripts/` directory):

| Command           | What it does |
| ----------------- | ------------ |
| `npm run seed`    | Generates 30 placeholder product images (pure-JS PNG encoder, no ffmpeg/ImageMagick), uploads them to Supabase Storage, and upserts 30 bilingual products into Firestore `products` with deterministic ids `seed_<slug>` (idempotent: set + merge). |
| `npm run admin`   | Creates (or repairs) the demo admin account `admin@sahety.app` / `Admin@123456` with `users/{uid}.role = 'admin'` (idempotent: reuses an existing Auth account, upserts the doc with merge, never overwrites a changed password). |
| `npm run watch`   | Long-running watcher: on every order `status` change it sends an FCM v1 push to the customer AND writes the in-app `notifications/{autoId}` record (Admin SDK bypasses security rules — this must come from here, never the app). |
| `npm run reset`   | Deletes all `products` docs whose id starts with `seed_` (nothing else). Pass `--images` to also delete the `seed/` objects in Supabase, `--dry-run` to preview. |

## Prerequisites

- Node.js >= 20 (developed on v24) and npm.
- A Firebase **service account JSON** for the project the Flutter app uses.
- A Supabase project with a public `product-images` bucket (one-time setup below).

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
   with check (bucket_id = 'product-images');
   ```

That insert policy is all `npm run seed` needs on a fresh bucket. Two optional
extras (needed when re-seeding over existing objects / using `reset --images`):

```sql
create policy "public update to product-images"
on storage.objects for update to anon, authenticated
with check (bucket_id = 'product-images');

create policy "public delete from product-images"
on storage.objects for delete to anon, authenticated
using (bucket_id = 'product-images');
```

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
npm run watch           # watch orders -> FCM push + in-app notification
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
  current statuses WITHOUT notifying (no history replay); new orders are
  recorded without a push (creation is not a status change). `pending` has no
  push body by design — the five notify-worthy statuses are `confirmed`,
  `preparing`, `shipped`, `delivered`, `cancelled`.
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
- [ ] **Start `npm run watch` BEFORE the demo** (keep the terminal open). If
      it is started after the status change, that transition is missed — there
      is intentionally no history replay.
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
