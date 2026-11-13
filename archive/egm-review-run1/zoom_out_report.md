# Goldfish Review Report

**Target:** `docs/designs/demo-ready-prd-completion.md` (full file, lines 1–339)
**Stage:** 5 — Initial Zoom Out

## Reviewer Status

| Reviewer | Status |
| --- | --- |
| `egm-zoom-out` | completed (inline — see note) |
| `egm-inventive-catalyst` | completed (inline — see note) |

**Note on execution:** Subagent execution was unavailable in this session — the Stage 5 workflow script compiled cleanly but the workflow runtime could not start it, and this harness exposes no Agent tool. The external delegate CLIs were ruled out by their own contracts (`agy` is not installed; `opencode` is installed but no human-approved model set exists in this repo, and its skill forbids guessing metered models). The synthesizer therefore executed each lens review directly against its persona/standard file (`agents/zoom_out.md`, `resources/document_standards/zoom-out-standard.md`, `agents/inventive_catalyst.md`), reading the full target and all five baseline files. As with the brainstorm stage (recorded in `concepts_brief.md`), finding recall may be lower than a true parallel Goldfish swarm.

**Verification base:** every code-level claim below was checked against the working tree — `lib/main.dart`, `lib/core/routing/app_router.dart`, `lib/core/models/product_model.dart`, `lib/core/helpers/product_localized_text.dart`, `lib/core/helpers/constants.dart`, `lib/features/cart/ui/widgets/cart_item_card.dart`, `lib/features/products/ui/widgets/favorite_heart_button.dart`, `pubspec.yaml`, `tests/*.e2e.ts`, `scripts/` — and against the five baseline files (PRD, `concepts_brief.md`, `scripts/README.md`, `GLOSSARY.md`, `.agents/skills/e2e/SKILL.md`).

**Blockers: none.** The document passes the standard's prerequisite checks: context is sufficient (§0), the pillars trace to named PRD gaps (root-problem focus §1), and no reinvention was found — the single shared resolver helper, Admin SDK scripts, and platform-standard `@firebase/rules-unit-testing` are the right reuse shape (§4). Six Major issues and six Nits follow.

## Prioritized Findings (Blockers -> Major -> Nits)

### Plan of record is stale on the e2e suite it exists to sequence - Severity: Major
* **Reviewer Lens:** `egm-zoom-out`
* **Affected Scope:** `Lines 29-33`, `Lines 162-169` (items 3–6), `Lines 266-274`
* **Discrepancy Description:** The document's "Current state" (line 33) says the remaining work is "authoring the five missing e2e specs", and Remaining changes items 5 and 6 (lines 266–274) mark `tests/favorites.e2e.ts` and `tests/cart.e2e.ts` as **(Create)**. Both files already exist as complete, convention-following specs (`tests/cart.e2e.ts`, 201 lines; `tests/favorites.e2e.ts`, 169 lines, both using the restart-after-auth pattern the document describes). Only `checkout`, `orders`, and `admin` remain to author. Two further files exist and are never mentioned: `tests/probe.e2e.ts` (103 lines, a self-described temporary walk-the-flow probe) and `tests/example.e2e.ts` (7 lines, a scaffold leftover asserting the Android system string `Network & internet`, which fails against this app).
* **Rationale & Recommendation:** This document is the plan of record for the parked verification work; its inventory of what remains is its core function, and an executor following it literally would re-create (i.e., overwrite) 370 lines of working spec code. Re-baseline the "Current state" paragraph, convert items 5–6 to "Verify the drafted spec" like items 3–4, and add a disposition for `probe.e2e.ts` and `example.e2e.ts` (delete, or exclude from any full-suite run) so the suite boundary matches the per-feature promise.

