# Technical specification

Status: Draft v0.1

Last updated: 2026-07-17

## Application stack

- Flutter and Dart for Android and iOS
- Android as the initial CI build and integration-test target
- Local SQLite persistence behind repository interfaces
- Platform-backed secure storage for user-supplied provider credentials
- ARB-based Flutter localization for German and English

Exact package selections are made during scaffolding and recorded here before
their first use. Dependencies must have a clear purpose and compatible license.

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

## AI integration

The MVP uses bring-your-own-key access and sends requests directly from the mobile
device over TLS. It ships no shared provider secret and therefore needs no backend.

The first implementation targets stable `gemini-2.5-flash`. Provider-specific
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
