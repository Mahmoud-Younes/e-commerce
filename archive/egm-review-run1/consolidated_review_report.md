# Consolidated Review Report

**Target:** `docs/designs/demo-ready-prd-completion.md` (full file)
**Mode:** Consolidated report — all five review rubrics, uninterrupted flow
**Date:** 2026-11-11
**Split:** FeatureRange 1–237 · DetailedRange 238–339 (split header at line 238)

## Stage Summary

| Stage | Rubric | Report | Raw findings |
| --- | --- | --- | --- |
| 5 | Initial Zoom Out (zoom-out + inventive-catalyst) | `zoom_out_report.md` | 0 🔴 · 6 🟡 · 6 🟢 |
| 6 | Comprehension Test (naive reader) | `comprehension_report.md` | 0 🔴 · 3 🟡 · 11 🟢 |
| 7 | Critic Review (design + structural + style) | `critic_report.md` | 0 🔴 · 13 🟡 · 16 🟢 |
| 8 | Intermediate Zoom Out (additions/mitigations arbitration) | `intermediate_zoom_out_report.md` | 0 🔴 · 3 🟡 · 2 🟢 |
| 9 | Implementation Readiness (readiness + codebase-details + style) | `implementation_readiness_report.md` | 2 🔴 · 9 🟡 · 14 🟢 |

**Raw total: 85 findings → consolidated below into 31 actionable items.**

**Execution disclosure:** subagent nesting was unavailable in this environment (concurrency limit of one); Stages 6–9 reviewers were dispatched directly, each in its own fresh context (true Goldfish isolation). Stage 5 ran both lenses inline inside the synthesizer context and discloses this in its report — its recall may be lower than a true swarm.

**Cross-stage convergence (findings independently hit by multiple stages — highest confidence):** stale e2e-spec inventory (Stages 5, 6, 7, 8, 9), `preparing` omission (5, 7), admin-spec contradiction (5, 6, 7, 9), full-journey promise unowned (5, 7), M8 churn (5, 8, 9), watcher no-replay risk (5, 7, 8), foreground-push gap (5, 7, 8), Arabic-RTL mechanism (6, 7, 9), `scripts/` tracking misstatement (7, 9), rules-test scaffolding/gating (8, 9).

---

## 🔴 Blockers (2) — must fix before the plan is executable

### C1 — Wire the three unwired admin routes (new task the plan lacks)
Admin navigation is broken today: `lib/features/admin/ui/admin_routes.dart` defines `AdminRoutes.adminProducts` / `adminOrders` / `adminOrderDetails` as a pending "merge agent" TODO, the dashboard and orders screens call `context.pushNamed` on them, but `app_router.dart` has no case for any of the three — `generateRoute` returns null and navigation throws. The admin e2e journey (Item 9) cannot execute one step past the dashboard.
**Action:** add an explicit plan task: register the three constants in `lib/core/routing/routes.dart`, wire the three cases in `app_router.dart` using the snippets already prescribed in `admin_routes.dart`. Make it the first routing task, ahead of any normalization decision.
**Sources:** ready-B1.

### C2 — Correct the `scripts/` tracking story everywhere; commit the scripts code
The doc calls `scripts/` "gitignored" three times (lines 101, 217, 293/299). Reality: `.gitignore` deliberately tracks scripts code (`!scripts/package.json`, "Code (package.json, *.mjs) is tracked") — only secrets, deps, and state are ignored. Consequence if uncorrected: `scripts/rules-test.mjs` never gets committed, silently voiding the B3 no-regression lock; and PRD §9's "organized source + README" submission criterion is unmet.
**Action:** reword all three sites to "code tracked; secrets/state ignored"; add "commit `scripts/` code (package.json, *.mjs, README)" to the remaining work.
**Sources:** ready-B2, critic-F7.

---

## 🟡 Major (19) — correctness and execution risks

