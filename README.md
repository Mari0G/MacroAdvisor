# MacroAdvisor

MacroAdvisor is an open-source, local-first mobile app for recording meals and
drinks, estimating their nutritional values with AI, and comparing daily intake
with personal nutrition goals.

The first release targets Android and iOS. Development and automated integration
testing initially focus on Android.

## Project status

The Flutter scaffold is in place. It intentionally contains only a localized
German/English setup screen; product behavior starts with the next vertical slice.

## Product principles

- Local-first and usable without an account
- User-owned AI credentials for the MVP
- AI results are transparent, editable estimates
- German and English from the first feature
- Feature work starts with acceptance criteria and tests
- Cloud synchronization remains optional

The current specifications are indexed in [specs/README.md](specs/README.md).
The repository workflow is defined in [docs/branching.md](docs/branching.md).

## Planned technology

- Flutter and Dart
- Riverpod for state management and dependency injection
- Drift for local SQLite persistence
- `flutter_secure_storage` for user-provided AI keys
- ARB-based `flutter_localizations` support for German and English
- Android-first automated testing; iOS remains a supported target
- Provider-neutral AI integration, starting with Google Gemini
- GitHub Actions for formatting, analysis, tests, builds, and releases

The binding technical choices and package lines are defined in
[specs/technical.md](specs/technical.md).

The draft screen and interaction plan is defined in
[specs/ui-ux.md](specs/ui-ux.md). The proposed vertical-slice delivery order is in
[docs/implementation-plan.md](docs/implementation-plan.md), with durable progress
tracked in [docs/implementation-status.md](docs/implementation-status.md).

## Local development

Use Flutter 3.44 stable with Dart 3.12 or a compatible newer stable patch, then
run:

```text
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

Generate Drift sources after adding or changing a schema with:

```text
dart run build_runner build --delete-conflicting-outputs
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). By contributing, you agree that your
contributions are licensed under the Apache License 2.0.

## License

Licensed under the [Apache License 2.0](LICENSE).
