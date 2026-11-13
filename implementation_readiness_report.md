# Goldfish Review Report — Stage 9 (Implementation Readiness Test)

**Target:** `docs/designs/demo-ready-prd-completion.md` (DetailedRange: lines 238–339)
**Reviewers:** `egm-implementation-readiness` (completed), `egm-codebase-details` (completed), `egm-style` (completed)
**Standards:** implementation-readiness-standard (implementation-readiness, codebase-details); persona judgment (style)

## Reviewer Status

| Reviewer | Status |
| --- | --- |
| `egm-implementation-readiness` | completed |
| `egm-codebase-details` | completed |
| `egm-style` | completed |

**Severity breakdown (deduplicated):** 2 🔴 Blocker · 10 🟡 Major · 11 🟢 Nit

## Prioritized Findings (Blockers → Major → Nits)

### 🔴 Three admin routes are pushed but never registered; the admin spec (item 9) cannot pass without an unplanned production change — Severity: Blocker
* **Reviewer Lens:** `egm-implementation-readiness`
* **Affected Scope:** Item 2 (lines 250–254), item 9 (lines 286–289)
* **Discrepancy Description:** `AdminDashboardScreen` pushes `AdminRoutes.adminProducts`/`adminOrders` (`admin_dashboard_screen.dart:33,40`), but `routes.dart` has no such constants and `app_router.dart` has no cases — `generateRoute` falls through to `default: return null`. `AdminOrderDetailsScreen` additionally calls `context.read<AdminOrdersCubit>()` (`admin_order_details_screen.dart:33`), which only the missing route would provide. Item 2 only says "convert the nine bare-screen route cases" — adding three missing routes is not conversion, and `routes.dart` is absent from the Target Files list entirely.
* **Rationale & Recommendation:** Add an explicit production step: register the three constants in `routes.dart` and wire the three cases in `app_router.dart` exactly per the snippet already documented in `lib/features/admin/ui/admin_routes.dart` (provider-backed `AdminProductsCubit`/`AdminOrdersCubit`, `adminOrderDetails` taking `settings.arguments as String`). Name it in the plan and add `routes.dart` to the target-file list; item 9 states this as its precondition.

### 🔴 Item 2 mischaracterizes the route work: two customer routes crash today, and the per-route provider mapping is missing — Severity: Blocker
* **Reviewer Lens:** `egm-implementation-readiness` (corroborated by `egm-codebase-details` Major: nine-case incoherence)
* **Affected Scope:** Item 2 (lines 250–254)
* **Discrepancy Description:** The plan frames item 2 as consistency. In reality `ProductsScreen` contains `BlocBuilder<ProductsCubit, …>` + `context.read` (products_screen.dart:34,38,59,91) and `ProductDetailsScreen` contains `BlocBuilder<ProductDetailsCubit, …>` (:38,51,67) — but neither route provides its cubit. Navigating Home → Browse Products throws `ProviderNotFoundException` on first build; opening any product card does the same. The 256-test baseline hides this (widget tests pump screens with their own `BlocProvider`s). Furthermore, of the nine bare cases: 3 have no cubit at all (Home, OrderSuccess, AdminDashboard); 4 already resolve through getIt inside the screen (Cart, Favorites, Notifications, AdminProductForm — self-provision deliberate for dispose-on-pop; a router-level provider would double-instantiate and would require editing those four screens, none in the target list); only Products/ProductDetails genuinely need the provider. "Convert the nine" leaves per-case decisions open (move vs. keep internal providers; where `uid` comes from for cart/favorites deep links; whether injected-cubit test seams survive — 8+ widget-test files pump screens with their own providers).
* **Rationale & Recommendation:** Scope item 2 down to the actual work: (a) wire the two broken routes (router-level `BlocProvider` for `ProductsCubit`/`ProductDetailsCubit`), (b) register the three admin routes, (c) extract checkout's inline `BlocListener` (verified at `checkout_screen.dart:41`) into `checkout_bloc_listener.dart` (Create). Leave the 4 self-providing screens and 3 cubit-less screens alone. Defer the pure nine-case normalization to post-demo (aligns with Stage 5 Major 3). State plainly that products/details routes are crash bugs so a mid-run failure is not misread as a regression.

### 🟡 Item 4: the "out-of-stock snackbar" is unreachable dead code — Severity: Major
* **Reviewer Lens:** `egm-codebase-details`
* **Affected Scope:** Item 4 (line 264); `add_to_cart_button.dart:103`, `:44–49`; `seed.mjs:305`
* **Discrepancy Description:** `onPressed: widget.product.inStock ? _add : null` disables the button when out of stock, so the snackbar in `_add` can never run. Seed data produces no out-of-stock product at all (`stockFor` yields 10–50, `isAvailable: true` always). The draft spec's "best-effort" snackbar comment refers to the 'Added to cart' success snackbar, not this one. An assertion on the out-of-stock snackbar can never pass.
* **Rationale & Recommendation:** Decide explicitly: drop the snackbar step (keep the reachable `'Out of stock'` status text), or seed an out-of-stock product and change button behavior (production change, list the files).

