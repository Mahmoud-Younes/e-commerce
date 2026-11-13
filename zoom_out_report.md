# Zoom Out Report — Stage 5 (Initial Zoom Out)

**Target:** `docs/designs/demo-ready-prd-completion.md` (full file, lines 1–339)
**Reviewers:** `egm-zoom-out` (completed), `egm-inventive-catalyst` (completed)

--------------------------------------------------------------------------------

# Reviewer 1: egm-zoom-out

**Verdict: PASS with 3 Major findings.** The design is high-altitude, root-cause-driven, and disciplined about YAGNI. No Blockers. Three Majors concern plan-of-record accuracy and one scoped misjudgment; all are one-sentence or one-reorder fixes.

## Context sufficiency (§0)

PASS — no context request needed. The doc is self-contained for a fresh reader: objective (PRD §9 demonstrable in a live demo), motivation, file-level root-cause evidence, explicit non-goals, open questions gated on user actions, and an Additional Resources list that resolves every reference checked.

## Findings

### 🟡 Major 1 — Remaining-work inventory is stale: two "(Create)" specs already exist as full drafts

* **Affected Scope**: "Current state" (line 33), "Remaining changes" items 3–6 (lines 166, 267–276)
* **Discrepancy**: The doc says the remaining work is "authoring the five missing e2e specs" and lists `./tests/favorites.e2e.ts` (item 5) and `./tests/cart.e2e.ts` (item 6) as **(Create)**. Both already exist on disk as substantive drafts — `tests/favorites.e2e.ts` (169 lines) and `tests/cart.e2e.ts` (201 lines), each with full header documentation of flow, the restart-after-auth limitation, and isolation strategy. Only `checkout.e2e.ts`, `orders.e2e.ts`, and `admin.e2e.ts` are genuinely missing. Additionally, `tests/probe.e2e.ts` and `tests/example.e2e.ts` exist but are unmentioned anywhere in the doc.
* **Rationale & Recommendation**: The doc's entire remaining scope *is* the verification phase, so an inaccurate inventory of what is drafted vs. missing is the one place state accuracy matters most. An executor told to "Create" favorites.e2e.ts will collide with 169 existing lines and must improvise reconciliation. Reclassify items 5–6 to the same "(Modify — verify the drafted spec)" treatment already used for catalog and product_details (whose on-disk line counts, 176 and 158, match the doc's "~170-line" and "~158-line" claims exactly). Also state a keep/delete decision for `probe.e2e.ts` and `example.e2e.ts` so the spec suite's final shape is decided in the plan, not by the executor's mood.

### 🟡 Major 2 — `scripts/` is repeatedly described as "gitignored"; it is untracked, and the repo's .gitignore says the code is meant to be tracked

* **Affected Scope**: "Landed components" (line 101: "gitignored `scripts/`"), NFR Security (lines 215–217: "local/untracked"), Detailed plan items 10–11 (lines 293, 299: "gitignored ops-scripts directory")
* **Discrepancy**: Verified against the working tree: `git ls-files scripts/` is empty (nothing committed) and `git status` shows `?? scripts/`, but `git check-ignore` confirms `scripts/seed.mjs` and friends match **no** ignore rule — only `scripts/serviceAccount*.json`, `scripts/.watch-checkpoint.json`, `scripts/.env*`, and `scripts/node_modules/` are ignored. The root `.gitignore` even carries `!scripts/package.json` with the comment: "Code (package.json, *.mjs) is tracked; secrets, deps and state are not." The doc's framing (a permanently-gitignored local-only directory, mirroring the PRD/tests convention) contradicts the ignore file's stated intent for the same directory.
* **Rationale & Recommendation**: This is not a security hole — the privilege-bearing artifact (`serviceAccount*.json`) is correctly ignored, and the NFR paragraph is right about that. But a plan of record that mischaracterizes tracking status in three places, inside the section that governs commit hygiene, invites two opposite executor mistakes: committing secrets thinking "everything here is tracked anyway," or treating the `.mjs` tooling as disposable when the .gitignore signals it should be committed. One sentence fixes it: "scripts/ code is untracked-but-trackable (the .gitignore deliberately keeps it committable); only `serviceAccount*.json`, `.watch-checkpoint.json`, `.env*`, and `node_modules/` are ignored" — plus an explicit decision on whether the `.mjs` files will ever be committed.

