# Demo-Ready PRD Completion: Bilingual Catalog, Supabase Uploads, Free Notifications, Per-Feature E2E

*   **Author:** Mahmoud-Younes
*   **Status:** Proposed
*   **Date:** 2026-11-10

--------------------------------------------------------------------------------

## Overview

The app already implements every PRD feature (stages 1–7 committed to `main`, unit/widget/integration tests green). What it does not yet do is survive a live demo: Arabic product content cannot display because the app shell has no localization plumbing, admin image upload cannot reach Supabase because `Supabase.initialize` was never called, order-status notifications produce nothing because the FCM receiver was dead code and no trusted sender existed on the free tier, and no test walks each feature end-to-end on a real device.

This design turns the built app into a demo-ready, PRD-compliant product:

1.  **Bilingual seed data** — 30 dummy products across 6 categories with Arabic and English fields seeded into the live Firestore project (`sahety-ba784`), displayed according to device locale with English fallback, correct RTL layout.
2.  **Real Supabase Storage** — admin product-image upload writes to a public `product-images` bucket and the returned URL renders in the catalog.
3.  **Order-status notifications without spending money** — a local Node.js Firebase Admin SDK watcher sends bilingual FCM pushes and writes in-app notification records for every order-status change (no Blaze plan, no payment card, no privileged credentials inside the app).
4.  **Per-feature verification** — one e2e spec per feature, run one at a time on the emulator, each followed by a screenshot review against a fixed checklist, closing with a notification scenario and a full-journey pass (login → browse → cart → checkout → order → admin status change → notification).

Target user: the project owner presenting a graduation-style demo. Core value: everything the PRD promises visibly works on the emulator, in both languages, with realistic content.

## The Problem

The PRD (`ecommerce_flutter_firebase_project.md`) is the source of truth, and its §9 acceptance criteria are not demonstrable today:

*   **Arabic cannot display.** `MaterialApp` had no `localizationsDelegates`/`supportedLocales` and pubspec had no `flutter_localizations`, so Arabic strings would render inside an LTR English shell. Product fields had no Arabic variants at all; search matched English names only.
*   **Supabase upload could not work even with credentials.** The uploader calls `Supabase.instance.client.storage...` but nothing initializes Supabase, so the first upload would throw into the "upload failed" branch at exactly the demo moment that should impress.
*   **Notifications produce nothing.** `FcmService.initialize()`, the background handler registration, and the `navigatorKey` documented in the service's own comments were never wired in; no notification document was ever created (client writes are rejected by `firestore.rules`, and the legacy FCM HTTP API the reference project copied was shut down in June 2024).
*   **Nothing verifies features one by one.** The e2e harness exists (`tests/*.e2e.ts`, Pixel 7 Pro emulator) but only `auth` had a spec; catalog, product details, favorites, cart, checkout, orders, admin, and notifications had none.

**Solution shape** (decided during brainstorming, partially landed already): app-shell localization plumbing plus one locale-resolver helper; `nameAr`/`descriptionAr` end-to-end (model, seed script, admin form, bilingual search); `Supabase.initialize` with real project credentials; FCM receiver fully wired with a scalar `fcmToken` contract; notification writes moved server-side to the watcher (Admin SDK bypasses the rules, keeping `firestore.rules` strict); seeded images uploaded to the real bucket so the storage path is exercised.

**Current state:** the implementation stages of this plan have landed (localization plumbing, bilingual model fields and search, admin form Arabic fields, FCM receiver wiring, scalar token contract, Supabase init with real credentials, `scripts/` with seed/watch/reset/admin-bootstrap, README updates). The remaining work concentrates on the verification phase: authoring the five missing e2e specs, fixing the one accessibility gap found while reading widgets (cart quantity/remove buttons lack tooltips, so e2e cannot target them by accessible name), running each spec with screenshot review, the notification scenario, and the final PRD §9 checklist. That work is parked while the design workflow ran; this document is the plan of record for it.

## Goals

