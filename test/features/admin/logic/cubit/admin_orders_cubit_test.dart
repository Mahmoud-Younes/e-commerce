import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:e_commerce_app/core/models/cart_item_model.dart';
import 'package:e_commerce_app/core/models/order_model.dart';
import 'package:e_commerce_app/core/models/order_status.dart';
import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/core/repositories/order_repository.dart';
import 'package:e_commerce_app/features/admin/data/repos/admin_orders_source.dart';
import 'package:e_commerce_app/features/admin/data/repos/admin_role_guard.dart';
import 'package:e_commerce_app/features/admin/logic/cubit/admin_orders_cubit.dart';
import 'package:e_commerce_app/features/admin/logic/cubit/admin_orders_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

class _MockAdminOrdersSource extends Mock implements AdminOrdersSource {}

class _MockAdminRoleGuard extends Mock implements AdminRoleGuard {}

void main() {
  late _MockOrderRepository orderRepository;
  late _MockAdminOrdersSource ordersSource;
  late _MockAdminRoleGuard roleGuard;
  late StreamController<List<OrderModel>> ordersController;

  const item = CartItemModel(productId: 'p-1', name: 'Mug', price: 9.5);
  OrderModel orderWithStatus(OrderStatus status) => OrderModel(
    id: 'order-1',
    userId: 'user-1',
    items: const [item],
    totalPrice: 19.0,
    shippingAddress: '14 Nile St, Cairo',
    phone: '01001234567',
    status: status,
    createdAt: DateTime(2026, 10, 31, 12, 30),
  );
  final pendingOrder = orderWithStatus(OrderStatus.pending);

  setUpAll(() {
    // mocktail needs a fallback for every custom type used with any()/
    // captureAny() — OrderStatus appears as updateStatus's 2nd argument.
    registerFallbackValue(OrderStatus.pending);
  });

  setUp(() {
    orderRepository = _MockOrderRepository();
    ordersSource = _MockAdminOrdersSource();
    roleGuard = _MockAdminRoleGuard();
    ordersController = StreamController<List<OrderModel>>();
    // Admin by default — the role-guard group overrides this.
    when(() => roleGuard.ensureAdmin())
        .thenAnswer((_) async => const ApiResult.success(null));
  });

  tearDown(() async {
    ordersController.close();
  });

  AdminOrdersCubit buildCubit() =>
      AdminOrdersCubit(orderRepository, ordersSource, roleGuard);

  group('AdminOrdersCubit.loadOrders (incoming orders, PRD §5)', () {
    blocTest<AdminOrdersCubit, AdminOrdersState>(
      'emits [ordersLoading, ordersSuccess] with the orders AND the customer '
      'display names for the list tiles',
      build: () {
        when(() => ordersSource.streamAllOrders())
            .thenAnswer((_) => ordersController.stream);
        when(() => ordersSource.customerNames(any())).thenAnswer(
          (_) async => const ApiResult.success({'user-1': 'Mahmoud Younes'}),
        );
        // Buffer the snapshot on the single-subscription controller so it is
        // delivered the moment loadOrders() subscribes in act.
        ordersController.add([pendingOrder]);
        return buildCubit();
      },
      act: (cubit) => cubit.loadOrders(),
      verify: (_) {
        final captured = verify(() => ordersSource.customerNames(captureAny()))
            .captured;
        expect(captured.single, <String>{'user-1'});
      },
      expect: () => <dynamic>[
        const AdminOrdersState.ordersLoading(),
        predicate<AdminOrdersState>((state) {
          final success = state as AdminOrdersSuccess;
          return success.orders.single.id == 'order-1' &&
              success.customerNames['user-1'] == 'Mahmoud Younes';
        }, 'ordersSuccess with orders and customer names'),
      ],
    );

    blocTest<AdminOrdersCubit, AdminOrdersState>(
      'emits [ordersLoading, ordersError] when the stream fails',
      build: () {
        when(() => ordersSource.streamAllOrders())
            .thenAnswer((_) => Stream.error(Exception('firestore down')));
        return buildCubit();
      },
      act: (cubit) => cubit.loadOrders(),
      expect: () => <dynamic>[
        const AdminOrdersState.ordersLoading(),
        isA<AdminOrdersError>(),
      ],
    );
  });

  group('AdminOrdersCubit.openOrder (review items/delivery, PRD §5)', () {
    blocTest<AdminOrdersCubit, AdminOrdersState>(
      'emits [orderDetailsLoading, orderDetailsSuccess] on success',
      build: () {
        when(() => orderRepository.getById('order-1'))
            .thenAnswer((_) async => ApiResult.success(pendingOrder));
        return buildCubit();
      },
      act: (cubit) => cubit.openOrder('order-1'),
      expect: () => <dynamic>[
        const AdminOrdersState.orderDetailsLoading(),
        AdminOrdersState.orderDetailsSuccess(pendingOrder),
      ],
    );

    blocTest<AdminOrdersCubit, AdminOrdersState>(
      'emits [orderDetailsLoading, orderDetailsError] on failure',
      build: () {
        when(() => orderRepository.getById('order-1')).thenAnswer(
          (_) async => const ApiResult.failure(
            ApiErrorModel(message: 'Order not found.'),
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.openOrder('order-1'),
      expect: () => <dynamic>[
        const AdminOrdersState.orderDetailsLoading(),
        const AdminOrdersState.orderDetailsError(
          ApiErrorModel(message: 'Order not found.'),
        ),
      ],
    );
  });

  group('AdminOrdersCubit.updateOrderStatus — sequential lifecycle '
      '(PRD §5, documented business rule)', () {
    blocTest<AdminOrdersCubit, AdminOrdersState>(
      'pending → confirmed: emits [statusUpdateLoading, statusUpdateSuccess] '
      'and calls repository.updateStatus',
      build: () {
        when(() => orderRepository.updateStatus(any(), any()))
            .thenAnswer((_) async => const ApiResult.success(null));
        return buildCubit();
      },
      act: (cubit) =>
          cubit.updateOrderStatus(pendingOrder, OrderStatus.confirmed),
      verify: (_) {
        final captured = verify(
          () => orderRepository.updateStatus(captureAny(), captureAny()),
        ).captured;
        expect(captured[0], 'order-1');
        expect(captured[1], OrderStatus.confirmed);
      },
      expect: () => <dynamic>[
        const AdminOrdersState.statusUpdateLoading(),
        // OrderModel has no == override, so assert the carried order
        // field-wise instead of by instance equality.
        isA<AdminOrderStatusUpdateSuccess>()
            .having((s) => s.updatedOrder.id, 'updatedOrder.id', 'order-1')
            .having(
              (s) => s.updatedOrder.status,
              'updatedOrder.status',
              OrderStatus.confirmed,
            )
            .having(
              (s) => s.successMessage,
              'successMessage',
              'Order is now confirmed.',
            ),
      ],
    );

    blocTest<AdminOrdersCubit, AdminOrdersState>(
      'REJECTS a jump pending → preparing (two steps): emits '
      'statusUpdateError and repository.updateStatus is never called',
      build: () {
        when(() => orderRepository.updateStatus(any(), any()))
            .thenAnswer((_) async => const ApiResult.success(null));
        return buildCubit();
      },
      act: (cubit) =>
          cubit.updateOrderStatus(pendingOrder, OrderStatus.preparing),
      verify: (_) =>
          verifyNever(() => orderRepository.updateStatus(any(), any())),
      expect: () => <dynamic>[
        predicate<AdminOrderStatusUpdateError>(
          // The cubit's rejection message names the current status and the
          // one allowed next step ("From pending the order can only move to
          // confirmed.") — it does not echo the attempted jump target.
          (state) =>
              state.apiErrorModel.message!.contains('pending') &&
              state.apiErrorModel.message!.contains('confirmed'),
          'statusUpdateError naming the only allowed next status',
        ),
      ],
    );

    blocTest<AdminOrdersCubit, AdminOrdersState>(
      'REJECTS a jump pending → shipped (three steps ahead)',
      build: () {
        when(() => orderRepository.updateStatus(any(), any()))
            .thenAnswer((_) async => const ApiResult.success(null));
        return buildCubit();
      },
      act: (cubit) =>
          cubit.updateOrderStatus(pendingOrder, OrderStatus.shipped),
      verify: (_) =>
          verifyNever(() => orderRepository.updateStatus(any(), any())),
      expect: () => <dynamic>[isA<AdminOrderStatusUpdateError>()],
    );

    blocTest<AdminOrdersCubit, AdminOrdersState>(
      'REJECTS a backwards move confirmed → pending',
      build: () {
        when(() => orderRepository.updateStatus(any(), any()))
            .thenAnswer((_) async => const ApiResult.success(null));
        return buildCubit();
      },
      act: (cubit) => cubit.updateOrderStatus(
        orderWithStatus(OrderStatus.confirmed),
        OrderStatus.pending,
      ),
      verify: (_) =>
          verifyNever(() => orderRepository.updateStatus(any(), any())),
      expect: () => <dynamic>[isA<AdminOrderStatusUpdateError>()],
    );

    blocTest<AdminOrdersCubit, AdminOrdersState>(
      'REJECTS updating a final order (delivered)',
      build: () {
        when(() => orderRepository.updateStatus(any(), any()))
            .thenAnswer((_) async => const ApiResult.success(null));
        return buildCubit();
      },
      act: (cubit) => cubit.updateOrderStatus(
        orderWithStatus(OrderStatus.delivered),
        OrderStatus.delivered,
      ),
      verify: (_) =>
          verifyNever(() => orderRepository.updateStatus(any(), any())),
      expect: () => <dynamic>[
        predicate<AdminOrderStatusUpdateError>(
          (state) => state.apiErrorModel.message!.contains('final'),
          'statusUpdateError saying the order is final',
        ),
      ],
    );

    blocTest<AdminOrdersCubit, AdminOrdersState>(
      'emits statusUpdateError when the repository update fails',
      build: () {
        when(() => orderRepository.updateStatus(any(), any())).thenAnswer(
          (_) async => const ApiResult.failure(
            ApiErrorModel(message: 'Permission denied.'),
          ),
        );
        return buildCubit();
      },
      act: (cubit) =>
          cubit.updateOrderStatus(pendingOrder, OrderStatus.confirmed),
      expect: () => <dynamic>[
        const AdminOrdersState.statusUpdateLoading(),
        const AdminOrdersState.statusUpdateError(
          ApiErrorModel(message: 'Permission denied.'),
        ),
      ],
    );
  });

  group('AdminOrdersCubit.cancelOrder — only BEFORE confirmed '
      '(PRD §5, documented business rule)', () {
    blocTest<AdminOrdersCubit, AdminOrdersState>(
      'a PENDING order can be cancelled: emits '
      '[statusUpdateLoading, statusUpdateSuccess] with status cancelled',
      build: () {
        when(() => orderRepository.updateStatus(any(), any()))
            .thenAnswer((_) async => const ApiResult.success(null));
        return buildCubit();
      },
      act: (cubit) => cubit.cancelOrder(pendingOrder),
      verify: (_) {
        final captured = verify(
          () => orderRepository.updateStatus(captureAny(), captureAny()),
        ).captured;
        expect(captured[0], 'order-1');
        expect(captured[1], OrderStatus.cancelled);
      },
      expect: () => <dynamic>[
        const AdminOrdersState.statusUpdateLoading(),
        // OrderModel has no == override — assert field-wise (see above).
        isA<AdminOrderStatusUpdateSuccess>()
            .having((s) => s.updatedOrder.id, 'updatedOrder.id', 'order-1')
            .having(
              (s) => s.updatedOrder.status,
              'updatedOrder.status',
              OrderStatus.cancelled,
            )
            .having(
              (s) => s.successMessage,
              'successMessage',
              'Order is now cancelled.',
            ),
      ],
    );

    blocTest<AdminOrdersCubit, AdminOrdersState>(
      'REJECTS cancelling a CONFIRMED order (after confirmed the fulfilment '
      'flow owns it): statusUpdateError, repository never called',
      build: () {
        when(() => orderRepository.updateStatus(any(), any()))
            .thenAnswer((_) async => const ApiResult.success(null));
        return buildCubit();
      },
      act: (cubit) => cubit.cancelOrder(orderWithStatus(OrderStatus.confirmed)),
      verify: (_) =>
          verifyNever(() => orderRepository.updateStatus(any(), any())),
      expect: () => <dynamic>[
        predicate<AdminOrderStatusUpdateError>(
          (state) =>
              state.apiErrorModel.message!.contains('Only pending orders'),
          'statusUpdateError explaining the cancellation rule',
        ),
      ],
    );

    blocTest<AdminOrdersCubit, AdminOrdersState>(
      'REJECTS cancelling a SHIPPED order',
      build: () {
        when(() => orderRepository.updateStatus(any(), any()))
            .thenAnswer((_) async => const ApiResult.success(null));
        return buildCubit();
      },
      act: (cubit) => cubit.cancelOrder(orderWithStatus(OrderStatus.shipped)),
      verify: (_) =>
          verifyNever(() => orderRepository.updateStatus(any(), any())),
      expect: () => <dynamic>[isA<AdminOrderStatusUpdateError>()],
    );
  });

  group('AdminOrdersCubit — role guard on every write (PRD §1/§5)', () {
    blocTest<AdminOrdersCubit, AdminOrdersState>(
      'REJECTS the status update for a NON-ADMIN: emits writeUnauthorized '
      'and repository.updateStatus is never called',
      build: () {
        when(() => roleGuard.ensureAdmin()).thenAnswer(
          (_) async => const ApiResult.failure(
            ApiErrorModel(message: 'Only admins can perform this action.'),
          ),
        );
        return buildCubit();
      },
      act: (cubit) =>
          cubit.updateOrderStatus(pendingOrder, OrderStatus.confirmed),
      verify: (_) =>
          verifyNever(() => orderRepository.updateStatus(any(), any())),
      expect: () => <dynamic>[
        const AdminOrdersState.statusUpdateLoading(),
        const AdminOrdersState.writeUnauthorized(
          ApiErrorModel(message: 'Only admins can perform this action.'),
        ),
      ],
    );

    blocTest<AdminOrdersCubit, AdminOrdersState>(
      'REJECTS the cancellation for a NON-ADMIN: emits writeUnauthorized '
      'and repository.updateStatus is never called',
      build: () {
        when(() => roleGuard.ensureAdmin()).thenAnswer(
          (_) async => const ApiResult.failure(
            ApiErrorModel(message: 'Only admins can perform this action.'),
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.cancelOrder(pendingOrder),
      verify: (_) =>
          verifyNever(() => orderRepository.updateStatus(any(), any())),
      expect: () => <dynamic>[
        const AdminOrdersState.statusUpdateLoading(),
        const AdminOrdersState.writeUnauthorized(
          ApiErrorModel(message: 'Only admins can perform this action.'),
        ),
      ],
    );
  });
}



