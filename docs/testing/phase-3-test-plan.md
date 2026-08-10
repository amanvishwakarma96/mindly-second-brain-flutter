# Phase 3 Test Plan — Text Capture + AI Extraction

## Goal
Deliver the first end-to-end Mindly capture path: typed/pasted text is saved locally first, then optionally sent directly from the client to the configured BYOK provider for structured extraction. No Mindly backend is introduced.

## Provider contract decisions
- OpenAI: use `POST /v1/responses`, `store: false`, and structured JSON schema output when supported.
- Anthropic: use `POST /v1/messages` with the required API/version headers and parse JSON from the returned text block.
- OpenAI-compatible: use a configurable base URL with a Chat Completions-compatible request/response contract for v1 compatibility.
- Provider credentials are read only through the Phase 2 secure key service and are never written to Drift, logs, errors, or capture metadata.

## Extraction schema
Every successful extraction must produce:
- `capture_id`
- `summary`
- `context`: `work`, `personal`, or `ambiguous`
- `people[]`
- `topics[]`
- `commitments[]`
- optional `tone`

Ambiguous context must remain explicitly `ambiguous`; Phase 3 must not silently guess work vs personal.

## Automated tests
| ID | Description | Expected result |
|---|---|---|
| P3-01 | Text capture saves before AI dispatch | Capture exists locally even if provider call fails |
| P3-02 | Empty/whitespace capture rejected | No DB row and no network request |
| P3-03 | Extraction schema parser accepts valid payload | Typed extraction model returned |
| P3-04 | Invalid/missing schema fields rejected | Controlled parse failure; raw provider body is not persisted |
| P3-05 | Ambiguous context preserved | Result context remains `ambiguous` |
| P3-06 | OpenAI request contract | `/v1/responses`, bearer key, `store:false`, structured schema request |
| P3-07 | Anthropic request contract | `/v1/messages`, x-api-key + anthropic-version, no key leakage |
| P3-08 | Compatible-provider request contract | Configured base URL + Chat Completions-compatible JSON |
| P3-09 | Missing provider key | Capture remains saved; extraction returns actionable missing-key state |
| P3-10 | Spend-cap preflight | Over-cap request is blocked before HTTP dispatch |
| P3-11 | Cost estimate surfaced before dispatch | Estimate available to orchestration/UI before provider call |
| P3-12 | Successful extraction persists structured memory | Summary/entities/commitments/relationships are linked to source capture |
| P3-13 | Provider failure does not destroy capture | Local source text remains available for retry |
| P3-14 | Credential logging guard | API key never appears in models/errors/logging paths |
| P3-15 | Mobile text-capture route | Mobile renders its own capture screen only |
| P3-16 | Desktop text-capture route | Desktop renders its own capture screen only |
| P3-17 | Web text-capture route | Web renders its own capture screen only |
| P3-18 | Screen-family boundary | No platform screen imports sibling platform screens |
| P3-19 | Existing DB/memory tests | Phase 1 data behavior remains green |
| P3-20 | Existing Phase 2 security tests | Key lifecycle, web warning and caps remain green |
| P3-21 | `flutter analyze` | No issues |
| P3-22 | Android debug build | Pass |
| P3-23 | iOS simulator debug build | Pass |
| P3-24 | Web build | Pass |
| P3-25 | Windows debug build | Pass |
| P3-26 | macOS debug build | Pass |
| P3-27 | Linux debug build | Pass |

## Generated-code gate
`lib/core/database/mindly_database.g.dart` is tracked so production builds that import the local database do not depend on another CI job's workspace. The permanent quality job regenerates Drift output and uses `git diff --exit-code` to detect drift from the committed generated source.

## Manual tests
1. Native: save a note with no internet; verify it remains in local memory and AI state is retryable.
2. Native: configure a real BYOK provider key and confirm a text capture receives a structured extraction.
3. Web: acknowledge the Phase 2 key warning, save a text capture, and confirm the provider call is made directly from the browser rather than through a Mindly server.
4. Ambiguous note: confirm the UI presents work/personal classification as unresolved rather than silently choosing one.

## Stop conditions
- Any credential leakage is a critical failure.
- Any path that sends provider traffic before spend-cap preflight is a critical failure.
- Any path that loses the locally saved capture after an AI/network failure is a critical failure.
- Any platform-screen boundary violation is a critical failure.
- Do not open a review-ready PR while any critical test or six-platform build is red.