### 🟡 Major 3 — M8 route normalization is scope-elevated beyond the root problem and sequenced ahead of the verification it exists to support

* **Affected Scope**: "Remaining changes" item 2 (lines 165–166, 250–254); "Technical Plan" preamble (line 90); sequencing in the Verification Plan (line 325: "changes 1–2")
* **Discrepancy**: The root problem is demo-readiness of PRD §9. Item 1 (tooltips) is load-bearing — without it the cart spec cannot target controls, and the codebase confirms the gap (`cart_item_card.dart` has ValueKeys only) and the convention it follows (`favorite_heart_button.dart` line 93 already uses tooltips). Item 2 (convert 9 bare route cases to the getIt `BlocProvider` pattern, move checkout/orders/admin listeners into `*_bloc_listener.dart` files) is justified only by consistency ("uniform routing removes a mid-demo inconsistency risk") — functionally it is a no-op refactor. Notably, the predecessor brief (`concepts_brief.md` M8) scoped it as *opportunistic*: "folded into whichever step touches each file… as time allows." The design instead elevates it to one of exactly **two** production-code changes and orders it **before** any spec authoring, meaning the largest remaining production diff lands against an app that currently passes 256 tests and stages 1–7 — the highest-regression-risk change, at the lowest-regression-tolerance moment, with zero demo-visible value.
* **Rationale & Recommendation**: Classic scope creep under a demo deadline: the empty-uid motivation from M8 (the one part with demo-failure potential) is already fixed by the landed checkout guard (`app_router.dart:94–101`), leaving pure consistency. YAGNI says ship the demo on the verified app. Either (a) defer M8 to post-demo, (b) invert the order — author and run all specs against the as-landed app, do the PRD §9 sweep, and treat M8 as a final hygiene pass gated on a green suite — or (c) keep it but explicitly demote it below the notification scenario in priority with a stated rollback point. The doc's own gates (`flutter analyze` + `flutter test` + APK rebuild) are good but don't address the ordering risk.

### 🟢 Nit 4 — Status enumeration omits `preparing`

* **Affected Scope**: G3 (line 39: "pending → confirmed → shipped → delivered, plus cancelled"); CUJ 3 (line 77)
* **Discrepancy**: The landed watcher and `scripts/README.md` cover **five** notify-worthy statuses — `confirmed, preparing, shipped, delivered, cancelled` (verified in `watch-orders.mjs:40–44`) — and PRD §4/§5 list `preparing`. The design's parenthetical drops it in both G3 and CUJ 3.
* **Rationale & Recommendation**: Wording-only; the shipped code is correct and broader than the doc claims. Align the enumeration with the frozen watcher contract so the verification scenario doesn't under-test `preparing`.

### 🟢 Nit 5 — Route-count arithmetic off by one

* **Affected Scope**: Item 2 (lines 165, 253: "the other six already use")
* **Discrepancy**: Seven route cases already use the getIt `BlocProvider` pattern (login, register, forgotPassword, profile, checkout, myOrders, orderDetails); nine are bare — that count is correct.
* **Rationale & Recommendation**: Trivial factual error; correct to "seven" so the migration checklist is countable.

### 🟢 Nit 6 — Admin spec's account story contradicts itself mid-sentence

* **Affected Scope**: Item 9 (line 289)
* **Discrepancy**: "Register a customer, then promote it via `npm run admin` semantics (bootstrap script targets the demo admin; the spec instead uses the seeded `admin@sahety.app`…)" — the parenthetical retracts the promotion idea in the same bullet.
* **Rationale & Recommendation**: State it once cleanly: register a throwaway customer in-spec (creates the order under test), then log in as the bootstrap-seeded `admin@sahety.app` for the status change. No behavior change, just removes a decision the executor would otherwise have to guess at.

### 🟢 Nit 7 — G4 overpromises "each feature has a deterministic spec"

* **Affected Scope**: G4 (line 40) vs. Remaining changes item 4 (line 167)
* **Discrepancy**: Notifications — a feature — get a manual scripted scenario, not a spec (the right call: push delivery to the system tray is not deterministically assertable by a UI driver).
* **Rationale & Recommendation**: Reword G4 to "every feature except notifications, which is verified by an explicit watcher-driven scenario" so the acceptance bar matches the plan.

