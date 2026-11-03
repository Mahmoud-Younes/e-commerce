import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/repositories/notification_repository.dart';

/// Firestore-backed [NotificationRepository] (PRD §6 in-app notification
/// center, §7). Notification docs live at `notifications/{notificationId}`
/// ([FirestorePaths.notificationDoc]) with fields
/// userId, title, body, orderId, isRead, createdAt.
///
/// Writing those records is done by [FcmService] when a push with an
/// `orderId` arrives (PRD §6) and by the trusted-server Cloud Functions;
/// this repo only reads/marks the stored records.
///
/// get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`):
/// ```dart
/// getIt.registerLazySingleton<NotificationRepository>(
///   () => NotificationRepositoryImpl(),
/// );
/// ```
///
/// [FirebaseFirestore] is injected so tests can pass `FakeFirebaseFirestore`
/// directly (same seam as [OrderRepositoryImpl]).
class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    return _firestore
        .collection(FirestorePaths.notifications)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true) // newest first (PRD §6)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(NotificationModel.fromDoc).toList(),
        );
  }

  @override
  Future<ApiResult<void>> markRead(String notificationId) async {
    try {
      await _firestore
          .doc(FirestorePaths.notificationDoc(notificationId))
          .update({'isRead': true});
      return ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
