# AGENTS.md

## What this is

Flutter e-commerce app (Android-first): Firebase Auth + Cloud Firestore + FCM, Supabase Storage for product images. Two roles — Customer and Admin — with role-based routing after login (`users/{uid}.role` in Firestore).

Scope is locked to the PRD `ecommerce_flutter_firebase_project.md` (see also `goal.md`). Anything not in the PRD is a future phase — don't implement it. Note: the PRD, `goal.md`, `CLAUDE.md`, and e2e tooling (`package.json`, `e2e.config.ts`, `tests/`, `.agents/`) are **gitignored local-only files** — they exist in this workspace but not in the repo.

## Commands

```bash
flutter pub get                                              # deps
flutter analyze                                              # lint / static analysis (no separate typecheck)
flutter test                                                 # all unit + widget tests
flutter test test/features/favorites                         # focused feature tests
dart run build_runner build --delete-conflicting-outputs     # freezed / json_serializable codegen
```

E2E (Android only, final verification phase): build + install the APK first, then `npx e2e run`. Config in `e2e.config.ts` (device: Pixel 7 Pro emulator, bundleId `com.example.e_commerce_app`), specs in `tests/*.e2e.ts`.

## Layout & architecture

Feature-first structure (mirrors the `doc_doc` reference project):

- `lib/core/` — constants (incl. `firestore_paths.dart`), di, helpers, shared models (product/order/cart/notification), networking (`ApiResult`/error handler), repositories, routing, theming, widgets.
- `lib/features/<feature>/{data,logic,ui}` — `data/` (repos + models), `logic/cubit/` (Cubit + freezed state), `ui/` (screens + widgets). Features: admin, auth, cart, catalog, checkout, favorites, notifications, orders, products.
- State management: **Cubits with freezed states**; navigation/dialogs go through `*_bloc_listener.dart` widgets, never inline in form callbacks.
- DI: `lib/core/di/dependency_injection.dart` (get_it) — repos as `registerLazySingleton`, cubits as `registerFactory`.
- Routing: `lib/core/routing/app_router.dart` — `generateRoute` switch; each screen wrapped in `BlocProvider(create: (_) => getIt<...>())`.
- Repos use Firebase SDK singletons directly (`FirebaseAuth.instance`, `FirebaseFirestore.instance`) — there is **no dio/HTTP layer**; `core/networking` holds only the `ApiResult`/error abstractions.
- UI sizing: `flutter_screenutil` with design size **375×812** — use `.w`/`.h`/`.sp` and `Spacing` helpers from `core/helpers/spacing.dart`.

## Firestore & security

- Collection paths: `lib/core/constants/firestore_paths.dart`.
- `firestore.rules` is the source of truth: role in `users/{uid}.role` (no self-promotion), orders created with `status == 'pending'` and updated by admin only, order totals and prices validated in rules. Any data-model change must keep rules in sync.
- Product images: Supabase public bucket `product-images` (admin upload via `image_picker`).

## Gotchas

- `dependency_overrides` in `pubspec.yaml` (`test: 1.31.1`, `analyzer >=14 <15`) resolve a bloc_test ↔ freezed analyzer clash — **do not remove or "fix" them**.
- Two test roots by design: `test/` = Flutter tests, `tests/` = e2e TypeScript specs. Don't mix them.
- Codegen files (`*.g.dart`, `*.freezed.dart`) are committed — never hand-edit; rerun build_runner after changing annotated models.
- `lib/firebase_options.dart` and `android/app/google-services.json` are committed for Firebase project `sahety-ba784`.
- Issues live in GitHub `Mahmoud-Younes/e-commerce` via `gh` CLI; writes need `GH_TOKEN` set (see `docs/agents/issue-tracker.md`).

## Read before touching

- `ecommerce_flutter_firebase_project.md` — the PRD (requirements source of truth)
- `GLOSSARY.md` — domain vocabulary (in Arabic; use its terms in code, tests, and issues)
- `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md` — GitHub and docs workflow