## Sections that pass (briefly)

* **Root problem focus (§1)** — Strong. Each problem statement names the actual root cause, verified in code: no localization plumbing (`e_commerce_app.dart` now has delegates + `supportedLocales [en, ar]`), no `Supabase.initialize` (now in `main.dart` with an `isConfigured` guard), dead FCM receiver (now wired: background handler before `runApp`, `attachNavigator` + `initialize()` after), no trusted sender (watcher writes server-side; `firestore.rules:115–118` confirmed admin-only create — the "no rules changes" claim holds).
* **Simplicity / YAGNI (§2)** — The Alternatives section is genuinely evidence-based, not theater: legacy FCM HTTP API shutdown (June 2024) kills the asroo_store copy; Blaze/payment-card constraint kills Cloud Functions; the rules-relaxation rejection protects a real forged-data hole; the `categories` collection rejection matches the code (nothing reads one — verified via `kCategoryArLabels` client-side derivation). Non-Goals and Future Improvements park exactly the right speculation (token maps, ARB localization, per-device push language).
* **Anti-weeds (§3)** — The Technical Plan stays at components/data-flows/contracts altitude; the detailed plan's descent into per-file targets and on-screen strings is appropriate for an executor-facing plan of record, not weeds.
* **Leverage existing (§4)** — Verified reuse throughout: resolver helper matches `product_localized_text.dart` exactly as described; bilingual search is in `product_repository_impl.dart:70–74` and `products_cubit.dart`; scalar token contract matches `fcm_service.dart:176–177` with no `fcmTokens` map left in `lib/`; bucket name agrees across `constants.dart:49` and `scripts/config.mjs:16`; the e2e Verification Plan's numbers (workers 1, timeout 420s, assertionTimeout 15s, bundleId) match `e2e.config.ts`; restart-after-auth and one-fresh-user-per-spec match the existing `auth.e2e.ts` / repo e2e conventions. The landed-components list is accurate in every particular checked — the drift is confined to Findings 1–2 above.

--------------------------------------------------------------------------------

# Reviewer 2: egm-inventive-catalyst

**Step 0 verdict:** Genuine false compromises exist (2 Major, 6 Nit). The core architectural resolution is sound and non-compromising; the findings below target the residual seams where the design accepted a reliability or security gap as an operational law.

## Findings

### 🟡 Major 1 — Watcher downtime silently and permanently loses notifications; "no history replay" is accepted as an operational law

* **Affected scope:** CUJ 3 (lines 74–78), "Landed components → `watch-orders.mjs`" (line 101), Verification Plan (line 331: only the *no-resend* direction is asserted), corroborated by `scripts/README.md` demo-day checklist ("If it is started after the status change, that transition is missed — there is intentionally no history replay").
* **False compromise:** The design resolves the "trusted sender vs free tier" contradiction inventively (local Admin SDK watcher), but then accepts that any status change occurring while the watcher is down is lost forever. This is presented as intentional simplicity, yet the data needed for recovery already exists: `scripts/.watch-checkpoint.json` stores `orderId -> lastNotifiedStatus`, so on cold start any order whose current status differs from its checkpoint entry was transitioned during downtime and could be notified exactly once. The design specifies dedupe-on-restart but is silent on catch-up-on-restart — the executor has no plan-of-record basis to demand or reject it.
* **Proposed resolution (Beforehand Cushioning + Blessing in Disguise):** At cold start, compare each tracked order's live status against its checkpoint entry; a mismatch is a missed transition → notify once, then update the checkpoint. The restart stops being pure loss and becomes the recovery trigger.
* **Secondary liabilities:** Risk of late/duplicate notifications if the checkpoint is hand-edited or corrupted; catch-up must be bounded to orders already present in the checkpoint (never replay pre-checkpoint history); the simple script gains one recovery branch that itself needs a test.

### 🟡 Major 2 — The watcher has no liveness signal; the demo's most fragile dependency is invisible from inside the app

