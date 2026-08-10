# Phase 2 Test & Security Plan — BYOK Key Management

## Goal

Implement local BYOK provider key management, nontrivial-call cost controls, and the mandatory Web API-key warning without introducing a Mindly backend or leaking provider credentials.

## Security invariants

1. Provider API keys are never written to Drift, logs, analytics, crash text, test snapshots, or source-controlled configuration.
2. Native targets store provider secrets only through OS-backed secure storage abstractions.
3. Web must display the mandatory warning before a key can be saved/used:

   > On web browsers, we can't fully protect your API key the way we can on the app — anyone with access to this device/browser session could potentially view it. Consider a key with provider-side spending limits.

4. Add / remove / rotate key operations must not expose the raw key after persistence.
5. Provider requests remain direct client-to-provider; no Mindly backend is introduced.
6. Cost estimation occurs before nontrivial AI calls and spend caps can block a call before dispatch.
7. Tests and fixtures use fake/non-secret values only.

## Automated test matrix

| ID | Area | Validation | Expected |
|---|---|---|---|
| P2-01 | Provider model | OpenAI, Anthropic and compatible-provider configurations serialize without raw secrets | Pass |
| P2-02 | Key storage | Save and retrieve a key through the secure-store abstraction | Returned only to the requesting service; no plaintext persistence outside store |
| P2-03 | Key removal | Remove provider key | Subsequent lookup returns no key |
| P2-04 | Key rotation | Replace an existing provider key | New key available, previous key unavailable |
| P2-05 | Redaction | Error/debug representations for credentials | Raw key never appears |
| P2-06 | Web warning | Web key-entry flow | Exact mandatory warning visible before key acceptance |
| P2-07 | Native warning isolation | Mobile/Desktop key-entry flows | Web-specific warning is not incorrectly shown |
| P2-08 | Cost estimate | Estimate a representative request before dispatch | Deterministic estimate returned with provider/model metadata |
| P2-09 | Daily cap | Request would exceed configured daily spend cap | Call is blocked before dispatch |
| P2-10 | Weekly cap | Request would exceed configured weekly spend cap | Call is blocked before dispatch |
| P2-11 | Within cap | Estimated request remains under caps | Call may proceed |
| P2-12 | No cap | Caps disabled | Estimation still available; request is not blocked by cap policy |
| P2-13 | Logging guard | Search source/tests for credential logging patterns | No raw-key logging path |
| P2-14 | Architecture | Core/security and AI configuration remain screen-independent | No screen imports in shared logic |
| P2-15 | Regression | Existing Phase 0/1 tests | Pass |
| P2-16 | Android build | Debug APK | Pass |
| P2-17 | iOS build | Simulator debug build | Pass |
| P2-18 | Web build | Flutter Web build | Pass |
| P2-19 | Windows build | Debug build | Pass |
| P2-20 | macOS build | Debug build | Pass |
| P2-21 | Linux build | Debug build | Pass |

## Security review checklist

- [ ] No provider key is stored in Drift/SQLite.
- [ ] No raw provider key appears in logs, exceptions, `toString()`, analytics, or crash-report payloads.
- [ ] Native secure-store implementation uses platform-secure storage through a maintained Flutter abstraction.
- [ ] Web behavior is explicitly separated and accompanied by the mandatory warning.
- [ ] Key rotation overwrites/removes the prior secret.
- [ ] Provider identifiers and non-secret configuration may be persisted separately from credentials.
- [ ] Spend limits are evaluated before dispatch.
- [ ] No server-side Mindly credential proxy is introduced.
- [ ] Dependency additions are reviewed for all six Flutter targets.

## CI gate

Phase 2 is not ready for review until formatting, analyzer, generated-code verification, full tests, security checks, and all six platform builds are green. Any critical credential-handling failure blocks the phase.