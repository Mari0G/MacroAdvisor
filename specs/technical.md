# Technical specification

Status: Accepted v0.1

Last updated: 2026-07-22

## Application stack

- Flutter 3.44 stable and Dart 3.12 are the baseline for Android and iOS. The
  project tracks compatible stable patch releases and declares the minimum SDK
  constraints in `pubspec.yaml`.
- Riverpod through `flutter_riverpod` is the required state-management and
  dependency-injection solution. UI state depends on application interfaces,
  never directly on persistence or provider adapters.
- Android as the initial CI build and integration-test target
- Drift (`drift` plus `drift_flutter`) is the required local SQLite persistence
  layer. Generated Drift sources are produced by `drift_dev` and `build_runner`
  and are never edited manually. Drift remains behind repository interfaces.
- `flutter_secure_storage` is the only persistence mechanism for user-supplied
  AI provider credentials. SQLite and ordinary preferences must never contain
  provider secrets.
- `flutter_localizations` with ARB files and Flutter's generated localization
  support is required for German and English. Every localization key must exist
  in both locales; English is the source locale and fallback.
- AI integrations implement the provider-neutral `NutritionAnalysisProvider`
  interface. Provider adapters, request/response DTOs, SDK types, model names,
  and credentials remain in infrastructure code and cannot leak into domain or
  presentation APIs.

The initial dependency lines are `flutter_riverpod` 3.x, `drift` 2.x,
`drift_flutter` 0.3.x, and `flutter_secure_storage` 10.x. Exact resolved versions
are recorded in `pubspec.lock`; upgrades outside these compatible lines require a
technical-specification update. All selected packages use permissive licenses.

## Layer boundaries

The codebase uses feature-oriented modules with four dependency directions:

```text
presentation -> application -> domain <- infrastructure
```

The domain does not import Flutter, database, HTTP, or provider SDK types.

Required boundaries include:

- `MealRepository` for meal persistence and observation
- `GoalRepository` for goal persistence and observation
- `NutritionAnalysisProvider` for text and image analysis
- `CredentialStore` for provider secrets
- `Clock` and ID generation abstractions for deterministic tests

### Project structure

Production code is organized by feature, with a small application composition
root and shared core. The intended structure is:

```text
lib/
  main.dart
  src/
    app/
      bootstrap.dart
      macro_advisor_app.dart
      app_router.dart
      app_theme.dart
      app_providers.dart
    core/
      domain/
        clock.dart
        id_generator.dart
        app_failure.dart
      infrastructure/
        database/
          app_database.dart
          tables/
          converters/
      localization/
      presentation/
        app_async_view.dart
        responsive_content.dart
    features/
      dashboard/
        application/
        presentation/
      meals/
        domain/
        application/
        infrastructure/
        presentation/
      meal_capture/
        domain/
        application/
        infrastructure/
        presentation/
      goals/
        domain/
        application/
        infrastructure/
        presentation/
      settings/
        domain/
        application/
        infrastructure/
        presentation/
  l10n/
    app_en.arb
    app_de.arb
```

The central `AppDatabase` owns the Drift connection, schema version, and table
registration because a single SQLite transaction may span related tables. Feature
infrastructure adapters own mapping and repository implementations. Generated
files remain next to their source and carry generated suffixes; they are never
moved to or edited in a separate hand-maintained tree.

Tests mirror production paths:

```text
test/src/features/...         unit and widget tests
test/src/core/...             shared contract and utility tests
test/support/                 fakes, fixed clocks, builders, and fixtures
integration_test/             critical Android journeys
```

Shared test support contains no production behavior. Provider fixtures are
sanitized and live under the relevant adapter test directory.

### Import and ownership rules

- Presentation may import its feature's application and domain code plus shared
  core presentation utilities. It never imports infrastructure.
- Application coordinates use cases and repository/provider interfaces. It never
  imports Flutter widgets, Drift, secure storage, HTTP clients, or provider DTOs.
- Domain imports only Dart libraries and other explicitly shared domain contracts.
- Infrastructure implements domain/application ports and may import platform or
  package APIs. Infrastructure never exposes those types through a public method.
- Cross-feature imports target domain or application contracts only. A feature
  never imports another feature's `presentation` or `infrastructure` directory.