* **Affected scope:** G3 (line 39), "Data flows → Notifications" (lines 121–138), NFR Security section (line 215), demo-day checklist dependency.
* **False compromise:** The entire G3/CUJ 3 surface depends on a manually started local process that, by design, calls `process.exit(1)` on any snapshot stream error (`scripts/watch-orders.mjs:241-244`). If it dies mid-demo or was never started, the app shows no symptom — pushes simply never arrive and the notification center stays empty. The mitigation is a human checklist item ("start the watcher before the demo"); reliability has been converted into a procedure, which is the definition of an unexamined bottleneck for the exact moment the design exists to protect.
* **Proposed resolution (Self-Service, demo-scaled):** Have the watcher write a periodic heartbeat (Admin SDK bypasses rules) and surface "watcher live/stale" in the notifications screen; or, with zero app code, add a `probe` verb to the ops scripts that fakes one status transition on a scratch order so the demo-day checklist becomes "run probe → see push" instead of "remember to start a process". Minimum viable version: rehearse the failure in the verification plan (kill the watcher mid-transition, observe the silence) so the failure mode is known before the stage, not on it.
* **Secondary liabilities:** A heartbeat loop adds writes and one more rules-bypass surface; flawed health-check logic produces its own false alarms (the documented Self-Service trade-off); a probe order adds cleanup surface to `reset.mjs`.

### 🟢 Nit 3 — Unscoped anonymous write access on Supabase contradicts the design's own security posture

* **Affected scope:** Open Questions (line 55), Remaining change 13 (lines 308–312), NFR (line 215), `scripts/README.md` §2 SQL.
* **False compromise:** The design is meticulous about Firestore strictness (rules test, B3 no-regression guarantee) yet accepts anon INSERT/UPDATE/DELETE on the entire `product-images` bucket, scoped only by `bucket_id`. Since the publishable key is public by design, anyone can write arbitrary objects to the bucket. One subsystem is locked down; its sibling is wide open — an unexamined asymmetry, not a stated trade-off.
* **Proposed resolution:** Scope the policies by object-name prefix, matching the two real write paths: `name like 'seed/%'` (seed.mjs) and `name like 'products/%'` (admin uploader, `admin_image_uploader.dart:64`).
* **Secondary liabilities:** Any future upload-path change must update policy SQL in two places (coordination overhead); marginally more policy surface to maintain.

### 🟢 Nit 4 — Plan-of-record token contract drifts from the landed watcher behavior

* **Affected scope:** "Contracts the remaining work depends on" (line 156) vs `scripts/watch-orders.mjs:83-98,149-155` and `scripts/README.md:98-102`.
* **Discrepancy:** The design declares "the legacy `fcmTokens` map is removed from the model and register path" and "The watcher skips a user silently when the token is absent." Landed reality: the watcher still tolerates the legacy map shape as a fallback, and a missing token does not skip the user — the push is skipped (logged) while the in-app record is still written. The code behavior is good Beforehand Cushioning; the plan-of-record misdescribes it, and this document is what the executor verifies against.
* **Rationale & recommendation:** Doc-only fix — restate the contract as "scalar token primary, legacy map tolerated for reads; missing token → push skipped, record still written." No operational cost.

### 🟢 Nit 5 — Implicit fixture contract: e2e specs depend on seeded product names that only `seed.mjs` produces

* **Affected scope:** "Contracts the remaining work depends on" (lines 154–160), items 3–6 (lines 256–274), item 11 (lines 297–300).
* **Discrepancy:** The frozen seed contract fixes document *shape* and IDs (`seed_<slug>`), but the drafted specs hardcode seeded *content* (searching `'Headphones'`, asserting seeded names). That content contract is undeclared — a rename inside `seed.mjs` breaks every spec with no doc-level signal. The segmentation boundary between fixtures and seed data lacks a declared interface.
* **Rationale & recommendation:** Declare the fixture product names used by specs as part of the frozen seed contract (one line in the Contracts section and `scripts/README.md`). Liability: the demo catalog's wording becomes deliberately frozen — acceptable at demo scale.

### 🟢 Nit 6 — Spec inventory drift: two of the five "missing" specs already exist; plus a route-count misstatement

* **Affected scope:** "Current state" (line 33: "authoring the five missing e2e specs"), items 5–6 (lines 266–274: "(Create)"); also line 90/item 2 ("the other six already use" the BlocProvider pattern).
* **Discrepancy:** `tests/favorites.e2e.ts` (169 lines) and `tests/cart.e2e.ts` (201 lines) already exist as full drafts whose headers mirror the design's known-environment limitation and cart locator gap — yet items 5–6 still say Create while items 3–4 correctly say "Modify — verify the drafted spec." Separately, the router currently wraps seven cases (login, register, forgotPassword, profile, checkout, myOrders, orderDetails), not six. Since this document is the plan of record, the executor should not re-author from scratch.
* **Rationale & recommendation:** Reclassify items 5–6 as verify-the-draft; correct the count. Doc-only.

