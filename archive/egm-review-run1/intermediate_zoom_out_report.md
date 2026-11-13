# Goldfish Review Report — Stage 8: Intermediate Zoom Out

**Target:** `docs/designs/demo-ready-prd-completion.md` (full file, lines 1–339)
**Reviewer:** `egm-zoom-out` (vs `zoom-out-standard`), with the Stage 5/6/7 reports as prior-stage context; focus on additions and mitigations.

## Prioritized Findings (Blockers -> Major -> Nits)

**Blockers: none.** The document passes the prerequisite check: the objective (make the built app demo-ready and PRD §9 demonstrable), the motivation, and the current landed state are all stated plainly, and the solution shape is appropriately minimal (no new runtime layers, strict rules preserved, one trusted sender outside the app).

### Major — The rules test wrongly gates the demo's headline scenario
* **Severity:** Major
* **Affected Scope:** Verification Plan, line 330 ("Rules test: ... must pass before the notification scenario runs"); item 5, lines 291–295; plan intro, line 240.
* **Discrepancy Description:** The plan makes `npm run test:rules` a hard prerequisite of the notification scenario (G3/CUJ 3 — the moment the demo is built around). The dependency is spurious: the scenario's sender is the Admin SDK watcher, which by the document's own design bypasses `firestore.rules` entirely (lines 137, 203), and the client write path is a no-op guard. The test's outcome cannot functionally affect the scenario. What it does affect is the schedule: the test requires the Firebase Emulator Suite plus a Java runtime on this Windows machine — a heavy, unconfirmed user prerequisite — so a tooling download can stall the demo's critical path while protecting nothing.
* **Rationale & Recommendation:** Delete the gating clause and move the rules test after the notification scenario (or to post-demo hygiene). No earlier stage questioned the ordering: Stage 5's related nit proposed *adding* the emulator/Java to Open Questions, implicitly accepting the test's priority. This is a pure simplification — reordering and one deleted sentence.

### Major — G2/CUJ 2 (real image upload) has no owned verification step
* **Severity:** Major
* **Affected Scope:** G2 (line 38), CUJ 2 (lines 68–72), item 9 (line 289), Verification Plan (lines 323–333).
* **Discrepancy Description:** Every pillar has an owned verification except G2. G1 is covered by the catalog/details specs, G3 by the notification scenario, G4 by the spec suite, G5's README clause by item 14. CUJ 2's round-trip (pick image → upload → public URL → renders in catalog) exists only inside the admin spec as "optional-gated: only if the Supabase bucket prerequisite is resolved" — but the bucket is a declared hard prerequisite for the demo itself (Open Question 2), so the gate is meaningless: if the bucket does not exist, the demo fails regardless of what the spec does. If the gate reflects the real unstated constraint (driving the Android system image picker from the e2e runner is flaky), then the plan has *nothing* exercising the app-side upload path, and a core pillar ships to the demo unverified.
* **Rationale & Recommendation:** Pick one in a sentence, not a section: either make the admin spec's upload step unconditional (the bucket is a prerequisite anyway), or name the picker limitation and assign CUJ 2 to a one-line manual rehearsal item in the Verification Plan ("as admin, add one product with a real image; confirm it renders"). Stage 5 caught the analogous ownership gaps for the full-journey pass and the G5 redirect; this is the remaining one, and it sits on a headline pillar.

