# Product specification

Status: Draft v0.1

Last updated: 2026-07-17

## Vision

MacroAdvisor helps people understand patterns in their food and drink intake
without demanding exact weighing, an account, or a permanent cloud connection.
It turns a short description or photo into a transparent nutrition estimate that
the user can inspect, correct, save, and compare with personal goals.

## Target users

- People who want a low-friction overview of daily nutrition
- People pursuing goals such as higher protein or fibre intake
- Privacy-conscious users who prefer local storage and optional cloud services

## Supported platforms and languages

- Android and iOS are product targets.
- Android is the initially tested and released platform.
- iOS-compatible code and platform abstractions remain required, but iOS build and
  integration automation are deferred.
- German and English are supported from the first implemented feature.

## MVP outcomes

The MVP enables a user to:

1. Configure a user-owned AI provider credential.
2. Record a meal or drink using text.
3. Receive itemized, structured nutrition estimates.
4. Review and correct foods, quantities, and nutrient values.
5. Save the confirmed entry locally.
6. View daily totals and progress toward selected goals.
7. Use the app in German or English.

Photo input is part of the product scope but follows the proven text-entry slice.

## Nutrient scope

The initial strongly typed nutrient set is:

- energy in kilocalories
- protein in grams
- carbohydrates in grams
- fat in grams
- fibre in grams
- sugars in grams
- salt in grams

Protein, carbohydrates, and fat form the initial macronutrient group. The model
must allow later nutrients without requiring changes to every persistence and UI
boundary. Salt and sodium must not be treated as interchangeable values.

## Goals

Initial goals are daily target ranges for individual nutrients. Presets may offer
high-protein or high-fibre defaults, but users can inspect and modify the numeric
targets. Optional body characteristics may inform suggestions in a later feature;
they are not required to use the app.

## Trust and safety

- AI-derived values are estimates, not measurements or medical advice.
- Results show assumptions and an overall confidence indication.
- Users confirm or edit an analysis before it becomes a saved entry.
- The UI avoids declaring food intrinsically "good" or "bad".
- Goal feedback describes progress and trends without diagnosis.
- Sensitive data and provider credentials are never written to application logs.

## Local-first behavior

All confirmed entries, goals, preferences, and optional profile values are stored
locally. Account creation and cloud synchronization are not part of the MVP. AI
analysis is the only operation that requires network access.

## Future scope

- Meal and drink photo analysis
- Week and month trends
- Optional body characteristics
- Additional nutrients
- Optional account and Neon-backed synchronization
- Managed AI access for users who do not bring an API key

## Explicit non-goals for the MVP

- Clinical dietary advice or diagnosis
- Guaranteed laboratory-level nutrient accuracy
- Barcode or packaged-food database lookup
- Social features
- Calorie restriction coaching
- Cloud backup or multi-device synchronization
