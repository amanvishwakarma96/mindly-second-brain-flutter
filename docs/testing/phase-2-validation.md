# Phase 2 Validation Record

Phase 2: BYOK key management, spend controls, and mandatory Web key warning.

## Security controls under validation

- Provider API keys use the secure-storage abstraction and are not persisted in Drift.
- Key lifecycle supports add, rotate, read-for-dispatch, presence checks, and removal.
- Web key writes require explicit acknowledgement of the SRS browser-storage warning.
- The exact mandatory Web warning is rendered only by the Web settings implementation.
- Cost estimates are calculated before dispatch inputs are accepted by the spend guard.
- Daily and rolling seven-day spend caps can block projected AI spend.
- Credential logging/source guards and platform-screen architecture boundaries are covered by automated tests.
- Android backup is disabled for secure-storage protection.
- Apple targets include Keychain entitlements.
- Linux CI installs libsecret runtime/development dependencies.

## Release gate

This phase is not considered complete until the permanent CI workflow passes formatting, generated-code verification, analyzer, full tests, vector characterization, and Android, iOS, Web, Windows, macOS, and Linux builds from the final branch head.
