# Goldfish Review Report

**Target:** `docs/designs/demo-ready-prd-completion.md` (DetailedRange, lines 238–339)
**Stage:** 9 — Implementation Readiness Test
**Reviewers:** `egm-implementation-readiness` (vs `implementation-readiness-standard`), `egm-codebase-details` (vs `implementation-readiness-standard`), `egm-style` (no standard) — each dispatched in its own fresh context.

## Reviewer Status

| Reviewer | Status |
| --- | --- |
| `egm-implementation-readiness` | completed |
| `egm-codebase-details` | completed |
| `egm-style` | completed |

**Deduplication note:** overlapping findings merged; sources listed per finding. **Severity-conflict resolution:** `egm-implementation-readiness` flagged the "256 passing baseline" as unverifiable; both `egm-codebase-details` and `egm-style` independently verified it is exact (186 `test(`/`testWidgets(` + 70 `blocTest(` declarations = 256, and a live `flutter test` run) — recorded under verified-accurate, not as a finding.

## Prioritized Findings (Blockers -> Major -> Nits)

### B1 (readiness-1) - Severity: 🔴 Blocker — Three admin routes are entirely unwired; the admin e2e journey cannot execute
* **Affected Scope:** Item 2 (lines 250–254) and Item 9 (`./tests/admin.e2e.ts`, lines 286–289)
* **Discrepancy Description:** The plan's routing work is described as "convert the nine bare-screen route cases," but the actual routing defect that blocks the plan is different and unaddressed: three admin routes are entirely unwired. `lib/features/admin/ui/admin_routes.dart` defines `AdminRoutes.adminProducts` (`/adminProducts`), `adminOrders` (`/adminOrders`), and `adminOrderDetails` (`/adminOrderDetails`) as a pending "merge agent" TODO, and `admin_dashboard_screen.dart:33,40` plus `admin_orders_screen.dart:110` call `context.pushNamed` on them — but `app_router.dart` has no case for any of the three, so `generateRoute` falls through to `default: return null` and navigation throws at runtime. The admin e2e journey in Item 9 (dashboard → products grid → product form → orders screen → status change) cannot execute even one step past the dashboard, and no target file or step in the plan wires these routes.
* **Rationale & Recommendation:** Add an explicit task to register the three admin route constants in `lib/core/routing/routes.dart` and wire the three cases in `app_router.dart` using the exact snippets already prescribed in `admin_routes.dart` (`getIt<AdminProductsCubit>()`, `getIt<AdminOrdersCubit>()`, and the `adminOrderDetails` case casting `settings.arguments as String`). Item 2 should be rewritten around the real gap (missing cases + the nine existing bare cases) rather than a blanket "convert nine cases" instruction.

### B2 (codebase-1) - Severity: 🔴 Blocker — `scripts/` is falsely described as gitignored; the rules-test lock would silently never be committed
* **Affected Scope:** Items 10–11 (lines ~293, ~299: "inside the gitignored ops-scripts directory", "Local Node.js Admin SDK ops scripts (gitignored directory)")
* **Discrepancy Description:** The plan repeatedly calls `scripts/` a gitignored directory. `.gitignore` does not ignore it: it excludes only `scripts/node_modules/`, `scripts/serviceAccount*.json`, `scripts/.env*`, `scripts/.watch-checkpoint.json`, and explicitly un-ignores `scripts/package.json` (`.gitignore:80`, `!scripts/package.json`) with the comment "Code (package.json, *.mjs) is tracked; secrets, deps and state are not". `git status` shows `scripts/` as untracked-but-addable, not ignored. (FeatureRange counterpart: Stage 7 F7, lines 101/217.)
* **Rationale & Recommendation:** Every later reader inherits the false statement "the scripts dir never enters the repo" and will therefore never commit the new `scripts/rules-test.mjs` — silently voiding the B3 no-regression lock that item 10 exists to provide, and contradicting the repo's stated tracking intent. Correct the scope wording everywhere: the directory's code is tracked; only the service-account JSON, `.env*`, and checkpoint state are ignored — and add committing `scripts/` code to the remaining work (PRD §9 submission).