### Major — Duplicated work inventories are the root cause of the stale-plan findings
* **Severity:** Major
* **Affected Scope:** "Remaining changes" (lines 162–169) vs "Detailed Implementation Plan" items 1–15 (lines 242–321); the screenshot checklist appears a third time in the Verification Plan (line 329), and the run command appears in two forms (G4 line 40 vs CUJ 4 line 83).
* **Discrepancy Description:** The document carries two normative inventories of the same remaining work at different granularity. Stage 5 (Major 1) and Stage 7 (F6) both found the inventories already disagree with the workspace — `tests/cart.e2e.ts` and `tests/favorites.e2e.ts` exist as complete drafts (verified: `tests/` holds auth, catalog, product_details, cart, favorites, probe, example; checkout/orders/admin are the only true gaps), while the doc says "authoring the five missing e2e specs" and marks cart/favorites as (Create). The duplication is the mechanism that allowed the drift and will regenerate it on the next edit; the "eight unspecced vs five missing" arithmetic confusion (comprehension F4) is the same disease.
* **Rationale & Recommendation:** Make one inventory canonical. Keep the Detailed Implementation Plan as the source of truth; reduce "Remaining changes" to a non-normative summary (no counts, no (Create)/(Modify) dispositions) or delete it in favor of a pointer. Define the screenshot checklist once (Verification Plan) and reference it from G4 and item 6. Keep exactly one run-command form (`tests/<spec>.e2e.ts:<line>`, matching the e2e skill's convention) and drop the bare form. This converts three accumulated "re-inventory" fixes into one structural deletion.

### Nit — Cart spec's cross-spec cart handoff is dead on arrival
* **Severity:** Nit
* **Affected Scope:** Item 6, line 274 ("leave one item in cart for the checkout spec's starting state or re-add as needed").
* **Discrepancy Description:** Carts are per-user Firestore documents and each spec uses its own fresh `e2e_<feature>_<stamp>` user, so the checkout spec can never observe the cart spec user's leftover cart. The clause also contradicts the orders spec's own stated principle one item later ("reuse the checkout flow inline rather than depending on another spec's leftovers", line 284).
* **Rationale & Recommendation:** Delete the handoff clause; "re-add as needed" is the only live path anyway.

### Nit — The notification scenario and the admin spec duplicate the same production action
* **Severity:** Nit
* **Affected Scope:** Item 4 (line 167), item 9 (line 289), CUJ 3 (lines 76–78).
* **Discrepancy Description:** Both the admin spec ("change its status, assert the status chip updates") and the notification scenario ("change status as admin, assert push + record + tap") produce an admin status change against a watcher-eligible order on the same emulator. Run separately, that is two demo-prep productions of the same flow.
* **Rationale & Recommendation:** State the reuse explicitly — run the admin spec with the watcher live and observe the notification surfaces during that same status change (the observation is manual; the spec's assertions stay unchanged) — or record one sentence on why they stay separate. This also disposes of Stage 5's "one spec per feature vs notifications" nit with a concrete run instead of more prose.

---

## Fix Arbitration (simplify vs add)

**Cluster: stale plan-of-record inventory (Stage 5 Major 1, Stage 7 F6, comprehension F4).** Resolve by *editing to match the workspace and deleting duplication*: re-baseline to "verify four drafts (catalog, product_details, cart, favorites); author three (checkout, orders, admin); notifications covered by the scenario"; and per my Major 3, collapse to one canonical inventory. For `tests/probe.e2e.ts` and `tests/example.e2e.ts`: delete the files (a repo deletion, one line of doc disposition) — do not add exclusion machinery to the runner config.

**Cluster: M8 route normalization (Stage 5 Major 6, critic N1, comprehension F1's "M8").** Resolve by *deferring, i.e., deleting item 2 from the pre-demo plan* and moving it to post-demo hygiene. The concepts brief committed it only "as time allows"; no spec depends on it; the one concrete failure it could claim (CheckoutCubit empty-uid) is already fixed by the landed guard. Do not "fix" this by adding justification prose — that would be adding text to defend churn. Deferring also dissolves three nits for free (route count "six vs seven", the taxonomy sentence, the M8 decode), and shrinks the doc's framing from "two production-code changes" to one.

**Cluster: order-status chain (Stage 5 Major 2, Stage 7 F2).** Accept the add — two words (`preparing`) in G3 and CUJ 3 plus one sentence acknowledging the intentional superset over PRD §6. This is a genuine correctness gap; the fix is minimal and load-bearing.

**Cluster: foreground-push no-op (Stage 5 nit, Stage 7 F3).** Resolve by *not building anything*: one sentence in Non-Goals ("no user-visible foreground push; the notification center and Firestore streams carry the foreground experience") and restate CUJ 3's Given as app-backgrounded. A snackbar/banner feature here would be YAGNI for demo scope.

**Cluster: admin spec contradiction (Stage 5 Major 3, comprehension F2).** Resolve by *deleting one half*: keep the seeded `admin@sahety.app` path, drop "register a customer, then promote it", and state the account-switch choreography in one sentence using the already-documented restart-after-auth pattern (checkout as the fresh customer → restart → sign in as seeded admin → restart → assert). No new helper scripts, no new machinery.

**Cluster: full-journey pass (Stage 5 Major 4, Stage 7 F8).** Resolve by *rewording the promise, not adding a work item*: line 18 becomes "closing with the notification scenario and the PRD §9 acceptance sweep". A dedicated full-journey spec would duplicate cart/checkout/orders/admin coverage almost line for line — classic YAGNI. If the owner wants the ritual, it is a manual walkthrough of CUJs 1–3, one checklist line, not a spec.

**Cluster: Arabic RTL verification (comprehension F3, Stage 7 F4, related G4/CUJ 4 lines).** Resolve by *subtraction*: delete "Arabic RTL run" from the per-spec automated checklist (it is unautomatable under the doc's own "English-only assertions" rule) and replace with one manual Arabic session — switch emulator locale, walk CUJ 1, capture screenshots against the checklist. Do not add locale-aware spec variants, a second AVD protocol, or a decode of how assertions interact; that path adds a test architecture for one manual pass.

**Cluster: watcher SPOF (Stage 5 inventive Major).** Accept only mitigation (a): one pre-demo health-check line in the Verification Plan (place a throwaway order, advance a status, assert push + record). Reject `watch --replay` (new script functionality whose manual recovery — re-trigger the transition or delete the checkpoint — is already documented in `scripts/README.md` Troubleshooting) and reject the supervised-restart wrapper (orchestration for a demo-day-only gain). Both are over-engineering.

**Cluster: e2e data cleanup (Stage 7 F5).** The proposed `reset.mjs --e2e` purge mode (Auth users, orders, notifications) is real engineering on the eve of a demo — reject it for now. The zoom-out fix is honesty in one line: namespaced e2e leftovers accumulate in the live project by design; add "cancel/delete e2e_ orders from the admin screen the morning of the demo" to the pre-demo checklist. Build the purge mode post-demo only if the volume actually annoys.

**Cluster: bucket anon policies (Stage 7 F1).** Do not build scoped prefix policies pre-demo (new SQL surface, new failure modes right before the demo). Record the accepted risk in the NFR Security bullet with a post-demo tightening note. Two lines, not a security project.

**Cluster: rules test (Stage 5 nit, Stage 7 N/A, my Major 1).** Keep the test itself (it honors the B3 commitment and uses the platform-standard `@firebase/rules-unit-testing`), but *demote its position* rather than promoting its prerequisite into Open Questions. The emulator/Java dependency gets one clause inside item 10, not a fourth Open Question.

**Cluster: Risks & Mitigations section (Stage 7 F11).** The one structural addition I endorse — but keep it to 4–5 bullets (watcher down = missed transitions with no replay; AVD FCM delivery unconfirmed; anon bucket policies; free-tier pause; e2e leftovers), placed with the NFR section, and point at `scripts/README.md`'s demo-day checklist as the operational home instead of duplicating it. A full standardized risks section with subheadings would be ceremony.

**Cluster: attribution, headings, and prose nits (Stage 7 F9, F12, F13, N2–N16; comprehension F5–F14).** Mostly accept as one-word/one-clause edits: fix tenses in The Problem, delete the "Rejected by author" prefixes (the trade-offs stand on their own), promote the two orphan H3s, fix the service-account claim to a verifiable instruction, drop the `products` bucket probe, drop the `**The idea**` labels, gloss "cold-start records without notifying" and "validation-only-when-non-empty" in half a sentence each, align line 156 with the README's actual token-absent behavior. Two deletions worth singling out: delete the opaque milestone IDs (M8/B3/N4/M5) in favor of plain referents — a decode table for four labels is ceremony — and delete the provenance footer / "7 Goldfish lenses" line (process metadata with zero user value). For the third data-flow diagram, prefer deleting it over redrawing it: the verification loop is fully recoverable from the Verification Plan prose.

**Cluster: G5 redirect verification (Stage 5 nit) and checkout spec self-undermining sentence (comprehension F11).** Add one single-case unit test (signed-out `generateRoute(checkoutScreen)` returns LoginScreen) and delete the "also covers the signed-out deep-link guard implicitly" sentence from item 7. The smallest honest resolution of both.

---

## Verdict

The architecture underneath this plan is sound and already minimal — no new runtime layers, a strict rules file preserved by writing notifications from a trusted process outside the app, a scalar token contract, seed-as-reset, and reuse of the existing Cubit/router/helper conventions and the platform-standard rules-testing library; the Alternatives section genuinely examined the real trade-offs, and no reinvention was found. What does not yet hold together is the plan layer, and every remaining defect is fixable by subtraction or one-line moves: re-baseline the work inventory against the workspace under a single canonical list, delete or defer the M8 refactor, delete the rules-test-to-scenario gating, delete the dead cart handoff, and pick a verification owner for G2/CUJ 2. Two structural items are genuinely still missing: a short consolidated risk block (watcher no-replay, AVD FCM uncertainty, anon bucket policies, e2e leftovers) that this document currently outsources entirely to `scripts/README.md`, and an explicit decision on M8 rather than its current silent elevation to the demo's critical path. With those two additions and the deletions above, the document is coherent at the architecture level and safe to execute; none of the accumulated findings require new code, new sections of substance, or new verification architecture.
