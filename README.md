# MacroAdvisor

MacroAdvisor is an open-source, local-first mobile app for recording meals and
drinks, estimating their nutritional values with AI, and comparing daily intake
with personal nutrition goals.

The first release targets Android and iOS. Development and automated integration
testing initially focus on Android.

## Project status

The project is currently in the specification phase. The first implementation
slice will cover text-based meal entry, AI-assisted nutrition analysis, manual
correction, local persistence, and a daily nutrition overview.

## Product principles

- Local-first and usable without an account
- User-owned AI credentials for the MVP
- AI results are transparent, editable estimates
- German and English from the first feature
- Feature work starts with acceptance criteria and tests
- Cloud synchronization remains optional

The current specifications are indexed in [specs/README.md](specs/README.md).

## Planned technology

- Flutter and Dart
- Android-first automated testing; iOS remains a supported target
- SQLite through a repository abstraction
- Secure platform storage for user-provided API keys
- Provider-neutral AI integration, starting with Google Gemini
- GitHub Actions for formatting, analysis, tests, builds, and releases

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). By contributing, you agree that your
contributions are licensed under the Apache License 2.0.

## License

Licensed under the [Apache License 2.0](LICENSE).
