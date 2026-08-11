# Phase 7 test plan — Tier 3 AI synthesis and explainability

Phase 7 adds user-triggered Tier 3 AI synthesis over a bounded local evidence bundle. It reuses Mindly's existing BYOK provider keys, direct provider transport pattern, cost estimation, and spend caps. Tier 1 and Tier 2 remain local-only and must continue to work when Tier 3 is unavailable.

## Acceptance rules

- Tier 3 generation is never automatic on screen load; a user action is required for every provider dispatch.
- Mindly must show an estimated cost and source count before the user can trigger a non-trivial Tier 3 request.
- The evidence bundle is bounded to at most 8 unique local source memories and at most 12,000 characters of source content/metadata.
- Provider requests go directly from the client with the user's BYOK key; no Mindly inference backend is introduced.
- Missing provider key, invalid configuration, or spend-cap denial must stop before any network dispatch.
- OpenAI Responses requests must disable provider-side response storage with `store: false` and request strict structured JSON output.
- Anthropic Messages requests must request structured JSON output using the provider's structured-output configuration.
- OpenAI-compatible providers follow the existing compatible-provider transport contract and must still be post-validated locally.
- Every generated Tier 3 insight must cite at least one source ID supplied in the bounded evidence bundle.
- If the provider returns an unknown, missing, duplicated-only, or otherwise invalid source reference, the generated insight is rejected rather than surfaced.
- Provider text is never treated as a source of truth for source identity; source references are rebuilt from local evidence after validation.
- Provider/API failures must not remove, replace, or hide eligible Tier 1/Tier 2 insights.
- API keys and raw authorization headers must never appear in user-facing errors, logs, fingerprints, or persisted insight preferences.
- Mobile, Desktop, and Web keep separate screen implementations while sharing the Tier 3 application/domain layer.
- CI may mock provider responses and request contracts; it must not claim live-provider or real-device/browser coverage.

## Automated test matrix

| ID | Description | Expected |
| --- | --- | --- |
| P7-01 | Tier 3 screen load without user action | No provider transport call occurs |
| P7-02 | Bounded evidence builder with many local sources | Bundle contains at most 8 unique sources and <= 12,000 characters |
| P7-03 | Evidence ordering/deduplication | Repeated preparation yields deterministic source ordering and no duplicates |
| P7-04 | Cost preview | Preview exposes provider/model, estimated cost, and bounded source count before dispatch |
| P7-05 | Missing provider key | Generation is blocked before transport invocation |
| P7-06 | Spend-cap denial | Generation is blocked before transport invocation and spend is not recorded |
| P7-07 | OpenAI request contract | Direct Responses request uses `store: false` and strict JSON schema output |
| P7-08 | Anthropic request contract | Direct Messages request uses structured JSON output configuration |
| P7-09 | OpenAI-compatible contract | Existing compatible endpoint/model configuration is honored and response is locally validated |
| P7-10 | Valid sourced Tier 3 response | Insight is surfaced as Tier 3 with locally rebuilt source references |
| P7-11 | Unknown source ID from provider | Entire generated insight is rejected |
| P7-12 | Empty source list from provider | Generated insight is rejected |
| P7-13 | Invalid severity/schema/provider payload | Generated insight is rejected with safe error state |
| P7-14 | Provider failure isolation | Existing Tier 1/Tier 2 list remains available after Tier 3 failure |
| P7-15 | Spend recording | Estimated spend is recorded only after successful provider generation |
| P7-16 | Credential redaction guard | Raw key/Authorization value never appears in errors, logs, fingerprints, or preferences |
| P7-17 | Tier 3 dismissal | Current generated card can be dismissed without mutating source memories |
| P7-18 | Source traceability | Every surfaced Tier 3 source opens a resolvable local source detail |
| P7-19 | Mobile generation UX | Mobile shows cost/source preview and explicit generate action in mobile-specific layout |
| P7-20 | Desktop generation UX | Desktop shows cost/source preview and explicit generate action in desktop-specific layout |
| P7-21 | Web generation UX | Web shows cost/source preview and explicit generate action in web-specific layout |
| P7-22 | Screen-family boundary regression | Mobile/Desktop/Web insight screen implementations remain separate |
| P7-23 | Existing Phase 0–6 regression suite | Existing tests remain green |
| P7-24 | Six-platform build matrix | Android, iOS simulator, Web, Windows, macOS, and Linux build successfully |

## Manual review script

1. Configure a provider key and conservative daily/weekly spend caps.
2. Seed several related captures/commitments so Tier 1 and Tier 2 local insights are visible.
3. Open Insights and confirm no Tier 3 request is sent automatically.
4. Review the displayed Tier 3 estimated cost and bounded source count, then explicitly trigger generation.
5. Open every source attached to the generated Tier 3 card and confirm it resolves to local memory content.
6. Disconnect the network and verify Tier 1/Tier 2 still load while Tier 3 fails safely.
7. Remove the provider key and confirm Tier 3 blocks before dispatch while local insights remain intact.
8. Set a spend cap below the previewed request and confirm generation is blocked before dispatch.
9. Repeat on Mobile, Desktop, and Web to review platform-specific interaction and browser-provider behavior.

## Deferred to later phases

- Automatic/background Tier 3 generation or scheduled proactive refresh.
- Local/push notification delivery of insights.
- Optional encrypted sync of generated-session state/preferences.
- Passive ambient capture triggers.

Hosted CI does not claim live OpenAI/Anthropic/compatible-provider requests, browser CORS behavior against a user's provider account, real-device UX, accessibility, or billing accuracy beyond the app's configured estimator. Those remain manual validation items.