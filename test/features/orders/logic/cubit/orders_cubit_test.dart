import 'package:bloc_test/bloc_test.dart';
import 'package:e_commerce_app/core/models/cart_item_model.dart';
import 'package:e_commerce_app/core/models/order_model.dart';
import 'package:e_commerce_app/core/models/order_status.dart';
import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/core/repositories/order_repository.dart';
import 'package:e_commerce_app/features/orders/logic/cubit/orders_cubit.dart';
import 'package:e_commerce_app/features/orders/logic/cubit/orders_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late _MockOrderRepository repo;

  const item = CartItemModel(productId: 'p-1', name: 'Mug', price: 9.5);
  final order = OrderModel(
    id: 'order-1',
    userId: 'user-1',
    items: const [item],
    totalPrice: 19.0,
    shippingAddress: '14 Nile St, Cairo',
    phone: '01001234567',
    status: OrderStatus.pending,
    createdAt: DateTime(2026, 10, 31, 12, 30),
  );

  setUp(() {
    repo = _MockOrderRepository();
  });

  group('OrdersCubit.loadOrders (My Orders stream)', () {
    blocTest<OrdersCubit, OrdersState<List<OrderModel>>>(
      'emits [loading, loaded] when the stream yields orders',
      build: () {
        when(() => repo.streamUserOrders('user-1'))
            .thenAnswer((_) => Stream.value([order]));
        return OrdersCubit(repo);
      },
      act: (cubit) => cubit.loadOrders('user-1'),
      expect: () => <OrdersState<List<OrderModel>>>[
        const OrdersState.ordersLoading(),
        OrdersState.ordersLoaded([order]),
      ],
    );

    blocTest<OrdersCubit, OrdersState<List<OrderModel>>>(
      'emits [loading, empty] when the stream yields no orders',
      build: () {
        when(() => repo.streamUserOrders('user-1'))
            .thenAnswer((_) => Stream.value(const <OrderModel>[]));
        return OrdersCubit(repo);
      },
      act: (cubit) => cubit.loadOrders('user-1'),
      expect: () => <OrdersState<List<OrderModel>>>[
        const OrdersState.ordersLoading(),
        const OrdersState.ordersEmpty(),
      ],
    );

    blocTest<OrdersCubit, OrdersState<List<OrderModel>>>(
      'emits ordersError when the stream fails',
      build: () {
        when(() => repo.streamUserOrders('user-1'))
            .thenAnswer((_) => Stream.error(Exception('firestore down')));
        return OrdersCubit(repo);
      },
      act: (cubit) => cubit.loadOrders('user-1'),
      expect: () => <Object>[
        const OrdersState<List<OrderModel>>.ordersLoading(),
        isA<OrdersError<List<OrderModel>>>(),
      ],
    );
  });

  group('OrdersCubit.loadOrderDetails', () {
    blocTest<OrdersCubit, OrdersState<List<OrderModel>>>(
      'emits [detailsLoading, detailsLoaded] on success',
      build: () {
        when(() => repo.getById('order-1'))
            .thenAnswer((_) async => ApiResult.success(order));
        return OrdersCubit(repo);
      },
      act: (cubit) => cubit.loadOrderDetails('order-1'),
      expect: () => <OrdersState<List<OrderModel>>>[
        const OrdersState.orderDetailsLoading(),
        OrdersState.orderDetailsLoaded(order),
      ],
    );

    blocTest<OrdersCubit, OrdersState<List<OrderModel>>>(
      'emits [detailsLoading, detailsError] on failure',
      build: () {
        when(() => repo.getById('order-1')).thenAnswer(
          (_) async => ApiResult.failure(
            const ApiErrorModel(message: 'Order not found.'),
          ),
        );
        return OrdersCubit(repo);
      },
      act: (cubit) => cubit.loadOrderDetails('order-1'),
      expect: () => <OrdersState<List<OrderModel>>>[
        const OrdersState.orderDetailsLoading(),
        const OrdersState.orderDetailsError(
          ApiErrorModel(message: 'Order not found.'),
        ),
      ],
    );
  });
}



