# Phase 7 completion report — Tier 3 AI-generated insights

Phase 7 completes the first predictive/generative layer of Mindly's Surface Engine. Tier 1 and Tier 2 remain deterministic and local-only; Tier 3 is an explicit, user-initiated BYOK flow that asks a selected provider for a small set of grounded recommendations or warnings derived only from a bounded relevant-memory context.

## Scope completed

- Add Tier 3 AI recommendation and warning kinds alongside the existing Tier 1/2 insight model.
- Build a bounded local context from recent captures, direct graph neighbors, and open commitments with deterministic deduplication and source keys.
- Add direct BYOK transports for OpenAI, Anthropic, and user-configured OpenAI-compatible providers; no Mindly inference/backend service is introduced.
- Estimate maximum request cost before generation and enforce the existing daily/rolling-seven-day spend caps before dispatch.
- Reject generation before provider dispatch when evidence is insufficient, the provider key is missing, or a spend cap blocks the request.
- Require every provider-generated card to cite one or more exact source keys from the supplied context; unknown/missing source references invalidate the provider response.
- Persist grounded Tier 3 cards locally, merge/deduplicate refreshes, and keep existing cards when a later valid provider response contains no new insight.
- Reuse the existing dismiss/mute preferences, including independent AI recommendation and AI warning categories.
- Expose "Why am I seeing this?" source navigation for AI cards.
- Keep Mobile, Desktop, and Web as independent screen implementations and make Tier 3 generation explicitly user-initiated on each surface.
- Add provider selection for OpenAI, Anthropic, and OpenAI-compatible providers. Compatible configuration includes base URL, model, and input/output token rates.
- Make the Web Insights header responsive so Tier 3 controls do not overflow at narrower browser widths.

## Architecture, privacy, and cost boundaries

- Opening or reloading Insights never initiates a paid Tier 3 provider request.
- Tier 1 and Tier 2 source files retain their offline/no-provider boundary.
- Tier 3 provider traffic goes directly from the client to the selected provider using the user's BYOK credential.
- The provider receives only the bounded context assembled for that generation attempt; Mindly does not upload the full local database.
- Provider output is treated as untrusted until JSON/schema checks, kind checks, text bounds, and exact source-key validation pass.
- Provider failures, invalid output, missing keys, or spend-cap blocks do not delete or mutate source memories.
- Successful provider usage is recorded through the existing local spend ledger; actual reported token usage is preferred when available.
- Tier 3 cards are clearly labeled as AI-generated and expose their supporting source memories.

## Automated validation

Permanent CI run `31486437673` passed all seven jobs on the code-complete head `2d985b5a11997cc71d6173b63feb28630b2a5333`:

| Gate | Result |
| --- | --- |
| Drift generated-code integrity | Pass |
| Dart formatter | Pass |
| Flutter analyzer | Pass |
| Full Flutter test suite | Pass |
| Tier 3 grounding/no-dispatch/spend/persistence regressions | Pass |
| Tier 1/2 offline-boundary regression | Pass |
| Vector benchmark characterization | Pass |
| Android debug build | Pass |
| iOS simulator debug build | Pass |
| Web build | Pass |
| Windows debug build | Pass |
| macOS debug build | Pass |
| Linux debug build | Pass |

The permanent CI matrix also exercised the existing Phase 0–6 architecture, database, BYOK, text capture, audio, memory/search/graph, and proactive-insight regressions.

## Acceptance mapping

- **Bounded relevant context:** Tier 3 context is assembled from a limited number of recent local captures, their direct graph neighbors, and open commitments; source keys are stable and deduplicated.
- **No fabricated evidence:** insufficient local evidence returns without provider dispatch, and provider output referencing anything outside the supplied context is rejected.
- **Explainability:** every accepted Tier 3 card has one or more local source references and the UI exposes "Why am I seeing this?" navigation.
- **Cost control:** cost estimation and daily/weekly spend-cap enforcement occur before dispatch; successful usage is recorded.
- **BYOK privacy:** OpenAI, Anthropic, and compatible-provider calls are direct from the client; no Mindly AI backend is added.
- **User control:** Tier 3 generation is explicit, cards are dismissible, and AI recommendations/warnings can be muted independently without mutating source memories.
- **Persistence:** grounded cards reload locally without a provider call and refreshes merge/deduplicate instead of erasing prior valid cards.
- **Platform isolation:** Mobile, Desktop, and Web retain separate screen files while sharing only application/domain/data logic.

## Manual follow-up not claimed by CI

CI intentionally does not claim the following release-level checks:

1. Real OpenAI, Anthropic, and OpenAI-compatible requests with production credentials and provider billing.
2. Model-quality review against realistic dense/sparse personal-memory datasets, including false-positive and overconfident-warning review.
3. Real provider rate-limit/outage behavior and actual token-usage/billing reconciliation.
4. Browser CORS/direct-provider behavior for real endpoints and the existing Web key-risk acknowledgement flow in a real browser.
5. Real-device/browser visual hierarchy, keyboard navigation, screen-reader labels, and accessibility review for the new Tier 3 controls/cards.
6. End-to-end source-detail navigation with realistic mixed capture/commitment graphs.

## Deferred to Phase 8 and later

- Notification delivery for surfaced insights.
- Notification frequency, quiet hours, and category controls.
- Passive/background paid Tier 3 generation; Phase 7 intentionally keeps provider calls explicit/user-initiated for privacy and cost control.
- Cross-device encrypted sync of Tier 3 preferences/cards.

Phase 7 is ready for review after the final branch-head CI pass. It must not be auto-merged; Phase 8 starts only after Phase 7 is reviewed and merged/signaled complete.