### M1 (readiness-2 + codebase-7 + codebase-11) - Severity: 🟡 Major — Item 2's blanket route-normalization leaves multiple design decisions open and mislabels its targets
* **Affected Scope:** Item 2 (lines 250–254)
* **Discrepancy Description:** (a) Three of the nine bare cases — `homeScreen`, `orderSuccessScreen`, `adminDashboardScreen` — have no cubit at all (verified); "converting" them is not applicable. (b) `favorites_screen.dart:37`, `cart_screen.dart:30`, and `notifications_screen.dart:40-46` intentionally self-wrap `BlocProvider` from `get_it` — `cart_screen.dart`'s doc comment documents this for testability — so moving the provider to the router reverses a documented design without the plan saying so. (c) Argument plumbing is unspecified: `product_details_screen.dart:102` and `admin_product_form_screen.dart:67` read `ModalRoute` arguments (productId / `AdminProductFormArgs`); a router-side factory needs a `registerFactoryParam` decision or the ModalRoute read must stay — the plan is silent. (d) "add the equivalent listener widgets for orders/admin where navigation or dialogs react to state" — no state-reactive navigation exists in orders/admin today (checkout's inline listener is the only one), so which states trigger which navigation/dialog is an open choice, and the new listener file names are never enumerated. (e) The Target Files entry uses a wildcard (`per-feature *_bloc_listener.dart`) instead of exact paths and mislabels them Modify — only auth has `*_bloc_listener.dart` files today; for checkout/orders/admin they are Creates. The implementation-readiness standard requires exact paths for hand-written files so a write allowlist can be enforced. (f) The normalization sweep omits `cart_screen.dart:39-52`'s inline `BlocConsumer` error-SnackBar listener while justifying the work as keeping the convention "true everywhere".
* **Rationale & Recommendation:** Rewrite Item 2 as a per-case table: for each of the 9 existing bare cases and the 3 missing admin cases, state the exact target shape (getIt factory to use, `registerFactoryParam` or keep ModalRoute read, whether a screen's internal BlocProvider is removed or kept, cubit-less screens left bare); enumerate the exact new `*_bloc_listener.dart` paths following the auth convention (e.g., `lib/features/checkout/ui/widgets/checkout_bloc_listener.dart`) marked Create, with the state→navigation/dialog mapping and which inline listeners move (verified inline listeners exist in `checkout_screen.dart:41`, `admin_product_form_screen.dart`, `admin_products_screen.dart`, `admin_order_details_screen.dart`; orders screens have none; cart's inline listener is in scope or the claim is scoped down).

### M2 (readiness-3 + codebase-2 + style-1) - Severity: 🟡 Major — Items 5–6 say "(Create)" but the specs already exist as drafts, and the plan's described coverage diverges from the drafts
* **Affected Scope:** Items 5 and 6 (lines 266–274)
* **Discrepancy Description:** `tests/favorites.e2e.ts` (169 lines) and `tests/cart.e2e.ts` (201 lines) already exist on disk as complete drafted specs with the fresh-user isolation, `fillSticky`, and restart-after-auth conventions the plan prescribes — items 3–4 treat the equally existing catalog/details drafts as "Modify — verify the drafted spec", making the suite's status ambiguous. The descriptions also diverge from the drafts: item 5 promises a fresh `e2e_fav_<stamp>@shop.test` user (draft uses `e2e_favorites_<stamp>@shop.test`, `tests/favorites.e2e.ts:66`), a product-card toggle plus a persistence re-toggle (the draft toggles only from the details AppBar heart and ends by removing); item 6 promises adding "two different products" (draft adds one, `Wireless Headphones`) and a cross-spec cart handoff (the draft ends with an empty cart and documents "zero cross-spec coupling").
* **Rationale & Recommendation:** Relabel Items 5 and 6 as "Modify — verify/extend the drafted spec" (matching Items 3–4), align the described coverage with the actual drafts, and pin the exact email prefixes (`e2e_favorites_`, `e2e_cart_`).