### 🟡 Items 5–6 say "(Create)" but full drafted specs exist; cart draft's locator strategy conflicts with item 1 — Severity: Major
* **Reviewer Lens:** `egm-implementation-readiness` (deduplicated with Stage 5/7 findings)
* **Affected Scope:** Items 5–6 (lines 266–274)
* **Discrepancy Description:** `favorites.e2e.ts` (169) and `cart.e2e.ts` (201) exist as complete drafts. The cart draft documents a coordinate-tapping workaround ("LOCATOR GAP (app fix pending)") — item 1's tooltips obsolete it, but the plan never instructs updating the draft. Minor: item 5 says `e2e_fav_<stamp>@shop.test` while the draft/Verification Plan pattern use `e2e_favorites_<stamp>`.
* **Rationale & Recommendation:** Restate items 5–6 as "Modify — verify the drafted spec"; instruct swapping coordinate taps for tooltip accessible-name locators after change 1 lands; fix the `e2e_fav_` naming.

### 🟡 Item 8's navigation instruction points to a nonexistent entry point — Severity: Major
* **Reviewer Lens:** `egm-implementation-readiness`
* **Affected Scope:** Item 8 (lines 281–284)
* **Discrepancy Description:** `Routes.myOrdersScreen` is pushed from exactly one place: `order_success_screen.dart:73`. No home or profile link to My Orders exists in `lib/` (Profile opens it — see codebase-details confirmation — but home does not; the instruction as written sends the implementer hunting).
* **Rationale & Recommendation:** Correct to: after placing the order in-spec, navigate from the order-success screen to My Orders (the entry point that exists today).

### 🟡 Item 9 contains a contradictory setup sentence and leaves credential handling and the "optional gate" mechanism undefined — Severity: Major
* **Reviewer Lens:** `egm-implementation-readiness` + `egm-style` (deduplicated)
* **Affected Scope:** Item 9 (lines 286–289)
* **Discrepancy Description:** "Register a customer, then promote it via `npm run admin` semantics (…the spec instead uses the seeded `admin@sahety.app`…)" — self-cancelling; `bootstrap-admin.mjs` cannot promote arbitrary customers (fixed account only). Unstated: how the spec switches identity, where the admin password lives (e2e skill requires passwords under `credentials`/`secrets` in `e2e.config.ts`, never inline), and what mechanism "optional-gated" means (skipped test? env var?) — a test-structure decision left to the implementer.
* **Rationale & Recommendation:** State the actual flow: register customer → place order → restart → log in as seeded `admin@sahety.app` with the password supplied via the config's credentials/secrets contract → advance status (from `AdminOrderDetailsScreen`'s status flow, not the list screen). Pre-decide the upload gate: exclude upload from the spec; cover it under CUJ 2 / demo-day checklist.

### 🟡 Item 7's "the guard is unit-level" asserts test coverage that does not exist — Severity: Major
* **Reviewer Lens:** `egm-codebase-details`
* **Affected Scope:** Item 7 (line 279)
* **Discrepancy Description:** No file under `test/` references `AppRouter`/`generateRoute` or the guard branch; the only mention is a doc comment in `integration_test/main_flow_test.dart:375`, and that test exercises checkout only while signed in. The landed guard has zero automated coverage of any kind.
* **Rationale & Recommendation:** Rephrase to state the guard has no automated coverage and add an explicit unit-test step (router test asserting `generateRoute(Routes.checkoutScreen)` returns `LoginScreen` when signed out), or delete the parenthetical.

### 🟡 Item 10 omits the emulator provisioning `npm run test:rules` depends on; dependency installation unstated; hard gate demotion advised — Severity: Major
* **Reviewer Lens:** `egm-implementation-readiness` + `egm-codebase-details` (dependency nit) + Stage 8 Major (deduplicated)
* **Affected Scope:** Item 10 (lines 291–295), Verification Plan line 330
* **Discrepancy Description:** `scripts/package.json` has only `firebase-admin` + `@supabase/supabase-js` — no `@firebase/rules-unit-testing`, no `firebase-tools`; root `firebase.json` has no `firestore` block. Emulator needs JDK + firebase-tools (first-run binary download). Three undocumented decisions on a deliverable that gates the notification scenario. The assertions themselves match `firestore.rules` exactly (customer create denied / admin create allowed / owner-only read).
* **Rationale & Recommendation:** Add: `@firebase/rules-unit-testing` as devDependency; `firestore: { rules: "firestore.rules" }` block in `firebase.json` (or `loadFirestoreRules` against a manually started emulator); document start command + port + JDK prerequisite in `scripts/README.md`. Demote the gate: run as parallel verification, not a blocker for CUJ 3 (the client write path is deleted; rules untouched by this plan).

