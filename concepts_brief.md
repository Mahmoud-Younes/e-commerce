# Demo-Ready PRD Completion: Bilingual Seed, Supabase Upload, Free Notifications, Per-Feature E2E

* **Author:** Mahmoud-Younes
* **Date:** 2026-11-08

## Overview

Turn the already-built Flutter e-commerce app (stages 1–7 committed, unit/widget/integration tests green) into a demo-ready product that fully satisfies `ecommerce_flutter_firebase_project.md`:

1. **Bilingual seed data** — dummy products and categories in Arabic and English in the live Firestore project (`sahety-ba784`), displayed according to device locale with English fallback.
2. **Real Supabase Storage** — the user supplies free-tier credentials; admin product-image upload stops falling back to the manual `imageUrl` text field.
3. **Order-status notifications without spending money** — a local Node.js Firebase Admin SDK watcher script sends FCM pushes and writes in-app notification records (no Blaze, no payment card, no credentials inside the app).
4. **Per-feature verification** — one new e2e spec per feature, run one at a time, with screenshot-based visual review after each run, closing with a full-journey pass (login → browse → cart → checkout → order → admin status change → notification).

Target user: the project owner presenting a graduation-style demo. Core value: everything the PRD promises visibly works on the emulator, in both languages, with realistic content.

## Analysis

Findings from the seven Goldfish lenses (`egm-design`, `egm-codebase-details`, `egm-zoom-out`, `egm-comprehension`, `egm-implementation-readiness`, `egm-structural`, `egm-inventive-catalyst`), deduplicated. Execution note: the lenses ran by direct dispatch inside the synthesizer (no subagent runtime was available that session), so finding recall is lower than a true parallel Goldfish swarm.

### Blockers

* **B1. Arabic cannot display or lay out RTL — the app has zero localization plumbing.** `MaterialApp` declares no `localizationsDelegates`/`supportedLocales` and pubspec has no `flutter_localizations`. Adding `nameAr`/`descriptionAr` alone would render Arabic strings inside an LTR English shell (wrong alignment, broken bidi punctuation). Displaying by device locale is an app-shell feature: add `flutter_localizations` + the three global delegates with `supportedLocales: [en, ar]`, and resolve product text through one helper (Arabic field when locale is `ar` and the field is non-empty, else English). Verify RTL rendering against the ScreenUtil 375×812 layouts in both locales. *(design, implementation-readiness, codebase-details)*
* **B2. The notification receiving side is dead code — FCM produces nothing today.** `main.dart` never calls `FcmService.initialize()`, never registers `FirebaseMessaging.onBackgroundMessage` (must happen before `runApp`), and no `navigatorKey` exists for tap-to-order-details. The wiring is documented in `FcmService`'s own doc comments but was never applied. Until this lands, no notification work is testable — receiver first, watcher second. *(codebase-details, implementation-readiness, structural)*
* **B3. Client-side notification recording is rejected by the shipped rules.** `recordOrderNotification` writes `notifications/{id}` from the client, but `firestore.rules:115-118` only allows `isAdmin()` to create notifications — a customer's write is denied, and background-handler failures are swallowed. Nobody creates notification documents today at all (no `functions/`, admin status updates only call `updateStatus`). Decision: the watcher (Firebase Admin SDK bypasses security rules) creates the `notifications/{id}` record server-side and sends the push; the client's recording path becomes an idempotent no-op guard. Add a rules test so this cannot regress. *(structural, codebase-details, zoom-out)*
* **B4. Token field mismatch — the watcher would look where no token is written.** `FcmService._saveToken` writes scalar `fcmToken` + `fcmTokenUpdatedAt` on `users/{uid}`, while `UserFields.fcmTokens` documents a map of `{token: true}`. Pick one source of truth: for a single-device demo keep the scalar `fcmToken`, fix the `UserFields` doc, and have the watcher read `users/{uid}.fcmToken` (skip silently when absent). Multi-device maps and `UNREGISTERED` cleanup are out of demo scope. *(codebase-details, structural)*
* **B5. Supabase upload cannot work even with real credentials — `Supabase.initialize` is never called.** The uploader calls `Supabase.instance.client.storage...` but `main.dart` never initializes Supabase; the first upload would throw into the "upload failed" branch at the exact demo moment that should impress. Fix: `await Supabase.initialize(...)` guarded by `isConfigured`; settle the bucket name (code says `products`, AGENTS.md says `product-images` — constants file wins, fix AGENTS.md); create a public bucket plus a storage policy allowing INSERT (anon key is not service-role). Verify the round-trip: pick image → upload → `getPublicUrl` → `cached_network_image` renders. *(implementation-readiness, codebase-details, structural)*
* **B6. The plan never verifies notifications, yet PRD §9 requires it.** Notification verification needs the app, the admin side, and the watcher running simultaneously. Plan an explicit scenario: seed customer token (auto-saved at login once B2 lands), start the watcher, place an order, advance status as admin, assert the push arrives, the in-app record appears, and tapping opens order details. Confirm the Pixel 7 Pro AVD image includes Google Play (FCM needs it); otherwise a physical device, which PRD §9 explicitly allows. *(zoom-out, comprehension)*

