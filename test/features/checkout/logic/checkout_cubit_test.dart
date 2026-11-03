import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:e_commerce_app/core/models/cart_item_model.dart';
import 'package:e_commerce_app/core/models/order_model.dart';
import 'package:e_commerce_app/core/models/order_status.dart';
import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/core/repositories/cart_repository.dart';
import 'package:e_commerce_app/core/repositories/order_repository.dart';
import 'package:e_commerce_app/features/checkout/logic/cubit/checkout_cubit.dart';
import 'package:e_commerce_app/features/checkout/logic/cubit/checkout_state.dart';

class MockCartRepository extends Mock implements CartRepository {}

class MockOrderRepository extends Mock implements OrderRepository {}

const String testUserId = 'user-1';

final List<CartItemModel> testItems = const [
  CartItemModel(productId: 'p1', name: 'Sneakers', price: 10.0, quantity: 2),
  CartItemModel(productId: 'p2', name: 'Cap', price: 5.0, quantity: 1),
];

void main() {
  setUpAll(() {
    registerFallbackValue(OrderModel(userId: 'x', createdAt: DateTime(2024)));
  });

  late MockCartRepository cartRepository;
  late MockOrderRepository orderRepository;

  CheckoutCubit buildCubit() {
    return CheckoutCubit(
      cartRepository,
      orderRepository,
      userId: testUserId,
      args: const CheckoutArgs(address: '12 Main St', phone: '0100000000'),
    );
  }

  setUp(() {
    cartRepository = MockCartRepository();
    orderRepository = MockOrderRepository();
  });

  group('CheckoutCubit loadCheckout', () {
    blocTest<CheckoutCubit, CheckoutState>(
      'emits [checkoutLoading, checkoutLoaded] with items and total from the '
      'cart stream',
      setUp: () {
        when(() => cartRepository.streamCart(testUserId))
            .thenAnswer((_) => Stream.value(testItems));
      },
      build: buildCubit,
      act: (cubit) => cubit.loadCheckout(),
      expect: () => [
        isA<CheckoutLoading>(),
        isA<CheckoutLoaded>()
            .having((s) => s.items, 'items', testItems)
            .having((s) => s.totalPrice, 'totalPrice', 25.0),
      ],
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'maps a stream error (network/permissions) to checkoutError through '
      'ApiErrorHandler',
      setUp: () {
        when(() => cartRepository.streamCart(testUserId)).thenAnswer(
          (_) => Stream<List<CartItemModel>>.error(
            FirebaseException(plugin: 'cloud_firestore', message: 'offline'),
          ),
        );
      },
      build: buildCubit,
      act: (cubit) => cubit.loadCheckout(),
      expect: () => [
        isA<CheckoutLoading>(),
        isA<CheckoutError>().having(
          (s) => s.apiErrorModel.message,
          'message',
          'offline',
        ),
      ],
    );
  });

  group('CheckoutCubit placeOrder — order payload shape (PRD §4)', () {
    blocTest<CheckoutCubit, CheckoutState>(
      'creates a pending order with purchase-time item snapshots, address and '
      'phone, then clears the cart and emits orderSuccess',
      setUp: () {
        when(() => cartRepository.validateStock(testUserId))
            .thenAnswer((_) async => ApiResult.success(testItems));
        when(() => orderRepository.createOrder(any()))
            .thenAnswer((_) async => const ApiResult.success('order-42'));
        when(() => cartRepository.clear(testUserId))
            .thenAnswer((_) async => const ApiResult.success(null));
      },
      seed: () =>
          CheckoutState.checkoutLoaded(items: testItems, totalPrice: 25.0),
      build: buildCubit,
      act: (cubit) => cubit.placeOrder(),
      expect: () => [
        isA<OrderPlacing>(),
        isA<OrderSuccess>().having((s) => s.orderId, 'orderId', 'order-42'),
      ],
      verify: (_) {
        final capturedOrders = verify(
          () => orderRepository.createOrder(captureAny()),
        ).captured;
        expect(capturedOrders, hasLength(1));
        final order = capturedOrders.single as OrderModel;

        // PRD §4: userId, items, total, address, phone, status, createdAt.
        expect(order.userId, testUserId);
        expect(order.status, OrderStatus.pending);
        expect(order.shippingAddress, '12 Main St');
        expect(order.phone, '0100000000');
        expect(order.totalPrice, 25.0);
        expect(
          order.createdAt.isAfter(
            DateTime.now().subtract(const Duration(minutes: 1)),
          ),
          isTrue,
          reason: 'createdAt must be the purchase timestamp',
        );

        // Purchase-time snapshot: name and price copied from the cart line
        // so historical orders don't change when products are edited.
        expect(order.items, hasLength(2));
        expect(order.items[0].productId, 'p1');
        expect(order.items[0].name, 'Sneakers');
        expect(order.items[0].price, 10.0);
        expect(order.items[0].quantity, 2);
        expect(order.items[1].productId, 'p2');
        expect(order.items[1].name, 'Cap');
        expect(order.items[1].price, 5.0);
        expect(order.items[1].quantity, 1);

        // PRD §4: cart cleared after a successful order.
        verify(() => cartRepository.clear(testUserId)).called(1);
      },
    );
  });

  group('CheckoutCubit placeOrder — failures', () {
    blocTest<CheckoutCubit, CheckoutState>(
      'emits checkoutError and never creates the order when stock validation '
      'fails (transient stock shortfall)',
      setUp: () {
        when(() => cartRepository.validateStock(testUserId)).thenAnswer(
          (_) async => const ApiResult.failure(
            ApiErrorModel(
              message: 'Insufficient stock for: Sneakers (only 1 left)',
            ),
          ),
        );
      },
      seed: () =>
          CheckoutState.checkoutLoaded(items: testItems, totalPrice: 25.0),
      build: buildCubit,
      act: (cubit) => cubit.placeOrder(),
      expect: () => [
        isA<OrderPlacing>(),
        isA<CheckoutError>().having(
          (s) => s.apiErrorModel.message,
          'message',
          'Insufficient stock for: Sneakers (only 1 left)',
        ),
      ],
      verify: (_) {
        verifyNever(() => orderRepository.createOrder(any()));
        verifyNever(() => cartRepository.clear(any()));
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'emits checkoutError and leaves the cart intact when order creation '
      'fails (network)',
      setUp: () {
        when(() => cartRepository.validateStock(testUserId))
            .thenAnswer((_) async => ApiResult.success(testItems));
        when(() => orderRepository.createOrder(any())).thenAnswer(
          (_) async => const ApiResult.failure(
            ApiErrorModel(message: 'Network error. Check your connection.'),
          ),
        );
      },
      seed: () =>
          CheckoutState.checkoutLoaded(items: testItems, totalPrice: 25.0),
      build: buildCubit,
      act: (cubit) => cubit.placeOrder(),
      expect: () => [
        isA<OrderPlacing>(),
        isA<CheckoutError>().having(
          (s) => s.apiErrorModel.message,
          'message',
          'Network error. Check your connection.',
        ),
      ],
      verify: (_) {
        verifyNever(() => cartRepository.clear(any()));
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'emits checkoutError when stock validation returns an empty cart',
      setUp: () {
        when(() => cartRepository.validateStock(testUserId))
            .thenAnswer((_) async => const ApiResult.success([]));
      },
      seed: () =>
          CheckoutState.checkoutLoaded(items: testItems, totalPrice: 25.0),
      build: buildCubit,
      act: (cubit) => cubit.placeOrder(),
      expect: () => [isA<OrderPlacing>(), isA<CheckoutError>()],
      verify: (_) {
        verifyNever(() => orderRepository.createOrder(any()));
      },
    );

    blocTest<CheckoutCubit, CheckoutState>(
      'guards against placing an order with nothing loaded',
      build: buildCubit,
      act: (cubit) => cubit.placeOrder(),
      expect: () => [
        isA<CheckoutError>().having(
          (s) => s.apiErrorModel.message,
          'message',
          'Your cart is empty.',
        ),
      ],
      verify: (_) {
        verifyNever(() => cartRepository.validateStock(any()));
        verifyNever(() => orderRepository.createOrder(any()));
      },
    );
  });
}



