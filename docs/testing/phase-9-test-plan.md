# Phase 9 Test Plan — Platform-Specific UI/UX

## Goal
Build out the three independently editable screen families required by SRS §4.5.5 without moving business logic into platform screens.

Phase 9 targets:
- Mobile: capture-first single-column navigation, bottom navigation, thumb-reachable quick capture, full-screen low-chrome capture, bottom-sheet Memory filters, swipeable Insights.
- Desktop: persistent sidebar, multi-pane/review-first home, master-detail Memory browser, keyboard shortcuts, persistent Insights treatment, multi-tab Settings.
- Web: desktop-like wide layout with explicit narrow-width collapse toward mobile structure while preserving browser-native navigation conventions and the existing web key-security warning.

## Automated tests

| ID | Area | Test | Pass criteria |
| --- | --- | --- | --- |
| P9-01 | Architecture | Platform screen folders never import sibling platform folders | Existing architecture test stays green |
| P9-02 | Architecture | Shared logic/design layers never import platform screens | Existing architecture test stays green |
| P9-03 | Routing | Android/iOS resolve only mobile screens | Existing + Phase 9 route tests pass |
| P9-04 | Routing | Windows/macOS/Linux resolve only desktop screens | Existing + Phase 9 route tests pass |
| P9-05 | Routing | Web resolves only web screens | Existing + Phase 9 route tests pass |
| P9-06 | Mobile Home | Home exposes bottom navigation and capture-first action | Widget test finds mobile navigation + quick capture controls |
| P9-07 | Mobile Memory | Filters open in a bottom sheet rather than persistent desktop-style rail | Widget test opens filter sheet and validates controls |
| P9-08 | Mobile Insights | Insight feed uses dismissible/swipeable cards without deleting evidence | Widget test finds Dismissible insight cards and existing dismiss behavior remains intact |
| P9-09 | Desktop Home | Persistent sidebar + main workspace + detail/review pane render at desktop viewport | Widget test validates all three structural regions |
| P9-10 | Desktop Memory | Master-detail layout renders list and selected memory detail concurrently | Widget test validates list/detail keys at desktop viewport |
| P9-11 | Desktop Memory | Keyboard shortcuts can move focus/selection through result list | Widget test dispatches keyboard event and validates selection change where data is available |
| P9-12 | Desktop Settings | Provider + notification settings are reachable through a tabbed desktop settings experience | Widget/route test validates tab shell and both settings sections |
| P9-13 | Web Wide | Wide viewport renders desktop-like navigation/workspace structure | Widget test at >= 1100 px finds wide shell |
| P9-14 | Web Narrow | Narrow viewport collapses toward mobile-style single-column/navigation structure | Widget test at <= 700 px finds narrow shell and no wide-only rail |
| P9-15 | Web Security | Existing NFR-4.5.4 key-security warning remains visible/re-checkable | Existing provider settings test stays green |
| P9-16 | Regression | Full Flutter test suite passes | 0 failures |
| P9-17 | Static quality | `dart format`, Drift generated-code diff, `flutter analyze` | All pass |
| P9-18 | Builds | Android, iOS simulator, Web, Windows, macOS, Linux debug builds | All six targets pass CI |

## Manual viewport / interaction checks

Automated widget tests cannot replace real platform rendering. Before Phase 9 is marked complete, manually verify these target sizes and document results:

- Mobile: 360x800 and 430x932 logical px.
- Desktop: 1280x720 and 1440x900.
- Web: 1440x900, 1024x768, 768x1024, 390x844.
- Confirm no clipped navigation, no RenderFlex overflow, and no unreachable primary action.
- Confirm mobile quick capture is thumb reachable.
- Confirm desktop navigation and master-detail layouts remain useful without full-screen maximization.
- Confirm browser back navigation continues to work on web routes.
- Confirm keyboard focus is visible and sensible on desktop/web.

## Screen-boundary review checklist

- [ ] No `screens/mobile/` file imports `screens/desktop/` or `screens/web/`.
- [ ] No `screens/desktop/` file imports `screens/mobile/` or `screens/web/`.
- [ ] No `screens/web/` file imports `screens/mobile/` or `screens/desktop/`.
- [ ] Shared feature/application/data/domain code does not import platform screen files.
- [ ] Shared design tokens contain visual primitives only, not platform layout decisions.
- [ ] Business rules remain in shared feature services/controllers.
- [ ] Platform differences are structural screen composition, not duplicated business logic.

## Completion rule
Phase 9 is complete only when all critical automated checks and all six CI builds pass. Real-device/browser viewport checks that cannot run in CI must be explicitly listed as manual follow-up if they have not been physically executed; they must never be reported as automated passes.
