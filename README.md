# E-Commerce App (Flutter + Firebase)

Android-first e-commerce application built with **Flutter** on a **Firebase** backend — Firebase Authentication (email/password), Cloud Firestore, and Firebase Cloud Messaging (FCM) — with product images stored in **Supabase Storage**. Two roles, **Customer** and **Admin**, are resolved from `users/{uid}.role` in Firestore after login and drive role-based routing.

Scope is locked to the PRD (`ecommerce_flutter_firebase_project.md`): catalog, favorites, cart, cash-on-delivery checkout, order tracking, admin management, and FCM notifications. Online payment, a separate web admin panel, discount coupons, and live courier tracking are explicitly out of scope for v1.

## Features

### Customer
- **Authentication** — register (name, email, password), login, logout, forgot password, and a profile with name, phone, and delivery address (`lib/features/auth`).
- **Catalog** — product cards with image, name, and price; search matches the English and the Arabic product name in either locale; category filtering that composes with the search query (`lib/features/products`, `lib/features/catalog`).
- **Product details** — image, name, description, price, category, and stock.
- **Favorites** — add/remove products, persisted per user at `users/{uid}/favorites` (`lib/features/favorites`).
- **Cart** — quantity increase/decrease, remove item, per-item subtotals and cart total; stored in Firestore so the cart survives app restarts (`lib/features/cart`).
- **Checkout** — order review with quantities and total, delivery address + phone, **Cash on Delivery only** (no payment gateway). Placing an order validates stock, creates the order document, clears the cart, and shows an order-success screen (`lib/features/checkout`). A signed-out deep link to checkout bounces to the login screen instead of building a broken order (`lib/core/routing/app_router.dart`).
- **My Orders** — order history and order details reflecting the live order status (`lib/features/orders`).
- **Notifications** — FCM permission request, device token persisted on the user document and re-saved whenever it changes; foreground / background / terminated handling; in-app notification center backed by the `notifications` collection (`lib/features/notifications`).

