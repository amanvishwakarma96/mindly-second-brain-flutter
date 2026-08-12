# Phase 8 Completion Report

## Status

Phase 8 — Notifications is complete for automated acceptance as of 2026-08-12.

- Code acceptance head: `4b1cac6e416b4e8a0e893b35f98d1ae2594e762b`
- Permanent code CI run: `31578841605`
- Flutter tests: 123 passed
- Result: all seven permanent CI jobs passed on the code acceptance head.

## Delivered

### Privacy-first notification lifecycle

- Notifications are off by default.
- When notifications are disabled, app startup stays fully lazy: Mindly does not initialize the native notification plugin and does not create the Insights/Drift database solely for notification preparation.
- Notification permission is requested only after an explicit first enable action.
- If permission is denied, enabled preferences are not persisted.
- Turning previously enabled notifications off initializes only the native bridge needed to cancel pending notification IDs; it does not request permission or create the Insights service.
- No Mindly notification backend was introduced and Phase 8 never runs AI generation in the background.

### Tier 2 pattern alerts

- New currently visible Tier 2 insights can be scheduled as one-shot local notifications.
- The notification path reuses the local Insights controller, so muted and dismissed local insights are filtered before scheduling.
- Stable insight fingerprints are persisted as deduplication keys so the same insight is not scheduled again on every reconciliation.
- The persisted fingerprint history is bounded and kept in secure local storage.

### Scheduled digests and quiet hours

- Digest frequency supports Off, Daily, and Weekdays.
- Users can choose a local digest time.
- Mindly keeps a bounded rolling window of 14 one-shot digest notifications rather than relying on platform repeating APIs.
- Quiet hours support both daytime and overnight windows, including the default 22:00–07:00 window.
- Candidates inside quiet hours are delayed to the next allowed local time.
- Android uses inexact allow-while-idle scheduling and therefore does not request exact-alarm permission.

### Notification interaction and persistence

- Notification payloads contain only an allowlisted local route plus an optional insight fingerprint.
- Valid notification taps route to the Insights screen.
- Invalid payloads and non-Insights routes are ignored safely.
- Memory content, provider API keys, and credentials are never placed in notification payloads.
- Notification preferences, pending notification IDs, and deduplication state are stored locally using the existing secure-store boundary.

### Platform-specific UX

- Mobile, Desktop, and Web each have their own Notification Settings screen family.
- Android, iOS, macOS, and Windows expose scheduled-local-notification capability.
- Android registers the plugin scheduling/boot receivers so pending notifications can be restored after reboot or package replacement.
- Windows uses the same bounded one-shot rolling schedule because the selected notification API does not provide repeating scheduling.
- Linux explicitly reports that scheduled/pending notifications are unavailable with the current desktop notification API; Phase 8 does not substitute a fake scheduler.
- Web explicitly reports that reliable scheduled/repeating local notification delivery is unavailable and does not request browser notification permission.
- Cross-device push remains deferred to the later optional encrypted-sync milestone, as required by the SRS.

### Build reproducibility and desktop regression hardening

- `pubspec.lock` is now tracked for reproducible Flutter application dependency resolution.
- Adding the Notification entry exposed a short-height Desktop sidebar overflow. The navigation section is now height-safe and scrollable while AI settings remains anchored at the bottom.

## Automated acceptance

Permanent CI run `31578841605` passed on code head `4b1cac6e416b4e8a0e893b35f98d1ae2594e762b`.

| Gate | Result |
| --- | --- |
| Drift generated-code integrity | Pass |
| Dart formatter | Pass |
| Flutter analyzer | Pass — no issues |
| Full Flutter test suite | Pass — 123 tests |
| Notification quiet-hours planning | Pass |
| Daily/weekday bounded digest planning | Pass |
| Tier 2 filtering and fingerprint deduplication | Pass |
| Lazy disabled startup / permission lifecycle | Pass |
| Disable-and-cancel lifecycle | Pass |
| Notification persistence and corrupt-state fallback | Pass |
| Notification tap payload routing | Pass |
| Mobile/Desktop/Web notification settings routing | Pass |
| Existing Phase 0–7 regressions | Pass |
| Vector benchmark characterization | Pass |
| Android debug build | Pass |
| iOS simulator debug build | Pass |
| Web build | Pass |
| Windows debug build | Pass |
| macOS debug build | Pass |
| Linux debug build | Pass |

## Manual follow-up not claimed by CI

- Real OS permission prompts and notification presentation on physical Android/iOS devices and installed macOS/Windows builds.
- Android OEM background scheduling and reboot/package-replacement restoration behavior.
- Notification taps from foreground, background, and terminated application states on physical targets.
- Daylight-saving-time transitions in a locale whose UTC offset changes.
- Windows packaged/MSIX behavior for notification cancellation/history APIs.
- Linux immediate desktop notification behavior; scheduled delivery remains intentionally unsupported in Phase 8.
- Real-device/browser visual hierarchy, keyboard navigation, screen-reader labels, and accessibility review.

## Phase boundary

Phase 8 is limited to local notification delivery, preferences, quiet scheduling, deduplication, routing, and explicit platform capability handling. Cross-device push is not part of this phase. Phase 9 should begin only after Phase 8 is reviewed and merged/signaled complete.
