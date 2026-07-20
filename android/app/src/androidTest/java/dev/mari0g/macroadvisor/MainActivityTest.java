package dev.mari0g.macroadvisor;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.integration_test.FlutterTestRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

/**
 * Native Android entry point for Flutter integration tests.
 *
 * <p>Run a specific Dart journey from the android directory, for example:
 * {@code .\gradlew.bat app:connectedPreviewDebugAndroidTest -Ptarget=..\integration_test\mvp_critical_journey_test.dart}
 */
@RunWith(FlutterTestRunner.class)
public class MainActivityTest {
  @Rule
  public ActivityTestRule<MainActivity> rule =
      new ActivityTestRule<>(MainActivity.class, true, false);
}