### Majors

* **M1. Search and category filtering are English-only.** Search matches `product.name` only; a user typing Arabic finds nothing. Search case-insensitively across `name` + `nameAr` regardless of locale. Decide the category model before seeding: keep `category` as a key and localize labels in the UI, or store `category`/`categoryAr`. *(codebase-details, design, comprehension)*
* **M2. Purchase-time name snapshot is single-language.** PRD §4 requires storing name and price at purchase time; the snapshot takes `product.name` (English). Resolve the display name at add-to-cart time and snapshot that — PRD §4 stays intact without widening `CartItemModel`. *(design, comprehension, inventive-catalyst)*
* **M3. Admin product form and grid ignore the Arabic fields.** Add optional `nameAr`/`descriptionAr` inputs (validate only when non-empty), prefill on edit, show `name · nameAr` in the admin list. Without this, admin-created data drifts from seeded data. *(codebase-details, design)*
* **M4. Seed and watcher scripts need a home, and the service account needs guarding.** Create a local-only `scripts/` (gitignored, matching this repo's local-only tooling convention) holding `seed.mjs` and `watch-orders.mjs`; the service-account JSON stays untracked and loads from an env var or untracked path. Committing it would repeat PRD §6's forbidden mistake for Firestore. Document setup in the README. *(structural, comprehension, implementation-readiness)*
* **M5. E2E specs run against the same live Firestore the demo shows.** Namespace test data (`e2e_` product-name prefix), let each spec create its own cart/order and tear down, and make "re-run the seed script" the reset button. Never run destructive specs against the demo dataset. *(inventive-catalyst, zoom-out, comprehension)*
* **M6. The watcher needs an idempotency and operations story.** A naive `onSnapshot` re-sends on restart and duplicate events; PRD §6 scopes customer pushes to confirmed/shipped/delivered while the admin flow also produces cancelled. Watch `orders` for status changes, dedupe on `(orderId, status)` with a local checkpoint file, map every reachable transition including cancelled, wrap as `npm run seed` / `npm run watch`, log every send, and write "start the watcher before the demo" into the README. *(inventive-catalyst, comprehension, implementation-readiness)*
* **M7. Push notification language is unspecified.** The watcher cannot know the device locale. Demo-grade answer: combined bilingual text ("Order shipped · تم شحن الطلب"). Slightly better: store device locale on `users/{uid}` at login. Send `notification` + `data{orderId, ...}` so both the system tray and tap-to-details work. *(comprehension, design, inventive-catalyst)*
* **M8. Pre-existing architecture inconsistencies will be exercised by the new work — fix in the same pass.** Nine bare-screen routes vs six getIt-wrapped; `OrderDetailsScreen` builds a separate `OrdersCubit` (fine functionally, inconsistent); `CheckoutCubit` silently falls back to an empty uid (rules reject at order creation — a mid-demo intermittent failure). Normalize routes to getIt `BlocProvider`s, replace the empty-uid fallback with an explicit redirect-to-login, add bloc listeners for checkout/orders/admin as time allows. *(structural, codebase-details)*
* **M9. README and structure docs lag the new reality (PRD §9 criterion).** Add README sections (Firebase, Supabase, seed, watcher, e2e) as the last step once behavior is stable; keep PRD §7's products row and `firestore_paths.dart` comments in sync with the bilingual fields. *(zoom-out, structural)*

### Minors

* **N1. A categories collection is probably dead weight.** The UI derives chips from products' `category` string; `Collections.categories` is declared but nothing reads it (verify before seeding). Seed bilingual category values on products only — YAGNI. *(inventive-catalyst, codebase-details)*
* **N2. Seed images should come from the real bucket.** Have `seed.mjs` upload a small local image set via supabase-js and store the returned public URLs — one script exercises both Supabase and the catalog, and the demo looks coherent (no Unsplash shortcuts). *(inventive-catalyst, implementation-readiness)*
* **N3. Model change ripples are small but real.** Rerun `dart run build_runner build --delete-conflicting-outputs` (codegen is committed, never hand-edit), then `flutter analyze` + `flutter test`; add unit tests for the locale-fallback helper (Arabic empty → English; English locale ignores `nameAr`). *(implementation-readiness, structural)*
* **N4. Screenshot review needs a checklist, not vibes.** Per feature capture: English run, Arabic run (RTL), empty/error states; store under `.e2e/` and review against a fixed checklist. Read `.agents/skills/e2e/SKILL.md` before writing specs. *(design)*
* **N5. Supabase free tier pauses idle projects.** Note in the README: wake/verify Supabase before the demo; the seed script doubles as a health check. *(implementation-readiness, comprehension)*
* **N6. Firestore rules need no change for the product fields — record the decision.** The only rules change in this whole plan is B3's notification-write decision; keep it under test. *(codebase-details, structural)*

### Inventive Contradictions and Pattern Resolutions

* **Trusted server vs free hosting:** PRD §6 demands a trusted sender; free tier forbids Cloud Functions. The local Admin SDK watcher resolves both — it *is* a trusted server environment, and because the Admin SDK bypasses security rules it also resolves B3. Ideal Final Result for this scale: one local Node entrypoint with three verbs — `seed`, `watch`, `reset` — so the entire ops surface is one terminal tab.
* **Bilingual display vs purchase-time snapshot:** capture the resolved display name at add-to-cart (M2); the catalog stores both languages and resolves at render time (B1 helper).
* **Live-project e2e vs hermetic verification:** no separate emulator-only Firestore project; namespaced fixtures plus seed-as-reset (M5) make the seed script the hermetic boundary.
* **Verification cost vs demo polish:** over-invest in the watcher checkpoint (M6) and FCM-receiver wiring (B2) — the two places under-engineering shows up live in front of an audience; under-invest in multi-device token maps (B4 keeps the scalar).

## Goals vs. Non-Goals

* **In-Scope Goals:**
  - Localization plumbing (delegates + supportedLocales + RTL-capable layouts) and a locale-resolver helper for product text.
  - `nameAr`/`descriptionAr` on products end-to-end: model + codegen, seed script, admin form, search across both languages.
  - Real Supabase Storage upload (init + bucket + policy) and bilingual seed data with images uploaded to the real bucket.
  - FCM receiver wired (init, background handler, navigator key, tap→order details) and a local Admin SDK watcher (push + notification record, idempotent, all status transitions).
  - One new e2e spec per feature run one-by-one with a screenshot checklist (EN/AR/empty/error), an explicit notification e2e scenario, and a final full-journey pass.
  - Architecture hygiene in passing: routes normalized to getIt BlocProviders, CheckoutCubit empty-uid fallback removed, rules test for the notification decision, README + PRD §7 sync.
* **Out-of-Scope Non-Goals:**
  - Blaze plan, deployed Cloud Functions, or any payment card.
  - Multi-device FCM token maps and `UNREGISTERED` cleanup (single scalar token).
  - Full UI-string localization (only product content is bilingual; framework plumbing added for RTL correctness).
  - PRD v1 exclusions: online payment, web admin panel, coupons, courier tracking.
  - A `categories` Firestore collection (unless verification shows the UI reads one).

## Alternatives Weighed

* **Cloud Functions for order-status notifications** — rejected by author: requires the Blaze billing plan and a payment card; the project must stay free.
* **Copying asroo_store's notification approach (legacy FCM HTTP API with server key in the app's `.env`)** — rejected on evidence: the legacy `fcm.googleapis.com/fcm/send` API was shut down in June 2024 (dead code), and storing privileged FCM credentials in the Flutter app violates PRD §6 directly.
* **Seeding product images from public URLs (Unsplash)** — rejected by review: placeholder URLs do not exercise the same `imageUrl` path the admin upload writes; seeding through Supabase validates the storage path and looks coherent.
* **A `categories` Firestore collection** — rejected for now by review: the UI derives filter chips from the product `category` string and nothing reads the collection; revisit only if verification shows otherwise.
* **Relaxing Firestore rules so customers create their own notification records** — rejected in favor of watcher-side writes: the Admin SDK path keeps the rules strict (customers still cannot write notifications) and the code/rules stay in agreement.
* **Multi-device token map (`fcmTokens` map per `UserFields` docs)** — rejected for demo scope: single scalar `fcmToken` is sufficient; the map drags in `UNREGISTERED` cleanup and migration logic.

