# Goldfish Review Report — Stage 6: Comprehension Test

**Target:** `docs/designs/demo-ready-prd-completion.md` (entire file, lines 1–339)
**Reviewer:** `egm-comprehension` (direct dispatch, no document standard, no external context — self-containment test)

## What this proposes

This document is a design/plan for taking an already-built Flutter e-commerce app (which, per the document, already implements every PRD feature) to a "demo-ready" state through four workstreams: (1) seeding 30 bilingual (Arabic/English) dummy products into the live Firestore project so catalog content displays per device locale with RTL layout and English fallback; (2) making admin product-image upload actually work against a real public Supabase Storage bucket; (3) delivering order-status notifications for free via a locally-run Node.js Firebase Admin SDK "watcher" script that sends bilingual FCM pushes and writes in-app notification records, explicitly avoiding paid Cloud Functions/Blaze; and (4) authoring per-feature e2e specs run one at a time with screenshot review, closed out by a Firestore rules test and the PRD §9 acceptance checklist. Most of the implementation has already landed; the remaining work is two small production-code changes (cart-button tooltips, route normalization), e2e spec authoring/verification, a rules test, and two owner-supplied prerequisites (a correct service-account JSON for project `sahety-ba784`, and creating the Supabase `product-images` bucket with policies).

## How the existing system works, per this document

The app is a feature-first Flutter application (Cubits, Firestore, FCM, Supabase Storage) whose "stages 1–7" are committed to `main`, with tests green. The document states that the localization plumbing, bilingual model fields and search, admin Arabic form fields, FCM receiver wiring (scalar `users/{uid}.fcmToken` contract), Supabase initialization, and local ops scripts (`seed.mjs`, `watch-orders.mjs`, `reset.mjs`, `bootstrap-admin.mjs`) have all already landed. The e2e harness exists (TypeScript specs on a Pixel 7 Pro emulator) but only `auth` had a spec; catalog and product-details specs exist as drafts to verify. Client-side notification writes are rejected by `firestore.rules` (by design), so the watcher is intended to be the sole writer of notification records, bypassing rules via the Admin SDK; push bodies carry one combined bilingual text; category chips are derived client-side from each product's `category` string; and screen labels remain English while only product content is bilingual.

---

## Findings

**Finding 1**
- **Severity**: Major
- **Affected Scope**: "Technical Plan (Architecture)" intro (line 90), "Remaining changes" items 2/5 (lines 165, 168), "Detailed Implementation Plan" items 2/10 (lines 250, 254, 295), "Verification Plan" (lines 329, 332)
- **Discrepancy Description & Rationale**: The document uses opaque milestone/commitment identifiers — **M8**, **B3**, **N4**, **M5** — that are never defined anywhere in the document ("route normalization closes M8", "B3's no-regression guarantee", "Visual review checklist (N4)", "Data hygiene (M5)"). They presumably map to numbered commitments in the predecessor artifact `concepts_brief.md`, which is named in Additional Resources (line 224) but is never connected to these IDs, and no legend or decode table is provided. A fresh reader must reverse-engineer each label from surrounding prose (e.g., infer that B3 = "the decision that only the watcher writes notifications"), and the first occurrences (line 90's "M8", line 168's "B3") appear before any contextual rescue. The actual work items are described in prose, so this is not a Blocker, but the identifiers function as dead references for anyone without the external brief.

**Finding 2**
- **Severity**: Major
- **Affected Scope**: "Detailed Implementation Plan" item 9, `./tests/admin.e2e.ts` (lines 286–289)
- **Discrepancy Description & Rationale**: The admin-spec instructions are self-contradictory. The main clause says "Register a customer, then promote it via `npm run admin` semantics", but the parenthetical immediately says "bootstrap script targets the demo admin; the spec instead uses the seeded `admin@sahety.app` account". A fresh reader cannot determine the actual flow: does the spec promote the freshly registered customer to admin, or does it log in as the pre-seeded admin account? The two statements point in opposite directions, and the landed `bootstrap-admin.mjs` is described elsewhere (line 101) as only ever creating the fixed `admin@sahety.app` — which makes the "promote it" clause look wrong rather than just poorly worded.

**Finding 3**
- **Severity**: Major
- **Affected Scope**: Goals G4 (line 40), "Remaining changes" item 3 (line 166), Non-Goals (line 47), "Verification Plan" visual checklist (line 329)
- **Discrepancy Description & Rationale**: The verification story is never reconciled across three separated statements: G4 requires screenshots "reviewed per run in English, Arabic (RTL), and empty/error states"; the spec-authoring conventions mandate "English-only assertions"; and Non-Goals states screen labels stay English (only product content is bilingual). How an "Arabic RTL run" is actually produced is unstated — does the emulator locale get switched between runs, does the spec set the locale, and do English-only assertions simply pass on an `ar` device because labels are English (while bilingual product-content assertions are conditionally skipped)? A fresh reader must assemble this reconciliation from three distant sections, and the mechanism (two runs per spec? manual locale change?) is left entirely to inference.

**Finding 4**
- **Severity**: Nit
- **Affected Scope**: "The Problem" (line 29) vs "Current state" (line 33) vs plan items 3–4 (lines 256–264)
- **Discrepancy Description & Rationale**: The spec-count arithmetic requires assembly. Line 29 lists eight features with no specs (catalog, product details, favorites, cart, checkout, orders, admin, notifications); line 33 then says the remaining work is "authoring the five missing e2e specs". Only at plan items 3–4 does the reader learn that catalog and product-details specs already exist as drafts (verify-only), and that notifications is covered by a manual scenario (item 4) rather than a spec file — yielding 2 drafts + 5 authored + 1 scenario = 8. Consistent once assembled, but a fresh reader hits an apparent 8-vs-5 mismatch before the explanation arrives.