### M3 (codebase-3) - Severity: 🟡 Major — Item 1's premise ("tooltips unlock the cart spec") is contradicted by the drafted cart spec's mechanics
* **Affected Scope:** Item 1 (line 247) and item 6 (line 274)
* **Discrepancy Description:** The drafted `tests/cart.e2e.ts` explicitly does not use tooltips: its LOCATOR GAP comment (lines 27–38) says the stepper buttons "have no tooltips, so they have no accessible name" and taps them via coordinates computed from the quantity text's bounding box (`tapNextToQuantity`, lines 76–80), and it removes the line via the decrease-to-zero path, never tapping the delete button. The plan's premise that tooltips are what "unlock" the cart spec is contradicted by the artifact on disk; tooltips only enable name-targeting the dedicated remove button, which the draft deliberately avoids — and no step says to rewrite the draft's coordinate-tap workaround into accessible-name locators after the tooltips land.
* **Rationale & Recommendation:** Restate item 1's rationale (tooltips let the spec replace fragile coordinate taps and target the remove button by accessible name), and add an explicit step to item 6: after Item 1 lands, replace the draft's `tapNextToQuantity` workaround and decrease-to-zero removal with `getByRole`/accessible-name locators (`Increase quantity` / `Decrease quantity` / `Remove from cart`).

### M4 (readiness-4 + codebase-5 + style-4) - Severity: 🟡 Major — Item 8's navigation step targets a control that does not exist
* **Affected Scope:** Item 8 (line 284: "open My Orders from home/profile navigation")
* **Discrepancy Description:** No My Orders entry exists on the Home screen or the Profile screen. `home_screen.dart` exposes only Favorites/Cart/Profile app-bar actions and "Browse Products"; grep of `lib/` shows the sole in-app path to `Routes.myOrdersScreen` is the order-success screen's "Track it in My Orders" `TextButton` (`order_success_screen.dart:70-80`). The spec author will search for a navigation affordance that does not exist.
* **Rationale & Recommendation:** Fix the step to reach My Orders via the order-success screen after placing the order (the checkout flow of item 7 naturally lands there), or add a Home/Profile → My Orders entry as an explicit production change in the target list.

