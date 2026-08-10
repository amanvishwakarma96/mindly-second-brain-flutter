# Phase 0 Test Plan

## Goal

Establish a Flutter shell for Android, iOS, Windows, macOS, Linux, and Web with shared logic, shared design tokens, isolated `screens/mobile`, `screens/desktop`, and `screens/web` implementations, plus runtime platform routing.

## Critical test cases

| Test ID | Description | Expected result |
|---|---|---|
| P0-01 | Generate Flutter project with all six platform runners | Android, iOS, Windows, macOS, Linux, and Web runner folders exist |
| P0-02 | Analyze Dart source | `flutter analyze` completes with no errors |
| P0-03 | Run unit/widget/architecture tests | `flutter test` passes |
| P0-04 | Route Android/iOS | Mobile screen family is selected |
| P0-05 | Route Windows/macOS/Linux | Desktop screen family is selected |
| P0-06 | Route Web | Web screen family is selected |
| P0-07 | Verify screen isolation | No platform screen folder imports a sibling screen folder |
| P0-08 | Verify shared-layer boundary | Shared logic/design layers never import platform screens |
| P0-09 | Build Android shell | Debug APK build succeeds |
| P0-10 | Build iOS shell | iOS simulator build succeeds |
| P0-11 | Build Windows shell | Windows debug build succeeds |
| P0-12 | Build macOS shell | macOS debug build succeeds |
| P0-13 | Build Linux shell | Linux debug build succeeds |
| P0-14 | Build Web shell | Web build succeeds |

Phase 0 is not complete until all critical tests pass or a blocking platform limitation is explicitly reported.
