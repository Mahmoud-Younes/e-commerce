# Goldfish Review Report — Stage 7 (Critic Review)

**Target:** `docs/designs/demo-ready-prd-completion.md` (FeatureRange: lines 1–237)
**Reviewers:** `egm-design` (completed), `egm-structural` (completed), `egm-style` (completed)
**Standards:** feature-spec-standard (design, structural); persona judgment (style)

## Reviewer Status

| Reviewer | Status |
| --- | --- |
| `egm-design` | completed |
| `egm-structural` | completed |
| `egm-style` | completed |

**Severity breakdown (deduplicated):** 0 🔴 Blocker · 9 🟡 Major · 15 🟢 Nit

## Prioritized Findings (Blockers → Major → Nits)

### 🟡 G3/CUJ3 premise "after login the device saves its FCM token" is false in the landed code — Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** Line 39 (G3), line 76 (CUJ3 Given), line 33 (Current state)
* **Discrepancy Description:** `FcmService.initialize()` (→ `register()` → `onRegistered` → `_saveToken`) runs exactly once per app launch (`lib/main.dart:54-55`); `getTokenAndSave()` has zero callers in `lib/` — no login/register flow saves the token mid-session. A user who registers/logs in during a running session gets no `users/{uid}.fcmToken` until relaunch. CUJ3's Given does not hold for a freshly registered demo user; the push would silently not arrive (watcher skips the push, writes only the record — `scripts/watch-orders.mjs:148-158`). E2e flows survive only via restart-after-auth.
* **Rationale & Recommendation:** Either (a) wire a post-auth token save (call `getTokenAndSave` from login/register success paths), or (b) amend G3/CUJ3 to state the "token lands on first app launch while signed in" contract and make the app restart an explicit step of the notification scenario and the demo-day checklist inside this document.

### 🟡 "Current state" and Remaining-work item 3 are stale: four of seven feature specs already exist; probe/example specs unaddressed — Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** Line 29, line 33, lines 164–166 (item 3)
* **Discrepancy Description:** `tests/` contains drafted `cart.e2e.ts` (201), `favorites.e2e.ts` (169), `catalog.e2e.ts` (176), `product_details.e2e.ts` (158) — the design says only catalog and product_details are drafted. Only `checkout`, `orders`, `admin` remain. `example.e2e.ts` (scaffold asserting system-settings text — guaranteed to fail) and `probe.e2e.ts` (self-described temporary, deletion overdue) are unmentioned. Additionally `cart.e2e.ts`'s header documents a coordinate-tapping workaround ("LOCATOR GAP (app fix pending)") — once Remaining change 1 (tooltips) lands, the cart spec must be rewritten to target the new accessible names.
* **Rationale & Recommendation:** Update lines 29/33/166 to the real spec inventory, add an explicit step to revise `cart.e2e.ts` after the tooltip change, and delete or explicitly schedule `example.e2e.ts`/`probe.e2e.ts` so a whole-suite run does not fail on scaffold noise.

### 🟡 `preparing` omitted from the notification status scope (G3 and CUJ3) — Severity: Major
* **Reviewer Lens:** `egm-design`, `egm-style` (deduplicated)
* **Affected Scope:** Line 39 (G3), line 77 (CUJ3), echo at line 17
* **Discrepancy Description:** The landed watcher pushes on five statuses — `confirmed, preparing, shipped, delivered, cancelled` (`watch-orders.mjs:39-45`); `OrderStatus` (`order_status.dart:10-16`) and GLOSSARY include `preparing`; PRD §5 lists it. G3's "every order-status change" is silently narrowed to five of six states; a scenario authored from G3/CUJ3 never exercises `preparing` at the acceptance gate.
* **Rationale & Recommendation:** Insert `preparing` into both enumerations ("pending → confirmed → preparing → shipped → delivered, plus cancelled") and add it to the notification scenario (one extra status advance in the same run).

