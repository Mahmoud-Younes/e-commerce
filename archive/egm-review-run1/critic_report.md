# Goldfish Review Report

**Target:** `docs/designs/demo-ready-prd-completion.md` (FeatureRange, lines 1–237)
**Stage:** 7 — Critic Review (feature-spec gates)
**Reviewers:** `egm-design` (vs `feature-spec-standard`), `egm-structural` (vs `feature-spec-standard`), `egm-style` (no standard) — each dispatched in its own fresh context.

## Reviewer Status

| Reviewer | Status |
| --- | --- |
| `egm-design` | completed |
| `egm-structural` | completed |
| `egm-style` | completed |

**Deduplication note:** overlapping findings across reviewers are merged into one entry; merged sources are listed per finding. Stable IDs use `<reviewer>-<round>-<n>` with the primary source first.

## Prioritized Findings (Blockers -> Major -> Nits)

**Blockers: none.**

### F1 (design-1) - Severity: Major — Public-bucket anon write/delete policies absent from the security risk surface
* **Reviewer Lens:** `egm-design` (merged: none)
* **Affected Scope:** Lines 55 (Open Questions), 215 (NFR: Security & Privacy), 190–192 (Alternative C)
* **Discrepancy Description:** The design prescribes storage policies "INSERT for uploads; UPDATE/DELETE so re-seeding can overwrite" on a public bucket, and `scripts/README.md` implements these as `to anon, authenticated` with only a `bucket_id` check — anonymous world-write and world-delete on the entire bucket. The Security NFR section (line 215) enumerates service-account secrecy, FCM credentials, the publishable key, and the admin password, but never mentions this hole. Since the publishable key ships inside the APK (`constants.dart`), anyone can overwrite or delete every product image (catalog defacement) or fill the free-tier storage quota — including via the very admin-upload path the demo showcases.
* **Rationale & Recommendation:** The standard requires security implications of the design's own prescriptions to be identified and mitigated; this one is actively prescribed yet absent from the risk surface. Either scope the policies (restrict INSERT/UPDATE/DELETE to a `seed/` name prefix and use a distinct path for admin uploads), move destructive operations to the service-role key inside the scripts only, or explicitly record "open anon write policies" as an accepted demo risk in the NFR section with a post-demo cleanup step.

### F2 (design-2 + style-2) - Severity: Major — Order-status chain omits `preparing`, contradicting the PRD and the landed watcher
* **Reviewer Lens:** `egm-design`, `egm-style`
* **Affected Scope:** Line 39 (G3), line 77 (CUJ 3)
* **Discrepancy Description:** G3 and CUJ 3 describe the status chain as "pending → confirmed → shipped → delivered, plus cancelled", omitting `preparing`. The PRD (§4 suggested statuses, §5 "Update order status from pending to confirmed, preparing, shipped, and delivered") includes it, the implementation includes it (`scripts/watch-orders.mjs:41` has a bilingual push body for `preparing`; `scripts/README.md` lists it among "the five notify-worthy statuses"), and the design claims G3 covers "every order-status change".
* **Rationale & Recommendation:** The spec contradicts both its requirements source of truth and its own landed implementation. If verification follows the doc's chain, the `preparing` transition is never exercised despite the PRD §9 sweep at line 169 claiming full acceptance coverage. Add `preparing` to the G3 chain and to the CUJ 3 admin-advance step.

