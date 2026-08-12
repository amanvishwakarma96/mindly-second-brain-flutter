# Notification Architecture

Phase 8 adds local notification delivery without adding a Mindly backend. Notification preferences and delivery state remain local to the current device, and enabling notifications never changes where memories or AI credentials are stored.

## Privacy and permission model

Notifications are disabled by default. Mindly initializes the native notification bridge without requesting permission. A permission request is made only when the user explicitly saves a configuration that enables either Tier 2 alerts or a scheduled digest. If permission is denied, the enabled configuration is not persisted.

Tier 2 candidates come from the same local insight controller used by the Insights screen. That means dismissed or muted local insights are filtered before notification planning. Phase 8 does not run AI generation in the background and does not send memories to a notification service.

## Scheduling policy

### Tier 2 alerts

When the app reconciles notifications, newly visible Tier 2 insights are scheduled as one-shot local notifications. Each insight uses its stable fingerprint as the deduplication key. A bounded history of fingerprints is kept in secure local storage so a previously announced insight is not scheduled again on every app launch.

### Digests

Digests support Off, Daily, and Weekdays. Mindly schedules a bounded rolling window of 14 one-shot occurrences instead of relying on OS repeating APIs. This makes behavior explicit across Windows, which does not support repeating notifications through the selected plugin, and keeps pending notifications comfortably below iOS limits. The schedule is refreshed when Mindly starts and whenever notification preferences are saved.

### Quiet hours

Quiet hours are evaluated in the device's local `DateTime` calendar. A candidate inside the quiet window is moved to the next quiet-end boundary. Overnight windows such as 22:00–07:00 are handled explicitly. Equal start and end values mean quiet hours are disabled.

Android uses inexact allow-while-idle scheduling, so Mindly does not request exact-alarm permission. Boot/package-replacement receivers are registered so the notification plugin can restore scheduled entries after reboot or app replacement.

## Notification taps

Payloads contain only an allowlisted local route plus an optional insight fingerprint. Phase 8 routes valid notification taps to the Insights screen. Invalid payloads or non-Insights routes are ignored. No memory content, API key, or provider credential is placed in the payload.

## Platform capability matrix

| Platform | Scheduled local notifications | Phase 8 behavior |
| --- | --- | --- |
| Android | Yes | Tier 2 alerts and rolling digest schedule |
| iOS | Yes | Tier 2 alerts and rolling digest schedule |
| macOS | Yes | Tier 2 alerts and rolling digest schedule |
| Windows | Yes, one-shot | Tier 2 alerts and rolling one-shot digest schedule |
| Linux | No scheduler API in current plugin | Capability gap shown explicitly; no fake schedule |
| Web | No reliable scheduled/repeating local notification support | Capability gap shown explicitly; browser permission is not requested |

Linux can show immediate desktop notifications while an application is running, but Phase 8 does not substitute immediate foreground messages for the SRS requirement of scheduled local notifications.

## Deferred to optional sync

Cross-device push notification delivery is intentionally not introduced in Phase 8. The SRS ties push delivery to optional sync, so any encrypted notification-sync metadata and push infrastructure remain part of that later milestone. This keeps the Phase 8 implementation local-first and backend-free.