*   **G1. Bilingual catalog end-to-end.** Every product carries `name`/`nameAr` and `description`/`descriptionAr`; the app shows Arabic on an `ar` locale device and English otherwise (English fallback when the Arabic field is empty); RTL layout holds against the 375×812 ScreenUtil designs in both locales; search matches Arabic and English names regardless of device locale; the admin form accepts and prefills the Arabic fields; category chips show localized labels.
*   **G2. Real image uploads.** Admin picks an image from the device, it uploads to the public Supabase `product-images` bucket, and the stored `imageUrl` renders in the catalog grid and details screen.
*   **G3. Free notifications that work.** After login the device saves its FCM token as `users/{uid}.fcmToken`; the local watcher detects every order-status change (pending → confirmed → shipped → delivered, plus cancelled) and both (a) delivers a bilingual push notification and (b) writes the `notifications/{id}` record; tapping the push opens that order's details screen; re-sends are prevented by the watcher's checkpoint.
*   **G4. Per-feature e2e with visual review.** Each feature has a deterministic spec run one-by-one (`npx e2e run tests/<spec>.e2e.ts`), with screenshots reviewed per run in English, Arabic (RTL), and empty/error states; test data is namespaced (`e2e_` prefix) and re-seeding resets the demo dataset.
*   **G5. Hygiene in passing.** Cart line items snapshot the locale-resolved display name at add-to-cart time (PRD §4); signed-out checkout deep links redirect to login; a rules test locks in the "customers cannot write notifications" decision; README and PRD §7 stay in sync with the shipped data model.

## Non-Goals

*   Blaze plan, deployed Cloud Functions, or any payment card — the project stays free.
*   Multi-device FCM token maps and `UNREGISTER` cleanup — one scalar `users/{uid}.fcmToken` is the whole contract for the demo.
*   Full UI-string localization — only product content is bilingual; framework plumbing exists so RTL renders correctly, but screen labels stay English.
*   PRD v1 exclusions: online payment, web admin panel, coupons/discounts, courier shipment tracking.
*   A `categories` Firestore collection — the UI derives filter chips from each product's `category` string and localizes the label client-side.
*   Multi-language push bodies chosen per device locale — pushes carry one combined bilingual text.

## Open Questions

*   **Service account for the right project.** The service-account JSON currently on disk belongs to `sahety-370c1`, but the app uses `sahety-ba784` (per `google-services.json` and `firebase_options.dart`). The owner must re-download the JSON from the `sahety-ba784` console. This blocks `npm run seed`, `npm run watch`, and `npm run admin`.
*   **Supabase bucket does not exist yet.** Both `products` and `product-images` were probed and returned "Bucket not found". The owner must create the public `product-images` bucket plus its storage policies (INSERT for uploads; UPDATE/DELETE so re-seeding can overwrite). This blocks seeded images and the admin-upload demo.
*   **Device for the notification test.** The Pixel 7 Pro AVD in use is a Google APIs image; FCM delivery on it must be confirmed once the service account lands. If it does not deliver, the fallback is a physical device, which PRD §9 explicitly allows.

--------------------------------------------------------------------------------

## Critical User Journeys (CUJs)

### CUJ 1: Demo browsing in either language

*   **Given**: The seed script has run against `sahety-ba784` (30 bilingual products across 6 categories with images from the `product-images` bucket), and the device locale is `ar`.
*   **When**: The user opens the app, browses Products, filters by a category chip, searches by an Arabic product name, and opens a product's details.
*   **Then**: Product names, descriptions, and category labels render in Arabic with correct RTL layout; the same journey on an `en` locale device renders English; a search for either language finds the same products; price and stock display identically in both.

### CUJ 2: Admin adds a product with a real image

*   **Given**: An admin (`admin@sahety.app`) is signed in and the `product-images` bucket exists with its storage policies.
*   **When**: The admin opens the product form, picks an image from the device gallery, waits for the upload, fills the English and Arabic fields, and saves.
*   **Then**: The image lives in Supabase Storage, the product document stores its public URL, and the new product renders with that image in the catalog grid and details screen.

### CUJ 3: Order status change reaches the customer for free