### Admin
- **Dashboard** — entry point to product and order management (`lib/features/admin/ui/screens/admin_dashboard_screen.dart`).
- **Product management** — create, edit, and delete products; bilingual form with optional Arabic name/description inputs (the Arabic category label is derived from the category key — see [Bilingual catalog](#bilingual-catalog-english--arabic)); image upload via `image_picker` → Supabase Storage → `products/{id}.imageUrl` (falls back to a manual image-URL field only while `SupabaseConfig` holds placeholder values).
- **Order management** — incoming orders list, order review (items, quantities, delivery info), and status updates along the lifecycle `pending → confirmed → preparing → shipped → delivered`; cancellation is allowed only while the order is still `pending` (`OrderStatusFlow` in `lib/features/admin/logic/order_status_flow.dart`).

### Shared
- **Role-based routing** — the boot gate (`lib/e_commerce_app.dart`) watches auth state, reads the role from the server-side user document, and shows the Customer UI or the Admin dashboard. Regular users cannot grant themselves admin: registration always creates `role: 'customer'` (`lib/features/auth/data/repos/register_repo.dart:31`), and the security rules reject any role change on update.

## Tech stack

| Layer | Choice |
| --- | --- |
| Framework | Flutter (Dart SDK `^3.13.4`), Android-first |
| Auth | Firebase Authentication — email/password |
| Database | Cloud Firestore |
| Push notifications | Firebase Cloud Messaging (FCM) |
| Product images | Supabase Storage + `image_picker` |
| State management | `flutter_bloc` (Cubits) with freezed states |
| DI | `get_it` |
| Navigation | `Navigator` with a `generateRoute` switch (`lib/core/routing/app_router.dart`) |
| UI sizing | `flutter_screenutil`, design size **375×812** (`.w`/`.h`/`.sp` + `Spacing` helpers) |
| Image caching | `cached_network_image` |
| Localization | `flutter_localizations` — supported locales `en` + `ar`, follows the device locale, RTL mirroring |
| Codegen | `build_runner` (freezed, json_serializable) |
| Testing | `flutter_test`, `mocktail`, `bloc_test`, `fake_cloud_firestore`, `firebase_auth_mocks`, `integration_test` |

## Project structure

Feature-first layout (`lib/features/<feature>/{data,logic,ui}`):

```
lib/
├── core/
│   ├── constants/        # FirestorePaths — single source of truth for collection paths
│   ├── di/               # get_it setup: repos as lazy singletons, cubits as factories
│   ├── helpers/          # spacing, regex, extensions, SupabaseConfig
│   ├── models/           # shared models: product, order, cart item, notification, order status
│   ├── networking/       # ApiResult / error abstractions (no HTTP layer — repos use the Firebase SDK directly)
│   ├── repositories/     # repo interfaces for cart, favorites, product, order, notifications
│   ├── routing/          # routes + generateRoute; each screen is wrapped in a BlocProvider
│   ├── theming/          # colors, styles, font weights
│   └── widgets/          # shared app button, text form field
├── features/
│   ├── admin/            # dashboard, product CRUD, order lifecycle (data / logic / ui)
│   ├── auth/             # login, register, forgot password, profile
│   ├── cart/             # cart screen + badge, Firestore-backed cart
│   ├── catalog/          # home screen (Customer shell)
│   ├── checkout/         # checkout form, cash-on-delivery, order success
│   ├── favorites/        # favorites list
│   ├── notifications/    # FCM service + in-app notification center
│   ├── orders/           # my orders + order details
│   └── products/         # products listing (search/filter) + product details
└── ...
```

Conventions: navigation and dialog wiring goes through `*_bloc_listener.dart` widgets, never inline in form callbacks; UI is sized with `flutter_screenutil`.

## Firestore data model

Path builders live in `lib/core/constants/firestore_paths.dart` (PRD §7):

| Collection / Path | Used for |
| --- | --- |
| `users/{uid}` | Profile: name, email, phone, address, `role` (`customer`/`admin`), scalar `fcmToken` + `fcmTokenUpdatedAt` |
| `users/{uid}/cart/{productId}` | Cart lines (product ID is the document ID) |
| `users/{uid}/favorites/{productId}` | Favorite references (product ID is the document ID) |
| `products/{productId}` | Catalog: name, description, price, imageUrl, category, stock, isAvailable — plus the optional Arabic variants `nameAr`, `descriptionAr`, `categoryAr` (`category` stays the canonical English key) |
| `orders/{orderId}` | userId, items (name/price snapshotted at purchase), totalPrice, shippingAddress, phone, status, createdAt |
| `notifications/{id}` | In-app notification center: userId, title, body, orderId, isRead, createdAt |

## Security (`firestore.rules`)

`firestore.rules` is the source of truth for authorization — admin actions are protected by rules, not merely by hiding UI buttons:

- **User isolation** — each user can read/write only their own `users/{uid}` document, cart, and favorites; deletes of user docs are denied.
- **No self-promotion** — a user update must keep `role` unchanged, so nobody can make themselves admin from the client.
- **Products** — public read, admin-only create/update/delete.
- **Orders** — a customer can read only their own orders; admins read all. Order creation is accepted only with the caller's own `userId`, `status == 'pending'`, 1–10 items, every line's price re-checked against the live `products/{productId}` document, and `totalPrice` recomputed by the rules — the client-supplied total is never trusted. Order updates (status changes) are admin-only; deletes are denied.
- **Notifications** — read limited to the owning user; create/update/delete admin-only.

## Bilingual catalog (English / Arabic)

Product documents carry optional Arabic variants alongside the English fields: `nameAr`, `descriptionAr`, and `categoryAr`. `category` itself remains a canonical lowercase English key; the Arabic label for each built-in category comes from `kCategoryArLabels` (`lib/core/helpers/product_localized_text.dart`).

- The app follows the device locale: `supportedLocales: [Locale('en'), Locale('ar')]` with the `flutter_localizations` delegates (Material/Cupertino translations and RTL mirroring) in `lib/e_commerce_app.dart`. There is no in-app language switcher.
- On an Arabic locale a product shows `nameAr`/`descriptionAr` when they are non-empty, otherwise the English text (`resolveProductText`) — a missing Arabic field falls back to English, never to a blank.
- Category display on an Arabic locale prefers the product's own `categoryAr`, then the `kCategoryArLabels` map, then the English key.
- Search matches both `name` and `nameAr` regardless of the active locale (`lib/features/products/logic/cubit/products_cubit.dart`).
- The admin product form has optional Arabic name and description inputs; `categoryAr` is derived at save time from the chosen category key (no free-text Arabic category input). The admin list shows both variants as `name · nameAr`.

## Notifications (demo architecture)

The app is only the receiver — sending happens in a trusted server environment (PRD §6). For this project that sender is a local Node.js Admin SDK watcher, so no Cloud Functions and no Blaze plan are needed.

Receiver (`lib/features/notifications/data/services/fcm_service.dart`, wired in `lib/main.dart`):

- A root `navigatorKey` is created in `main.dart` and attached to `FcmService`, so a tapped notification can navigate from any app state.
- The top-level background handler is registered before `runApp`; `FcmService.initialize()` runs after it (permission request, token registration, tap streams), so a terminated-state tap resolves against a live navigator.
- Foreground messages are an intentional no-op: the in-app notification center updates through its own Firestore stream on the `notifications` collection.
- A tapped notification carrying an `orderId` in its data opens the order details screen (`pushNamed(Routes.orderDetailsScreen, arguments: orderId)`) from both background and terminated (cold-start) states.

Token contract: the registration token is stored as a **scalar** `fcmToken` field plus `fcmTokenUpdatedAt` on `users/{uid}` (merge write), re-saved whenever FCM re-registers the app instance (`firebase_messaging` 17+ `register()` / `onRegistered`). The watcher reads this scalar first (with a legacy `fcmTokens` map fallback); multi-device token registration is out of scope in the app.

Sender: `npm run watch` (`scripts/watch-orders.mjs`) — on every order `status` change it sends the FCM v1 push to the customer's `fcmToken` and writes the in-app record to `notifications/{autoId}` with `userId`, `title`, `body`, `orderId`, `isRead: false`, and `createdAt`. The security rules only allow admins to create `notifications` documents, so these writes must come from the Admin SDK — the app never creates them client-side. Setup lives in [Local ops scripts](#local-ops-scripts).

## Supabase Storage (product images)

Product images are stored in **Supabase Storage** (Firebase Storage requires the Blaze plan). Admin uploads go `image_picker` → Supabase bucket → public URL → `products/{id}.imageUrl`, and the catalog loads them through `cached_network_image`.

- Config lives in `SupabaseConfig` (`lib/core/helpers/constants.dart`): project URL, publishable key, and bucket name `product-images`. `lib/main.dart` runs `Supabase.initialize` only when the values are real (not `YOUR_` placeholders), so the app also boots without Supabase — the admin product form then falls back to a manual image-URL field (`lib/features/admin/data/upload/admin_image_uploader.dart`).
- The publishable key is safe to expose in a client; writes are gated by the bucket policies below.

One-time dashboard setup:

1. Supabase Dashboard → Storage → **New bucket**: name `product-images`, **Public bucket: ON** (the app loads images by public URL).
2. Supabase Dashboard → SQL Editor → allow uploads:

   ```sql
   create policy "public upload to product-images"
   on storage.objects for insert to anon, authenticated
   with check (bucket_id = 'product-images');
   ```

   The optional UPDATE/DELETE policies needed for re-seeding over existing objects (`npm run reset -- --images`) are printed in `scripts/README.md` §2.

Free-tier note: Supabase projects pause after about a week of inactivity — open the dashboard before a demo to wake the project (see the [demo-day checklist](#demo-day-checklist)).

## Getting started

### Prerequisites
- Flutter SDK (stable) matching `pubspec.yaml` (`sdk: ^3.13.4`) with the Android toolchain and an emulator/device.
- Node.js (for the e2e tooling, see [Testing](#testing), and the local ops scripts, see [Local ops scripts](#local-ops-scripts)).

### Firebase setup
The repo ships committed config for Firebase project **`sahety-ba784`** (`lib/firebase_options.dart` and `android/app/google-services.json`), so the app builds against that project out of the box.

To use your own project:
1. Create a Firebase project and enable **Email/Password** authentication.
2. Create a **Cloud Firestore** database.
3. Add an Android app with package name `com.example.e_commerce_app`.
4. Download `google-services.json` into `android/app/`.
5. Run `flutterfire configure` (or keep the committed `lib/firebase_options.dart`).
6. Deploy the security rules: `firebase deploy --only firestore:rules`.

To create an admin, register a normal account first, then set `role: 'admin'` on its `users/{uid}` document from the Firebase console — the app has no admin-creation flow, and the rules block self-promotion.

## Run / Build / Codegen

```bash
flutter pub get                 # install dependencies
flutter run                     # run on a connected device/emulator
flutter build apk               # release APK
dart run build_runner build --delete-conflicting-outputs   # freezed / json_serializable codegen
```

Codegen files (`*.g.dart`, `*.freezed.dart`) are committed — never hand-edit them; rerun `build_runner` after changing annotated models.

## Local ops scripts

`scripts/` holds a small Node.js toolkit for seeding and demoing the app. See **`scripts/README.md`** for the full setup, storage policies, and troubleshooting. The three commands, run from the `scripts/` directory after `npm install`:

```bash
npm run seed    # 30 bilingual demo products + generated images uploaded to Supabase (idempotent)
npm run watch   # order status changes -> FCM push + notifications/{autoId} record
npm run reset   # delete the seed_ products (optionally the seeded images too)
```

The scripts authenticate with a Firebase **service account JSON**: save it as `scripts/serviceAccount.json`, or point `SERVICE_ACCOUNT_PATH=/path/to/the.json` at it. The Firestore project is read from the file's `project_id`, so it must be the same project the Flutter app talks to. The seed script does not bootstrap any admin account — create one as described under [Getting started](#getting-started).

## Testing

Three test roots, each with its own runner:

```bash
flutter test                                # unit + widget tests (test/)
flutter test test/features/favorites        # a focused feature slice
flutter test integration_test -d <device>   # integration tests (integration_test/) — boots the real app, needs a device/emulator
```

**E2E (Android, local tooling)** — build and install the APK first, then:

```bash
npx e2e run
```

Config lives in `e2e.config.ts` (Pixel 7 Pro emulator, bundle id `com.example.e_commerce_app`), specs in `tests/*.e2e.ts`, and runner output (report + per-spec traces) lands in `.e2e/`. Note that the e2e tooling (`package.json`, `e2e.config.ts`, `tests/`) is a gitignored local-only workspace file, not part of the repository.

## Demo-day checklist

1. **Start `npm run watch` first** and keep the terminal open — a status change made before the watcher starts is never notified (there is no history replay).
2. Wake the Supabase project if it has been idle for about a week (free tier pauses it). `npm run seed` doubles as a health check: it fails fast with exact fix instructions when the bucket or insert policy is missing.
3. Confirm the seeded catalog renders in the app with images loading from Supabase URLs.
4. Have the admin account ready: register a normal account, then set `role: 'admin'` on its `users/{uid}` document in the Firebase console (the seed script does not create admins).
5. Run on an emulator or device image **with Google APIs** (Play services) so FCM can register a token; log in once in the app so the token lands on `users/{uid}` before status changes are triggered.

## Screenshots

> Placeholders — screenshots are not captured yet. Drop files under `docs/screenshots/` and replace the pending cells below.

| Screen | Screenshot |
| --- | --- |
| Login / Register | `docs/screenshots/login.png` _(pending)_ |
| Home (catalog) | `docs/screenshots/home.png` _(pending)_ |
| Product details | `docs/screenshots/product_details.png` _(pending)_ |
| Products (search & filter) | `docs/screenshots/products.png` _(pending)_ |
| Favorites | `docs/screenshots/favorites.png` _(pending)_ |
| Cart | `docs/screenshots/cart.png` _(pending)_ |
| Checkout (cash on delivery) | `docs/screenshots/checkout.png` _(pending)_ |
| Order success | `docs/screenshots/order_success.png` _(pending)_ |
| My Orders / Order details | `docs/screenshots/orders.png` _(pending)_ |
| Notifications | `docs/screenshots/notifications.png` _(pending)_ |
| Admin dashboard | `docs/screenshots/admin_dashboard.png` _(pending)_ |
| Admin product form | `docs/screenshots/admin_product_form.png` _(pending)_ |
| Admin orders | `docs/screenshots/admin_orders.png` _(pending)_ |

## Notes

- Order-status notifications are *delivered* by the app (token registration, foreground/background/terminated handling, tap → order details), but *sending* them on status changes must come from a trusted Admin SDK environment per PRD §6 — for this project that is the local watcher (`scripts/watch-orders.mjs`), never the Flutter client.
- Order totals and product prices are validated by Firestore Security Rules, never trusted from the client.
- The cart is stored in Firestore per user, so it persists across sessions.
- `dependency_overrides` in `pubspec.yaml` (`test: 1.31.1`, `analyzer >=14 <15`) resolve a bloc_test ↔ freezed analyzer clash — do not remove them.
