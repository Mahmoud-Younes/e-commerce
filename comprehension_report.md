# Comprehension Report — Stage 6 (Comprehension Test)

**Target:** `docs/designs/demo-ready-prd-completion.md` (FeatureRange 1–237, DetailedRange 238–339)
**Reviewer:** `egm-comprehension` (completed)

--------------------------------------------------------------------------------

## What this proposes

The document is a completion plan that turns an already-built Flutter e-commerce app into a "demo-ready" product for a graduation-style demo. It commits to four streams: (1) seeding 30 bilingual (Arabic/English) demo products with images into the live Firestore project `sahety-ba784`, rendered per device locale with English fallback and correct RTL layout; (2) making admin product-image upload actually work against a real public Supabase `product-images` bucket; (3) free order-status notifications delivered by a locally-run Node.js Firebase Admin SDK "watcher" that both sends bilingual FCM push messages and writes the in-app notification records — avoiding Firebase's paid Blaze plan and keeping the client-side write rules strict; and (4) per-feature e2e specs run one at a time on the Pixel 7 Pro emulator, each followed by a manual screenshot review, closing with a notification scenario and the PRD §9 acceptance checklist. Most implementation has already landed; the remaining work is authoring five e2e specs, two small production-code changes (cart-button tooltips, route normalization), a Firestore rules test, owner-supplied credentials (service-account JSON, Supabase bucket creation), and the run/verify sequence.

## How the existing system works, per this document

The app is a feature-first Flutter codebase (Cubits, Firebase Auth, Firestore, FCM, Supabase Storage) with customer and admin roles held in `users/{uid}.role`. Before this plan, Arabic content could not render because `MaterialApp` had no localization delegates or supported locales; the Supabase uploader existed but `Supabase.initialize` was never called, so the first upload would throw; `FcmService` and its background handler were dead code never wired into app startup; and clients cannot write `notifications` documents because `firestore.rules` rejects customer writes — with no server-side writer, notification records never existed. An e2e harness (`tests/*.e2e.ts`, Pixel 7 Pro emulator) exists but only the auth feature had a spec. Ops scripts in a gitignored `scripts/` directory (seed, watch-orders, reset, admin bootstrap) plus the localization plumbing, bilingual model fields, and Supabase initialization have since landed, which is why the remaining work concentrates on verification.

--------------------------------------------------------------------------------

## Findings

### 🟡 Major — Opaque internal identifiers (M5, M8, B3, N4) are never defined

**Severity**: 🟡 Major
**Affected scope**: "Remaining changes" item 2 ("M8"), item 5 ("B3's no-regression guarantee"); "Verification Plan" ("Data hygiene (M5)", "Visual review checklist (N4)"); "Detailed Implementation Plan" intro ("closes M8"), item 2 ("route normalization, M8"), item 10 ("B3 decision", "The brief (B3) committed…"); "Alternative E" ("the code/rules contradiction from the brainstorm").
**Description**: Four identifiers — M5, M8, B3, N4 — plus the referent "the brief" are used as if the reader already knows a predecessor artifact. The only hint is in Additional Resources: `concepts_brief.md` is described as a "predecessor brainstorm artifact (7 Goldfish lenses, deduplicated)". The ID-to-meaning mapping is never given, so a fresh reader cannot decode what these commitments are without opening another file that may itself be local-only. The surrounding prose does describe the substance in each case (uniform BlocProvider routing, rules test, namespaced e2e users, screenshot checklist), so the plan stays executable — hence Major, not Blocker. Phrases like "restored by author decision at finalization" and "restores that commitment into the plan of record" add internal-workflow history that is also undecodable.
**Recommendation**: Gloss each identifier inline at first use (e.g., "M8 — the brief's routing-uniformity commitment", "B3 — the brief's decision that notification writes happen server-side only", "M5 — the brief's data-hygiene rule", "N4 — the brief's screenshot-review note"), or drop the IDs and keep the plain descriptions. Add one line stating that all such IDs come from `concepts_brief.md`.

### 🟡 Major — The Arabic RTL review run is mandated but its mechanism is unstated

**Severity**: 🟡 Major
**Affected scope**: "Goals" G4; "CUJ 4" Then; "Remaining changes" item 6; "Verification Plan" ("Visual review checklist (N4)", "E2E execution discipline").
**Description**: The plan requires that after each spec, screenshots are reviewed for an "Arabic RTL run (device locale `ar`)" — but no step says how that run is produced: who or what switches the emulator's locale to `ar` (emulator settings, an adb command, a runner flag, a separate spec variant), whether the identical spec is re-run unchanged, or what "pass" means for that run. The reconciliation is also left implicit: "Remaining changes" item 3 says specs use "English-only assertions", and Non-Goals says screen labels stay English, so the Arabic run can only be validated by human screenshot review — a reader must assemble that inference themselves. This is an assumed workflow prerequisite: executing the checklist as written is impossible without unstated setup knowledge.
**Recommendation**: Add one or two sentences to the Verification Plan: how the emulator locale is set to `ar` before the Arabic re-run, that the same spec is re-run with no (or relaxed) programmatic assertions, and explicitly that Arabic runs are validated by screenshot review only while automated assertions remain English-only.

### 🟢 Nit — FCM is never expanded; other ecosystem shorthand assumes Firebase/Android familiarity

