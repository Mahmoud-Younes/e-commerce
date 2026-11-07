// Driver entry for `flutter drive` (PRD stage 7 — Firestore Security Rules,
// error handling, and testing).
//
// Run (Windows):
//   cmd /c flutter drive --driver=test_driver/integration_test.dart --target=integration_test/main_flow_test.dart -d chrome
//
// This is the standard integration_test driver counterpart of the app-side
// `IntegrationTestWidgetsFlutterDriver` extension: it collects the results the
// test app reports over the flutter_driver channel and exits non-zero when any
// test failed. A test that called `markTestSkipped` (the environmental-failure
// path in main_flow_test.dart) does not count as a failure, so the suite still
// exits 0 with the reason recorded in the response data.
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
