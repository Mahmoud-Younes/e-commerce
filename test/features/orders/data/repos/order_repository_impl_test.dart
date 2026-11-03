import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:e_commerce_app/core/models/cart_item_model.dart';
import 'package:e_commerce_app/core/models/order_model.dart';
import 'package:e_commerce_app/core/models/order_status.dart';
import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/core/repositories/cart_repository.dart';
// Direct import so the freezed `when` extension and the Success/Failure
// union types are visible to the tests.
import 'package:e_commerce_app/features/orders/data/repos/order_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCartRepository extends Mock implements CartRepository {}

void main() {
  late FakeFirebaseFirestore firestore;
  late _MockCartRepository cartRepository;
  late OrderRepositoryImpl repo;

  final oldCreatedAt = DateTime(2026, 1, 1, 10);
  final newCreatedAt = DateTime(2026, 6, 15, 18);

  OrderModel payload({
    String userId = 'user-1',
    OrderStatus status = OrderStatus.pending,
    DateTime? createdAt,
  }) =>
      OrderModel(
        userId: userId,
        items: const [
          CartItemModel(
            productId: 'p-1',
            name: 'Mug at purchase time',
            price: 9.5,
            quantity: 2,
          ),
        ],
        totalPrice: 19.0,
        shippingAddress: '14 Nile St, Cairo',
        phone: '01001234567',
        status: status,
        createdAt: createdAt ?? oldCreatedAt,
      );

  setUp(() {
    firestore = FakeFirebaseFirestore();
    cartRepository = _MockCartRepository();
    when(() => cartRepository.clear(any()))
        .thenAnswer((_) async => ApiResult.success(null));
    repo = OrderRepositoryImpl(firestore, cartRepository);
  });

  group('OrderRepositoryImpl.createOrder', () {
    test('writes the payload as-is, forces status=pending and createdAt=now, '
        'and returns the Firestore-assigned id', () async {
      final result = await repo.createOrder(
        payload(status: OrderStatus.delivered, createdAt: oldCreatedAt),
      );

      final orderId =
          result.when(success: (id) => id, failure: (e) => fail('failed: $e'));
      expect(orderId, isNotEmpty);

      final doc = await firestore.doc('orders/$orderId').get();
      expect(doc.exists, isTrue);

      final saved = OrderModel.fromDoc(doc);
      expect(saved.id, orderId);
      expect(saved.userId, 'user-1');
      expect(saved.totalPrice, 19.0);
      expect(saved.shippingAddress, '14 Nile St, Cairo');
      expect(saved.phone, '01001234567');
      // Item name/price stored at purchase time, as-is from the payload.
      expect(saved.items.single.name, 'Mug at purchase time');
      expect(saved.items.single.price, 9.5);
      expect(saved.items.single.quantity, 2);
      // Trust fields forced by the repo, not the caller.
      expect(saved.status, OrderStatus.pending);
      expect(
        saved.createdAt.difference(DateTime.now()).inMinutes.abs(),
        lessThan(1),
      );
    });

    test('clears the cart through CartRepository (PRD §4)', () async {
      await firestore.collection('users/user-1/cart').doc('p-1').set({
        'productId': 'p-1',
        'name': 'Mug',
        'price': 9.5,
        'quantity': 2,
      });

      await repo.createOrder(payload());

      verify(() => cartRepository.clear('user-1')).called(1);
    });

    test('treats a cart-clear failure as non-fatal once the order doc is '
        'committed (duplicate orders are worse than a stale cart)',
        () async {
      when(() => cartRepository.clear(any())).thenAnswer(
        (_) async => ApiResult.failure(
          const ApiErrorModel(message: 'cart clear failed'),
        ),
      );

      final result = await repo.createOrder(payload());

      expect(result, isA<Success<String>>());
      final orderId =
          result.when(success: (id) => id, failure: (e) => fail('failed: $e'));
      final doc = await firestore.doc('orders/$orderId').get();
      expect(doc.exists, isTrue);
    });
  });

  group('OrderRepositoryImpl.streamUserOrders', () {
    test('returns only the user\'s orders, newest first', () async {
      await firestore.collection('orders').doc('order-old').set(
            payload(createdAt: oldCreatedAt).toJson(),
          );
      await firestore.collection('orders').doc('order-new').set(
            payload(createdAt: newCreatedAt).toJson(),
          );
      // Another customer's order must not leak in (PRD §9: users cannot read
      // other users' order data).
      await firestore.collection('orders').doc('order-other').set(
            payload(userId: 'user-2').toJson(),
          );

      final orders = await repo.streamUserOrders('user-1').first;

      expect(orders, hasLength(2));
      expect(orders.first.id, 'order-new');
      expect(orders.last.id, 'order-old');
      expect(orders.map((o) => o.userId), everyElement('user-1'));
    });

    test('emits again when an order status changes live', () async {
      await firestore.collection('orders').doc('order-1').set(
            payload().toJson(),
          );

      var emissions = 0;
      final subscription = repo.streamUserOrders('user-1').listen((orders) {
        emissions++;
        if (emissions == 1) {
          expect(orders.single.status, OrderStatus.pending);
        } else {
          expect(orders.single.status, OrderStatus.shipped);
        }
      });

      await firestore
          .collection('orders')
          .doc('order-1')
          .update({'status': OrderStatus.shipped.value});
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(emissions, greaterThanOrEqualTo(2));
      await subscription.cancel();
    });
  });

  group('OrderRepositoryImpl.getById', () {
    test('returns the order when the doc exists', () async {
      await firestore.collection('orders').doc('order-1').set(
            payload().toJson(),
          );

      final result = await repo.getById('order-1');

      result.when(
        success: (order) {
          expect(order.id, 'order-1');
          expect(order.items.single.name, 'Mug at purchase time');
        },
        failure: (e) => fail('unexpected failure: $e'),
      );
    });

    test('returns a failure when the doc does not exist', () async {
      final result = await repo.getById('missing');

      expect(result, isA<Failure<OrderModel>>());
      result.when(
        success: (_) => fail('unexpected success'),
        failure: (error) => expect(error.message, 'Order not found.'),
      );
    });
  });

  group('OrderRepositoryImpl.updateStatus', () {
    test('persists the new status', () async {
      await firestore.collection('orders').doc('order-1').set(
            payload().toJson(),
          );

      final result = await repo.updateStatus('order-1', OrderStatus.shipped);

      expect(result, isA<Success<void>>());
      final saved = OrderModel.fromDoc(
        await firestore.doc('orders/order-1').get(),
      );
      expect(saved.status, OrderStatus.shipped);
    });
  });
}



