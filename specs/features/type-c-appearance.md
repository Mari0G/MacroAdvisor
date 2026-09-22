# Type C appearance and palettes

Status: Accepted v0.1

Feature ID: F-006

Delivery slice: S-014

## User outcome

The whole app uses the dark Type C design in `prototypes/macro_advisor_ui_prototype.html`. A user can choose Lime, Ocean, Coral, or Violet in Settings; the choice takes effect immediately and survives a restart.

## Scope and behavior

- Preserve the existing Today root and push-route navigation, forms, data flows, language behavior, branding, icon, and native splash.
- Apply the Type C palette, typography hierarchy, surfaces, radii, controls, focus treatment, and responsive layout throughout Today, History, Settings, Provider settings, Goals, capture, review, item editing, and meal detail/edit, including loading, empty, error, dialog, and sheet states.
- Use the prototype's exact Type C palette and hero-gradient color values. Use semantic error and destructive colors. Pair goal, nutrient, and selection colors with words or icons.
- Provide reusable Type C page, section, notice, metric/hero, and selection components. Touch targets are at least 48 by 48 pixels.
- Today has a large dated header, compact day selector, energy hero with a goal ring when an energy goal exists, responsive nutrient grid, full nutrient expansion, circular meal symbols, reduced meal rows, and round capture FAB. At 840 pixels and above, progress is left and meals are right.
- Settings has a wrapping palette selector with swatch, name, check, and radio semantics. Selection needs no save button and preserves the current route, form, and scroll state.
- Store a stable palette ID (`lime`, `ocean`, `coral`, `violet`) in one Drift settings row. Lime is the default for new and upgraded installs. Unknown stored IDs display Lime without overwriting the row.
- A failed save restores the last confirmed palette and presents localized retry. Loading and load errors have localized states.
- Align system bars with dark surfaces. Add no production dependency, font, or image.

## Non-goals

- Prototype bottom navigation and developer switcher
- Changing provider, nutrition, goal, meal, or navigation behavior
- S-013 expandable warning behavior
- Live Gemini calls

## Acceptance criteria

- All four palettes use the prototype Type C colors and can be selected immediately across the active route and the rest of the app.
- A palette survives restart; v1, v2, and v3 databases migrate to v4 with Lime while meal, goal, and image data remain intact.
- Unknown IDs fall back to Lime without a write; failed saves revert and can be retried.
- Today and every existing screen use the shared dark visual language without losing workflows, and Today uses two columns at 840 pixels.
- English and German selection, loading, and failure states work at 200% text scale with accessible semantics and contrast.

## Verification

- Domain, controller, Drift migration/reopen, app, widget, semantic, and golden tests
- Contrast checks for text, action, and focus roles in every palette
- `tools/verify.ps1 -Mode Full` and the deterministic Android critical journey with palette persistence after restart
