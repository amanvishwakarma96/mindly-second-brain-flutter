# Phase 8 Notification Test Plan

## Goal

Implement privacy-first local notification delivery for scheduled digests and Tier 2 pattern alerts on supported mobile/desktop targets, with configurable frequency and quiet hours, deterministic deduplication, notification tap routing to Insights, and explicit capability gaps where the platform cannot schedule local notifications.

## Required behavior

- Notifications are off by default and no permission prompt appears during app startup.
- Notification permission is requested only after an explicit user action that enables a notification feature.
- Tier 2 alert candidates come only from currently visible/non-muted/non-dismissed Tier 2 insights.
- A Tier 2 insight fingerprint is scheduled at most once.
- Quiet hours delay alerts to the next allowed local time, including overnight quiet windows.
- Digest cadence supports Off, Daily, and Weekdays at a user-selected local time.
- Digest scheduling stays within the platform pending-notification limits by keeping a bounded rolling window.
- Notification taps route to the Insights screen without requiring a Mindly backend.
- Android/iOS/macOS/Windows expose scheduled-local-notification capability.
- Linux explicitly reports that scheduled notifications are unavailable with the current system notification API; no fake scheduler is used.
- Web explicitly reports scheduled/repeating notifications as unavailable; no browser permission is requested by Phase 8.
- Sync-only cross-device push is not implemented in Phase 8 because optional sync is a later milestone.

## Automated tests

| Area | Coverage |
| --- | --- |
| Quiet hours | daytime, overnight, boundary, disabled/equal-time behavior |
| Digest planning | daily, weekdays, next eligible day, bounded schedule count |
| Tier 2 planning | only Tier 2, deterministic order, quiet-hour delay |
| Deduplication | previously notified fingerprints are not scheduled again |
| Persistence | preferences and delivery state JSON round-trip safely |
| Permission | explicit enable requests permission; startup initialization does not |
| Capabilities | Android/iOS/macOS/Windows scheduled; Linux/Web documented unavailable |
| Tap payload | valid payload routes to Insights; invalid payload is ignored safely |
| Platform UI | mobile/desktop/web notification settings route to separate screen families |
| Regression | existing Phase 0–7 tests, analyzer, formatter, Drift generation, vector benchmark |

## Build matrix

The permanent CI gate must pass Android debug, iOS simulator, Web, Windows debug, macOS debug, and Linux debug builds on the exact final Phase 8 head.

## Manual validation not claimed by CI

- Real permission prompts and OS notification presentation on Android/iOS/macOS/Windows.
- Android OEM background scheduling behavior and reboot rescheduling.
- Notification taps from foreground/background/terminated app states on physical targets.
- Daylight-saving transitions in a locale that changes UTC offset.
- Windows packaged/MSIX behavior for cancellation/history APIs.
- Linux desktop-server behavior for immediate notifications; scheduled delivery remains intentionally unsupported.
- Accessibility and visual review of the three notification settings screen families.
