# Intermediate Zoom Out Report — Stage 8

**Target:** `docs/designs/demo-ready-prd-completion.md` (full file, lines 1–339)
**Reviewer:** `egm-zoom-out` (completed)
**Prior findings treated as tracked:** zoom_out_report.md (Stage 5), comprehension_report.md (Stage 6), critic_report.md (Stage 7) — not re-raised here.

**Headline:** the earlier lenses audited the document's *content* against the code but not against *git*. The single most important fact about this plan — that the entire "landed" implementation exists only as uncommitted working-tree state, and that the document's rollback instruction would delete it — was missed by all three stages. Two further Majors concern the verification plan's gates.

--------------------------------------------------------------------------------

## Findings

### 🔴 1. Blocker — The whole "landed" implementation is uncommitted, and the plan's rollback instruction is destructive

* **Affected Scope:** Line 11 ("stages 1–7 committed to `main`"), line 33 ("Current state: the implementation stages of this plan have landed"), "Landed components (plan of record)" (line 92), NFR "Rollout & Rollback" (line 217), Detailed Plan items 1–15 (lines 240–321 — no item commits anything).
* **Discrepancy:** Verified with `git status` on branch `main`: **32 modified tracked files** — including every landed component the doc lists: `lib/e_commerce_app.dart`, `lib/main.dart`, `pubspec.yaml` (the `flutter_localizations` dependency itself is an uncommitted edit), `lib/core/models/product_model.dart` + codegen, `app_router.dart`, `fcm_service.dart`, `admin_image_uploader.dart`, plus 4 modified test files — and two **untracked** paths the plan depends on entirely: `lib/core/helpers/product_localized_text.dart` (the locale resolver every bilingual feature routes through) and `test/core/helpers/` (its tests). Even `docs/designs/` — this plan of record itself — is untracked. Only the *original* PRD stages 1–7 are committed (`d8f5346`, `95be01e`); "stages 1–7 committed to `main`" is literally true but the demo-ready delta described in "Current state" and "Landed components" exists nowhere in git history.
* **Why this is a blocker at this stage:** Line 217 states: "rollback is `git checkout` of the touched files." For uncommitted working-tree modifications, `git checkout` of the touched files **destroys the landed work itself** — it reverts to the pre-demo-ready commit. The NFR section that governs commit hygiene prescribes the one command that deletes the deliverable. Compounding this: the remaining scope (per the doc) is a verification campaign — specs, screenshot reviews, fixes, and the highest-regression-risk change (M8, per Stage 5 Major 3) — all to be executed against uncommitted code with **no commit step anywhere in the 15-item plan**. A green suite result cannot be tied to a commit; a botched M8 cannot be reverted to a pre-change baseline except by redoing work; a careless `git checkout .` or stash loss days before the demo erases everything.
* **Recommendation:** Add a plan item 0 (before item 1): run `flutter analyze` + `flutter test` green, then commit the landed baseline — including the untracked `product_localized_text.dart`, `test/core/helpers/`, and this design document — so HEAD becomes the known-good reference. Thereafter, one commit per plan item (tooltips, M8, each spec) so rollback means "revert to the previous commit," and rewrite line 217 accordingly. One item and two sentences; without them the plan is not safe to execute.

### 🟡 2. Major — The §9 closing gate exists only as a phrase: no step in the Verification Plan, and two of §9's six criteria have no instrument

* **Affected Scope:** Overview item 4 (line 18, "closing with… a full-journey pass"), Remaining change 6 (line 169, "close with the full acceptance checklist"), Verification Plan (lines 323–333 — the step is absent), G4/item 6 checklist enumeration (lines 40, 169, 329).
* **Discrepancy (three sub-parts, verified against the PRD §9 text at `ecommerce_flutter_firebase_project.md` lines 142–155):**
    1. **No scheduled step.** The Verification Plan lists analyze, unit tests, build, e2e discipline, visual checklist, rules test, notification scenario, data hygiene, platform limitation — and stops. The "PRD §9 sweep / full-journey pass" — the document's entire raison d'être — has no position in the sequence, no preconditions (fresh seed via `npm run reset`? post-e2e junk dataset? watcher running? both locales?), and no owner. Item 6 says "close with" it; the plan that operationalizes every other item never does.
    2. **Checklist silently narrows §9's first criterion.** §9 requires "clear **loading, empty, success,** and error states"; G4, item 6, and the visual checklist (line 329) verify only "English, Arabic RTL, empty, and error" — loading and success captures are dropped from the very instrument meant to prove that bullet.
    3. **Security criteria have no verification instrument.** §9 also requires "users cannot read or modify other users' private order data" and "customers cannot change product prices or trusted order totals." The rules test (item 10) was deliberately scoped to notification writes only; no e2e spec or step anywhere demonstrates cross-user isolation or total-forgery denial (correctly so — these are not UI-demonstrable). The landed rules enforce them, but the closing sweep has no way to evidence them.
