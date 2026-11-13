# Consolidated Review Report — Full EGM Review (Run 2)

**Target:** `docs/designs/demo-ready-prd-completion.md` (FeatureRange 1–237 · DetailedRange 238–339)
**Mode:** Consolidated report with all review rubrics (Stages 5–9, uninterrupted)
**Date:** 2026-11-12 · **Run 1 reports archived at:** `archive/egm-review-run1/` (doc unchanged since run 1; this run re-reviewed with fresh eyes)

## Reviewer Status

| Stage | Reviewers | Status |
| --- | --- | --- |
| 5 — Initial Zoom Out | `egm-zoom-out`, `egm-inventive-catalyst` | completed |
| 6 — Comprehension | `egm-comprehension` | completed |
| 7 — Critic | `egm-design`, `egm-structural`, `egm-style` | completed |
| 8 — Intermediate Zoom Out | `egm-zoom-out` | completed |
| 9 — Implementation Readiness | `egm-implementation-readiness`, `egm-codebase-details`, `egm-style` | completed |

**Raw totals:** 12 reviewers · 3 🔴 Blocker · 22 🟡 Major · 30+ 🟢 Nit → **deduplicated: 3 Blockers · 17 Majors · 20 Nits** (traceability matrix below).

## Verdict

The design's architecture is sound and unusually verifiable — nearly every "landed" claim was confirmed against code by multiple independent reviewers, the Alternatives analysis is evidence-based, and the contracts section is precise. The plan of record is **not safe to execute as written** for three reasons: (1) the entire "landed" implementation exists only as uncommitted working-tree state and the doc's own rollback instruction would destroy it; (2) three admin routes and two customer routes are broken in the running app while the plan frames route work as style normalization; (3) the verification campaign's closing gate (PRD §9) has no scheduled step. Everything else is doc-drift correction and bounded hardening.

## Prioritized Findings (deduplicated)

### 🔴 Blocker 1 — Landed implementation is uncommitted; the plan's rollback instruction is destructive
* **From:** Stage 8 Finding 1 (sole source)
* **Evidence:** 32 modified tracked files + untracked `lib/core/helpers/product_localized_text.dart`, `test/core/helpers/`, `docs/designs/`, `scripts/` — none in git history. NFR line 217: "rollback is `git checkout` of the touched files" — which reverts the landed work itself. No commit step exists in the 15-item plan.
* **Fix:** Plan item 0: analyze + test green → commit the baseline (including this design doc) → one commit per plan item thereafter; rewrite the rollback NFR.

### 🔴 Blocker 2 — Three admin routes are pushed but never registered
* **From:** Stage 9 `egm-implementation-readiness` Blocker 1
* **Evidence:** `admin_dashboard_screen.dart:33,40` pushes `AdminRoutes.adminProducts/adminOrders`; no constants in `routes.dart`, no cases in `app_router.dart`; `AdminOrderDetailsScreen` needs the route-provided `AdminOrdersCubit`. `routes.dart` absent from the target-file list. Admin e2e (item 9) is impossible until wired.
* **Fix:** Register 3 constants + 3 cases per the snippet already in `lib/features/admin/ui/admin_routes.dart`; add `routes.dart` to target files; item 9 states it as precondition.

### 🔴 Blocker 3 — Item 2 mischaracterizes route work: two customer routes crash today
* **From:** Stage 9 `egm-implementation-readiness` Blockers 2 + Major 3 + `egm-codebase-details` Major (nine-case incoherence)
* **Evidence:** `ProductsScreen`/`ProductDetailsScreen` build `BlocBuilder`s + `context.read` but no route provides those cubits → `ProviderNotFoundException` on Home→Browse and on opening any product card. Hidden by widget tests that pump screens with their own providers. Of the nine bare cases: 3 have no cubit, 4 self-provide via getIt (router-level provider would double-instantiate), only 2 genuinely need wiring.
* **Fix:** Scope item 2 to the real work: wire Products/ProductDetails providers (bugfix), register admin routes (Blocker 2), extract checkout inline listener (Create `checkout_bloc_listener.dart`); leave 7 cases untouched; defer pure normalization post-demo (Stage 5 Major 3 concurs).

