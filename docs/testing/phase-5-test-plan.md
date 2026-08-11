# Phase 5 test plan — memory browser, search, and graph

## Goal
Phase 5 turns the local memory store built in Phases 1–4 into a browsable, searchable, explainable memory surface without adding a Mindly backend. It must reuse Drift/FTS5/vector/relationship data already present locally and preserve the independent Mobile, Desktop, and Web screen families.

## Scope
- Browse captures, people, topics, and commitments from local Drift data.
- Filter captures by context, mode, pinned state, and date ordering.
- Open a memory detail view that shows source text/transcript/summary and connected entities.
- Run lexical FTS5 search and expose a hybrid-search application boundary that can merge lexical and vector hits when a query embedding is available.
- Keep semantic ranking model/dimension isolated; do not fabricate semantic matches when no embedding is available.
- Traverse the local relationship graph in both directions with bounded depth and cycle protection.
- Render graph-adjacent memory data in independent Mobile, Desktop, and Web screen implementations.
- Preserve delete/wipe behavior and all Phase 0–4 security/architecture boundaries.

## Explicit non-goals
- No hosted Mindly search service or server-side index.
- No new AI provider call solely to manufacture query embeddings in Phase 5. The hybrid-search boundary accepts an optional query embedding; lexical search remains fully usable without one. A provider/local embedding production strategy must be introduced explicitly in a later phase before semantic UI can claim end-to-end availability.
- No Tier 1/2 proactive insight surfacing; that is Phase 6.
- No Tier 3 AI recommendations; that is Phase 7.
- No collapse of Mobile/Desktop/Web into a shared responsive screen.

## Automated validation

| ID | Description | Steps | Expected |
| --- | --- | --- | --- |
| P5-01 | Capture browser ordering | Seed captures with different timestamps and load browser page | Newest-first deterministic ordering |
| P5-02 | Capture browser filters | Seed work/personal, text/audio, pinned/unpinned captures and apply filters | Only matching captures are returned |
| P5-03 | People/topic/commitment browsing | Seed each entity type and list each collection | Correct typed rows returned without cross-type leakage |
| P5-04 | Memory detail resolution | Seed a capture with summary/source plus connected entities | Detail returns source fields and connected graph neighbors |
| P5-05 | Empty/detail-not-found states | Request empty collection and unknown ID | Empty list and explicit not-found result; no exception leakage |
| P5-06 | FTS lexical search | Seed indexed documents and query multiple tokens | Relevant FTS hits returned in rank order |
| P5-07 | FTS escaping | Search punctuation/quotes/blank input | Query remains safe; invalid raw FTS syntax is not injected |
| P5-08 | Hybrid search without query vector | Run hybrid search with only text query | Lexical results returned; no fabricated semantic score |
| P5-09 | Hybrid search with query vector | Seed embeddings and provide matching model/dimension query vector | Lexical and semantic hits merge/deduplicate deterministically |
| P5-10 | Semantic isolation | Seed embeddings from different models/dimensions | Only requested model/dimension contributes semantic rank |
| P5-11 | Graph bidirectional traversal | Seed incoming and outgoing edges and load neighborhood | Both directions are represented with relation labels |
| P5-12 | Graph cycle protection | Seed cyclic graph and traverse bounded depth | Traversal terminates, contains no duplicate node explosion |
| P5-13 | Graph depth bound | Seed chain longer than requested depth | Nodes beyond configured depth are excluded |
| P5-14 | Delete consistency | Delete an entity visible in browser/search/graph | Entity disappears from list, FTS/vector data, and graph edges |
| P5-15 | Platform routing | Route memory browser/search/graph for Mobile/Desktop/Web families | Each family resolves to its own screen implementation |
| P5-16 | Screen architecture boundary | Run architecture tests over `lib/screens/**` | Mobile/Desktop/Web screens do not import each other |
| P5-17 | UI state coverage | Pump each family with loading, empty, data, search-result, and detail states | No exceptions/overflow in test viewport; states are explicit |
| P5-18 | Regression suite | Run existing Phase 0–4 tests | Existing local-first, BYOK, audio, and security behavior remains green |
| P5-19 | Generated Drift integrity | Run build_runner and `git diff --exit-code` | Generated code is current with no uncommitted drift |
| P5-20 | Six-target build matrix | Build Android, iOS simulator, Web, Windows, macOS, Linux | All permanent CI jobs pass |

## Manual validation before release
1. Populate a realistic mixed memory set on one native target and verify browsing/filtering/search navigation feels coherent.
2. Verify a browser reload retains memory browser/search results through the existing Drift WASM persistence path.
3. Inspect graph presentation with dense and sparse neighborhoods on Mobile, Desktop, and Web.
4. Verify keyboard navigation/shortcuts on Desktop and browser back behavior on Web where implemented.
5. Confirm semantic-search UI never implies semantic coverage when no query embedding is available.

## Critical gates
Phase 5 must not open a PR until P5-01 through P5-20 are green in permanent CI where automatable. Manual items remain explicitly manual and must not be reported as CI coverage.
