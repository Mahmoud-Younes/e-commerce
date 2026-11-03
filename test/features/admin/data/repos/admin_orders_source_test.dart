import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e_commerce_app/core/helpers/constants.dart';
import 'package:e_commerce_app/core/models/cart_item_model.dart';
import 'package:e_commerce_app/core/models/order_model.dart';
import 'package:e_commerce_app/core/models/order_status.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/features/admin/data/repos/admin_orders_source.dart';

/// Admin-side seam over the WHOLE `orders` collection (PRD §5: "View
/// incoming orders with order ID, customer, total, and status") plus the
/// customer display names from the `users/{uid}` docs.
void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreAdminOrdersSource source;

  Map<String, dynamic> orderJson({
    String userId = 'user-1',
    double totalPrice = 19.0,
    OrderStatus status = OrderStatus.pending,
    required DateTime createdAt, // DateTime is not const-constructible.
  }) => OrderModel(
    userId: userId,
    items: const [
      CartItemModel(productId: 'p-1', name: 'Mug', price: 9.5, quantity: 2),
    ],
    totalPrice: totalPrice,
    shippingAddress: '14 Nile St, Cairo',
    phone: '01001234567',
    status: status,
    createdAt: createdAt,
  ).toJson();

  setUp(() {
    firestore = FakeFirebaseFirestore();
    source = FirestoreAdminOrdersSource(firestore);
  });

  group('FirestoreAdminOrdersSource.streamAllOrders', () {
    test('emits every order from ALL users, newest first', () async {
      final older = DateTime(2026, 10, 1, 9, 0);
      final newer = DateTime(2026, 10, 31, 12, 30);

      await firestore.collection(Collections.users).doc('user-1').set({
        UserFields.name: 'First Customer',
      });
      await firestore
          .collection('orders')
          .add(orderJson(userId: 'user-1', createdAt: older));
      await firestore
          .collection('orders')
          .add(orderJson(userId: 'user-2', createdAt: newer, totalPrice: 40.0));

      final orders = await source.streamAllOrders().first;

      expect(orders, hasLength(2));
      // Newest first (orderBy createdAt descending).
      expect(orders.first.userId, 'user-2');
      expect(orders.first.totalPrice, 40.0);
      expect(orders.last.userId, 'user-1');
      // Items survive the round-trip with purchase-time name/price.
      expect(orders.last.items.single.name, 'Mug');
      expect(orders.last.items.single.price, 9.5);
      expect(orders.last.items.single.quantity, 2);
    });

    test('parses unknown status values as pending without throwing', () async {
      await firestore.collection('orders').add({
        ...orderJson(createdAt: DateTime(2026, 10, 31)),
        'status': 'some-unknown-status',
      });

      final orders = await source.streamAllOrders().first;

      expect(orders.single.status, OrderStatus.pending);
    });
  });

  group('FirestoreAdminOrdersSource.customerNames', () {
    test('maps each userId to its users/{uid}.name', () async {
      await firestore.collection(Collections.users).doc('user-1').set({
        UserFields.name: 'Mahmoud Younes',
      });
      await firestore.collection(Collections.users).doc('user-2').set({
        UserFields.name: 'Sara Ali',
      });

      final result = await source.customerNames({'user-1', 'user-2'});

      expect(result, isA<Success<Map<String, String>>>());
      expect((result as Success<Map<String, String>>).data, {
        'user-1': 'Mahmoud Younes',
        'user-2': 'Sara Ali',
      });
    });

    test('falls back to the userId itself for a missing user doc', () async {
      await firestore.collection(Collections.users).doc('user-1').set({
        UserFields.name: 'Mahmoud Younes',
      });

      final result = await source.customerNames({'user-1', 'ghost-9'});

      final names = (result as Success<Map<String, String>>).data;
      expect(names['user-1'], 'Mahmoud Younes');
      expect(names['ghost-9'], 'ghost-9');
    });

    test('succeeds with an empty set (no orders yet)', () async {
      final result = await source.customerNames(<String>{});

      expect((result as Success<Map<String, String>>).data, isEmpty);
    });
  });
}