- `core` contains code that is stable and used by multiple features. Code does not
  move to `core` in anticipation of reuse; a second real consumer is required.
- Files use package imports for `lib/` code and relative imports only within a
  tightly related local group when doing so improves generated-code compatibility.

Architecture tests enforce forbidden import directions and localization parity.
These tests operate on source paths/imports and fail with a message describing the
allowed dependency direction.

### App composition and dependency injection

`main.dart` contains only framework initialization and a call to `bootstrap()`.
`bootstrap()` initializes Flutter bindings, creates platform-level dependencies,
and mounts one root `ProviderScope`. Dependency overrides for integration tests
are accepted at this composition boundary.

`app_providers.dart` is the production composition root. It binds interfaces such
as `MealRepository`, `GoalRepository`, `NutritionAnalysisProvider`,
`CredentialStore`, `Clock`, and `IdGenerator` to infrastructure implementations.
Features consume providers for the interfaces, not providers for concrete
adapters. Provider declarations live next to the interface or controller they
expose; the composition root supplies the concrete overrides.

No global service locator, static repository singleton, or direct database lookup
from `BuildContext` is permitted. Resources with a lifecycle, including the Drift
database and network clients, are disposed by Riverpod or by the bootstrap owner.

### Domain and application modeling

Domain entities and value objects are immutable. Mutation is expressed by creating
a reviewed draft or updated entity, and repository writes accept complete valid
domain values. Core nutrition rules use explicit types instead of maps keyed by
localized strings.

The initial model includes:

- stable `NutrientId` values for all core nutrients and an extensible identifier
  for future nutrients
- `NutritionValue` as an explicit known/unknown variant with decimal-safe magnitude,
  unit, and source; unknown is not encoded as null or zero
- target variants for minimum, maximum, and range rather than boolean flags
- provider-neutral confidence, assumption, validation warning, and provenance
  values
- sealed provider and persistence failure categories with no sensitive payload

Known core nutrient magnitudes use a non-negative fixed-point integer representing
one thousandth of the canonical unit. The same representation is persisted as an
integer and is converted to localized decimal input/output only at presentation
boundaries. This avoids floating-point calculation drift without adding a numeric
production dependency. A future nutrient that needs different precision must
declare its scale as domain metadata rather than introducing `double` arithmetic.

Application use cases perform orchestration that is meaningful outside one widget,
for example analyzing a description, confirming a reviewed meal, observing a day,
and saving a goal set. Pure nutrient arithmetic and validation remain domain code.

Riverpod `Notifier` or `AsyncNotifier` controllers own screen workflows. Their
state is immutable and exhaustive enough to render loading, input, recoverable
failure, review, saving, and completion. Widgets do not infer workflow state from
several unrelated booleans. Controllers prevent concurrent submissions and use a
stable draft/confirmation identifier so retries are idempotent.

Presentation-specific formatting is performed in display models or small
formatters that receive locale-aware services. Localized strings and rounded
display numbers are never persisted back into the domain model.

### UI construction rules

Screen code follows a page/view split when dependency wiring would otherwise make
widget tests awkward:

- `*Page` watches providers, maps application state, and handles navigation intent.
- `*View` receives immutable display state and callbacks and renders widgets.
- reusable widgets own no repository or provider access.

Small screens may keep the page and view in one file until the split improves
testability; empty layers and one-line wrapper classes are not required. Large
widget build methods are decomposed by meaningful UI region, not by arbitrary line
count.

All user-facing text comes from generated localizations. Keys are semantic and
feature-prefixed where ambiguity is likely. English and German entries are added
in the same change. Dates and numbers use the active locale, while persistence and
provider contracts use locale-independent representations.

The detailed screen, responsive, interaction, and accessibility requirements are
defined in [ui-ux.md](ui-ux.md).

### Navigation

The text MVP uses Flutter's Router/Navigator APIs without an additional navigation
dependency. The app has one root Today route and pushed routes for capture, review,
item edit, meal detail, goals, and settings. Route definitions and redirect/back
policy are centralized in `app_router.dart`; leaf widgets emit navigation intents
instead of constructing provider or persistence objects.