* **Recommendation:** Add a final Verification Plan step: "§9 sweep — preconditions: `npm run reset` + reseed, watcher running, notification permission granted; run the full journey on `en` and `ar`; walk each §9 bullet with its evidence (spec results for features, screenshot set for states incl. loading/order-success, rules test + rules read-through for the two security bullets)." Extend item 10's rules test with 2–3 more assertions (cross-user order read denied, customer price/total write denied) — same emulator run, marginal cost — or state explicitly that those bullets are evidenced by rules review with the reviewer's findings as the record.

### 🟡 3. Major — Item 10 (rules test) is a hard gate hiding an unstated toolchain: JDK, `firebase-tools`, and emulator downloads appear nowhere in the plan

* **Affected Scope:** Item 10 (lines 291–295), Verification Plan line 330 ("must pass before the notification scenario runs"), Additional Resources line 225, `scripts/package.json`, `scripts/README.md` "Prerequisites".
* **Discrepancy:** Verified: `scripts/package.json` contains only `firebase-admin` and `@supabase/supabase-js` — no `firebase-tools`, no `@firebase/rules-unit-testing`, no `test:rules` mapping (item 10 honestly says "(Create)", but only for the file and script entry). `scripts/README.md`'s Prerequisites section lists Node, service account, Supabase bucket — nothing about the Firestore emulator. The root `firebase.json` is a `flutterfire` platform config with **no `firestore` block**, so the emulator invocation needs either a config edit or documented flags. Running the Firestore emulator at all requires a Java JDK and `firebase-tools` (with a first-run emulator binary download) — a second, independent Node/Java toolchain introduced on the demo critical path by a single test, and made a **hard gate** for CUJ 3's notification scenario. If the emulator cannot run on the owner's machine, the notification scenario stalls with zero plan-of-record guidance.
* **Recommendation:** Either (a) state the prerequisites in item 10 and in `scripts/README.md` Prerequisites (JDK, `firebase-tools`, `@firebase/rules-unit-testing` with the ESM-`"type": "module"` caveat, the `firebase.json` firestore block or `--config` flag), and verify toolchain availability early — it is the only plan item needing Java; or (b) demote the gate: run `test:rules` as a parallel verification, not a blocker for CUJ 3, since the regression it guards is a deliberate future code change (the client write path is deleted and the rules file is untouched by this plan). Note the doc already contains the gating idiom to copy: item 9 optional-gates the image upload on bucket readiness.

### 🟡 4. Major (systemic pattern) — The accumulated findings are one genus: state asserted from memory, not verified from disk. Absorb it structurally.

* **Affected Scope:** Line 33 ("Current state"), line 92 ("Landed components"), line 319 (item 15, finalize step).
* **Discrepancy:** Counting across stages 5–8, the same failure mode now accounts for at least eight findings: spec inventory stale (three separate reviewers), service-account "currently on disk" stale, token-contract wording vs. watcher, route count off-by-one, `scripts/` "gitignored" mischaracterization, the Problem/Current-state tense contradiction, the cart spec's coordinate-tap workaround undeclared — and now Finding 1 (uncommitted baseline presented as "landed," with a destructive rollback instruction). Each reviewer found instances; none named the pattern. A plan of record whose factual existence/count/status claims fail at this rate will keep drifting every time it is edited.
* **Recommendation:** Make the finalize step (item 15) a **state audit**, not just a document creation: re-derive every factual claim from disk immediately before declaring the doc final — spec inventory (`ls tests/`), line counts, `git status`/`git log`, `git check-ignore` for the scripts story, on-disk credentials. Better: replace the narrative "Current state" with a small verifiable table (path → exists? → git status → classification), so the executor and any future reviewer can re-run the checks mechanically instead of trusting prose.