### C3 — Re-baseline the work inventory to the workspace; make one list canonical
Items 5–6 say "(Create)" but `tests/cart.e2e.ts` (201 lines) and `tests/favorites.e2e.ts` (169 lines) exist as complete drafts; only checkout/orders/admin are truly missing. "Remaining changes" (162–169) duplicates the Detailed Implementation Plan as a second normative inventory — the mechanism that caused the drift. The 8-vs-5 spec arithmetic (line 29 vs 33) never reconciles at point of use.
**Action (mostly subtraction, per Stage 8):** re-baseline to "verify four drafts (catalog, product_details, cart, favorites); author three (checkout, orders, admin); notifications covered by the scenario"; relabel items 5–6 "Modify — verify/extend the drafted spec"; pin `e2e_favorites_`/`e2e_cart_` prefixes; reduce "Remaining changes" to a non-normative summary; add one reconciliation clause at line 33; give `tests/probe.e2e.ts` and `tests/example.e2e.ts` a one-line disposition (delete both).
**Sources:** zoom-M1, critic-F6, comp-F4, izo-M3, ready-M2, ready-N5, codebase-12.

### C4 — Split Item 2: keep the Blocker-level routing fix, defer the nine-case normalization
Stage 8 arbitrated: M8 normalization is unjustified pre-demo churn (no named failure it prevents; the brief committed it only "as time allows"; the concrete failure is already fixed by the landed guard). But Stage 9 found routing DOES need work — the three admin routes (C1). Do not delete routing work; delete the wrong half.
**Action:** rewrite Item 2 as: (1) wire the three admin routes (C1); (2) defer nine-case BlocProvider normalization to post-demo hygiene. If the owner insists on keeping normalization pre-demo, it must become a per-case table (cubit-less screens left bare; documented self-wrapping screens kept; `registerFactoryParam` vs ModalRoute-read decisions; exact new `*_bloc_listener.dart` paths marked Create; cart's inline listener in scope or claim scoped down) — no blanket instruction.
**Sources:** zoom-M6, izo-arb(M8), ready-M1, critic-N1 (dissolves).

### C5 — Add `preparing` to the status chain; acknowledge the intentional superset
G3 (line 39) and CUJ 3 (line 77) omit `preparing`, contradicting PRD §4/§5, `GLOSSARY.md`, and the landed watcher (`watch-orders.mjs:41`, scripts/README "five notify-worthy statuses"). Following the doc's chain would skip that transition despite the claimed full PRD §9 sweep.
**Action:** two words in G3/CUJ 3 plus one sentence acknowledging the deliberate superset over PRD §6.
**Sources:** zoom-M2, critic-F2.

### C6 — Foreground push: fix CUJ 3's silent precondition, do not build a banner
PRD §6 requires foreground handling; the design makes foreground a no-op and never lists it as a non-goal; CUJ 3 asserts a tray push that Android will not show while the app is foregrounded — the natural demo posture fails silently.
**Action (per Stage 8 — no code):** one Non-Goals sentence ("no user-visible foreground push; the notification center and Firestore streams carry the foreground experience") + restate CUJ 3's Given as app-backgrounded/terminated. Demo-day tip: lead the walkthrough with the notification center (guaranteed path), not the tray push.
**Sources:** critic-F3, zoom-N6, zoom-N5, izo-arb.

### C7 — Replace the automated "Arabic RTL run" with one manual Arabic session
"English-only assertions" and an `ar`-locale run are mutually incompatible as specified; no locale-switch mechanism is ever named; "error state" captures are undefined per feature.
**Action (per Stage 8 — subtraction):** delete "Arabic RTL run" from the per-spec automated checklist; add one manual Arabic session to the Verification Plan (switch emulator locale — name the exact adb commands — walk CUJ 1, capture screenshots against the checklist; Arabic product-content strings are verified there, English-only strings hold everywhere). Do not build locale-aware spec variants or a second AVD protocol.
**Sources:** comp-F3, critic-F4, ready-M8, izo-arb.

### C8 — Admin spec: state the two-role setup, the credential source, and the upload gate concretely
Item 9's first sentence gives two mutually exclusive setups ("register a customer, then promote it" vs seeded `admin@sahety.app`); `bootstrap-admin.mjs` cannot promote arbitrary users (hardcoded account). The admin password is never stated; `e2e.config.ts` has no `credentials` section and is not in the target list; "optional-gated" upload names no mechanism.
**Action:** rewrite as the two-role flow (fresh customer places the order → restart → sign in as seeded admin → assert), state the credential source (`scripts/README.md` / `bootstrap-admin.mjs`, password `Admin@123456`) and declare it under `credentials` in `e2e.config.ts` (add that file to the target list); upload steps "run only if the `product-images` bucket exists before this spec runs; otherwise skip".
**Sources:** zoom-M3, comp-F2, ready-M6, codebase-10.

### C9 — Notification scenario: pick one mechanism; ungate the rules test; specify its full recipe
(a) The rules test gates the headline scenario yet cannot functionally affect it (the watcher bypasses rules by design) — while requiring Firebase Emulator Suite + Java on this Windows machine. (b) "place an order in-spec or manually" leaves the mechanism undecided; nothing asserts "push received". (c) The test itself has zero scaffolding: no `@firebase/rules-unit-testing`/`firebase-tools` deps, no `firebase.json` emulator config, no start command, `scripts/package.json` not a target. (d) The admin spec and the scenario duplicate the same status-change production.
**Action:** delete the gating clause (test moves after the scenario or to post-demo hygiene); add `scripts/package.json` as a Modify target with the `test:rules` script entry + devDeps; specify the `firebase.json` `emulators.firestore` + rules block or the exact `npx firebase-tools emulators:start --only firestore --project <id>` command; pick the scenario mechanism (scripted manual procedure with adb/screenshot evidence, or run the admin spec with the watcher live and observe notification surfaces during its status change — the concrete reuse Stage 8 recommends); the emulator/Java prerequisite gets one clause inside item 10, not a fourth Open Question.
**Sources:** izo-M1, ready-M7, zoom-N3, izo-N2.

### C10 — Give G2/CUJ 2 (real image upload) an owned verification step
Every pillar has an owner except the upload round-trip: the admin spec's upload step is "optional-gated" on a bucket that is a hard demo prerequisite anyway (making the gate meaningless), so a headline pillar ships unverified if picker-driving is the real (unstated) constraint.
**Action (one sentence, per Stage 8):** either make the admin spec's upload step unconditional, or name the picker limitation and add a one-line manual rehearsal to the Verification Plan ("as admin, add one product with a real image; confirm it renders").
**Sources:** izo-M2.

### C11 — e2e leftovers: one line of honesty instead of a purge project
`reset.mjs` deletes only `seed_` products; e2e Auth users/carts/favorites/orders/notifications accumulate in the live project and surface in the admin's incoming-orders view during the demo. The brief's M5 per-spec teardown language was dropped.
**Action (per Stage 8 — reject `reset.mjs --e2e` pre-demo):** state the accumulation by design in one line; add "cancel/delete `e2e_` orders from the admin screen the morning of the demo" to the pre-demo checklist; build the purge mode post-demo only if the volume annoys.
**Sources:** critic-F5, izo-arb.

### C12 — Watcher SPOF: add a pre-demo health check; reject replay/restart machinery
The watcher is an unmonitored single point of failure with at-most-once checkpoint delivery: a transition missed while it is down is never notified, and this failure mode is absent from the document (it lives only in `scripts/README.md`).
**Action:** one Verification Plan line — pre-demo health check (throwaway order, advance a status, assert push + record). Reject `watch --replay` and supervised-restart wrappers (manual recovery is already documented). The failure mode itself is recorded by C13's risk block.
**Sources:** zoom-M5, zoom-N5, izo-arb.

### C13 — Add the compact Risks & Mitigations block (the one endorsed structural addition)
The Feature Spec Standard requires risks to be identified with mitigations; the spec has no such section, and demo-critical failure modes are scattered (AVD FCM uncertainty in Open Questions, free-tier pause buried in Alternative C, watcher no-replay absent entirely) — plus F1's bucket exposure is missing from the security surface altogether.
**Action (per Stage 8 — keep it to 4–5 bullets, placed with the NFR section, pointing at `scripts/README.md` as the operational home):** (1) watcher down = missed transitions, no replay → health check + manual recovery; (2) AVD FCM delivery unconfirmed → physical-device fallback; (3) anon INSERT/UPDATE/DELETE on the public bucket (publishable key ships in the APK → anyone can overwrite/delete every image or fill the quota) → accepted demo risk + post-demo tightening (scoped `seed/` prefix policies or service-role-only destructive ops); (4) free-tier Supabase pause → seed script doubles as health check; (5) e2e leftovers (C11).
**Sources:** critic-F11, critic-F1, zoom-M5, izo-M2, izo-verdict.

### C14 — Reword the full-journey promise instead of adding a work item
Line 18 promises a "full-journey pass (login → browse → cart → checkout → order → admin status change → notification)" that no remaining-change item owns; a dedicated spec would duplicate cart/checkout/orders/admin coverage line for line.
**Action (per Stage 8 — YAGNI):** line 18 becomes "closing with the notification scenario and the PRD §9 acceptance sweep"; if the owner wants the ritual, it is a manual CUJ 1–3 walkthrough, one checklist line, not a spec.
**Sources:** zoom-M4, critic-F8, izo-arb.

### C15 — Calibrate the Problem section and the Status field
Present-tense problem bullets ("Arabic cannot display", "Notifications produce nothing", "not demonstrable today") are false against line 33's landed state; the bullets also mix tenses; Status still says "Proposed".
**Action:** label The Problem as the pre-fix baseline (or convert to past tense, dated snapshot); Status → "Partially implemented — verification pending".
**Sources:** critic-F9 (+ design-9).

### C16 — Align the token-absent contract with the shipped behavior
"The watcher skips a user silently when the token is absent" contradicts the README (push skipped **with a log line**; in-app record **still written** — which is what keeps G3(b) true). Also `UNREGISTER` → `UNREGISTERED`.
**Action:** reword line 156; note the demo-day expectation (no push, record appears); fix the identifier on line 46.
**Sources:** critic-F10 (+ design-11, style-16).

### C17 — Fix Item 8's navigation step (the control it names does not exist)
No Home/Profile entry leads to My Orders; the only in-app path is the order-success screen's "Track it in My Orders" button.
**Action:** reach My Orders via the order-success screen after the in-spec checkout (or add a Home/Profile → My Orders entry as an explicit production change in the target list).
**Sources:** ready-M4, codebase-5, style-4.

### C18 — Decide the order-success `orderId` wiring (the assertion cannot pass today)
`checkout_screen.dart:48-51` passes `arguments: orderId` but `app_router.dart:110-111` builds `const OrderSuccessScreen()` and never reads it — `orderId` is always `''`, so "assert landing with the order reference" can never pass.
**Action:** either wire the argument in `app_router.dart` as an explicit production change (folds into C1/C4's routing work) or drop the reference assertion (app bar + 'Order placed successfully!' copy). If asserted, quote the literal string.
**Sources:** ready-M5 (+ style-9), codebase-4.

### C19 — Restate Item 1's rationale and add the draft-locator rewrite step
The drafted cart spec does not use tooltips at all — it coordinate-taps via `tapNextToQuantity` and removes lines by decrease-to-zero. "Tooltips unlock the cart spec" is false as written; and no step converts the draft to accessible-name locators after tooltips land.
**Action:** restate item 1's rationale ("tooltips let the spec replace fragile coordinate taps and target the remove button by accessible name"); add to item 6: after item 1 lands, replace the workaround with `getByRole`/accessible-name locators (`Increase quantity` / `Decrease quantity` / `Remove from cart`).
**Sources:** ready-M3, codebase-3.

### C20 — Fix the guard-coverage claim and add the one missing unit test
Item 7 claims the checkout spec "covers" the signed-out deep-link guard "implicitly" — impossible when the spec always signs in first — and "the guard is unit-level" names no test (none exists; the closest is integration-level).
**Action:** replace the sentence ("Does not cover the signed-out deep-link guard; that path needs its own unit test"); add the single-case unit test (signed-out `generateRoute(checkoutScreen)` returns `LoginScreen`) — the Stage 8-endorsed smallest honest resolution.
**Sources:** ready-M9, comp-F11, zoom-N2, izo-arb.

### C21 — Editorial majors in one sweep: delete the opaque IDs, the attribution prefixes, and promote the orphan H3s
(a) M8/B3/N4/M5 are never defined in this document (comprehension rated this Major) — delete them for plain referents rather than adding a decode table. (b) All six "Rejected by author" lead-ins attribute decisions to the maintainer with no linked record (standard violation; the trade-offs stand on their own). (c) `### Additional Resources` and `### Future Improvements` are orphaned H3s after the thematic break — promote to H2.
**Sources:** comp-F1, critic-F12, critic-F13, izo-arb.

---

## 🟢 Nit (10 consolidated groups)

### C22 — Section honesty and stale specifics in the spec half
Rename "Open Questions" → "Open Questions & Blockers"/"External Prerequisites"; drop the `products` bucket probe (line 55); restate the service-account item as a verifiable instruction (no `serviceAccount*.json` is on disk anymore); fix tenses/flourishes: cut "the demo moment that should impress", trim "partially landed already", replace "parked while the design workflow ran", pick "sample/realistic" framing for the seed set, rename "Hygiene in passing", qualify G4 ("every feature except notifications"), unify the snapshot moment ("add-to-cart time, an accepted approximation of PRD §4's purchase-time snapshot"), fix `UNREGISTER`→`UNREGISTERED`.
**Sources:** critic-N2, N3, N8, N9–N12, N16; comp-F12 partial.

### C23 — Formatting conventions
One horizontal-rule convention for all top-level sections (prefer `---`); drop the repeated `**The idea**:` lead-ins (lead with the subject); delete the third data-flow diagram (the verification loop is fully recoverable from the Verification Plan prose — Stage 8 prefers deletion over redraw); fix "both were updated" → "all three" (item 14).
**Sources:** critic-N4, N5, N6; style-13; izo-arb.

### C24 — Comprehension glosses (half a sentence each)
"cold-start records without notifying" (watcher start semantics), "`Supabase.initialize` guarded by a placeholder check", "explicit-null serialization", `SupabaseConfig.productsBucket` ↔ `constants.dart` connection, "validation-only-when-non-empty" (state the actual rule), a forward gloss for "trusted sender" and "stages 1–7" in the Overview, PRD §-reference glosses where bare (§2/§3/§4/§5, "§7's products row"), the `:<line>` run-command semantics (G4 vs CUJ 4 forms).
**Sources:** comp-F5–F10, critic-N7 partial, style-17.

### C25 — Plan-layer nits
Delete the cross-spec cart handoff sentence (item 6 — impossible under the isolation rule; "re-add as needed" gives no decision rule); drop the `cartEmpty` ValueKey reference (keep the `Your cart is empty` string — the plan's own contract forbids key targeting); reword "re-run toggle" (item 5); define "counts as a fix" operationally (item 11 — same analyze/test gates, re-verified before proceeding); delete the contentless item 15; restate the plan-intro ordering narrative to match the list; scope UPDATE/DELETE policies explicitly vs the README's "optional extras"; scope the `:<line>` suffix ("append when a file holds several tests") and add the APK install command; "fix and rerun until the spec passes all four checklist states"; replace the M8 process shorthand ("restored by author decision at finalization") with the plain delta — or dissolve via C4's deferral; update the route count "six"→"seven" — or dissolve via C4.
**Sources:** ready-N1(becomes B1 context), N3, N4, N6, N7, N8, N9, N10, N11, N12, N14; style-2, 6, 7, 8, 10, 12, 13, 14, 15, 16, 18; izo-N1.

### C26 — Delete the process-metadata provenance
The provenance footer / "Drafted with EGM" / "7 Goldfish lenses" line (Additional Resources) is process metadata with zero reader value — delete (Stage 8 arbitration).
**Sources:** comp-F14, izo-arb.

---

## Traceability Matrix

| Consolidated | Raw sources |
| --- | --- |
| C1 | ready-B1 |
| C2 | ready-B2 (codebase-1), critic-F7 (design-7) |
| C3 | zoom-M1, critic-F6 (design-6+style-4+style-5), comp-F4, izo-M3, ready-M2, ready-N5, codebase-12, style-5 |
| C4 | zoom-M6, izo-arb M8-cluster, ready-M1 (readiness-2 + codebase-7 + codebase-11), critic-N1 (design-8), comp-F1 (M8 half) |
| C5 | zoom-M2, critic-F2 (design-2+style-2) |
| C6 | critic-F3 (design-3), zoom-N6, zoom-N5, izo-arb foreground-cluster |
| C7 | comp-F3, critic-F4 (design-4), ready-M8 (readiness-7), izo-arb RTL-cluster |
| C8 | zoom-M3, comp-F2, ready-M6 (readiness-6), codebase-10, style-3, style-11 |
| C9 | izo-M1, izo-N2, ready-M7 (readiness-5 + codebase-6), zoom-N3 |
| C10 | izo-M2 |
| C11 | critic-F5 (design-5), izo-arb cleanup-cluster |
| C12 | zoom-M5 (inventive), zoom-N5, izo-arb SPOF-cluster |
| C13 | critic-F11 (structural-1 + design-13), critic-F1 (design-1), zoom-M5, izo-M2, izo-verdict |
| C14 | zoom-M4, critic-F8 (style-3), izo-arb journey-cluster |
| C15 | critic-F9 (style-1), design-9 |
| C16 | critic-F10 (style-6 + design-11), style-16 |
| C17 | ready-M4 (readiness-4 + codebase-5 + style-4) |
| C18 | ready-M5 (codebase-4 + style-9) |
| C19 | ready-M3 (codebase-3) |
| C20 | ready-M9 (style-5), comp-F11, zoom-N2, izo-arb redirect-cluster |
| C21 | comp-F1, critic-F12 (structural-3), critic-F13 (structural-2) |
| C22 | critic-N2, N3, N8, N9, N10, N11, N12, N16, design-10, design-14, design-12, style-18, style-17, style-15, comp-F12 |
| C23 | critic-N4, N5, N6 (structural-7 + style-14), style-13, izo-arb diagram-cluster |
| C24 | comp-F5, F6, F7, F8, F9, F10, critic-N7, style-17, comp-F13 partial |
| C25 | ready-N3, N4, N6, N7, N8, N9, N10, N11, N12, N14; style-2, 6, 7, 8, 10, 12, 15, 16, 18; izo-N1 |
| C26 | comp-F14, izo-arb provenance-cluster |

*(Stage 5 IDs: zoom-M1…M6 / zoom-N1…N6; Stage 6: comp-F1…F14; Stage 7: critic-F1…F13 / critic-N1…N16; Stage 8: izo-M1…M3 / izo-N1…N2 + arbitration clusters; Stage 9: ready-B1…B2 / ready-M1…M9 / ready-N1…N14.)*

---

## Recommended fix order

1. **C1, C2** (blockers) → then **C4** (routing split, inherits C1) and **C3** (inventory re-baseline — every later edit reads the corrected list).
2. **C5–C10** (behavior/journey corrections: statuses, foreground, RTL session, admin spec, notification mechanism, upload owner).
3. **C11–C14** (risk honesty: leftovers, health check, risk block, journey rewording).
4. **C15–C21** (calibration and editorial majors) → **C22–C26** (nits, mostly one-line deletions).
5. Re-run `flutter analyze` + `flutter test` after any production-code change (C1/C18/C20 add code; everything else is document-only).

## What the review confirmed as sound

* The architecture is minimal and correct: no new runtime layers, strict `firestore.rules` preserved by a trusted sender outside the app, scalar token contract, seed-as-reset, reuse of existing Cubit/router/helper conventions and the platform-standard `@firebase/rules-unit-testing`; no reinvention found.
* Landed-state claims verified in code: Supabase init, FCM wiring, localization plumbing, Arabic model fields, checkout guard, favorite-button tooltips, seed/watch/reset/bootstrap scripts, bucket constant, rules file — all match the tree.
* Every quoted on-screen string, config value (workers 1 / 420s / 15s / bundleId), and the "256 passing baseline" (186 + 70 blocTest) verified exact; `flutter analyze` clean.
* The Alternatives section genuinely examined the real trade-offs; two of the six rejections rest on verifiable external facts (legacy FCM API shutdown, PRD §6).