### 🟡 `scripts/` described as "gitignored / local / untracked"; repo convention is the opposite — Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** Line 101, line 215, line 217, detailed-plan items 10–11 (lines 293, 299)
* **Discrepancy Description:** `.gitignore` deliberately ignores only `scripts/node_modules/`, `scripts/serviceAccount*.json`, `scripts/.env*`, `scripts/.watch-checkpoint.json`, with an explicit comment "Code (package.json, *.mjs) is tracked; secrets, deps and state are not" plus `!scripts/package.json`. Nothing is committed yet, but the code files are trackable and intended to be tracked. The rollback claim ("rollback is `git checkout` of the touched files") is internally incoherent for untracked tooling.
* **Rationale & Recommendation:** Commit the scripts (secrets/state stay ignored) and rewrite lines 101/217 to "tracked code with untracked secrets/state"; or explicitly decide they stay untracked and fix the rollback story.

### 🟡 World-writable Supabase bucket mandated but never acknowledged as a security trade-off — Severity: Major
* **Reviewer Lens:** `egm-design` (corroborated by Stage 5 inventive-catalyst Nit 3)
* **Affected Scope:** Line 55, line 215, `scripts/README.md` §2 SQL
* **Discrepancy Description:** Required policies are unscoped anon INSERT/UPDATE/DELETE on the whole `product-images` bucket; with the publishable key in `constants.dart`, any third party can create/overwrite/delete every product image. The Security NFR is silent on it — one subsystem (Firestore) locked down, its sibling wide open.
* **Rationale & Recommendation:** (a) Add an explicit accepted-risk statement with a post-demo expiry (re-scope or revoke anon write policies after verification); (b) prefer service-role uploads from the seed script and scope anon INSERT to the admin-upload path pattern; (c) never ship anon UPDATE/DELETE if only the seed script needs overwrite (it can use the service-role key locally). Minimum fix: scope policies by object-name prefix (`seed/%`, `products/%`).

### 🟡 No cleanup path for e2e artifacts; they pollute the live demo dataset — Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** Lines 40, 84 (G4/CUJ4), line 217
* **Discrepancy Description:** `npm run reset` deletes only `products` docs in the `seed_` range (`reset.mjs:39-49`). E2e registration creates real Firebase Auth accounts plus carts, favorites, and (once checkout/notification scenario run) orders and notifications in the live project. The admin dashboard reads the global `orders` collection, so demo-day the admin sees accumulated `e2e_` junk orders interleaved with demo orders. G4's "re-seeding resets the demo dataset" is true only for products.
* **Rationale & Recommendation:** Add an ops step — a `reset --e2e` mode deleting orders/notifications authored by `e2e_` users plus the throwaway accounts — or an explicit accepted-limitation note with a demo-day mitigation.

### 🟡 Opaque cross-reference IDs (M5, M8, B3, N4) and "the brief" never defined — Severity: Major
* **Reviewer Lens:** `egm-style`; `egm-comprehension` (Stage 6, fuller version)
* **Affected Scope:** Lines 90, 165, 168 (FeatureRange instances); Verification Plan (DetailedRange)
* **Discrepancy Description:** The IDs are defined only in `concepts_brief.md` (local file). "B3" appears with no antecedent in lines 1–237. Internal-workflow phrases ("restored by author decision at finalization") are undecodable to a fresh reader.
* **Rationale & Recommendation:** Gloss each ID inline at first use or drop the IDs; add one line stating all such IDs come from `concepts_brief.md`. For line 168 specifically: "…locking in the decision that customers cannot create notifications (watcher-side writes only)."

### 🟡 Tense contradiction between "The Problem" and "Current state" — Severity: Major
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** Lines 24–33
* **Discrepancy Description:** Line 24 asserts §9 criteria "are not demonstrable **today**" under present-tense bullet headers, but the evidence inside each bullet is past tense, and line 33 states the implementation "have landed". A fresh reader cannot tell which problems still exist at reading time.
* **Rationale & Recommendation:** Anchor the section: "…were not demonstrable when this design opened"; convert bullet headers to past tense; end with "Current state: all but the verification work has since landed (see below)."

