import '../../../../core/models/notification_model.dart';

/// A notification record paired with its Firestore document id.
///
/// Why this exists: `NotificationModel` (lib/core/models/notification_model.dart)
/// has no `id` field (PRD §7 notifications columns: userId, title, body,
/// orderId, isRead, createdAt), while
/// `NotificationRepository.markRead(notificationId)` keys on the document id.
/// The interface stream `streamUserNotifications` therefore cannot carry the
/// id back to the UI. This wrapper is produced by
/// `NotificationRepositoryImpl.streamUserNotificationRecords` (this feature's
/// own data layer — core/ was not modified); the ideal fix, for the owner, is
/// adding an `id` to `NotificationModel` exactly like `OrderModel.id`
/// (lib/core/models/order_model.dart:33,80).
class NotificationRecord {
  const NotificationRecord({required this.id, required this.notification});

  /// Firestore document id at `notifications/{id}`.
  final String id;

  final NotificationModel notification;
}