### M5 (codebase-4 + style-9) - Severity: 🟡 Major — Item 7's order-reference assertion cannot pass: `orderId` is never wired to `OrderSuccessScreen`
* **Affected Scope:** Item 7 (line 279: "assert landing on the order-success screen with the order reference")
* **Discrepancy Description:** The order reference is never rendered. `checkout_screen.dart:48-51` navigates with `arguments: orderId`, and `OrderSuccessScreen`'s doc comment says "[orderId] arrives as the route argument" (`order_success_screen.dart:13-14`), but `app_router.dart:110-111` builds `const OrderSuccessScreen()` and never reads `settings.arguments` — `orderId` is always the default `''`, so the screen renders 'Pay cash when your order arrives.' without `Order #<id>` (`order_success_screen.dart:53-55`). The specified assertion cannot pass against current code.
* **Rationale & Recommendation:** Either add the missing argument wiring in `app_router.dart` as an explicit production change (it naturally folds into Item 2's work on that file) or drop the order-reference assertion and assert only the 'Order Success' app bar and 'Order placed successfully!' copy. When asserted, quote the literal on-screen string.

### M6 (readiness-6 + codebase-10 + style-3 + style-11) - Severity: 🟡 Major — Item 9's setup is self-contradictory and key mechanisms are unnamed (admin credential, image-upload gate, notification-scenario mechanism)
* **Affected Scope:** Item 9 (lines 286–289) and Verification Plan line 331
* **Discrepancy Description:** (a) The first sentence is self-contradictory — "Register a customer, then promote it via `npm run admin` semantics (bootstrap script targets the demo admin; the spec instead uses the seeded `admin@sahety.app` …)" — and `bootstrap-admin.mjs` cannot promote an arbitrary customer (hardcoded `ADMIN_EMAIL = 'admin@sahety.app'`, `ADMIN_PASSWORD = 'Admin@123456'`, `bootstrap-admin.mjs:29-30`). The admin credential is never stated in the plan; the e2e skill mandates credentials under `credentials` in `e2e.config.ts`, but that file is not in the Target Files list and has no `credentials` section — where the admin password lives is an open decision. (b) "Image upload inside the spec is optional-gated" names no gating mechanism. (c) The notification scenario says "place an order in-spec or manually" — "or" is a design decision — and no spec file for it appears in the Target Files list, nor is any mechanism given for asserting "bilingual push received" (system-tray inspection is not something the described deterministic specs do).
* **Rationale & Recommendation:** Rewrite Item 9's opening as the two-role setup (register a customer to place the order → restart → sign in as the seeded `admin@sahety.app` for admin-side steps), state the admin password source explicitly (documented in `scripts/README.md` / `bootstrap-admin.mjs`) and where it is declared (add `credentials` to `e2e.config.ts` and add that file to the target list), define the image-upload gate concretely ("steps run only if the `product-images` bucket exists before this spec runs; otherwise skip"), and pick one mechanism for the notification scenario (scripted manual procedure with `adb`/screenshot evidence, or a dedicated spec with the watcher running) saying how push arrival is asserted.

### M7 (readiness-5 + codebase-6) - Severity: 🟡 Major — Item 10's rules test is not executable as specified: no dependencies, no emulator config, no start command
* **Affected Scope:** Item 10 (lines 291–295) and Verification Plan line 330
* **Discrepancy Description:** The rules test is specified only as "Load `./firestore.rules` into the emulator," but the repo has none of the required scaffolding: `scripts/package.json` has only `firebase-admin` and `@supabase/supabase-js` (no `@firebase/rules-unit-testing`, no `firebase` client SDK, no `firebase-tools`) and is not in the Target Files list; the root `firebase.json` contains only the Flutter platform config — no `firestore` rules block and no `emulators` section; a JVM is required and unconfirmed. The executor must decide which packages to add and where, how the emulator is started, and how rules are loaded — a cluster of environment and dependency design decisions the Zero-Decision Rule forbids. (Cross-ref Stage 8 Major 1: the test's position on the critical path is separately contested.)
* **Rationale & Recommendation:** Specify the full recipe: exact devDependencies to add to `scripts/package.json` (add that file as a Modify target with the `test:rules` script entry), the `firebase.json` `emulators.firestore` + `firestore.rules` config to create (or an explicit `npx firebase-tools emulators:start --only firestore --project <id>` command), the test project id, and the rules-load/teardown path. The planned assertions themselves match the shipped rules (`firestore.rules:115-118`) and are correct.

### M8 (readiness-7) - Severity: 🟡 Major — The Arabic (RTL) verification pass has no concrete procedure in the Verification Plan
* **Affected Scope:** Verification Plan, "Visual review checklist (N4)" (line 329) and Item 3 (line 259)
* **Discrepancy Description:** The checklist requires "Arabic RTL run (device locale `ar`)" per spec, but no step says how the device locale is switched: `e2e.config.ts` defines a single target with no locale control, and no adb command (`adb shell settings put system locale ar-AE` + restart) or harness API is named. Item 3 also asks the catalog draft to be checked against "the localized Arabic labels," which cannot be asserted in the declared English-only assertion mode. "Error state" captures are likewise undefined per feature (catalog has no natural error state). The executor cannot produce the AR pass from the plan as written. (FeatureRange counterpart: Stage 7 F4.)
* **Rationale & Recommendation:** Add the concrete locale-switch procedure (exact adb commands or AVD setting, plus whether the app must be restarted/cleared afterward) to the Verification Plan, and clarify that Arabic labels are verified in the AR pass while the default run asserts English-only strings.

### M9 (style-5) - Severity: 🟡 Major — Item 7's signed-out-guard coverage claim outruns the evidence
* **Affected Scope:** Item 7, line 279 (last sentence)
* **Discrepancy Description:** "Also covers the signed-out deep-link guard implicitly (the spec always registers/logs in first; the guard is unit-level)." A spec that always signs in first never triggers the signed-out guard, so it cannot "cover" it under any reading of "implicitly." The follow-on claim "the guard is unit-level" names no test; no unit test in `test/` covers the router guard (the closest match is `integration_test/main_flow_test.dart`, which is integration-level and does not target the guard). (Cross-ref: comprehension F11; Stage 8 arbitration proposes a single-case unit test.)
* **Rationale & Recommendation:** Replace with "Does not cover the signed-out deep-link guard; that path needs its own unit test (none exists today) or an explicit deep-link step" — and, per the Stage 8 arbitration, add the one single-case unit test (signed-out `generateRoute(checkoutScreen)` returns `LoginScreen`).

---

## Nits

### N1 (codebase-8 + style-6) - Nit — Route count "the other six" should be seven
* **Affected Scope:** Item 2, line 253
* `app_router.dart` currently has 16 route cases: 9 bare and 7 getIt-wrapped (login, register, forgotPassword, profile, checkout, myOrders, orderDetails); "six" was true before the landed signed-out checkout guard wrapped the checkout case. Update to "seven" (or count from the file). (Note: the Stage 8 arbitration proposes deferring Item 2 entirely, which dissolves this nit.)

### N2 (codebase-9 + readiness-9) - Nit — Stale "the file currently on disk belongs to `sahety-370c1`"
* **Affected Scope:** Item 12, line 305
* No `serviceAccount*.json` exists on disk anymore — `scripts/` contains only the loader (`service-account.mjs`) plus code. Drop the clause or restate as "if a previously downloaded JSON exists, verify its `project_id`"; the action itself (obtain the `sahety-ba784` key) and the `.gitignore` exclusion claim are correct.

### N3 (readiness-8 + style-2 + Stage 8 Nit) - Nit — Cross-spec cart handoff is impossible under the suite's own isolation rule
* **Affected Scope:** Item 6, line 274 (last sentence)
* Carts are per-user; every spec registers its own fresh user, so the checkout spec can never inherit the cart spec's cart; the draft states "zero cross-spec coupling, no cleanup", and item 8 states the opposite principle explicitly. "Or re-add as needed" gives no decision rule. (`egm-style` rated this Major; the majority and the one-deletion fix size put it at Nit — delete the sentence; item 7 already opens "From a cart with items", which the checkout spec builds itself.)

### N4 (readiness-11 + style-17) - Nit — Missing install command; `:<line>` semantics overstated
* **Affected Scope:** Verification Plan, lines 327–328
* (a) "install to the running Pixel 7 Pro emulator" names the build command but not the install command (`adb install -r build/app/outputs/flutter-apk/app-debug.apk` vs `flutter install`). (b) The `:<line>` suffix executes the single test starting at that line, not the whole file; scope it — "append `:<line>` when a file holds several tests" — so whole-spec verification and single-test iteration are distinguishable.

### N5 (readiness-12 + codebase-12) - Nit — Unmentioned scratch specs `tests/probe.e2e.ts` and `tests/example.e2e.ts`
* **Affected Scope:** Target Files list (lines 242–321) vs `tests/`
* `probe.e2e.ts` (103 lines; its own header says "Deleted after the customer spec is written") and `example.e2e.ts` (7 lines, asserts an OS Settings screen) exist but are unmentioned; their disposition is left to the executor. Add a one-line disposition (delete both — per the Stage 8 arbitration — or document exclusion).

### N6 (style-8) - Nit — "assert the `cartEmpty` empty state" cites an untargetable identifier
* **Affected Scope:** Item 6, line 274
* `cartEmpty` is a ValueKey (`cart_screen.dart:158`), and the plan's own contract (line 160) states specs target accessible names, not ValueKeys. Drop the key reference; keep the string `Your cart is empty`.

### N7 (style-10) - Nit — "re-run toggle to confirm persistence" is ambiguous
* **Affected Scope:** Item 5, line 269
* Ambiguous between re-running the spec and toggling the heart again. Reword to "toggle the heart again and confirm the favorite persists against Firestore."

### N8 (style-12) - Nit — "Any defect found while running counts as a fix under this plan" defines nothing operational
* **Affected Scope:** Item 11, line 300
* No boundary on fix scope, no re-verification requirement. State the rule concretely: defects surfaced during run-gated verification are fixed and re-verified under the same `flutter analyze` / `flutter test` gates before the spec run proceeds.

### N9 (style-13) - Nit — "both were updated" has a three-item antecedent
* **Affected Scope:** Item 14, line 317
* The item lists three files (`scripts/README.md`, `./README.md`, `ecommerce_flutter_firebase_project.md`); use "all three".

### N10 (style-14) - Nit — Item 15 is a contentless self-reference
* **Affected Scope:** Item 15, lines 319–321
* "`./docs/designs/demo-ready-prd-completion.md` → this document (Create at finalize step)" states no change, verification, or dependency. Drop it, or mark it Verify-only like items 11 and 14.

### N11 (style-15; cross-ref comprehension F13) - Nit — The plan-intro ordering narrative does not match the list
* **Affected Scope:** Plan intro, line 240
* "then the user-supplied credentials that gate script runs, then the run/verify sequence" — item 11 (run-gated scripts) precedes items 12–13 (the gates), and "the run/verify sequence" is the separate Verification Plan section, not a list item. Restate the principle accurately or reorder so the gates precede what they gate.

### N12 (style-16) - Nit — The plan silently upgrades two documented-optional policies to requirements
* **Affected Scope:** Item 13, line 311
* The cited `scripts/README.md` §2 marks the UPDATE/DELETE policies as "two optional extras" and says the INSERT policy "is all `npm run seed` needs on a fresh bucket". Scope UPDATE/DELETE to re-seeding/`reset --images` explicitly, or align with the README.

### N13 (style-18) - Nit — "until each passes its own checklist" is fuzzy
* **Affected Scope:** Verification Plan, line 329
* N4 defines one fixed checklist, not a per-spec one. "Fix and rerun until the spec passes all four checklist states."

### N14 (style-7) - Nit — "Honors the brief's M8 commitment (restored by author decision at finalization)" is cryptic process shorthand
* **Affected Scope:** Item 2, line 254
* A fresh reader cannot tell what was restored, from where, or what "at finalization" means. State the delta plainly ("The brief folded M8 route hygiene into opportunistic file touches; this plan restores it as a standalone item, by author decision") — or, per the Stage 8 arbitration, defer Item 2 and delete the sentence.

---

## Verified accurate (no finding)

* Item 1's code facts (three IconButtons with `cartItem*` ValueKeys and no tooltips at `cart_item_card.dart:58-86`; `favorite_heart_button.dart:93` tooltips); item 3/4 line counts and every quoted catalog/details string; item 6's cart strings (`cartEmpty` key at `cart_screen.dart:158`); item 7's strings (validators at `checkout_form.dart:27,37`, CoD tile copy); item 8's order-details strings; item 9's admin facts (`adminDisplayName` at `product_localized_text.dart:105-107`, Arabic-optional validator, role-based routing gate in `lib/e_commerce_app.dart`).
* Item 11's four scripts exist with the claimed behaviors; item 12's `.gitignore` exclusion of `scripts/serviceAccount*.json`; item 13 (`SupabaseConfig.productsBucket = 'product-images'` at `constants.dart:49`); item 14 (root README already documents the scalar `fcmToken` contract; PRD §7 products row already carries Arabic variants).
* Rules-test assertions match `firestore.rules:115-118` exactly (own-user read, admin-only create/update/delete).
* Verification Plan: `flutter analyze` clean (ran it — "No issues found"); **the "256 passing baseline" is exact** (186 `test(`/`testWidgets(` + 70 `blocTest(` declarations; two reviewers independently verified — the readiness reviewer's static-count concern is resolved); `e2e.config.ts` matches workers 1 / timeout 420s / assertionTimeout 15s / bundleId / Pixel 7 Pro; the `auth.e2e.ts` restart-after-auth pattern with `fillSticky`/`dismissKeyboard` exists as described.