### 🟡 Self-falsifying scope sentence in Technical Plan intro — Severity: Major
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** Line 90
* **Discrepancy Description:** "Every remaining change is either configuration, a script already in place, or test authoring — with two production-code changes…" — the em-dash clause refutes "every" mid-sentence.
* **Rationale & Recommendation:** Reword: "Most remaining changes are configuration, already-placed scripts, or test authoring; the two production-code changes are the cart-control tooltips and route normalization, and `firestore.rules` is untouched."

### 🟢 Route-case count off by one ("the other six already use" → seven) — Severity: Nit
* **Reviewer Lens:** `egm-design`; `egm-zoom-out` + `egm-inventive-catalyst` (Stage 5, corroborating)
* **Affected Scope:** Lines 90, 165, 253
* **Discrepancy Description:** `app_router.dart` has seven BlocProvider-wrapped cases (login, register, forgotPassword, profile, checkout-with-guard, myOrders, orderDetails); nine bare ones — the bare count is correct.
* **Rationale & Recommendation:** Correct to "seven" so the migration checklist is countable.

### 🟢 Token contract wording does not match watcher behavior — Severity: Nit
* **Reviewer Lens:** `egm-design`; `egm-inventive-catalyst` (Stage 5, corroborating)
* **Affected Scope:** Line 156, line 46
* **Discrepancy Description:** The watcher (a) logs a SKIP line (not silent), (b) skips only the push — still writes the in-app record, (c) tolerates the legacy `fcmTokens` map as read-side fallback (`watch-orders.mjs:83-89`).
* **Rationale & Recommendation:** Reword: "push skipped with a log line; the in-app record is still written; legacy map tolerated as read-side fallback."

### 🟢 Stale service-account detail (`sahety-370c1` "currently on disk") — Severity: Nit
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** Line 54
* **Discrepancy Description:** No `serviceAccount*.json` exists in the repo now (only the loader `scripts/service-account.mjs`); the file was removed or lives outside the repo. The actionable requirement stands.
* **Rationale & Recommendation:** Drop the stale on-disk claim; state the requirement and the verification step (`watch` prints the project id at startup).

### 🟢 Password caveat missing where the password is documented — Severity: Nit
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** Line 215 vs `scripts/README.md`
* **Discrepancy Description:** `scripts/README.md` documents `admin@sahety.app` / `Admin@123456` with no demo-only/change-before-production warning — the caveat lives only in the design doc. The design also never says where the password is documented.
* **Rationale & Recommendation:** Add the warning next to the password in `scripts/README.md`; state the documentation location in the design.

### 🟢 G4 overpromises "each feature has a deterministic spec" — Severity: Nit
* **Reviewer Lens:** `egm-design`; `egm-zoom-out` (Stage 5, corroborating)
* **Affected Scope:** Line 40 vs line 167
* **Discrepancy Description:** Notifications get a manual scripted scenario, not a spec (reasonable — push delivery is not deterministically assertable by a UI driver).
* **Rationale & Recommendation:** Scope G4 explicitly: "each feature except notifications, which is verified by an explicit watcher-driven scenario per CUJ 3."

### 🟢 Remaining-change taxonomy miscounts the rules test — Severity: Nit
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** Line 90 vs line 168
* **Discrepancy Description:** "Every remaining change is either configuration, a script already in place, or test authoring" — but item 5 authors `./scripts/rules-test.mjs` from scratch (it does not exist).
* **Rationale & Recommendation:** Reclassify item 5 as new ops-script authoring.

### 🟢 Back-matter sections outline-nest under NFR (template-inherited) — Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** Lines 213–234
* **Discrepancy Description:** The two H3 back-matter sections render as NFR children though they are document-level back matter. Template-inherited from the EGM blueprint, not an author deviation.
* **Rationale & Recommendation:** Leave as-is; if outline nesting matters, raise upstream as a template change.

### 🟢 Horizontal-rule placement deviates from the blueprint — Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** Rules at lines 58, 86, 171
* **Discrepancy Description:** Three extra rules create "chapter" grouping the blueprint doesn't mandate; the Problem→Goals→Non-Goals→Open Questions block gets none — two visual regimes.
* **Rationale & Recommendation:** Apply one convention (strip the extras for strict fidelity, or keep intentional grouping).