### 🟡 Majors (deduplicated, remediation-owner tagged)

| # | Finding | Sources | Fix owner |
| --- | --- | --- | --- |
| M1 | FCM token not saved at login (zero callers of `getTokenAndSave`; token lands only on relaunch) — G3/CUJ3 Given false for fresh users | S7 design M1 · S8 mitigation note (restart-after-auth ~90% mitigates; residual = contract wording) | code: wire post-auth save + doc rewording |
| M2 | Spec inventory stale: items 5–6 "(Create)" but drafts exist (favorites 169 / cart 201 lines); cart draft's coordinate-tap workaround conflicts with tooltips item; `probe.e2e.ts`/`example.e2e.ts` undecided; `e2e_fav_` naming | S5 zoom-out M1 · S7 design M2 · S9 impl M4 | doc + code: reclassify, rewrite cart locators, delete scaffold specs |
| M3 | `preparing` omitted from G3/CUJ3 status enumerations (watcher pushes 5 statuses incl. preparing) | S5 zoom-out N4 · S7 design M3 + style M1 | doc |
| M4 | `scripts/` "gitignored" mischaracterization (untracked-but-trackable per `.gitignore` intent; rollback story incoherent) | S5 zoom-out M2 · S7 design M4 | doc + commit decision |
| M5 | M8 route normalization scope-elevated + sequenced before verification (largest diff at lowest-tolerance moment, zero demo value) | S5 zoom-out M3 · S5 inventive N7 | doc (scope-down decision) |
| M6 | Watcher downtime silently loses notifications; checkpoint enables bounded catch-up but plan is silent | S5 inventive M1 | code: catch-up branch |
| M7 | Watcher has no liveness signal; demo's most fragile dependency invisible | S5 inventive M2 | code: probe verb + rehearsed failure |
| M8 | World-writable Supabase bucket unacknowledged (anon INSERT/UPDATE/DELETE unscoped + publishable key public) | S5 inventive N3 → S7 design M5 | doc + README SQL scoping |
| M9 | E2e artifacts pollute live demo dataset (real auth accounts, orders; `reset` covers products only) | S7 design M6 | doc: `reset --e2e` or accepted limitation |
| M10 | Opaque brief IDs (M5/M8/B3/N4) + "the brief" never defined | S6 comprehension M1 · S7 style M4 · S9 style N | doc |
| M11 | Arabic RTL review run mandated but mechanism unstated (locale switch, English-only assertions reconciliation) | S6 comprehension M2 | doc |
| M12 | Tense contradiction Problem vs Current state ("not demonstrable today" vs "have landed") | S7 style M2 | doc |
| M13 | Self-falsifying scope sentence (line 90: "Every remaining change… with two production-code changes") | S7 style M3 | doc |
| M14 | §9 closing gate has no scheduled step; loading/success states dropped from checklist; two security criteria lack an instrument | S8 M2 | doc: add §9 sweep step + rules-test assertions |
| M15 | Rules-test toolchain unstated (JDK, firebase-tools, `@firebase/rules-unit-testing`, firebase.json firestore block) + hard-gate demotion advised | S8 M3 · S9 impl M7 + cd Nit | doc + README + package.json + firebase.json |
| M16 | Systemic pattern: state asserted from memory, not disk (≥8 findings one genus) — finalize step should be a state audit | S8 M4 | doc (finalize step redefinition) |
| M17 | Detailed-plan wording Majors: item 4 out-of-stock snackbar unreachable; item 7 "guard is unit-level" false coverage claim; item 8 "home/profile navigation" wrong entry (order-success is the only one); item 9 contradictory sentence + credential/optional-gate undefined; intro dependency-order mismatch; item 6 cross-spec handoff forbidden by own rules; "validation-only-when-non-empty" compressed | S9 impl M1/M5/M6 · S9 cd M1/M3 · S9 style M1/M2/M4 | doc |

### 🟢 Nits (consolidated, one edit pass)

