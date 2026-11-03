import '../models/notification_model.dart';
import '../networking/api_result.dart';

/// In-app notification center repository (PRD §6 optional, §7). Notification
/// docs live at `notifications/{notificationId}` (see
/// `FirestorePaths.notificationDoc`); push delivery itself is FCM +
/// Cloud Functions — this repo only reads/marks the stored records.
///
/// get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`):
/// ```dart
/// getIt.registerLazySingleton<NotificationRepository>(
///   () => NotificationRepositoryImpl(),
/// );
/// ```
///
/// Conventions: one-shot writes return [ApiResult] (failures via
/// `ApiErrorHandler.handle`, never thrown); realtime reads return plain
/// `Stream`s.
abstract class NotificationRepository {
  /// Live stream of one user's notifications, newest first (PRD §6: in-app
  /// notification center).
  Stream<List<NotificationModel>> streamUserNotifications(String userId);

  /// Mark a notification as read (`isRead: true`).
  Future<ApiResult<void>> markRead(String notificationId);
}