### 🟢 Nit 7 — Route normalization (M8) sits on the demo critical path without a declared cut-line

* **Affected scope:** Remaining change 2 (lines 250–254), Verification Plan (lines 325–327).
* **False compromise:** M8 trades demo stability for convention integrity — it touches nine route cases plus listener extraction across three features immediately before the entire verification suite runs, with indirect demo value. The ordering (production changes first, then specs) is correct, but the concepts brief's original "as time allows" became mandatory at finalization with no fallback if regressions appear late.
* **Proposed resolution:** Keep M8 but declare the cut order: route-case conversion is mandatory; the orders/admin listener extractions are the first to drop if the re-run budget slips (only checkout's inline-listener move has demo-path relevance via CUJ 3). Liability: AGENTS.md's listener convention stays partially honored — an explicitly accepted debt rather than a silent one.

### 🟢 Nit 8 — FCM-on-emulator feasibility is the riskiest unverified assumption yet is sequenced last

* **Affected scope:** Open Questions (line 56), Verification Plan ordering (lines 328–331).
* **False compromise:** The plan parks the "does FCM deliver on a Google APIs AVD at all" question behind all spec authoring. CUJ 3's feasibility hinges on it, and the fallback (physical device) changes the demo setup. The probe costs minutes once the service account lands.
* **Proposed resolution (Preliminary Action):** Run the delivery probe immediately after the service-account gate clears — before, not after, spec authoring — so a physical-device fallback is known while there is still schedule room. Liability: essentially none; one token registration happens earlier than strictly needed.

## What holds up well

* **The central inventive move is genuinely non-compromising.** "Trusted sender vs free tier" is dissolved by relocating the trusted sender outside the app (local Admin SDK watcher) rather than paying (Alt A) or loosening rules (Alt E). Verified in code: `firestore.rules:115-118` still restricts notification writes to admins, and the client write path is gone (`lib/core/repositories/notification_repository.dart` is read-only; the FCM foreground handler is a documented no-op). Code and rules now agree — the brainstorm's B3 contradiction is fully closed.
* **Alternative B's rejection is evidence-based**, not preference-based (legacy FCM HTTP API shutdown, June 2024) — the strongest kind of alternative analysis.
* **The consciously examined compromises are real compromises, not false ones.** Scalar token vs map (Alt F, with a declared future path) and combined bilingual push text (Non-Goal line 50, Future Improvements line 233) are bounded, documented decisions with revisit triggers — explicitly not flagged.
* **The design document is unusually verifiable.** Nearly every "landed" claim checked held exactly: localization delegates and `supportedLocales [en, ar]` (`lib/e_commerce_app.dart:43-48`), guarded `Supabase.initialize` (`lib/main.dart:39-44`), FCM wiring order (`lib/main.dart:32,54-55`), checkout signed-out guard (`app_router.dart:94-100`), bilingual search (`product_repository_impl.dart:70-74`), purchase-time resolved-name snapshot (`add_to_cart_button.dart:71`), missing cart tooltips (`cart_item_card.dart` — the gap is real), and `Collections.categories` declared but unread (validating Alternative D's YAGNI rejection).
* **The signed-out checkout guard converts a silent failure into an explicit redirect** — a textbook Blessing-in-Disguise resolution of M8's empty-uid intermittent failure.
* **The rules test (item 10)** restores the B3 no-regression commitment the draft had dropped — the right kind of beforehand cushioning.

**Bottom line:** the design's contradictions are resolved at the architecture level; the two Major findings are both on the notification critical path (recovery-on-restart, liveness) and are cheap, free-tier-compatible closures the plan of record should absorb before the verification phase starts.

--------------------------------------------------------------------------------

# Stage 5 Severity Summary

| Reviewer | 🔴 Blocker | 🟡 Major | 🟢 Nit |
| --- | --- | --- | --- |
| egm-zoom-out | 0 | 3 | 4 |
| egm-inventive-catalyst | 0 | 2 | 6 |
| **Total (raw)** | **0** | **5** | **10** |
