import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/helpers/constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../firebase_options.dart';
import 'fcm_mobile_guard.dart';

/// FCM plumbing for PRD §6 — the only messaging entry point in the app.
///
/// Responsibilities:
/// - request notification permission (mobile only; no-op on web/desktop via
///   [isMobilePlatform], so the app stays healthy there);
/// - register the app instance with FCM and persist the delivered token on
///   the user's document (`users/{uid}.fcmToken` — scalar, see
///   [UserFields.fcmToken]), refreshing it on `onRegistered`
///   (firebase_messaging 17+ removed `getToken` / `onTokenRefresh` in favor
///   of `register()` + `onRegistered`);
/// - handle messages in all app states:
///   - foreground: [FirebaseMessaging.onMessage] → no-op on purpose (the
///     server-side watcher that sent the push already created the
///     `notifications/{id}` record, so the in-app center updates through its
///     own Firestore stream);
///   - background: top-level [firebaseMessagingBackgroundHandler]
///     (registered in `lib/main.dart` before `runApp`) — same contract, no
///     client-side writes;
///   - terminated: the tap is resolved by [FirebaseMessaging.getInitialMessage];
/// - a tapped notification carrying `orderId` in its data opens the order
///   details screen via named navigation:
///   `pushNamed(Routes.orderDetailsScreen, arguments: orderId)` — the exact
///   seam documented by the orders feature
///   (lib/features/orders/ui/screens/order_details_screen.dart:16-31,
///   lib/features/orders/ui/screens/my_orders_screen.dart:35).
///
/// SENDING (PRD §6): notifications are sent from a trusted server — an
/// Admin SDK watcher outside this repo (`scripts/watch-orders.mjs`) that
/// (1) creates the `notifications/{id}` record (firestore.rules only allow
/// admins to create those docs, so this app never writes them client-side)
/// and (2) sends an FCM message carrying a `{orderId, status}` data payload
/// to the recipient's [UserFields.fcmToken] — the tap handler here reads
/// only `orderId`. No sending credentials or server keys live in this app.
///
/// get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`):
/// ```dart
/// getIt.registerLazySingleton<FcmService>(() => FcmService());
/// ```
///
/// main.dart wiring (merge agent / owner applies it):
/// ```dart
/// final appNavigatorKey = GlobalKey<NavigatorState>();
/// runApp(ECommerceApp(appRouter: AppRouter(), navigatorKey: appNavigatorKey));
/// await getIt<FcmService>()..attachNavigator(appNavigatorKey)..initialize();
/// ```
///
/// All Firebase singletons are injectable so unit tests can pass mocktail
/// mocks (`MockFirebaseMessaging`, `MockFirebaseAuth`) and
/// `FakeFirebaseFirestore` directly.
class FcmService {
  // Private named initializing formals (Dart 3.7+): callers pass the public
  // names `messaging:`, `auth:`, `firestore:` (e.g. mocks in unit tests).
  FcmService({this._messaging, this._auth, this._firestore});

  final FirebaseMessaging? _messaging;
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  /// Lazily resolved: on web/desktop the guarded methods never touch it.
  FirebaseMessaging get _msg => _messaging ?? FirebaseMessaging.instance;

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  GlobalKey<NavigatorState>? _navigatorKey;

  /// Wires the navigator used to open order details from a tapped
  /// notification. Called from main before [initialize].
  void attachNavigator(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  // ============================== INITIALIZATION ==============================

  /// Requests permission, saves the token, subscribes to refresh + message
  /// streams. No-op (healthy) on web and desktop (PRD §6 mobile scope).
  Future<void> initialize() async {
    if (!isMobilePlatform) return;

    // PRD §6: request permission when required by the platform. A denial is
    // not fatal — data messages still arrive and feed the in-app center.
    await requestPermission();

    // PRD §6: persist the token on the user's document and update it whenever
    // it changes. `onRegistered` delivers the token for the initial
    // registration and for every subsequent refresh, so it is subscribed
    // BEFORE `register()` is awaited — the token arrives on the stream once
    // registration completes (firebase_messaging 17+ has no direct `getToken`).
    _subscriptions.add(_msg.onRegistered.listen(_saveToken));
    // register() fails when the platform plugin is degraded (disabled
    // installation-ID API, missing Play services, …). Notifications are
    // best-effort (PRD §6): the token path must never take the app down —
    // report it and continue; the in-app notification center still works
    // through its own Firestore stream, and the watcher's pushes are simply
    // skipped for a device without a token.
    try {
      await _msg.register();
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'FcmService',
          context: ErrorDescription('registering the FCM token'),
          informationCollector: () => [
            ErrorHint(
              'FCM token registration failed — continuing without push; '
              'the in-app notification center remains functional.',
            ),
          ],
        ),
      );
    }