Route count "six"→seven (S5+S7) · token-contract wording vs watcher behavior (S5+S7: push skipped+logged, record still written, legacy map tolerated) · stale "sahety-370c1 on disk" (S7+S9) · password caveat location (S7) · G4 notifications scope (S5+S7) · rules-test taxonomy (S7) · FCM acronym + `\uf8ff` + UNREGISTER + "Google APIs image" glosses (S6) · "real device" vs emulator (S6) · "no agent/model steps" context (S6) · PRD §-reference glosses (S6) · stray `products` bucket mention (S6) · EGM/Goldfish provenance terms (S6) · structural: back-matter nesting (template-inherited, leave), HR placement, risks invisible in outline, heading case, diagram column drift (S7 structural) · style: "should impress", "trivial", "parked" clause, "partially landed already", "**The idea**" ×4, "fresh" qualifier, one-spec-at-a-time phrase drift, Alternatives adjectives (S7 style) · S8: Open-Questions mislabeled (2 are owner actions), FCM probe permission-denial confusable · S9: item 1 tooltip strings self-containment, listener files Create-vs-Modify, item 14 "both"→three, item 1 self-labeling, "confirmed strings" calibration, coinages, triple "wrong", Build bullet verb.

## Traceability Matrix (raw → consolidated)

| Stage report | Raw findings | Consolidated into |
| --- | --- | --- |
| zoom_out_report.md (S5) | 3 Major + 4 Nit | B-adjacent M5; M2, M3, M4, M6, M7, M8; Nits (preparing, route count, admin sentence, G4, token wording) |
| — inventive-catalyst (S5) | 2 Major + 6 Nit | M6, M7, M8; Nits (token wording, fixture contract, spec drift, M8 cut-line, FCM probe timing) |
| comprehension_report.md (S6) | 2 Major + 9 Nit | M10, M11; Nits (acronyms, `\uf8ff`, real-device, admin sentence, agent-steps, PRD refs, data policy, products bucket, EGM terms) |
| critic_report.md (S7) | 9 Major + 15 Nit | M1, M2, M3, M4, M8, M9, M10, M12, M13; Nits (route count, token wording, service account, password, G4, taxonomy, structural ×5, style ×7) |
| intermediate_zoom_out_report.md (S8) | 1 Blocker + 3 Major + 2 Nit | **B1**, M14, M15, M16; Nits (open questions, FCM permission) |
| implementation_readiness_report.md (S9) | 2 Blocker + 10 Major + 11 Nit | **B2, B3**, M17 (+ M15 deps, M10 IDs); Nits (item 1 strings, Create/Modify, item 12, item 14, style ×7) |

## Decisions bound for remediation (coordinator, per review recommendations)

1. **Baseline commit first** (B1) — analyze + test green, then commit everything landed including docs and reports; scripts *code* (`package.json`, `*.mjs`) gets committed per `.gitignore` intent; secrets/state stay ignored (M4).
2. **Route work scoped down** (B2, B3, M5) — bugfix wiring only: 3 admin routes + Products/ProductDetails providers + checkout listener extraction; pure nine-case normalization deferred post-demo.
3. **FCM token saved post-auth in code** (M1) — wire `getTokenAndSave` into login/register success paths; doc states the launch-fallback contract.
4. **Watcher hardening** (M6, M7) — bounded catch-up-on-restart; `probe` verb for liveness; permission-grant line in the scenario.
5. **Rules test** (M15, M14) — authored with documented prerequisites, demoted from hard gate; extended with cross-user order + price/total assertions feeding the §9 security bullets.
6. **Supabase policies scoped by prefix** (M8) — README SQL + accepted-risk note with post-demo expiry.
7. **Doc pass** (M2, M3, M10–M14, M16, M17 + all Nits) — one structured edit wave on the design doc per the consolidated findings; finalize step becomes a state audit (M16).
8. **E2e authoring** (M2) — checkout/orders/admin specs authored per corrected flows; scaffold specs deleted; cart spec locators rewritten for tooltips. Execution on the emulator remains a later phase (needs device + credentials) — not part of this wave.