Routes carry stable IDs and small serializable arguments only. Domain entities are
loaded through application interfaces so process recreation and deep links do not
depend on in-memory objects. Credentials, descriptions, raw provider payloads, and
image bytes are never embedded in route names or diagnostic state.

If nested root navigation, authenticated redirects, or external deep links later
make the framework router disproportionately complex, a navigation package may be
proposed with its purpose and version line documented here before it is added.

### Persistence and transaction boundaries

Drift data classes are infrastructure types. Repository mappers translate them to
and from domain entities and validate values at the boundary. Schema tables use
stable IDs, UTC timestamps plus the recorded occurrence offset where required,
revisions, and tombstone metadata described by the domain model.

Saving or updating a meal and all of its items/nutrients is one database
transaction. Goal-set updates are atomic. Observation streams emit domain objects
and surface categorized failures; they do not leak Drift exceptions.

Database migrations are additive where practical, covered by migration tests, and
include schema fixtures for every supported upgrade path. Tests use an in-memory
database unless the behavior specifically depends on the platform filesystem.

Credentials use `CredentialStore` backed only by `flutter_secure_storage`. Their
presence may be represented as ordinary boolean configuration state, but their
value is never cached in a Riverpod state that can be inspected by UI diagnostics.

### Error and privacy boundaries

Infrastructure catches package/provider exceptions at the adapter boundary and
maps them to sealed provider-neutral failures. Raw exception messages and response
bodies do not cross into presentation. User-facing recovery copy is selected by
localized failure category.

Logging APIs accept an operation identifier, timing, anonymous category, and
documented safe metadata. Arbitrary object interpolation is not used for meals,
provider requests, repository entities, credentials, or profile data. Tests assert
redaction for adapter error mapping and any structured logging boundary.

## AI integration

The MVP uses bring-your-own-key access and sends requests directly from the mobile
device over TLS. It ships no shared provider secret and therefore needs no backend.

The first implementation targets stable `gemini-3.5-flash`. Provider-specific
requests and responses remain inside an infrastructure adapter. Domain code
consumes a provider-neutral `NutritionAnalysis` contract.

The provider configuration supports adding other adapters without migrating meal
data. OpenAI is the first planned alternative. A future managed-key mode must use
a server-side gateway; embedding a project-owned key in the app is forbidden.

User-provided keys must:

- be entered and removed through settings
- be stored only in Android Keystore or iOS Keychain-backed secure storage
- never enter SQLite, analytics, crash reports, logs, fixtures, or screenshots
- be redacted from errors
- be testable through an explicit connection check

Provider output is untrusted. Validate JSON shape, finite and non-negative values,
units, plausible upper bounds, and item-total consistency before showing results.
Semantic validation warnings do not silently discard user data.

## Domain model

### MealEntry

- stable client-generated UUID
- occurrence timestamp and timezone offset
- optional user description
- one or more meal items
- nutrient totals
- analysis provenance and user-edited flag
- created, updated, and optional deleted timestamps
- local revision number and synchronization state

### MealItem

- stable UUID
- localized or user-provided name
- amount and unit as reported or corrected by the user
- normalized amount in grams when known
- typed core nutrients
- extensible additional nutrient values
- item-level confidence and assumptions

### NutritionValue

Every nutrient has a stable nutrient identifier, decimal value, unit, and source.
Core values use grams except energy, which uses kilocalories. Calculations use a
decimal-safe representation and UI rounding occurs only at the display boundary.

## Cloud readiness without cloud behavior

Repository interfaces, client-generated IDs, timestamps, tombstones, and local
revision metadata prepare records for eventual synchronization. No Neon SDK,
network database client, account model, or sync worker is added in the MVP.

A future Neon integration is expected to sit behind a server API. Mobile clients
must not connect to Neon using privileged database credentials.

## Error behavior

Provider failures are mapped to provider-neutral categories: missing credential,
invalid credential, rate limited, offline, invalid response, content rejected,
and unknown failure. User-facing messages are localized and offer a recovery path.

Saving a confirmed entry never depends on provider availability. Draft analysis
can be retried without duplicating confirmed entries.

## Observability and privacy

Structured logs may contain operation names, timings, anonymous error categories,
and provider/model identifiers. They must not contain descriptions, images,
nutrition entries, profile values, or credentials. Analytics are out of MVP scope.
