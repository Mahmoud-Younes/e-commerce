import 'package:bloc_test/bloc_test.dart';
import 'package:e_commerce_app/core/models/cart_item_model.dart';
import 'package:e_commerce_app/core/models/order_model.dart';
import 'package:e_commerce_app/core/models/order_status.dart';
import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/features/orders/logic/cubit/orders_cubit.dart';
import 'package:e_commerce_app/features/orders/logic/cubit/orders_state.dart';
import 'package:e_commerce_app/features/orders/ui/screens/my_orders_screen.dart';
import 'package:e_commerce_app/features/orders/ui/screens/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockOrdersCubit
    extends MockCubit<OrdersState<List<OrderModel>>>
    implements OrdersCubit {}

OrderModel _order({
  required String id,
  required OrderStatus status,
  required DateTime createdAt,
}) =>
    OrderModel(
      id: id,
      userId: 'user-1',
      items: const [
        CartItemModel(productId: 'p-1', name: 'Mug', price: 9.5, quantity: 2),
      ],
      totalPrice: 19.0,
      shippingAddress: '14 Nile St, Cairo',
      phone: '01001234567',
      status: status,
      createdAt: createdAt,
    );

void main() {
  late _MockOrdersCubit cubit;

  setUp(() {
    cubit = _MockOrdersCubit();
    // Tapping a row pushes the details screen, which calls loadOrderDetails;
    // an unstubbed Future<void> method on a MockCubit returns null.
    when(() => cubit.loadOrderDetails(any())).thenAnswer((_) async {});
  });

  Widget app() =>
      // Same ScreenUtil setup as the real app (lib/e_commerce_app.dart) —
      // TextStyles use .sp, which needs ScreenUtilInit before building.
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          routes: {
            // Same cubit instance across routes, as BlocProvider.value would be
            // wrapped by the real router case for orderDetailsScreen too.
            '/orderDetailsScreen': (context) =>
                BlocProvider<OrdersCubit>.value(
                  value: cubit,
                  child: const OrderDetailsScreen(),
                ),
          },
          home: BlocProvider<OrdersCubit>.value(
            value: cubit,
            child: const MyOrdersScreen(),
          ),
        ),
      );

  group('MyOrdersScreen', () {
    testWidgets('shows a spinner while the orders stream is loading',
        (tester) async {
      whenListen(
        cubit,
        const Stream<OrdersState<List<OrderModel>>>.empty(),
        initialState: const OrdersState<List<OrderModel>>.ordersLoading(),
      );

      await tester.pumpWidget(app());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows the empty state when there are no orders',
        (tester) async {
      whenListen(
        cubit,
        const Stream<OrdersState<List<OrderModel>>>.empty(),
        initialState: const OrdersState<List<OrderModel>>.ordersEmpty(),
      );

      await tester.pumpWidget(app());

      expect(find.text('No orders yet.'), findsOneWidget);
    });

    testWidgets('shows each order with date, total and a colored status chip',
        (tester) async {
      final orders = [
        _order(
          id: 'order-1',
          status: OrderStatus.pending,
          createdAt: DateTime(2026, 10, 31, 12, 30),
        ),
        _order(
          id: 'order-2',
          status: OrderStatus.delivered,
          createdAt: DateTime(2026, 10, 1, 9, 0),
        ),
      ];
      whenListen(
        cubit,
        const Stream<OrdersState<List<OrderModel>>>.empty(),
        initialState: OrdersState<List<OrderModel>>.ordersLoaded(orders),
      );

      await tester.pumpWidget(app());

      // Date + total + status text per row.
      expect(find.text('2026-10-31 – 12:30'), findsOneWidget);
      expect(find.text('2026-10-01 – 09:00'), findsOneWidget);
      expect(find.text('\$19.00'), findsNWidgets(2));
      expect(find.text('pending'), findsOneWidget);
      expect(find.text('delivered'), findsOneWidget);
    });

    testWidgets('shows the error message when the stream fails',
        (tester) async {
      whenListen(
        cubit,
        const Stream<OrdersState<List<OrderModel>>>.empty(),
        initialState: const OrdersState<List<OrderModel>>.ordersError(
          ApiErrorModel(message: 'Firestore is unreachable.'),
        ),
      );

      await tester.pumpWidget(app());

      expect(find.text('Firestore is unreachable.'), findsOneWidget);
    });

    testWidgets('tapping a row pushes orderDetailsScreen with the order id',
        (tester) async {
      final order = _order(
        id: 'order-42',
        status: OrderStatus.pending,
        createdAt: DateTime(2026, 10, 31, 12, 30),
      );
      whenListen(
        cubit,
        const Stream<OrdersState<List<OrderModel>>>.empty(),
        initialState: OrdersState<List<OrderModel>>.ordersLoaded([order]),
      );

      await tester.pumpWidget(app());
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      // The details route receives the order id as route arguments.
      expect(find.text('Order Details'), findsOneWidget);
    });
  });
}