*   **Given**: A customer is signed in (so `users/{uid}.fcmToken` holds a fresh token) and `npm run watch` is running locally.
*   **When**: The customer places a Cash-on-Delivery order, then the admin advances the order status (confirmed → shipped → delivered, or cancelled).
*   **Then**: The customer receives a bilingual push ("Order Update · تحديث الطلب") and an in-app notification record appears in the notifications screen; tapping the push opens that order's details; restarting the watcher does not re-send past transitions (checkpoint dedupe on `(orderId, status)`).

### CUJ 4: Feature-by-feature e2e with visual review

*   **Given**: The debug APK is installed on the Pixel 7 Pro emulator and the seed data is present.
*   **When**: Each spec runs alone (`npx e2e run tests/<spec>.e2e.ts:<line>`), using its own fresh `e2e_<feature>_<stamp>@shop.test` user and namespaced data.
*   **Then**: Every spec passes deterministically; the per-run screenshots in `.e2e/` are reviewed against the checklist (English run, Arabic RTL run, empty and error states); re-seeding restores the demo dataset afterwards.

--------------------------------------------------------------------------------

## Technical Plan (Architecture)

The architecture keeps the existing feature-first Cubit structure and adds no new runtime layers. Every remaining change is either configuration, a script already in place, or test authoring — with two production-code changes (accessible tooltips; M8 route normalization) and no changes to `firestore.rules`.

### Landed components (plan of record)

*   **App shell localization** (`lib/e_commerce_app.dart`, `pubspec.yaml`): `flutter_localizations` with the three global delegates and `supportedLocales: [en, ar]`.
*   **Locale resolver** (`lib/core/helpers/product_localized_text.dart`): `resolveProductText(english, arabic, isArabic)` trims and falls back to English when the Arabic field is empty or the locale is English; `productTextFor(context, ...)` reads the locale; `categoryLabelFor`/`categoryDisplayFor` localize the fixed category keys; `ProductAdminDisplayX.adminDisplayName` renders `name · nameAr`.
*   **Bilingual product model** (`lib/core/models/product_model.dart` + codegen): nullable `nameAr`, `descriptionAr`, `categoryAr` with explicit-null serialization.
*   **Bilingual features**: catalog search matches `name` and `nameAr` regardless of locale (`product_repository_impl.dart`, `products_cubit.dart`); details/cards/category chips resolve through the helper; favorites and admin screens render resolved names; the add-to-cart button snapshots the resolved display name into the cart item at purchase time.
*   **Supabase** (`lib/core/helpers/constants.dart`, `lib/main.dart`, `lib/features/admin/data/upload/admin_image_uploader.dart`): real project URL + publishable key, `Supabase.initialize` guarded by a placeholder check, upload to the `product-images` bucket with `getPublicUrl`.
*   **FCM receiver** (`lib/main.dart`, `lib/features/notifications/data/services/fcm_service.dart`): background handler registered before `runApp`, `initialize()` after it, `navigatorKey` threaded through `MaterialApp`; foreground messages no-op, taps from `onMessageOpenedApp`/`getInitialMessage` navigate to order details with the `orderId`; `onRegistered` saves the scalar `users/{uid}.fcmToken` + `fcmTokenUpdatedAt`.
*   **Checkout guard** (`lib/core/routing/app_router.dart`): a signed-out checkout deep link builds `LoginScreen` instead of a `CheckoutCubit` with an empty uid.
*   **Ops scripts** (gitignored `scripts/`): `seed.mjs` (30 bilingual products, generated PNGs uploaded to Supabase, deterministic `seed_<slug>` document IDs), `watch-orders.mjs` (orders `onSnapshot`, cold-start records without notifying, status-change-only detection, FCM v1 bilingual push + data payload, `notifications` record write, `.watch-checkpoint.json` dedupe), `reset.mjs` (`--images`/`--dry-run`), `bootstrap-admin.mjs` (`npm run admin` — idempotent `admin@sahety.app` with `users/{uid}.role='admin'`).

### Data flows

