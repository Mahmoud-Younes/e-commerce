import 'package:e_commerce_app/core/models/notification_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = DateTime(2026, 10, 31, 9, 0);

  group('NotificationModel round-trip', () {
    test('toJson -> fromJson preserves all fields', () {
      final notification = NotificationModel(
        userId: 'user-1',
        title: 'Order shipped',
        body: 'Your order #order-1 is on the way.',
        orderId: 'order-1',
        isRead: false,
        createdAt: createdAt,
      );

      final decoded = NotificationModel.fromJson(notification.toJson());

      expect(decoded.userId, notification.userId);
      expect(decoded.title, notification.title);
      expect(decoded.body, notification.body);
      expect(decoded.orderId, notification.orderId);
      expect(decoded.isRead, notification.isRead);
      expect(decoded.createdAt.toUtc(), createdAt.toUtc());
    });

    test('missing fields fall back to defaults', () {
      final decoded = NotificationModel.fromJson(<String, dynamic>{
        'createdAt': createdAt.millisecondsSinceEpoch,
      });

      expect(decoded.userId, '');
      expect(decoded.title, '');
      expect(decoded.body, '');
      expect(decoded.orderId, '');
      expect(decoded.isRead, isFalse);
    });
  });
}



