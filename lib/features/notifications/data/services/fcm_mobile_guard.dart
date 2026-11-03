/// Mobile-only guard for FCM (PRD §6 scope is mobile). Compiled via
/// conditional import from `fcm_mobile_guard.dart`:
/// - native (Android/iOS/desktop): real `dart:io` [Platform] check
/// - web: always `false` (dart:io is unavailable, FCM push is a no-op)
///
/// FcmService early-returns on `!isMobilePlatform`, so the app stays
/// healthy on web and desktop.
library;

export 'fcm_mobile_guard_io.dart'    if (dart.library.js_interop) 'fcm_mobile_guard_web.dart';