```text
Bilingual content:

  seed.mjs ──▶ products/{seed_<slug>}   (name, nameAr, description, descriptionAr,
      │                                  category, categoryAr, price, stock, imageUrl)
      │
      └──▶ Supabase product-images bucket (seed/<slug>.png) ──▶ imageUrl in the doc

  ProductModel.fromJson ──▶ resolveProductText(en, ar, isArabicLocale(context))
                                   │
        ┌──────────┬───────────────┼────────────────┬──────────────┐
        ▼          ▼               ▼                ▼              ▼
    catalog     details      search (name +     category      cart-item name
    cards/chips  screen      nameAr, any locale) chips        snapshot at add-to-cart
```

```text
Notifications (free, trusted sender outside the app):

  admin updates orders/{id}.status
        │
        ▼
  watch-orders.mjs ── onSnapshot, checkpoint dedupe on (orderId, status)
        │
        ├──▶ FCM v1 push: notification "Order Update · تحديث الطلب"
        │                 + data {orderId, status}
        │                       │
        │                       ▼
        │         FcmService:  foreground no-op · background → system tray
        │                       · tap → navigatorKey → orderDetailsScreen(orderId)
        │
        └──▶ notifications/{autoId}: {userId, title, body, orderId, isRead: false, createdAt}
             (Admin SDK bypasses firestore.rules; customers still cannot write notifications)
```

```text
Verification loop:

  tests/<feature>.e2e.ts ──▶ e2e runner (workers 1, timeout 420s)
        ▲                              │
        │                              ▼
        │                      Pixel 7 Pro emulator (com.example.e_commerce_app)
        │                              │
  npm run seed (reset)                 ▼
        └─────────────── .e2e/ report + traces + screenshots
                                       │
                          screenshot review checklist (EN / AR RTL / empty / error)
```

### Contracts the remaining work depends on

*   **Token**: scalar `users/{uid}.fcmToken` + `fcmTokenUpdatedAt`; the legacy `fcmTokens` map is removed from the model and register path. The watcher skips a user silently when the token is absent.
*   **Push payload**: `notification` (bilingual title/body per status) + `data {orderId, status}` — data drives tap-to-details; the client never writes notification documents.
*   **Notification record**: `{userId, title, body, orderId, isRead, createdAt}` written only by the watcher.
*   **Seed documents**: deterministic IDs `products/seed_<slug>` so re-seeding upserts and `reset.mjs` deletes the exact range `seed_`..`seed_\uf8ff`.
*   **e2e locator discipline**: ValueKeys are not semantics identifiers — specs target accessible names (`getByText`/`getByRole`/`getByPlaceholder`); IconButtons must carry tooltips to be reachable. This is the driver of the first production change below.

### Remaining changes

1.  **Tooltips on cart line controls** (`lib/features/cart/ui/widgets/cart_item_card.dart`): add `tooltip: 'Increase quantity'` / `'Decrease quantity'` / `'Remove from cart'` to the three IconButtons so the cart spec can target them by accessible name. One of the two production-code changes; unit/widget tests re-run after both.
2.  **Route normalization (M8)** (`lib/core/routing/app_router.dart` + per-feature `*_bloc_listener.dart`): convert the nine bare-screen route cases to the getIt `BlocProvider` pattern the other six already use, and move inline `BlocListener`s into the feature `*_bloc_listener.dart` convention for checkout/orders/admin. The landed signed-out checkout redirect stays.
3.  **E2E spec suite** (`tests/`): verify the drafted `catalog.e2e.ts` and `product_details.e2e.ts` against the confirmed on-screen strings, then author `favorites.e2e.ts`, `cart.e2e.ts`, `checkout.e2e.ts`, `orders.e2e.ts`, and `admin.e2e.ts` following the `auth.e2e.ts` patterns (`fillSticky` retry helper, `dismissKeyboard`, restart-after-auth because live auth responses do not reach Dart mid-session, one fresh namespaced user per spec, English-only assertions).
4.  **Notification scenario**: run the watcher, place an order, advance its status as admin, assert push + notification record + tap-to-details (CUJ 3).
5.  **Rules test for the notification decision** (`./scripts/rules-test.mjs`): loads `firestore.rules` into the Firestore emulator and asserts a customer's `notifications/{id}` create is denied while an admin's create succeeds — B3's no-regression guarantee. The rules file itself stays unmodified.
6.  **Screenshot checklist + PRD §9 sweep** (`.e2e/` artifacts): English, Arabic RTL, empty, and error captures per feature; close with the full acceptance checklist.

