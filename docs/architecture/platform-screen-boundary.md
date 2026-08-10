# Platform screen boundary

Mindly deliberately keeps complete screen implementations separate by platform class:

- `lib/screens/mobile/`
- `lib/screens/desktop/`
- `lib/screens/web/`

Shared business logic belongs in `lib/core/` and `lib/features/`. Shared visual language belongs in `lib/shared/design_tokens/`, with intentionally small reusable UI elements in `lib/shared/widgets/`.

`lib/app/platform/platform_screen_router.dart` is the one composition boundary allowed to import all three screen families and select a complete implementation at runtime.

## Enforcement

1. A platform screen folder must never import another platform screen folder.
2. `core`, `features`, and `shared` must never import `screens`.
3. Cross-platform behavior changes in a shared layer instead of being duplicated into screens.
4. Platform-specific layout changes stay inside that platform's screen folder.
5. `test/architecture/platform_screen_boundary_test.dart` enforces rules 1 and 2 in CI.

The extra files are intentional: platform isolation takes priority over layout-code reuse.