### 🟢 Risks area substantively covered but invisible in the outline — Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** Lines 52–56, 213–217
* **Discrepancy Description:** Failure modes with fallbacks (Open Questions) and security mitigations (NFR) exist in content, but no heading contains "Risk", so TOC scanners can't locate risk treatment.
* **Rationale & Recommendation:** One pointer sentence in NFR ("failure-mode risks and their fallbacks are tracked under Open Questions").

### 🟢 Heading-case inconsistency among author-added H3s — Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** Lines 92, 103, 154, 162
* **Discrepancy Description:** Author-added H3s use sentence case while every H2 and template H3 uses Title Case.
* **Rationale & Recommendation:** Pick Title Case to match the rest.

### 🟢 Wrapped labels drift off-column in the first data-flow diagram — Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** Lines 117–118
* **Discrepancy Description:** Second lines of two-line column labels sit 1–2 characters right of column start; "snapshot at add-to-cart" extends past the right edge.
* **Rationale & Recommendation:** Realign wrap lines to column starts.

### 🟢 Subjective color in a factual bullet ("at exactly the demo moment that should impress") — Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** Line 27
* **Rationale & Recommendation:** Cut to "…at the first upload attempt during the demo."

### 🟢 Uncalibrated performance adjective ("trivial") — Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** Line 216
* **Rationale & Recommendation:** "…is far below Firestore and Supabase free-tier limits; no pagination or caching work is in scope."

### 🟢 Garbled temporal clause ("parked while the design workflow ran") — Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** Line 33
* **Rationale & Recommendation:** "That verification work is paused; this document is its plan of record."

### 🟢 Filler adverb and repeated empty label ("partially landed already"; "**The idea**:" ×4) — Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** Lines 31, 231–234
* **Rationale & Recommendation:** Cut "already"; drop the repeated label, keep the bolded topic phrases. (Note: the structural reviewer flags the label as blueprint-mandated — author's call.)

### 🟢 Vague qualifier "fresh" (CUJ 3 Given) — Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** Line 76
* **Rationale & Recommendation:** "holds a token saved at login" — though see Major 1: the token is not saved at login in the landed code; coordinate the two fixes.

### 🟢 Phrase drift for the same operational rule — Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** Lines 18, 40, 83–84
* **Rationale & Recommendation:** Pick one phrase — "run one spec at a time" — since the constraint is load-bearing for checkpoint dedupe.

### 🟢 Low-value subjective framing in Alternatives (optional pass) — Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** Lines 177, 189, 195
* **Rationale & Recommendation:** Trim where touched anyway; not worth a standalone edit pass.

## Sections that pass

* **Overview / The Problem diagnoses:** every root-cause claim verified against code (`e_commerce_app.dart:43-48`, `main.dart:30-55`, `firestore.rules:115-118`, legacy FCM HTTP shutdown accurate).
* **Goals G1, G2, G5:** verified end-to-end (bilingual search `product_repository_impl.dart:70-74`, chips `category_filter_chips.dart:49`, admin Arabic fields `admin_product_form_screen.dart:156-169`, add-to-cart snapshot `add_to_cart_button.dart:67-74`, checkout guard `app_router.dart:94-101`, missing tooltips real).
* **Landed components / Data flows / Contracts:** point-for-point traceable to code (seed determinism, checkpoint dedupe, FCM v1, reset range, e2e config numbers, ValueKeys-not-semantics claim).
* **Alternatives Considered:** satisfies the standard's mandatory Alternatives Rule — six options, uniform template, evidence-based rejections.
* **Structural integrity:** exact blueprint header order, no skipped heading levels, balanced fences, uniform 80-hyphen rules, identical CUJ Given/When/Then structure, all NFR concern categories filled.
* **Style baseline:** no marketing fluff or filler phrases anywhere in scope; Open Questions/NFR are calibrated caveat-writing.

**Suggested disposition:** address Majors 1–3 (they gate the notification verification and spec-authoring work) and Majors 4–6 (commit/rollback and demo-day cleanliness) before this plan of record is declared the execution baseline; the Nits are one-pass wording fixes.