--------------------------------------------------------------------------------

## Alternatives Considered

### Alternative A: Cloud Functions for order-status notifications

*   **Pros**: The canonical Firebase shape — a `functions` trigger on order-document writes needs no local process, survives restarts by design, and is the natural path to multi-device token handling later.
*   **Cons**: Requires the Blaze billing plan and a payment card on the Firebase account, even at zero usage.
*   **Reason for Rejection**: Rejected by author: the project must stay free — no payment card, per the demo constraint. The local Admin SDK watcher provides the same trusted-sender guarantee without billing.

### Alternative B: Copying the reference project's notification approach (asroo_store)

*   **Pros**: A working Flutter reference the owner pointed at; copying it is fast and familiar, and its server-key `.env` pattern needs no Firebase console changes.
*   **Cons**: It sends pushes through the legacy `fcm.googleapis.com/fcm/send` HTTP API with a static server key stored inside the app's `.env`.
*   **Reason for Rejection**: Rejected by author, on evidence: Google shut the legacy FCM HTTP API down in June 2024, so the copied code would be dead on arrival; and storing privileged FCM credentials in the Flutter app violates PRD §6 (no privileged sending credentials in the client). The watcher keeps sending rights on the trusted side only.

### Alternative C: Seeding product images from public URLs (Unsplash)

*   **Pros**: No Supabase dependency at seed time; large, attractive photos for free.
*   **Cons**: Placeholder URLs never exercise the same `imageUrl` write path the admin upload produces, so the demo would show content the app itself cannot create.
*   **Reason for Rejection**: Rejected by author: seeding through Supabase Storage validates the exact storage path used in production demos, keeps the catalog visually coherent, and makes the seed script double as a Supabase health check (free-tier projects pause when idle).

### Alternative D: A `categories` Firestore collection

*   **Pros**: Category metadata could carry its own bilingual fields, icons, and ordering, and seeding categories explicitly looks more "real".
*   **Cons**: Nothing in the codebase reads a categories collection — filter chips are derived from each product's `category` string, so the collection would be dead weight to seed and keep in sync.
*   **Reason for Rejection**: Rejected by author for demo scope (YAGNI): category labels are localized client-side through `categoryLabelFor`; revisit only if verification shows the UI reads a collection.

### Alternative E: Relaxing Firestore rules so customers create their own notification records