    // Foreground (PRD §6): record into the in-app center. The OS does not
    // show a system notification for foreground data messages; the center
    // screen is the surface.
    _subscriptions.add(FirebaseMessaging.onMessage.listen(_handleForeground));

    // Background tap (PRD §6: tapping opens order details).
    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen(handleMessageTap),
    );

    // Terminated tap (PRD §6): the app was cold-started by the notification.
    final initialMessage = await _msg.getInitialMessage();
    if (initialMessage != null) {
      await handleMessageTap(initialMessage);
    }
  }

  // ================================ PERMISSION ================================

  /// Requests notification permission; returns whether it was granted.
  Future<bool> requestPermission() async {
    if (!isMobilePlatform) return false;
    final settings = await _msg.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  // ================================== TOKEN ===================================

  /// Registers the app instance with FCM, stores the delivered token on
  /// `users/{uid}` (PRD §6: "store it securely" — the doc is only writable by
  /// the authenticated user's own security rules) and returns the token, or
  /// null when unavailable/skipped.
  Future<String?> getTokenAndSave([String? userId]) async {
    if (!isMobilePlatform) return null;
    final token = await _registerForToken();
    if (token == null) return null;
    await _saveToken(token, userId);
    return token;
  }

  /// Registers this app instance with FCM and completes with the token once
  /// it is delivered on `onRegistered` (firebase_messaging 17+ delivers the
  /// token on that stream instead of a direct `getToken`). The wait is
  /// bounded so a stalled registration cannot hang callers; returns null
  /// when no token arrives.
  Future<String?> _registerForToken() async {
    final Completer<String?> tokenCompleter = Completer<String?>();
    final StreamSubscription<String> registration = _msg.onRegistered.listen(
      tokenCompleter.complete,
      onError: tokenCompleter.completeError,
    );
    try {
      await _msg.register();
      return await tokenCompleter.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
    } finally {
      await registration.cancel();
    }
  }

  Future<void> _saveToken(String token, [String? userId]) async {
    final uid = userId ?? _currentUserId();
    if (uid == null || uid.isEmpty) return;
    await _userDoc(uid).set(<String, dynamic>{
      UserFields.fcmToken: token,
      UserFields.fcmTokenUpdatedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ================================ MESSAGES ==================================

  void _handleForeground(RemoteMessage message) {
    // Intentional no-op: the server-side watcher that sent this push already
    // created the `notifications/{id}` record (client writes to that
    // collection are denied by firestore.rules), and the in-app notification
    // center picks the record up through its own Firestore stream.
    assert(() {
      debugPrint(
        'FCM foreground message${message.data.containsKey('orderId') ? ' (orderId: ${message.data['orderId']})' : ''}',
      );
      return true;
    }());
  }

  /// A notification was tapped (background or terminated). When it carries
  /// an `orderId` it opens the order details screen (PRD §6), using the
  /// same route seam as the orders feature.
  @visibleForTesting
  Future<void> handleMessageTap(RemoteMessage message) async {
    final orderId = message.data['orderId'];
    if (orderId is String && orderId.isNotEmpty) {
      _navigatorKey?.currentState?.pushNamed(
        Routes.orderDetailsScreen,
        arguments: orderId,
      );
    }
  }

  // ================================ HELPERS ===================================

  String? _currentUserId() {
    final auth = _auth;
    if (auth != null) return auth.currentUser?.uid;
    if (Firebase.apps.isNotEmpty) return FirebaseAuth.instance.currentUser?.uid;
    return null;
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      (_firestore ?? FirebaseFirestore.instance).doc(
        FirestorePaths.userDoc(uid),
      );

  /// Cancels all message/token subscriptions.
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }
}

// ============================ BACKGROUND ISOLATE ==============================

/// Background/terminated handler (PRD §6). Must be a top-level function and
/// registered in main BEFORE runApp:
/// ```dart
/// FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
/// ```
/// In the background isolate the signed-in user is not resolvable reliably,
/// so the sender (the server-side Admin SDK watcher) must include `userId`
/// in the data payload.
///
/// No client-side writes here: `notifications/{id}` records are created by
/// that watcher (firestore.rules only allow admins to create them). A cold
/// start caused by a notification tap is resolved by
/// [FcmService.initialize] via `getInitialMessage`.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