## Key Decisions & Staging for Next Steps

* **Decisions resolved during ideation:**
  - Bilingual display = app-shell localization plumbing + one resolver helper (B1), not per-screen hacks.
  - Notification record writes move to the watcher (Admin SDK); client recording becomes a no-op guard; rules test added (B3).
  - Token contract: scalar `users/{uid}.fcmToken`; fix `UserFields` docs (B4).
  - Purchase snapshot = resolved display name at add-to-cart (M2).
  - E2E hygiene: `e2e_` namespacing, per-spec teardown, seed-as-reset (M5).
  - Ops surface: one local Node entrypoint — `seed`, `watch`, `reset` — in a gitignored `scripts/` with an untracked service-account JSON (M4, M6).
  - Push text: bilingual combined payload (M7).
* **Staging for `/egm-draft` (dependency order):**
  1. **Shell + model foundation:** B1 plumbing, ProductModel fields + codegen (N3), M1 search, M3 admin form.
  2. **Config gates:** B5 Supabase init + bucket policy, B2 FCM receiver wiring, B4 token decision.
  3. **Server-side scripts:** M4 scripts home + service account, N2 seed with images, M6 watcher with checkpoint, M7 notification language.
  4. **Verification:** B6 notification e2e scenario, per-feature specs with M5 namespace hygiene, N4 screenshot checklist, final full-journey pass.
  5. **Docs and sweep:** M9 README + PRD §7 sync; PRD §9 acceptance-criteria checklist as the closing gate; M8 router/cubit hygiene folded into whichever step touches each file.
* **Inputs needed from the author:** Supabase project URL + anon key (+ creating the public bucket and INSERT policy), service-account JSON downloaded from the Firebase console, and a decision on the physical device vs Google-Play-enabled AVD for the notification test (B6).