**Severity**: 🟢 Nit
**Affected scope**: Throughout — first use in the Overview ("the FCM receiver was dead code"); also `UNREGISTER` (Non-Goals, Alternative F) and "Google APIs image" (Open Question 3).
**Description**: "FCM" is never expanded to "Firebase Cloud Messaging" anywhere in the document. It is standard Firebase vocabulary, but since push delivery is one of the document's four core streams, a one-time expansion would make the document fully self-contained. Similarly, `UNREGISTER` (an FCM error code for stale tokens) and the significance of the emulator being a "Google APIs image" (why that image type makes FCM delivery uncertain) are used without gloss.
**Recommendation**: Expand FCM at first use ("FCM (Firebase Cloud Messaging)"); add a parenthetical for `UNREGISTER` and a half-sentence on why the emulator image type puts FCM delivery in doubt.

### 🟢 Nit — The `\uf8ff` range endpoint is unexplained

**Severity**: 🟢 Nit
**Affected scope**: "Contracts the remaining work depends on" ("Seed documents"); Detailed Plan item 11.
**Description**: "`reset.mjs` deletes the exact range `seed_`..`seed_\uf8ff`" uses the Unicode escape U+F8FF — the largest code point — as a Firestore range trick to make the prefix range inclusive of every `seed_*` document. A reader unfamiliar with this idiom has no way to decode it from the text.
**Recommendation**: One parenthetical: "`\uf8ff` (the last Unicode code point, so the range covers every `seed_` document)".

### 🟢 Nit — Overview says "real device" while the entire verification plan runs on an emulator

**Severity**: 🟢 Nit
**Affected scope**: Overview item 4 vs. CUJ 4, Verification Plan, Open Question 3.
**Description**: The Overview states the gap as "no test walks each feature end-to-end on a real device", but every subsequent section (CUJ 4, E2E execution discipline) runs the specs on the Pixel 7 Pro emulator; a physical device appears only as the FCM fallback in Open Question 3. A naive reader meets an apparent contradiction on the very first page.
**Recommendation**: Reword the Overview to "on the emulator (physical device only as the FCM fallback)".

### 🟢 Nit — Self-contradicting sentence in the admin e2e spec item; admin password source unstated

**Severity**: 🟢 Nit
**Affected scope**: Detailed Plan item 9; also CUJ 2 and "Non-Functional Requirements".
**Description**: Item 9 opens "Register a customer, then promote it via `npm run admin` semantics…" and immediately contradicts itself in the parenthetical "(…the spec instead uses the seeded `admin@sahety.app` account…)", where "instead" signals the first clause is a stale leftover. A reader must untangle which approach the spec actually takes. Relatedly, the spec (and CUJ 2) require signing in as `admin@sahety.app`, but the document never says where the password comes from — NFRs only say it "is documented as demo-only" without a location.
**Recommendation**: Delete the stale first clause so the item states only the seeded-admin approach; state where the demo admin password is documented (presumably `./scripts/README.md`).

### 🟢 Nit — "No agent/model steps" assumes knowledge of the e2e runner's AI capabilities

**Severity**: 🟢 Nit
**Affected scope**: Verification Plan, "E2E execution discipline".
**Description**: "Specs are deterministic screen/expect steps only — no agent/model steps" only makes sense if the reader already knows the e2e runner supports optional AI-agent/model-driven steps. Nothing in the document introduces that capability, so the constraint reads as a non sequitur.
**Recommendation**: One clause: "…only deterministic locator/expect steps, not the runner's optional AI-agent steps."

### 🟢 Nit — PRD-internal references rely on an external, gitignored file without gloss

**Severity**: 🟢 Nit
**Affected scope**: Overview ("stages 1–7 committed to `main`"); Detailed Plan items 5–9 (PRD §2/§3/§4/§5 tags); item 14 ("PRD §7's products row").
**Description**: The PRD is properly named and listed in Additional Resources, so pointing to it is acceptable; but "stages 1–7" (whose stages?), and especially "PRD §7's products row" (a table row in §7? which column?) are cryptic even with the pointer. §9 and §6 are glossed inline; the others are not.
**Recommendation**: Gloss at first use, e.g., "stages 1–7 of the PRD's implementation plan" and "PRD §7's data-model table row for the `products` collection".

### 🟢 Nit — Conflicting data-dependency policy between the cart and orders specs

**Severity**: 🟢 Nit
**Affected scope**: Detailed Plan item 6 vs. item 8 and the "one spec at a time" discipline.
**Description**: Item 6 says the cart spec may "leave one item in cart for the checkout spec's starting state or re-add as needed", implying inter-spec state handoff; item 8 says the orders spec creates its order "in-spec … rather than depending on another spec's leftovers", implying each spec is self-sufficient. A naive reader cannot tell which policy governs.
**Recommendation**: State one policy once (e.g., "every spec sets up its own data; no spec depends on another's leftovers") and make item 6 comply.

### 🟢 Nit — Stray `products` bucket mention in Open Question 2

**Severity**: 🟢 Nit
**Affected scope**: "Open Questions", item 2.
**Description**: "Both `products` and `product-images` were probed and returned 'Bucket not found'" — but the design uses only the `product-images` bucket everywhere else; nothing explains what the `products` bucket is or why it was probed (the constant name `SupabaseConfig.productsBucket` also points at `product-images`). A reader wonders whether a second bucket is required.
**Recommendation**: Either drop `products` or add "(a legacy/incorrect bucket name checked during diagnosis; only `product-images` is needed)".

### 🟢 Nit — "EGM" and "Goldfish lenses" provenance terms are unexplained

**Severity**: 🟢 Nit
**Affected scope**: Footer ("Drafted with EGM", the provenance HTML comment); Additional Resources ("7 Goldfish lenses, deduplicated").
**Description**: EGM is an acronym never expanded, and "Goldfish lenses" is internal vocabulary; both appear only in metadata, so they do not affect the plan's substance, but a fresh reader cannot decode them.
**Recommendation**: Expand once ("Drafted with EGM (…)") or remove the provenance footer; gloss "lenses" as "review perspectives" or drop the phrase.