**Finding 5**
- **Severity**: Nit
- **Affected Scope**: Overview (line 11); "Landed components" (line 101); item 12 (line 305)
- **Discrepancy Description & Rationale**: "Stages 1–7 committed to `main`" is never enumerated or defined; the reader only learns the consequence ("every PRD feature" is implemented). Similarly, the Overview's "no trusted sender existed on the free tier" (line 11) uses the term "trusted sender" before the trusted-side concept is established — it is only explained much later via Alternatives A/B (lines 177–185). A forward pointer or one-line gloss would make the opening self-contained.

**Finding 6**
- **Severity**: Nit
- **Affected Scope**: PRD section references throughout (lines 24, 37, 41, 185, 215, 223, 268–288, 317)
- **Discrepancy Description & Rationale**: Section references to the external PRD (`ecommerce_flutter_firebase_project.md`, linked in Additional Resources) are mostly acceptable pointers, but several are bare or vague: spec items cite "(PRD §2)", "(PRD §3)", "(PRD §4/§5)", "(PRD §5)" with no inline gloss of what those sections contain, and line 317's "PRD §7's products row" is unexplained jargon (what a "products row" in a PRD section is, is never said). By contrast §9 (acceptance criteria, line 24) and §6 (line 185) are paraphrased inline — the good pattern the other references don't follow.

**Finding 7**
- **Severity**: Nit
- **Affected Scope**: "Landed components" → Ops scripts (line 101)
- **Discrepancy Description & Rationale**: "cold-start records without notifying" is a compressed, ambiguous behavior description of `watch-orders.mjs`. The plausible reading (when the watcher first starts, pre-existing order states produce notification records but no push) is never stated; a fresh reader must guess whether "cold-start" means backfilling records, skipping them, or something else. This matters because verification (checkpoint/no-re-send behavior) leans on the watcher's start semantics.

**Finding 8**
- **Severity**: Nit
- **Affected Scope**: "Landed components" → Supabase (line 98), Bilingual product model (line 96)
- **Discrepancy Description & Rationale**: Two pieces of compressed jargon are unexplained: "`Supabase.initialize` guarded by a placeholder check" (what placeholder check — presumably skipping init while URL/key still hold placeholder values — is never said) and "explicit-null serialization" (presumably null Arabic fields are written as explicit JSON nulls so upserts clear stale values; the term and its rationale are undefined).

**Finding 9**
- **Severity**: Nit
- **Affected Scope**: "Landed components" (line 98) vs item 13 (line 311)
- **Discrepancy Description & Rationale**: Item 13 introduces the symbol `SupabaseConfig.productsBucket` without connecting it to anything; the Supabase landed-component entry (line 98) points at `lib/core/helpers/constants.dart` for "real project URL + publishable key" and never names a `SupabaseConfig` class. A fresh reader cannot tell whether `SupabaseConfig` lives in `constants.dart` or elsewhere.

**Finding 10**
- **Severity**: Nit
- **Affected Scope**: Goals G4 (line 40) vs CUJ 4 (line 83) and "Verification Plan" (line 328)
- **Discrepancy Description & Rationale**: The e2e run command is stated inconsistently: G4 gives `npx e2e run tests/<spec>.e2e.ts` while CUJ 4 and the Verification Plan give `npx e2e run tests/<spec>.e2e.ts:<line>`. The semantics of the `:<line>` suffix (running a spec section anchored at a line?) are never explained, leaving the reader to guess whether the two forms mean different things.

**Finding 11**
- **Severity**: Nit
- **Affected Scope**: "Detailed Implementation Plan" item 7, `./tests/checkout.e2e.ts` (line 279)
- **Discrepancy Description & Rationale**: "Also covers the signed-out deep-link guard implicitly (the spec always registers/logs in first; the guard is unit-level)" is self-undermining: a spec that always signs in first cannot exercise the signed-out path, and the parenthetical then relocates coverage to unit level. The reader must conclude the e2e suite does not actually cover the guard at all — which contradicts the sentence's opening claim that the spec "covers" it.

**Finding 12**
- **Severity**: Nit
- **Affected Scope**: "Detailed Implementation Plan" item 9 (line 289)
- **Discrepancy Description & Rationale**: "Arabic-field prefill and validation-only-when-non-empty behavior" is ambiguous: it does not say what the validation rule actually is (presumably the Arabic fields are only validated when one of them is filled, e.g., filling `nameAr` requires `descriptionAr`? — never stated). The cart spec relies on similar on-screen-copy precision elsewhere, so this vagueness is conspicuous.

**Finding 13**
- **Severity**: Nit
- **Affected Scope**: "Detailed Implementation Plan" intro (line 240) vs items 3–13 and CUJ 4 (line 82)
- **Discrepancy Description & Rationale**: The plan claims to be "ordered by dependency" with "spec authoring/verification" before "the user-supplied credentials that gate script runs", but the credentials (items 12–13) gate `npm run seed`/`watch`/`admin` (Open Questions, line 54: "This blocks `npm run seed`, `npm run watch`, and `npm run admin`"), and spec execution requires seeded data (CUJ 4 Given: "the seed data is present"). So running/verifying specs before the credentials exist is impossible; only authoring can precede them. The stated ordering narrative does not match the actual gating.

**Finding 14**
- **Severity**: Nit
- **Affected Scope**: Additional Resources (line 224); provenance footer (lines 337–339)
- **Discrepancy Description & Rationale**: "7 Goldfish lenses" and "EGM" ("Provenance: Indicates initial structural drafting via EGM" / "Drafted with EGM") are process/provenance terms never defined. They are not load-bearing for the plan, but a fresh reader has no way to know what EGM is or what a "Goldfish lens" refers to.