### Order-status contract omits `preparing` and never reconciles PRD §6 - Severity: Major
* **Reviewer Lens:** `egm-zoom-out`
* **Affected Scope:** `Line 39` (G3), `Line 77` (CUJ 3); context `Lines 17`, `289`
* **Discrepancy Description:** G3 enumerates the watcher's coverage as "pending → confirmed → shipped → delivered, plus cancelled" and CUJ 3 as "confirmed → shipped → delivered, or cancelled" — both omit **`preparing`**. The PRD (§4: "pending, confirmed, preparing, shipped, delivered, and cancelled"; §5: admin updates through "confirmed, preparing, shipped, and delivered"), `GLOSSARY.md` (Order Status), and `scripts/README.md` (the five notify-worthy statuses are "confirmed, preparing, shipped, delivered, cancelled") all include it. Separately, PRD §6 scopes customer notifications to confirmed/shipped/delivered, while the watcher deliberately notifies a five-status superset — a divergence the document never acknowledges.
* **Rationale & Recommendation:** The verification phase is planned from these enumerations; orders/admin specs and the notification checklist built from G3 as written would not cover the `preparing` transition that the shipped watcher actually pushes. Fix G3 and CUJ 3 to the full chain (matching GLOSSARY, per AGENTS.md's "use its terms"), and add one line stating that the watcher's superset over PRD §6 is intentional.

### Admin e2e spec contradicts itself and skips its hardest constraint - Severity: Major
* **Reviewer Lens:** `egm-zoom-out`
* **Affected Scope:** `Line 289` (item 9), with `Line 333` (platform limitation)
* **Discrepancy Description:** The admin spec's design first says "Register a customer, then promote it via `npm run admin` semantics", then in the same sentence says the spec "instead uses the seeded `admin@sahety.app`" — the two halves contradict each other. Worse, the spec requires a customer order "created in-spec", which means the spec must switch accounts (customer checkout → admin login) mid-session, under the document's own constraint that "live Firebase auth responses do not reach Dart mid-session" and the restart-after-auth pattern (line 333). No account-switch choreography is specified.
* **Rationale & Recommendation:** Account switching is the one flow no existing spec exercises (`auth` restarts into the same session; checkout/orders specs are single-account), so this is an untested assumption at the heart of the hardest spec. Either state the exact choreography (register + order as customer → restart → sign out → sign in as the seeded admin → restart → assert) or take order creation out of the spec (create the customer order via a script/seed helper) and keep the spec single-account. Resolve the register-then-promote vs seeded-admin contradiction while rewriting the item.

### The promised closing full-journey pass has no plan item - Severity: Major
* **Reviewer Lens:** `egm-zoom-out`
* **Affected Scope:** `Line 18` (overview pillar 4) vs `Lines 162-169` (Remaining changes) and `Lines 323-333` (Verification Plan)
* **Discrepancy Description:** The Overview promises the verification closes with "a notification scenario and a full-journey pass (login → browse → cart → checkout → order → admin status change → notification)", and `concepts_brief.md` staged a "final full-journey pass" as its own step. Neither Remaining changes nor the Verification Plan contains such an item: the last planned steps are the notification scenario (item 4, line 167) and the screenshot checklist + PRD §9 sweep (item 6, line 169).
* **Rationale & Recommendation:** A closing gate named in the overview but absent from the plan will silently not happen. Either add an explicit full-journey verification item (it can be a scripted checklist walking CUJs 1–3 end to end), or state that the pass is constituted by the notification scenario plus the admin spec and say so at line 18 — but do not leave the promise and the plan disjoint.

### Watcher is an unmonitored single point of failure with unrecoverable misses - Severity: Major
* **Reviewer Lens:** `egm-inventive-catalyst`
* **Affected Scope:** `Line 78`, `Lines 127-137` (data flow), `Line 167` (item 4); cf. `scripts/README.md` demo-day checklist
* **Discrepancy Description:** The document presents the checkpoint dedupe purely as a feature ("restarting the watcher does not re-send past transitions", line 78) and accepts a single local process as the trusted sender. The unstated flip side: the checkpoint is at-most-once delivery, so any status transition that occurs while the watcher is down — crash, sleep, closed terminal — is never notified, ever (`scripts/README.md`: "intentionally no history replay"), and the watcher's death is silent. CUJ 3, the demo's headline moment, has an unrecoverable failure mode, and this design document never states that liability or a mitigation beyond a checklist line that lives only in `scripts/README.md`.
* **Rationale & Recommendation:** This is the one unexamined compromise left in the design (the core contradictions — trusted sender vs free tier, bilingual display vs purchase-time snapshot, live-project e2e vs demo-data safety — are already examined and balanced in Alternatives; no other false compromise detected). Minimal inventive resolution, with declared trade-offs: (a) **Beforehand cushioning** — add a pre-demo watcher health check to this document's Verification Plan (place a throwaway order, advance a status, assert push + record), not just the ops README; (b) **Blessing in disguise** — a `watch --replay` verb that backfills missed transitions from order history, with the checkpoint as the duplicate guard (trade-off: replay can re-push if the checkpoint was partially written; keep the idempotent `(orderId, status)` guard); (c) optionally **self-service** — a supervised `npm run watch` wrapper that restarts on exit (trade-off: added orchestration for a demo-day-only gain). Ideal Final Result: a watcher crash between two status changes degrades to "one late push after recovery", never "notification permanently lost".

### M8 route normalization is unjustified pre-demo churn - Severity: Major
* **Reviewer Lens:** `egm-zoom-out`
* **Affected Scope:** `Line 90`, `Line 165` (item 2), `Lines 250-254`; cf. `concepts_brief.md` M8
* **Discrepancy Description:** The only justification recorded for converting nine route cases and moving inline listeners across checkout/orders/admin is "uniform routing removes a mid-demo inconsistency risk" (line 254) — no concrete failure mode is named, no e2e spec depends on it, and the concepts brief committed M8 only "as time allows". The document's own altitude claim (line 90: "every remaining change is either configuration, a script already in place, or test authoring — with two production-code changes") elevates a pure refactor to a committed change on the demo's critical path.
* **Rationale & Recommendation:** Rewriting the routing table right before the demo it is meant to protect adds regression surface (routing touches every screen) for a consistency benefit that is invisible to the audience. Either defer M8 to post-demo hygiene, or record the specific mid-demo failure it prevents (e.g., an actual intermittent breakage observed from the bare-screen pattern) — an assertion without a named failure does not carry a pre-demo production change.

### Route arithmetic off by one in M8's framing - Severity: Nit
* **Reviewer Lens:** `egm-zoom-out`
* **Affected Scope:** `Lines 165`, `253`
* **Discrepancy Description:** "Convert the nine bare-screen route cases to the getIt `BlocProvider` pattern the other six already use" — verified against `app_router.dart`: nine bare cases is correct, but **seven** cases already use the pattern (login, register, forgotPassword, profile, checkout, myOrders, orderDetails — eight `BlocProvider` occurrences because checkout has two).
* **Rationale & Recommendation:** Harmless to the change itself, but the plan's arithmetic should match the file it governs; fix "six" to "seven" so the executor's before/after picture is exact.

### G5's signed-out deep-link redirect has no verification step - Severity: Nit
* **Reviewer Lens:** `egm-zoom-out`
* **Affected Scope:** `Line 41` (G5), `Line 100`, `Line 279`
* **Discrepancy Description:** G5 commits to "signed-out checkout deep links redirect to login", but the checkout spec explicitly disclaims coverage ("the guard is unit-level", line 279), no unit test file appears in Target Files, and the Verification Plan has no related bullet. The landed guard exists (`app_router.dart:94-101`, verified), yet nothing in the plan ever exercises it.
* **Rationale & Recommendation:** A goal with zero planned verification is a claim, not a plan item. Add a one-case unit/widget test to Target Files (signed-out `generateRoute(Routes.checkoutScreen)` returns LoginScreen), or drop the G5 clause.

### Rules-test prerequisite missing from Open Questions - Severity: Nit
* **Reviewer Lens:** `egm-zoom-out`
* **Affected Scope:** `Lines 52-56`, `Lines 291-295`, `Line 330`
* **Discrepancy Description:** `npm run test:rules` requires the Firebase Emulator Suite, which requires a Java runtime on this Windows machine — a user-supplied prerequisite exactly like the service account, the Supabase bucket, and the AVD image, all of which Open Questions lists. The emulator/Java dependency is nowhere mentioned.
* **Rationale & Recommendation:** The document's own pattern is to surface every blocking user action in Open Questions; add the emulator (and Java) as a fourth prerequisite so the rules-test step does not stall on demo-prep day.

### "One e2e spec per feature" vs notifications coverage model - Severity: Nit
* **Reviewer Lens:** `egm-zoom-out`
* **Affected Scope:** `Line 18`, `Line 29`, `Line 167`, `Line 331`
* **Discrepancy Description:** The Overview promises "one e2e spec per feature" and line 29 counts notifications among the features that "had none", but the plan never authors a notifications spec: item 4 is a watcher scenario and line 331 allows placing the order "in-spec or manually".
* **Rationale & Recommendation:** State the coverage model explicitly — notifications is verified by the scripted scenario rather than a `tests/` spec — or add a minimal `notifications.e2e.ts` (assert the in-app record appears and tap-to-details works; push delivery itself stays manual per the AVD caveat). Vague coverage promises are what the final PRD §9 sweep then silently drops.

### Lead the demo with the guaranteed notification surface, not the push - Severity: Nit
* **Reviewer Lens:** `egm-inventive-catalyst`
* **Affected Scope:** `Line 56`, `Lines 76-78` (CUJ 3), `Line 167`
* **Discrepancy Description:** Push delivery on the Google APIs AVD is itself listed as unconfirmed (line 56), yet CUJ 3 and the notification scenario lead with the push as the visible moment. The in-app `notifications/{id}` record — written by the watcher independently of FCM delivery — is the dependable path.
* **Rationale & Recommendation:** **Beforehand cushioning** at presentation level: script CUJ 3's demo beats so the notification center is the primary proof and the system-tray push the bonus. Secondary trade-off: none material (ordering only); if the push fails live, the demo moment survives.

### State the compensating foreground UX for the FCM no-op - Severity: Nit
* **Reviewer Lens:** `egm-inventive-catalyst`
* **Affected Scope:** `Line 99`, `Lines 133-134`
* **Discrepancy Description:** "Foreground messages no-op" reads, against PRD §6 ("Handle notifications while the app is in the foreground, background, or terminated"), like an unmet requirement. The compensating mechanism — the in-app notification record plus Firestore-live order screens — exists but is never connected to that PRD line in the document.
* **Rationale & Recommendation:** One sentence (foreground experience is delivered by the Firestore streams and the notification center; FCM's foreground banner is intentionally unused) closes the apparent PRD gap for any reader auditing compliance. Trade-off declared: no real-time in-app banner while foregrounded — accepted.

---

*Aggregated and deduplicated by the EGM Synthesizer. Reviewer lens reports were executed inline against their personas; no overlapping findings required cross-lens merging (6 Major: 5 zoom-out, 1 inventive-catalyst; 6 Nit: 4 zoom-out, 2 inventive-catalyst).*