### F3 (design-3) - Severity: Major — Foreground-push no-op silently breaks the flagship CUJ
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** Line 99 (FCM receiver: "foreground messages no-op"), line 78 (CUJ 3 "Then")
* **Discrepancy Description:** The design makes foreground FCM messages a deliberate no-op, but PRD §6 explicitly requires handling notifications "while the app is in the foreground, background, or terminated", and foreground is never listed as a non-goal (lines 43–50). Worse, CUJ 3 asserts "The customer receives a bilingual push" — on Android an FCM `notification` payload is not displayed in the tray while the app is foregrounded, so following CUJ 3 with the customer app open (the natural demo posture) shows nothing.
* **Rationale & Recommendation:** Either surface foreground messages minimally (snackbar/dialog, or rely on the notifications screen's Firestore stream and document that), or add "no user-visible foreground push" to Non-Goals and restate CUJ 3's Given as "customer app backgrounded/terminated". As written, the flagship demo journey (G3/CUJ 3) has an unstated precondition that silently fails on stage.

### F4 (design-4) - Severity: Major — Arabic RTL verification pass has no defined mechanism
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** Lines 40 (G4), 84 (CUJ 4), 166 (Remaining change 3: "English-only assertions"), 169 (Remaining change 6)
* **Discrepancy Description:** G4/CUJ 4/remaining change 6 require screenshot review of "English run, Arabic RTL run, empty and error states" per feature, but the design never defines the mechanism for the Arabic pass: how the device locale is switched (adb, second AVD, manual), whether the specs are re-run or the pass is a manual navigation session, and which assertions hold. Line 166 pins specs to "English-only assertions", which cannot pass against Arabic product names on an `ar`-locale device — so "Every spec passes deterministically" (CUJ 4) and "Arabic RTL run" are mutually incompatible as currently specified.
* **Rationale & Recommendation:** The standard requires the spec to be executable by a fresh engineer without ambiguity. Define the Arabic pass concretely: either a separate manual screenshot protocol (no assertions, checklist-only) or locale-aware spec variants, and reconcile CUJ 4's determinism claim with it.

### F5 (design-5) - Severity: Major — No cleanup contract for `e2e_` test data; live project accumulates leftovers
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** Lines 40 (G4), 84 (CUJ 4), 159 (seed/reset contract); cross-ref `scripts/README.md` reset scope
* **Discrepancy Description:** G4 says test data is namespaced with an `e2e_` prefix and "re-seeding resets the demo dataset", and CUJ 4 ends with "re-seeding restores the demo dataset afterwards". But `reset.mjs` deletes only `seed_`-prefixed product documents; nothing deletes e2e-created Auth users, carts, favorites, orders, or notification records. Each spec "uses its own fresh `e2e_<feature>_<stamp>@shop.test` user" (line 83), so leftovers accumulate monotonically in the live project and appear in the admin dashboard's incoming-orders view during the demo. The predecessor brief (`concepts_brief.md` M5) explicitly required per-spec teardown; this design dropped that language.
* **Rationale & Recommendation:** Add a cleanup contract: either extend `reset.mjs` with an `--e2e` mode that deletes `e2e_`-namespaced data (orders whose items reference `e2e_` users, notification docs by userId, Auth users via Admin SDK) or require each spec to tear down in `afterAll`. Otherwise the "demo dataset" the doc promises to restore is permanently polluted.

### F6 (design-6 + style-4 + style-5) - Severity: Major — Plan-of-record inventory is stale: two "missing" specs already exist, and the 8-vs-5 arithmetic never reconciles at point of use
* **Reviewer Lens:** `egm-design`, `egm-style`
* **Affected Scope:** Line 29 ("only `auth` had a spec; eight features had none"), line 33 ("the five missing e2e specs"), line 166 (Remaining change 3)
* **Discrepancy Description:** The plan of record states only `catalog.e2e.ts` and `product_details.e2e.ts` are drafted and instructs authoring `favorites.e2e.ts`, `cart.e2e.ts`, `checkout.e2e.ts`, `orders.e2e.ts`, and `admin.e2e.ts`. The workspace already contains complete drafted specs for `tests/cart.e2e.ts` (201 lines, deterministic flow with isolation notes) and `tests/favorites.e2e.ts` (169 lines), so only checkout, orders, and admin are actually missing — following the doc literally would discard or duplicate two existing drafts. Separately, line 29 lists eight unspecced features while line 33 says "five missing"; the mapping (two already drafted → verify; notifications covered by the scenario, not a spec) exists only inside Remaining change 3/4 and is never stated where the numbers appear, so the reader hits an apparent 8-vs-5 mismatch first.
* **Rationale & Recommendation:** The document claims to be "the plan of record" for exactly this verification phase (line 33), so its inventory must match the workspace and reconcile at point of use. Re-inventory remaining change 3 — verify four drafts (catalog, product_details, cart, favorites), author three (checkout, orders, admin) — and add one clause at line 33: "five specs to author; catalog and product details exist as drafts to verify; notifications is covered by the scenario (item 4), not a spec."

### F7 (design-7) - Severity: Major — `scripts/` framing is wrong: code is tracked, rollback claim is false, and PRD §9 submission needs it committed
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** Line 101 ("gitignored `scripts/`"), line 217 (Rollout & Rollback: "all new tooling is local/untracked... rollback is `git checkout`")
* **Discrepancy Description:** The doc twice describes `scripts/` as gitignored/local-only tooling. The repo's `.gitignore` deliberately tracks the scripts' code: only `scripts/node_modules/`, `scripts/serviceAccount*.json`, `scripts/.env*`, and `scripts/.watch-checkpoint.json` are ignored, with an explicit `!scripts/package.json` negation and the comment "Code (package.json, *.mjs) is tracked". Currently the directory is merely untracked (`git ls-files scripts/` is empty), so "git checkout of the touched files" is meaningless for the ops tooling — there is no committed history to roll back to.
* **Rationale & Recommendation:** The misstatement matters because (a) the rollback NFR is wrong for the tooling it describes, and (b) PRD §9 requires submitting organized source with a README explaining setup — the seed/watch/reset scripts and their README must be committed for that criterion, contradicting the "local/untracked" framing. Correct lines 101/217 to: secrets and state are gitignored, scripts code is committed; and add "commit `scripts/` code" to the remaining work so PRD §9's submission criterion is actually met.

### F8 (style-3) - Severity: Major — Overview promises a "full-journey pass" that no work item owns
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** Overview item 4, line 18 vs "Remaining changes", lines 162–169
* **Discrepancy Description:** Line 18: "closing with a notification scenario and a full-journey pass (login → browse → cart → checkout → order → admin status change → notification)". The Remaining changes list (items 1–6) and line 33's remaining-work sentence contain the notification scenario and the "final PRD §9 checklist" but no full-journey pass; "close with the full acceptance checklist" (line 169) is a criteria sweep, not a journey walkthrough.
* **Rationale & Recommendation:** An Overview-promised deliverable has no owner in the plan of record. Add the full-journey pass to item 6 (or a new item) or state it is subsumed by the PRD §9 sweep.

### F9 (style-1) - Severity: Major — Present-tense problem claims are stale against the landed state
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** Overview line 11; "The Problem", lines 24–29
* **Discrepancy Description:** "Arabic product content cannot display because the app shell has no localization plumbing" (line 11); "**Arabic cannot display.**" and "**Notifications produce nothing.**" (lines 26, 28); "its §9 acceptance criteria are not demonstrable today" (line 24). Line 33 then states "the implementation stages of this plan have landed (localization plumbing, ... FCM receiver wiring, ... Supabase init with real credentials)", making the present-tense bullets false as written. A fresh reader cannot tell which problems are live without reaching line 33, and the four bullets mix tenses ("cannot display" present, "could not work" past, "produce nothing" present).
* **Rationale & Recommendation:** Label the section as the pre-fix baseline ("Before the implementation stages landed:") or convert the bullets to past tense, and anchor "not demonstrable today" to a dated snapshot. (Related Nit design-9: the Status field "Proposed" vs line 33's "landed" — set Status to e.g. "Partially implemented — verification pending".)

### F10 (style-6 + design-11) - Severity: Major — Token-absent behavior misstated ("skips silently") and contradicts the ops README
* **Reviewer Lens:** `egm-style` (Major), `egm-design` (Nit, same scope)
* **Affected Scope:** "Contracts", line 156; G3, line 39
* **Discrepancy Description:** "The watcher skips a user silently when the token is absent." `scripts/README.md` states the implemented behavior: the push "is skipped with a log line (the in-app record is still written so the notification center stays correct)" — so the skip is not silent, and the record does still land, which is what keeps G3's clause (b) true when no token exists. G3's "both (a) delivers a bilingual push and (b) writes the record" also implies both always happen.
* **Rationale & Recommendation:** Reword line 156 to "the push is skipped and logged; the in-app record is still written", and state the demo-day expectation in G3's terms (no push, but record appears). (Related Nit style-16: the nonstandard identifier `UNREGISTER` on line 46 should be `UNREGISTERED`.)

### F11 (structural-1 + design-13) - Severity: Major — No Risks & Mitigations section; demo-critical failure modes are scattered or absent
* **Reviewer Lens:** `egm-structural` (section gap), `egm-design` (instance)
* **Affected Scope:** Lines 1–237 (entire FeatureRange); nearest stand-in is `## Non-Functional Requirements` (lines 213–217)
* **Discrepancy Description:** The Feature Spec Standard lists **Risks & Mitigations** as a required area and requires the spec to "identify potential failure modes, security implications, scalability limits, and how they will be mitigated." No Risks section, or any heading carrying that function, exists in lines 1–237. Risk material exists but is scattered and unstructured: emulator FCM delivery uncertainty sits in `## Open Questions` (line 56), the Supabase free-tier pause is buried inside Alternative C's rejection rationale (line 191), and the watcher's no-replay failure mode (watcher down = transitions missed forever, notifications silently lost mid-demo) exists only in `scripts/README.md`'s demo-day checklist, not in this document.
* **Rationale & Recommendation:** Add a `## Risks & Mitigations` section (after `## Alternatives Considered`, before `## Non-Functional Requirements`) consolidating these failure modes with explicit mitigations: local watcher availability + no replay (mitigation: re-trigger a status change or delete the checkpoint file), scalar FCM token staleness, free-tier service pausing, emulator FCM delivery (move from Open Questions), and F1's bucket-policy exposure.

### F12 (structural-3) - Severity: Major — Rejection rationales attribute decisions to the maintainer with no linked record
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** Lines 179, 185, 191, 197, 203, 209 (`**Reason for Rejection**` bullets under Alternatives A–F)
* **Discrepancy Description:** All six rejection rationales open with "Rejected by author" (or "Rejected by author for demo scope"). The standard states rejection rationales "must not attribute a rejection to a maintainer without linking their issue, discussion, or PR." The author (Mahmoud-Younes) is the maintainer; each rationale attributes the decision to them with no linked issue, discussion, PR, or other record. The predecessor `concepts_brief.md` attributed Alternatives C and D to "review" (lines 78–79), so the design doc also silently rewrote the attribution source.
* **Rationale & Recommendation:** The trade-off content of each rationale is concrete and compliant; the person-attribution prefix is the gap. Either delete the "Rejected by author:" lead-in so each rationale stands on its trade-off, or link the deciding record (e.g., the relevant `concepts_brief.md` lens/decision entry or a tracking issue).

### F13 (structural-2) - Severity: Major — `Additional Resources` and `Future Improvements` are orphaned H3 headings
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** Lines 221 (`### Additional Resources`) and 229 (`### Future Improvements`)
* **Discrepancy Description:** Both sections are marked H3 but are document-level appendix sections, not subsections of `## Non-Functional Requirements` (line 213). The thematic break at line 219 explicitly ends the NFR section, leaving two H3 headings with no parent H2; additionally, `### Future Improvements` directly follows `### Additional Resources`, so it renders as a child of "Additional Resources," which it is not.
* **Rationale & Recommendation:** Skipped/orphaned heading level: under an H1-rooted outline, main sections must be H2. Promote both headers to `## Additional Resources` and `## Future Improvements`.

---

## Nits

### N1 (design-8) - Nit — Route count: "the other six" should be seven
* **Affected Scope:** Line 165 (Remaining change 2)
* **Discrepancy Description:** "convert the nine bare-screen route cases to the getIt `BlocProvider` pattern the other six already use" — the nine bare cases is correct, but the wrapped side is seven (login, register, forgotPassword, profile, checkout, myOrders, orderDetails in `app_router.dart`; checkout joined when the signed-out guard landed).
* **Rationale & Recommendation:** Update the count to seven; a fresh implementer recounting the file will hit the discrepancy immediately.

### N2 (design-10) - Nit — Stale "currently on disk" service-account claim
* **Affected Scope:** Line 54 (Open Questions, item 1)
* **Discrepancy Description:** "The service-account JSON currently on disk belongs to `sahety-370c1`" — no `scripts/serviceAccount*.json` exists in the workspace now (only `service-account.mjs`, which resolves `SERVICE_ACCOUNT_PATH` or the default path). The claim is stale or refers to an unnamed external path.
* **Rationale & Recommendation:** Restate as a verifiable instruction ("obtain a service-account JSON for `sahety-ba784` and place it at `scripts/serviceAccount.json` or set `SERVICE_ACCOUNT_PATH`").

### N3 (structural-4) - Nit — "Open Questions" contains no questions
* **Affected Scope:** Lines 52–56
* **Discrepancy Description:** All three items are blocking prerequisites with prescribed owner actions and stated fallbacks — decided-plus-blocked, not open questions.
* **Rationale & Recommendation:** Rename to `## Open Questions & Blockers` or `## External Prerequisites`, or split genuinely undecided items from owned blocking actions.

### N4 (structural-5) - Nit — Inconsistent horizontal-rule delimitation between top-level sections
* **Affected Scope:** Rules at lines 7, 58, 86, 171, 211, 219, 236; absent at Overview→The Problem, The Problem→Goals, Goals→Non-Goals, Non-Goals→Open Questions, Resources→Future Improvements
* **Discrepancy Description:** 80-hyphen rules separate some sibling H2 sections but not others (the first four H2 sections run together), so visual grouping is not derivable from a consistent convention.
* **Rationale & Recommendation:** Pick one convention and apply it uniformly; prefer the 3-dash `---` form over 80-dash lines.

### N5 (structural-6) - Nit — Verification-loop diagram is less legible than its siblings
* **Affected Scope:** Lines 140–152 (third `text` block under `### Data flows`)
* **Discrepancy Description:** The first two data-flow diagrams are linear with labeled edges; the third uses an unlabeled vertical `▲/│` chain and a bare `└────────▶` edge, so the seed-reset relationship and report flow are ambiguous on first read.
* **Rationale & Recommendation:** Redraw with explicit arrow direction and edge labels (e.g., "seed resets data before each spec run").

### N6 (structural-7 + style-14) - Nit — Repeated zero-information "**The idea**:" lead-in
* **Affected Scope:** Lines 231–234 (`Future Improvements` bullets)
* **Discrepancy Description:** All four bullets carry the identical bold lead-in `**The idea**:`, which adds no information under a heading already named "Future Improvements"; no other list in the range uses a repeated zero-information label.
* **Rationale & Recommendation:** Drop the label and let each bullet lead with its subject (`**Multi-device pushes** — …`), matching every other list in the document.

### N7 (style-13) - Nit — Dangling blocker ID "B3" (see also comprehension F1)
* **Affected Scope:** Remaining change 5, line 168
* **Discrepancy Description:** "— B3's no-regression guarantee." "B3" is an ID from `concepts_brief.md`, never defined in this document (same for M8/N4/M5 — recorded as Major in the Stage 6 comprehension report).
* **Rationale & Recommendation:** Replace with the plain referent or add a decode note for the IDs.

### N8 (style-11 + design-12) - Nit — Snapshot moment drift (add-to-cart vs purchase) and unstated price-snapshot semantics
* **Affected Scope:** G5 line 41 vs Landed components line 97
* **Discrepancy Description:** G5 says "snapshot the locale-resolved display name at add-to-cart time (PRD §4)"; line 97 says "at purchase time." PRD §4 says store name and price "at the time of purchase" — add-to-cart is earlier, so a product edited between add-to-cart and checkout yields an order item whose name predates purchase time, and the doc never states when price is snapshotted.
* **Rationale & Recommendation:** Pick "add-to-cart time" at first use and state explicitly that it is an accepted approximation of PRD §4 for demo scope (or snapshot both at order creation).

### N9 (design-14) - Nit — G4 over-claims "each feature has a deterministic spec"
* **Affected Scope:** Line 40 (G4) vs remaining change 4
* **Discrepancy Description:** Notifications is verified by the manual watcher scenario, not by an e2e spec — consistent with line 29, but G4's absolute claim is never qualified.
* **Rationale & Recommendation:** Qualify G4: "every feature except notifications, which is verified by the scripted watcher scenario."

### N10 (style-17) - Nit — Vague goal label "Hygiene in passing"
* **Affected Scope:** G5, line 41
* **Discrepancy Description:** "In passing" describes when, not what; the four items beneath are concrete.
* **Rationale & Recommendation:** Rename to "Consistency fixes" or similar.

### N11 (style-18) - Nit — "dummy" vs "realistic" for the same seed set
* **Affected Scope:** Line 15 vs line 20
* **Discrepancy Description:** "30 dummy products" (line 15) vs "realistic content" (line 20) give the same data opposite connotations.
* **Rationale & Recommendation:** Pick one framing, e.g. "30 sample products with realistic names, prices, and images".

### N12 (style-8) - Nit — Subjective flourish in the Supabase problem bullet
* **Affected Scope:** Line 27
* **Discrepancy Description:** "at exactly the demo moment that should impress" is a subjective evaluation inside an otherwise concrete failure description.
* **Rationale & Recommendation:** Cut the clause; the sentence is complete at "upload failed" branch.

### N13 (style-9) - Nit — Redundant "already" and superseded parenthetical
* **Affected Scope:** Line 31
* **Discrepancy Description:** "(decided during brainstorming, partially landed already)" — "already" duplicates "partially landed", and the parenthetical is superseded by the "Current state" inventory.
* **Rationale & Recommendation:** Trim to "(decided during brainstorming; see Current state)".

### N14 (style-10) - Nit — Vague, informal closing sentence of Current state
* **Affected Scope:** Line 33
* **Discrepancy Description:** "That work is parked while the design workflow ran; this document is the plan of record for it." — "parked" is informal jargon; "while the design workflow ran" is opaque.
* **Rationale & Recommendation:** State the operational fact directly: "Verification work is paused pending this design review; this document is the plan of record for resuming it."

### N15 (style-12) - Nit — Taxonomy sentence does not cover the rules-test script
* **Affected Scope:** Technical Plan intro, line 90
* **Discrepancy Description:** "Every remaining change is either configuration, a script already in place, or test authoring" — remaining change 5 authors a new script (`scripts/rules-test.mjs`), which fits none of the three categories.
* **Rationale & Recommendation:** Add "a new ops script" to the taxonomy or name the rules test explicitly.

### N16 (style-15) - Nit — Irrelevant `products` bucket probe in Open Question 2
* **Affected Scope:** Line 55
* **Discrepancy Description:** "Both `products` and `product-images` were probed" — the plan uses only `product-images`; the `products` probe is leftover diagnostic context the reader must then disregard.
* **Rationale & Recommendation:** Drop the `products` half of the sentence.

---

## Verified consistent (no finding)

* Cited lib file paths exist and match claims: `lib/e_commerce_app.dart`, `lib/core/helpers/product_localized_text.dart` (all named helpers), `lib/core/helpers/constants.dart`, `lib/features/notifications/data/services/fcm_service.dart`, `lib/features/admin/data/upload/admin_image_uploader.dart`.
* Scalar `fcmToken` contract with the legacy map fully removed from `lib/`; `firestore.rules:115-118` matches the admin-only notification-write decision; cart IconButtons indeed lack tooltips; checkout guard landed in `app_router.dart`.
* Seed contract (30 products, 6 categories, `seed_<slug>`), `fillSticky`/`dismissKeyboard` conventions in `tests/auth.e2e.ts`, and `e2e.config.ts` values ("workers 1, timeout 420s") match.
* Alternative B's June-2024 legacy FCM shutdown and PRD §6 citations are accurate; the Alternatives section satisfies the standard's mandatory evaluation with concrete technical rationales; `scripts/rules-test.mjs` correctly listed as not-yet-existing.
