# Android integration journeys

These tests drive the compiled Flutter application on an Android emulator or
device. They are the default verification for every feature or bug fix that
changes a user journey. They use deterministic test seams for provider and
credential behavior, but production navigation and persistence.

From `android/`, run one journey with native Android instrumentation:

```powershell
$target = (Resolve-Path ..\integration_test\mvp_critical_journey_test.dart).Path.Replace('\', '/')
.\gradlew.bat app:connectedPreviewDebugAndroidTest "-Ptarget=$target"
```

Use `app:connectedProductionDebugAndroidTest` for the production flavor. A
connected Android device or emulator is required.