### 🟢 5. Nit — Two of the three "Open Questions" are not open questions; they are closed, mandatory owner actions

* **Affected Scope:** Lines 52–56 (Open Questions 1–2 vs. 3), duplicated as items 12–13.
* **Discrepancy:** Items 1–2 are decided requirements with assigned owner actions ("The owner must re-download…", "The owner must create…") gating `npm run seed/watch/admin` and the G2 round-trip; only item 3 (FCM-on-AVD delivery) is a genuine unknown. Filed under "Open Questions," the two hard gates read as deferrable. Nothing is lost (items 12–13 carry them), but the section type misleads a reader triaging what blocks the plan.
* **Recommendation:** Retitle the section or move items 1–2 into a "Owner prerequisites" list; leave only item 3 as an open question.

### 🟢 6. Nit — The FCM feasibility probe has two confusable failure modes; permission denial mimics watcher-dead silence

* **Affected Scope:** Open Question 3 (line 56), Verification Plan notification scenario (line 331).
* **Discrepancy:** The doc (and Stage 5's "probe early" nit) treats FCM-on-AVD as a binary unknown. In fact a silent demo has two independent causes: emulator delivery failure **or** a denied Android 13+ runtime notification permission — the Pixel 7 Pro AVD runs API 33+, where pushes are not displayed without the grant. The app handles the request in code (verified: `fcm_service.dart` `initialize()` calls `requestPermission()` at line 95 — no code fix needed), but the probe/scenario never says to confirm the grant, and a denial during the probe would be misdiagnosed as "FCM doesn't work on this AVD," triggering the physical-device fallback unnecessarily.
* **Recommendation:** One line in the probe procedure: grant/verify the notification permission before concluding anything about delivery.

--------------------------------------------------------------------------------

## Mitigations already in the document that earlier reviewers overlooked

* **Stage 7 Major 1 (token not saved at login) is ~90% mitigated by artifacts the reviewers treated as separate findings.** Line 333's restart-after-auth pattern (`app.open()` re-launch after register/login — exactly when `FcmService.initialize()` runs and saves the token) plus the `scripts/README.md` demo-day checklist item "Log in on a real device/emulator build that has registered its FCM" together already encode the "token lands at launch; restart after auth" contract. The residual fix is one sentence in G3/CUJ 3 — no code and no checklist surgery required.
* **Item 9's optional-gating idiom** ("Image upload inside the spec is optional-gated: only if the Supabase bucket prerequisite is resolved") is the template the plan should reuse for the rules-test gate (Finding 3) and the §9 sweep preconditions (Finding 2) — the document already knows how to gate on prerequisites; it just doesn't apply the pattern where it matters most.
* **No reuse finding to report:** the only genuinely new tool proposed is `scripts/rules-test.mjs`, and `scripts/` is the correct home — it is the project's only Node toolchain, and Firestore rules cannot be tested from the Flutter `test/` roots. No existing utility duplicates anything the plan creates; the tooltips and route changes are modifications of existing files, not new abstractions.
* **Screenshot mechanism is real, verified:** the e2e runner already emits screenshots into `.e2e/` (`.e2e/pm-smoke/boot.png`, `results/*/attempt-1/screenshots/`), so G4/CUJ 4's screenshot-review assumption is sound; no finding raised there.

## What remains clean

Beyond the tracked findings: free-tier budget exposure (30 products + watcher writes is negligible — no premature-optimization issue), the Alternatives analysis (still evidence-based), the no-new-runtime-layers architecture claim, the data-flow diagrams' altitude, and the contracts section's substance all hold. The document's weaknesses at this point are almost entirely concentrated in two places: **git-state honesty** (Findings 1, 4) and **verification-gate completeness** (Findings 2, 3).

| Severity | Count |
| --- | --- |
| 🔴 Blocker | 1 |
| 🟡 Major | 3 (incl. 1 systemic) |
| 🟢 Nit | 2 |
