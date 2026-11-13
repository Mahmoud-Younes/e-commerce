import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/dependency_injection.dart';
import 'core/helpers/constants.dart';
import 'core/routing/app_router.dart';
import 'e_commerce_app.dart';
import 'features/notifications/data/services/fcm_service.dart';
import 'firebase_options.dart';

/// Root navigator. Passed to [ECommerceApp] (MaterialApp) and attached to
/// [FcmService], so tapping a push notification with an `orderId` can push
/// `Routes.orderDetailsScreen` from anywhere in the app.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Mirrors `SupabaseAdminImageUploader.isConfigured`: only touch Supabase
/// when [SupabaseConfig] holds real values, so the app boots fine without a
/// Supabase project (placeholder config → manual image URLs only).
bool get _isSupabaseConfigured {
  bool isReal(String value) => value.isNotEmpty && !value.startsWith('YOUR_');
  return isReal(SupabaseConfig.url) && isReal(SupabaseConfig.publishableKey);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FCM background/terminated handler (PRD §6). Must be a top-level function
  // registered BEFORE runApp — see [firebaseMessagingBackgroundHandler].
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupGetIt();

  // Supabase Storage (product images) — only with real config; skipped
  // otherwise so boot never depends on Supabase.
  if (_isSupabaseConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }

  // To fix texts being hidden bug in flutter_screenutil in release mode.
  await ScreenUtil.ensureScreenSize();
  runApp(ECommerceApp(appRouter: AppRouter(), navigatorKey: appNavigatorKey));

  // FCM receiver (PRD §6): attach the root navigator first, then initialize
  // (permission request, token save, message/tap streams). It runs AFTER
  // runApp so the terminated-state tap resolved inside initialize() finds a
  // live navigator; awaiting here cannot delay first paint anymore.
  final fcm = getIt<FcmService>()..attachNavigator(appNavigatorKey);
  await fcm.initialize();
}
