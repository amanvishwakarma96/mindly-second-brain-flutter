# Phase 7 test plan — Tier 3 AI-generated insights

Phase 7 adds predictive Tier 3 recommendations and warnings generated directly by the user's configured BYOK AI provider from a bounded, relevant local-memory context. Tier 1 and Tier 2 remain local-only. No Mindly backend, hosted inference, notification scheduling, sync, or passive capture is introduced.

## Acceptance rules

- Tier 3 generation is explicit/user-initiated; opening the Insights screen must never trigger a paid provider call.
- Before dispatch, the app must show a cost estimate and enforce the existing daily/weekly spend caps.
- If evidence is insufficient, no provider key lookup or provider request is required and no fabricated insight is surfaced.
- Provider requests contain only the bounded local context selected for the generation attempt and go directly to the chosen provider.
- Every returned Tier 3 insight must reference one or more source keys supplied in that request; unknown/missing source references make the provider output invalid.
- Tier 3 cards are clearly labeled AI-generated, can be dismissed, and can be muted independently by recommendation/warning category.
- Dismiss/mute operations never delete or mutate source memories.
- Generated Tier 3 cards persist locally so reopening Insights does not require another provider call.
- Provider failures, invalid JSON/schema, missing keys, and spend-cap blocks degrade gracefully without changing source memories.
- Mobile, Desktop, and Web keep separate screen implementations while sharing Tier 3 application/domain/data logic.

## Automated test matrix

| ID | Description | Expected |
| --- | --- | --- |
| P7-01 | Bounded context construction | Only the configured latest captures/open commitments are included; each has a stable source key |
| P7-02 | Insufficient evidence | Returns insufficient-evidence outcome and performs no provider request |
| P7-03 | Pre-dispatch cost estimate | Estimate is available before generation and uses the selected provider rate card |
| P7-04 | Missing BYOK key | Returns missing-key outcome and performs no provider request |
| P7-05 | Daily spend cap | Generation is blocked before dispatch when projected daily spend exceeds the cap |
| P7-06 | Weekly spend cap | Generation is blocked before dispatch when projected weekly spend exceeds the cap |
| P7-07 | Provider failure | Returns provider-failure outcome and keeps source memories unchanged |
| P7-08 | Invalid JSON/schema | Returns invalid-output outcome and persists no Tier 3 card |
| P7-09 | Unknown source reference | Provider output referencing a source not supplied in the request is rejected |
| P7-10 | Valid recommendation | Persists an AI recommendation with one or more valid source-memory references |
| P7-11 | Valid warning | Persists an AI warning with one or more valid source-memory references |
| P7-12 | Explainability | Every surfaced Tier 3 card exposes its exact source memories through existing source-detail navigation |
| P7-13 | Local persistence | Generated Tier 3 cards reload without a new provider request |
| P7-14 | Dismiss persistence | Dismissed Tier 3 fingerprint stays hidden on reload |
| P7-15 | Category mute/unmute | AI recommendations and AI warnings can be muted independently |
| P7-16 | Spend recording | Successful provider usage is recorded using actual usage when available |
| P7-17 | No implicit generation | Normal `InsightController.load()` never invokes the Tier 3 transport |
| P7-18 | Direct-provider boundary | Tier 3 production path contains no Mindly backend or hosted service dependency |
| P7-19 | Platform screen labels | Mobile/Desktop/Web render Tier 3 cards as AI-generated while retaining independent screen files |
| P7-20 | Phase 0–6 regression suite | Existing architecture, data, BYOK, capture, audio, memory, and Tier 1/2 tests remain green |
| P7-21 | Six-platform build matrix | Android, iOS simulator, Web, Windows, macOS, and Linux build successfully |

## Manual review script

1. Configure an OpenAI or Anthropic BYOK key and low but non-zero spend caps.
2. Seed at least three related captures/commitments with enough context for a recommendation or warning.
3. Open Insights and confirm no network/provider activity occurs automatically.
4. Tap the Tier 3 generate action, review the provider + maximum estimated cost, and confirm the call.
5. Verify every returned AI card is labeled as AI-generated and exposes "Why am I seeing this?" source chips/details.
6. Dismiss one AI card, reload/restart, and confirm it stays dismissed without another provider call.
7. Mute AI recommendations, verify warnings remain visible, then unmute recommendations.
8. Remove the provider key and confirm generation shows a missing-key state without losing existing cards.
9. Set a spend cap below the projected request and confirm the call is blocked before provider dispatch.
10. Test provider-unavailable/rate-limited behavior and confirm existing memories and previously generated cards remain intact.
11. Repeat generation smoke tests on Mobile, Desktop, and Web; on Web confirm the existing browser key-security warning/acknowledgement flow still applies.

## Deferred to later phases

- Phase 8 notification delivery and quiet-hour/frequency controls.
- Cross-device Tier 3 generation or sync-triggered insights.
- Passive ambient triggers.
- Background autonomous/periodic paid Tier 3 generation; Phase 7 is intentionally explicit/user-initiated to preserve cost and privacy control.

Hosted CI does not claim real-provider billing behavior, model quality, browser CORS policy, or real-device visual/accessibility quality. Those remain manual validation items.
