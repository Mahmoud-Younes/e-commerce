import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/models/cart_item_model.dart';
import 'package:e_commerce_app/core/models/order_model.dart';
import 'package:e_commerce_app/core/models/order_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 31, 12, 30);

  OrderModel orderWith(OrderStatus status) => OrderModel(
        id: 'order-1',
        userId: 'user-1',
        items: const [
          CartItemModel(productId: 'p-1', name: 'Mug', price: 9.5, quantity: 2),
        ],
        totalPrice: 19.0,
        shippingAddress: '14 Nile St, Cairo',
        phone: '01001234567',
        status: status,
        createdAt: now,
      );

  group('OrderModel round-trip', () {
    test('toJson -> fromJson preserves all fields incl. nested items', () {
      final order = OrderModel(
        id: 'order-1',
        userId: 'user-1',
        items: const [
          CartItemModel(productId: 'p-1', name: 'Mug', price: 9.5, quantity: 2),
          CartItemModel(
            productId: 'p-2',
            name: 'Beans 1kg',
            price: 30.0,
            quantity: 1,
          ),
        ],
        totalPrice: 49.0,
        shippingAddress: '14 Nile St, Cairo',
        phone: '01001234567',
        status: OrderStatus.shipped,
        createdAt: now,
      );

      final decoded = OrderModel.fromJson(order.toJson());

      expect(decoded.id, order.id);
      expect(decoded.userId, order.userId);
      expect(decoded.items.length, 2);
      expect(decoded.items.first.productId, 'p-1');
      expect(decoded.items.first.price, 9.5);
      expect(decoded.items.last.name, 'Beans 1kg');
      expect(decoded.totalPrice, 49.0);
      expect(decoded.shippingAddress, order.shippingAddress);
      expect(decoded.phone, order.phone);
      expect(decoded.status, OrderStatus.shipped);
      expect(decoded.createdAt.toUtc(), now.toUtc());
    });

    test('createdAt round-trips through Firestore Timestamp', () {
      final json = orderWith(OrderStatus.pending).toJson();

      expect(json['createdAt'], isA<Timestamp>());

      final decoded = OrderModel.fromJson(json);
      expect(decoded.createdAt.toUtc(), now.toUtc());
    });

    test('missing fields fall back to defaults', () {
      final decoded = OrderModel.fromJson(<String, dynamic>{
        'createdAt': now.millisecondsSinceEpoch,
      });

      expect(decoded.id, '');
      expect(decoded.userId, '');
      expect(decoded.items, isEmpty);
      expect(decoded.totalPrice, 0.0);
      expect(decoded.shippingAddress, '');
      expect(decoded.phone, '');
      expect(decoded.status, OrderStatus.pending);
    });
  });

  group('OrderStatus mapping', () {
    test('every status serializes to its lowercase PRD value', () {
      expect(OrderStatus.pending.value, 'pending');
      expect(OrderStatus.confirmed.value, 'confirmed');
      expect(OrderStatus.preparing.value, 'preparing');
      expect(OrderStatus.shipped.value, 'shipped');
      expect(OrderStatus.delivered.value, 'delivered');
      expect(OrderStatus.cancelled.value, 'cancelled');
    });

    test('OrderModel serializes status to the Firestore string', () {
      for (final status in OrderStatus.values) {
        expect(orderWith(status).toJson()['status'], status.value);
      }
    });

    test('OrderStatusMapper.fromFirestore maps known values', () {
      for (final status in OrderStatus.values) {
        expect(OrderStatusMapper.fromFirestore(status.value), status);
      }
    });

    test('OrderStatusMapper.fromFirestore falls back to pending', () {
      expect(OrderStatusMapper.fromFirestore('unknown_status'),
          OrderStatus.pending);
      expect(OrderStatusMapper.fromFirestore(null), OrderStatus.pending);
      expect(OrderStatusMapper.fromFirestore(''), OrderStatus.pending);
    });
  });
}