### 🟡 Section intro's "ordered by dependency" does not match the list — Severity: Major
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** Line 240
* **Discrepancy Description:** The promised phase sequence (production → specs/rules test → credentials → run/verify) is broken by the actual order (item 11 depends on 12–13; items 14–15 uncovered by any phase).
* **Rationale & Recommendation:** Reword the intro to describe the real grouping; drop "One unified list" redundancy.

### 🟡 Item 6 instructs a cross-spec cart handoff the plan's own rules forbid — Severity: Major
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** Item 6 (line 274)
* **Discrepancy Description:** "leave one item in cart for the checkout spec's starting state" contradicts the fresh-user-per-spec discipline (line 332), contradicts the same bullet's empty-cart assertion, and contradicts item 8's explicit rejection of leftovers.
* **Rationale & Recommendation:** Delete the clause; end the bullet at the `Your cart is empty` assertion.

### 🟡 "validation-only-when-non-empty behavior" is compressed past recoverability — Severity: Major
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** Item 9 (line 289)
* **Discrepancy Description:** Five hyphenated words stand in for an assertion the executor must implement; meaning (Arabic fields optional; validate what when filled?) is guesswork.
* **Rationale & Recommendation:** Spell out the expected behavior in one clause matching `admin_product_form_screen.dart:256–257` (Arabic fields optional; validator fires only when non-empty).

### 🟢 Nits (consolidated)
1. **Item 1 exact tooltip strings not self-contained** (`egm-implementation-readiness`): repeat `'Increase quantity'` / `'Decrease quantity'` / `'Remove from cart'` inside item 1 (currently only at Technical Plan line 164).
2. **Item 2 heading labels would-be-Created listener files "(Modify)"** (`egm-codebase-details`): no `*_bloc_listener.dart` exists outside auth; mark `checkout_bloc_listener.dart` as Create.
3. **Item 12 stale "currently on disk / `sahety-370c1`"** (`egm-implementation-readiness`): no service-account JSON in the workspace now; reword to "no valid service account present; download from the `sahety-ba784` console".
4. **Item 10: name the devDependency** (`egm-codebase-details`): add the install sentence (folded into the Major above).
5. **Item 14 "both were updated" has a three-file antecedent** (`egm-codebase-details` + `egm-style`): "all three" or name the two; drop the "No structural changes expected" hedge.
6. **Item 1 redundant self-labeling** (`egm-style`): delete "This is one of the two production-code changes…" sentence.
7. **Undefined brief-letter IDs M8/B3/N4/M5** (`egm-style`; tracked from Stage 6): gloss or drop.
8. **"confirmed on-screen strings" uncalibrated** (`egm-style`, item 3): "as written in the widget sources".
9. **Speculative risk framing in item 2 justification** (`egm-style`): drop "mid-demo inconsistency risk", keep the convention clause.
10. **Coinages: "optional-gated", "Run-gated verification", "match shipped reality"** (`egm-style`): replace with plain operations.
11. **Triple "wrong" in item 12** (`egm-style`): "A mismatched service account would seed the wrong Firestore project and route its pushes through it."
12. **Missing verb in Build bullet** (`egm-style`, line 327): "after changes 1–2 land or any fix is applied".

## Execution-ready as written

Items 1, 3, 4 (strings), 7 (strings), 11, 13, 14–15, and most of the Verification Plan are execution-ready: every cited on-screen string verified in source (`products_screen.dart:117,171`, `category_filter_chips.dart:32,49`, `product_details_screen.dart:47,62,182–183,195`, `add_to_cart_button.dart:46,101`, `favorite_heart_button.dart:93`, `product_card.dart:21`, `checkout_form.dart:27,37`, `checkout_screen.dart:134,141,175`, `order_success_screen.dart:24,55,70–81`, `cart_screen.dart:46,87,129–133,158,168`, `seed.mjs:133`), config numbers match `e2e.config.ts` exactly (workers 1 / timeout 420000 / assertionTimeout 15000 / bundleId), the 256-test baseline verified by static count (117 test + 69 testWidgets + 70 blocTest), and the rules-test assertions match `firestore.rules:115–118`.

**Bottom line:** resolve Blockers 1–2 and Majors 3–7 before dispatching implementation; the doc-only Majors/Nits are one edit pass on the plan itself.
