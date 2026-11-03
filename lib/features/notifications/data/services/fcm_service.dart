import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/routing/routes.dart';
import '../../../../firebase_options.dart';
import 'fcm_mobile_guard.dart';

/// FCM plumbing for PRD §6 — the only messaging entry point in the app.
///
/// Responsibilities:
/// - request notification permission (mobile only; no-op on web/desktop via
///   [isMobilePlatform], so the app stays healthy there);
/// - get the device token and persist it on the user's document
///   (`users/{uid}.fcmToken`), refreshing it on `onTokenRefresh`;
/// - handle messages in all app states:
///   - foreground: [FirebaseMessaging.onMessage] → record the notification;
///   - background: top-level [firebaseMessagingBackgroundHandler] records it;
///   - terminated: [firebaseMessagingBackgroundHandler] ran on delivery, and
///     the tap is resolved by [FirebaseMessaging.getInitialMessage];
/// - a tapped notification carrying `orderId` in its data opens the order
///   details screen via named navigation:
///   `pushNamed(Routes.orderDetailsScreen, arguments: orderId)` — the exact
///   seam documented by the orders feature
///   (lib/features/orders/ui/screens/order_details_screen.dart:16-31,
///   lib/features/orders/ui/screens/my_orders_screen.dart:35).
///
/// SENDING (PRD §6): notifications are sent from a trusted server
/// (Cloud Functions with the Firebase Admin SDK). No sending credentials or
/// server keys live in this app.
/// TODO(owner): implement the Cloud Function trigger on order-status change
/// that sends an FCM data message `{orderId, userId, title, body}` to
/// `users/{uid}.fcmToken` and drops the `notifications/{id}` record server-side.
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
  FcmService({
    FirebaseMessaging? messaging,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _messaging = messaging,
        _auth = auth,
        _firestore = firestore;

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

    await getTokenAndSave();

    // PRD §6: update the stored token whenever it changes.
    _subscriptions.add(_msg.onTokenRefresh.listen(_saveToken));

    // Foreground (PRD §6): record into the in-app center. The OS does not
    // show a system notification for foreground data messages; the center
    // screen is the surface.
    _subscriptions.add(FirebaseMessaging.onMessage.listen(_handleForeground));

    // Background tap (PRD §6: tapping opens order details).
    _subscriptions.add(FirebaseMessaging.onMessageOpenedApp.listen(handleMessageTap));

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

  /// Gets the FCM token and stores it on `users/{uid}` (PRD §6: "store it
  /// securely" — the doc is only writable by the authenticated user's own
  /// security rules). Returns the token, or null when unavailable/skipped.
  Future<String?> getTokenAndSave([String? userId]) async {
    if (!isMobilePlatform) return null;
    final token = await _msg.getToken();
    if (token == null) return null;
    await _saveToken(token, userId);
    return token;
  }

  Future<void> _saveToken(String token, [String? userId]) async {
    final uid = userId ?? _currentUserId();
    if (uid == null || uid.isEmpty) return;
    await _userDoc(uid).set(
      <String, dynamic>{
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ================================ MESSAGES ==================================

  void _handleForeground(RemoteMessage message) {
    // Fire-and-forget: recording must not crash the UI stream.
    recordOrderNotification(
      message,
      _firestore ?? FirebaseFirestore.instance,
      userId: _currentUserId(),
    ).catchError((_) {});
  }

  /// A notification was tapped (background or terminated). Records it and —
  /// when it carries an `orderId` — opens the order details screen
  /// (PRD §6), using the same route seam as the orders feature.
  @visibleForTesting
  Future<void> handleMessageTap(RemoteMessage message) async {
    await recordOrderNotification(
      message,
      _firestore ?? FirebaseFirestore.instance,
      userId: _currentUserId(),
    );

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
      (_firestore ?? FirebaseFirestore.instance)
          .doc(FirestorePaths.userDoc(uid));

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
/// so the sender (Cloud Function — TODO(owner)) must include `userId` in the
/// data payload.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await recordOrderNotification(
    message,
    FirebaseFirestore.instance,
    userId: message.data['userId'] as String?,
  );
}

/// Records an incoming order notification into the in-app notification
/// center collection (`notifications` — PRD §6/§7) when it carries an
/// `orderId`; promotional messages without one are ignored.
Future<void> recordOrderNotification(
  RemoteMessage message,
  FirebaseFirestore firestore, {
  String? userId,
}) async {
  final orderId = message.data['orderId'];
  if (orderId is! String || orderId.isEmpty) return;

  await firestore.collection(FirestorePaths.notifications).add(
    <String, dynamic>{
      'userId': userId ?? '',
      'title':
          message.notification?.title ?? (message.data['title'] as String?) ?? '',
      'body':
          message.notification?.body ?? (message.data['body'] as String?) ?? '',
      'orderId': orderId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
  );
}