*   **Pros**: No watcher needed for the in-app list — the client could write its own `notifications/{id}` documents on receiving a push, keeping everything inside the app.
*   **Cons**: A customer-writable notifications collection is a forged-data hole (clients could fabricate records or spam other users' lists if the rules are loosened further), and it inverts the source of truth: the record should exist because the status changed, not because a device heard about it.
*   **Reason for Rejection**: Rejected by author: the Admin SDK watcher writes the record server-side and bypasses rules, so `firestore.rules` stays strict (customers still cannot create notifications) and the code/rules contradiction from the brainstorm is resolved without loosening anything.

### Alternative F: Multi-device FCM token map (`fcmTokens` per user)

*   **Pros**: Pushes reach every signed-in device, and stale tokens can be cleaned up on `UNREGISTER` errors.
*   **Cons**: Drags in token-map migration, cleanup logic, and a second token contract to keep consistent across the app and the watcher.
*   **Reason for Rejection**: Rejected by author for demo scope: one scalar `users/{uid}.fcmToken` is sufficient for a single-device demo; the map is future work if the product ever needs it.

--------------------------------------------------------------------------------

## Non-Functional Requirements

*   **Security & Privacy**: the service-account JSON is a privileged credential — it stays untracked (`scripts/serviceAccount*.json` is gitignored) and is never committed; no privileged FCM credentials live inside the Flutter app (PRD §6); the Supabase publishable key is public by design and safe in `constants.dart`; the demo admin password is documented as demo-only and must be changed before real users; `firestore.rules` stays strict — customers cannot write notifications, locked by the rules test.
*   **Performance & Latency**: demo scale (30 products, single device) is trivial for Firestore and Supabase; no pagination or caching work is in scope.
*   **Rollout & Rollback**: all new tooling is local/untracked and the production changes are small; rollback is `git checkout` of the touched files; `npm run reset` removes seeded data and `npm run seed` rebuilds it.

--------------------------------------------------------------------------------

### Additional Resources

*   `ecommerce_flutter_firebase_project.md` — the PRD, requirements source of truth (gitignored local file)
*   `concepts_brief.md` — predecessor brainstorm artifact (7 Goldfish lenses, deduplicated)
*   `./scripts/README.md` — ops setup: service-account placement, Supabase bucket SQL, demo-day checklist
*   `GLOSSARY.md` — domain vocabulary (Arabic)
*   `.agents/skills/e2e/SKILL.md` — e2e authoring conventions for this repo

### Future Improvements

*   **The idea**: Multi-device pushes — promote the scalar token to an `fcmTokens` map with `UNREGISTER` cleanup.
*   **The idea**: Full UI-string localization via ARB files, beyond bilingual product content.
*   **The idea**: Per-device push language — store device locale at login and let the watcher choose the body text.
*   **The idea**: A categories collection with bilingual metadata, if the catalog outgrows client-side derived chips.

--------------------------------------------------------------------------------

## Detailed Implementation Plan

One unified list, ordered by dependency: the production-code changes first (tooltips unlock the cart spec; route normalization closes M8), then spec authoring/verification and the rules test, then the user-supplied credentials that gate script runs, then the run/verify sequence. Files already landed are listed as verify-only so the executor does not rebuild them.

### Target Files to Create/Modify

#### 1. `./lib/features/cart/ui/widgets/cart_item_card.dart` (Modify)

*   **Type / Scope**: Flutter widget — one cart line item.
*   **Proposed Changes**: Add an accessibility tooltip to each of the three quantity/delete IconButtons: increase, decrease, and remove actions get distinct visible-on-long-press labels. No behavior change; existing keys and callbacks stay untouched. This is one of the two production-code changes in the plan (the other is route normalization), and it exists because e2e locators match accessible names, not widget `Key`s — without tooltips the cart spec cannot target the stepper or remove buttons.
*   **Why necessary**: Unlocks `./tests/cart.e2e.ts`; keeps the widget consistent with `favorite_heart_button.dart`, which already carries tooltips.

#### 2. `./lib/core/routing/app_router.dart` + per-feature `*_bloc_listener.dart` (Modify — route normalization, M8)

*   **Type / Scope**: Routing table + listener wiring (production code).
*   **Proposed Changes**: Convert the nine bare-screen route cases to the getIt `BlocProvider` pattern the other six already use, so every screen resolves its cubit through `getIt` consistently; move the inline `BlocListener` in `checkout_screen.dart` into the feature's `*_bloc_listener.dart` convention and add the equivalent listener widgets for orders/admin where navigation or dialogs react to state. The landed signed-out checkout redirect stays as-is.
*   **Why necessary**: Honors the brief's M8 commitment (restored by author decision at finalization); uniform routing removes a mid-demo inconsistency risk and keeps AGENTS.md's "navigation/dialogs go through bloc listeners" convention true everywhere.

#### 3. `./tests/catalog.e2e.ts` (Modify — verify the drafted spec)

*   **Type / Scope**: E2E spec (TypeScript, `@e2e-dev/mobile` runner).
*   **Proposed Changes**: Line-by-line check of the ~170-line draft against the confirmed on-screen strings from the widget sources: Products app bar, search hint `Search products by name...`, category chip labels including `All` and the localized Arabic labels, empty-search copy `No products match "X".`, empty-category copy, seeded product names, and the `N.NN EGP` price format. Fix any locator that drifts from source truth.

#### 4. `./tests/product_details.e2e.ts` (Modify — verify the drafted spec)

*   **Type / Scope**: E2E spec.
*   **Proposed Changes**: Same verification pass on the ~158-line draft: navigation from a product card, details app bar `Product Details`, price format, `In stock (N available)` / `Out of stock` states, `Description` header, favorite heart toggle from the app bar, and `Add to Cart` behavior including the out-of-stock snackbar.

#### 5. `./tests/favorites.e2e.ts` (Create)

*   **Type / Scope**: E2E spec — favorites feature (PRD §2).
*   **Proposed Changes**: Fresh `e2e_fav_<stamp>@shop.test` user; toggle favorites from a product card and from the details screen (heart tooltip flip `Add to favorites` → `Remove from favorites`); open Favorites via the home app bar and assert the resolved product name and the per-tile remove control; remove from the list and assert the empty state; re-run toggle to confirm persistence against Firestore. Restart-after-auth pattern for the register step.

#### 6. `./tests/cart.e2e.ts` (Create)

*   **Type / Scope**: E2E spec — cart feature (PRD §3).
*   **Proposed Changes**: Fresh user; add two different products from the catalog; assert `My Cart` app bar, per-item name (resolved display name snapshot), quantity text, and per-line subtotal; exercise the new tooltips (increase/decrease change quantity and subtotal, remove deletes the line); assert the `Total` bar matches the sum of line subtotals and the `cartEmpty` empty state after the last removal (`Your cart is empty`); leave one item in cart for the checkout spec's starting state or re-add as needed.

#### 7. `./tests/checkout.e2e.ts` (Create)

*   **Type / Scope**: E2E spec — checkout feature (PRD §4).
*   **Proposed Changes**: From a cart with items: assert `Checkout` app bar, items list, `Total`, the `Delivery details` section, and the Cash-on-Delivery tile copy; submit empty to assert both validators (`Please enter a delivery address`, `Please enter a phone number`); fill address + phone and place the order with `Place Order (Cash on Delivery)`; assert landing on the order-success screen with the order reference. Also covers the signed-out deep-link guard implicitly (the spec always registers/logs in first; the guard is unit-level).

#### 8. `./tests/orders.e2e.ts` (Create)

*   **Type / Scope**: E2E spec — orders feature (PRD §4/§5).
*   **Proposed Changes**: With an order created in-spec (reuse the checkout flow inline rather than depending on another spec's leftovers): open My Orders from home/profile navigation, assert the order tile shows status `pending`; open order details and assert the items, quantities, totals, delivery address/phone snapshot, and status chip; navigate back to the list and assert the entry persists (Firestore-backed stream).

#### 9. `./tests/admin.e2e.ts` (Create)

*   **Type / Scope**: E2E spec — admin role (PRD §5).
*   **Proposed Changes**: Register a customer, then promote it via `npm run admin` semantics (bootstrap script targets the demo admin; the spec instead uses the seeded `admin@sahety.app` account created by `scripts/bootstrap-admin.mjs`); log in as admin and assert role-based routing to the admin dashboard; walk the admin products screen (grid, `name · nameAr` display), open the product form (Arabic-field prefill and validation-only-when-non-empty behavior), and exercise the admin orders screen: pick the customer order created in-spec, change its status, and assert the status chip updates. Image upload inside the spec is optional-gated: only if the Supabase bucket prerequisite is resolved before this spec runs.

#### 10. `./scripts/rules-test.mjs` + `npm run test:rules` (Create)

*   **Type / Scope**: Firestore rules unit test (Node, `@firebase/rules-unit-testing` against the Firestore emulator) inside the gitignored ops-scripts directory.
*   **Proposed Changes**: Load `./firestore.rules` into the emulator; authenticate as (a) a plain customer and (b) an admin with `users/{uid}.role == 'admin'`; assert the customer's create/update on `notifications/{id}` is denied, the admin's create succeeds, and customers can still read their own notifications. Locks in the B3 decision (watcher-side writes only, Admin SDK bypasses rules; the shipped rules file itself is never modified).
*   **Why necessary**: The brief (B3) committed to a rules test so the notification-write contradiction cannot regress; this restores that commitment into the plan of record.

#### 11. `./scripts/seed.mjs`, `./scripts/watch-orders.mjs`, `./scripts/reset.mjs`, `./scripts/bootstrap-admin.mjs` (Verify-only — landed)

*   **Type / Scope**: Local Node.js Admin SDK ops scripts (gitignored directory).
*   **Proposed Changes**: No rewrites planned. Run-gated verification only: seed (30 bilingual products + Supabase image uploads + deterministic `seed_<slug>` IDs), watch (onSnapshot → bilingual push + `notifications` record + checkpoint dedupe), reset (delete the `seed_`..`seed_\uf8ff` range, `--images`/`--dry-run` flags), admin bootstrap (idempotent `admin@sahety.app`). Any defect found while running counts as a fix under this plan.

#### 12. `./scripts/serviceAccount.json` (Create — user-supplied, untracked)

*   **Type / Scope**: Privileged credential for the Admin SDK scripts.
*   **Proposed Changes**: The owner re-downloads the service-account JSON from the **`sahety-ba784`** Firebase console (the file currently on disk belongs to `sahety-370c1`) and saves it to the gitignored scripts path. It must never be committed; `.gitignore` already excludes `scripts/serviceAccount*.json`.
*   **Why necessary**: `npm run seed`, `npm run watch`, `npm run admin` all load this file; the wrong project would write demo data to the wrong Firestore and send pushes to the wrong project.

#### 13. Supabase bucket `product-images` (Configuration — user action, no repo file)

*   **Type / Scope**: Supabase Storage configuration in the existing free-tier project.
*   **Proposed Changes**: Create a **public** bucket named `product-images` (matching `SupabaseConfig.productsBucket`), plus storage policies: INSERT for uploads, UPDATE/DELETE so re-seeding can overwrite images (SQL documented in `./scripts/README.md` §2).
*   **Why necessary**: Both the seed script's image uploads and the admin in-app upload path fail with "Bucket not found" until this exists; this is the G2 round-trip.

#### 14. `./scripts/README.md`, `./README.md`, `./ecommerce_flutter_firebase_project.md` (Verify-only — landed)

*   **Type / Scope**: Documentation.
*   **Proposed Changes**: One final read-through after the run phase so commands, the token contract (scalar `fcmToken`), the bucket name, and PRD §7's products row match shipped reality; PRD §9 checklist is the closing gate. No structural changes expected — both were updated in the docs pass.

#### 15. `./docs/designs/demo-ready-prd-completion.md` → this document (Create at finalize step)

*   **Type / Scope**: The finalized design document.

### Verification Plan

*   **Static analysis**: `flutter analyze` — must stay clean after changes 1–2 (baseline is clean today).
*   **Unit/widget tests**: `flutter test` — 256 passing baseline; re-run after changes 1–2; focused re-runs acceptable during iteration.
*   **Build**: no rebuild needed for specs themselves; rebuild/reinstall the debug APK after changes 1–2 or any fix lands (`flutter build apk --debug` then install to the running Pixel 7 Pro emulator).
*   **E2E execution discipline**: one spec at a time — `npx e2e run tests/<spec>.e2e.ts:<line>` (workers 1, timeout 420s, assertion timeout 15s, bundleId `com.example.e_commerce_app`); report + traces + screenshots land in `.e2e/`. Specs are deterministic screen/expect steps only — no agent/model steps.
*   **Visual review checklist (N4)**: after each spec, review captured screenshots for: English run, Arabic RTL run (device locale `ar`), empty state, and error state; fix-and-rerun until each passes its own checklist.
*   **Rules test**: `npm run test:rules` (Firestore emulator) — customer notification-create denied, admin create allowed, customer reads own notifications; must pass before the notification scenario runs.
*   **Notification scenario (G3/CUJ 3)**: with the watcher running, place an order in-spec or manually, change status as admin, then assert: bilingual push received, `notifications` record appears in-app, tap opens order details, and a watcher restart does not re-send (checkpoint).
*   **Data hygiene (M5)**: every spec uses its own `e2e_<feature>_<stamp>@shop.test` user and namespaced data; `npm run seed` is the reset button before demo data is touched; never run destructive steps against the demo dataset.
*   **Known platform limitation carried into the plan**: live Firebase auth responses do not reach Dart mid-session on this emulator setup — specs restart the app via `app.open()` after register/login and assert from the persisted session, matching the `./tests/auth.e2e.ts` pattern.

--------------------------------------------------------------------------------

<!-- Provenance: Indicates initial structural drafting via EGM. -->

*Drafted with EGM*
