# Mindly

Mindly is a local-first, BYOK second-brain application built with Flutter for iOS, Android, Windows, macOS, Linux, and Web.

## Architecture

```text
lib/
├── app/                      # app composition + platform screen routing
├── core/                     # shared non-UI logic
├── features/                 # shared feature/application logic
├── shared/
│   ├── design_tokens/        # colors, spacing, theme
│   └── widgets/              # small reusable components only
└── screens/
    ├── mobile/               # independent mobile screens
    ├── desktop/              # independent desktop screens
    └── web/                  # independent web screens
```

The platform screen folders are isolated by architecture tests. The runtime routing layer chooses one complete screen family without merging platform layouts.

## Supported targets

Android · iOS · Windows · macOS · Linux · Web

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Read `docs/architecture/platform-screen-boundary.md` before adding or moving UI code.
