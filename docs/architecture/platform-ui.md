# Platform UI Architecture

## Purpose

Phase 9 turns Mindly's existing platform-specific screen folders into deliberate, independently editable UX families while keeping product rules in shared feature/application layers.

The structural boundary is:

- `lib/screens/mobile/` owns mobile navigation and composition.
- `lib/screens/desktop/` owns desktop navigation, pane structure, and keyboard-oriented composition.
- `lib/screens/web/` owns browser-specific responsive composition.
- `lib/features/`, `lib/core/`, and `lib/shared/` continue to own reusable business logic, persistence, controllers, models, and visual primitives.

Platform screens must not import sibling platform screen folders. Shared feature/application/data/domain code must not import platform screen files. Existing architecture tests enforce both rules.

## Mobile family

The mobile family is capture-first and single-column:

- `MobilePrimaryNavigation` provides Home, Capture, Memory, Insights, and Settings destinations on the primary mobile surfaces.
- Home keeps text/audio quick capture immediately reachable.
- Memory keeps entity selection inline, while capture-specific Work/Personal/Pinned filters live in a modal bottom sheet so the content list remains the main surface.
- Insights keeps swipe-to-dismiss cards while continuing to delegate dismiss/mute/source behavior to the shared `InsightController`.
- Settings is a simple list that routes to provider/spend and notification controls.

The capture implementations remain dedicated low-chrome routes rather than being embedded into desktop/web shells.

## Desktop family

The desktop family is review-first and multi-pane:

- Home keeps a persistent sidebar, central workspace, and a dedicated review/detail region.
- Memory uses a master-detail structure: result list and selected memory detail are visible concurrently.
- Memory supports Arrow Up / Arrow Down keyboard selection through Flutter shortcuts without moving selection rules into shared business code.
- Insights retains its persistent review/detail treatment.
- Settings is a tabbed desktop window containing AI/provider/spend and notification controls. The existing provider and notification screens support embedded rendering while retaining standalone deep-link routes.

### Desktop capture limitation

The SRS notes that desktop capture can run as a compact floating window. Phase 9 does **not** add an OS-level native floating or multi-window capture surface because the current application has no window-management primitive. Desktop capture remains a dedicated in-app route. Native floating-window behavior is an explicit future/native-hardening gap rather than an implemented Phase 9 capability.

## Web family

The web family is desktop-like when space permits and collapses toward a mobile-style structure when narrow:

- Home exposes an explicit wide shell and a narrow single-column shell.
- Settings uses wide cards on larger viewports and a narrow list on smaller viewports.
- Wide Settings is vertically scrollable as well as width-responsive so short browser windows do not overflow.
- Browser-facing Settings keeps an AppBar back action using `Navigator.maybePop`, preserving route/back semantics instead of inventing desktop-only navigation.
- Existing provider settings continue to enforce and display the Web API-key security warning before first key acceptance.

Responsive widget tests cover selected widths, but real-browser rendering, focus visibility, browser history behavior, and accessibility remain manual validation items.

## Settings routes and compatibility

Phase 9 adds a combined entry point:

- `/settings`

Existing routes remain valid for compatibility and deep links:

- `/settings/providers`
- `/settings/notifications`

`platform_screen_router.dart` resolves all three Settings variants through the same screen-family selection used by Home, Capture, Memory, and Insights.

## Business-logic boundary

Phase 9 intentionally avoids moving behavior into platform screens:

- Memory data/filter/search/detail behavior stays in `MemoryBrowserController` and its shared feature services.
- Insight generation, dismiss, mute, source resolution, and persistence stay in `InsightController` and shared insight services.
- Provider key/spend behavior stays in AI settings services/controllers.
- Notification scheduling/preferences stay in the notification controller and shared notification layer.

Platform code decides *how the same capability is composed for a device class*, not *what the capability means*.

## Automated architecture guardrails

The test suite verifies:

1. Mobile/Desktop/Web screen folders do not import one another.
2. Shared layers do not import platform screen files.
3. Android/iOS resolve the mobile screen family.
4. Windows/macOS/Linux resolve the desktop screen family.
5. Web resolves only the web screen family.
6. Phase 9 structural regressions cover mobile navigation/filter sheets/swipe actions, desktop pane/keyboard/settings behavior, and web wide/narrow shells.
