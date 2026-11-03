import 'package:bloc_test/bloc_test.dart';
import 'package:e_commerce_app/core/models/cart_item_model.dart';
import 'package:e_commerce_app/core/models/order_model.dart';
import 'package:e_commerce_app/core/models/order_status.dart';
import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/features/orders/logic/cubit/orders_cubit.dart';
import 'package:e_commerce_app/features/orders/logic/cubit/orders_state.dart';
import 'package:e_commerce_app/features/orders/ui/screens/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockOrdersCubit
    extends MockCubit<OrdersState<List<OrderModel>>>
    implements OrdersCubit {}

OrderModel _order({OrderStatus status = OrderStatus.shipped}) =>
    OrderModel(
      id: 'order-1',
      userId: 'user-1',
      items: const [
        CartItemModel(productId: 'p-1', name: 'Mug', price: 9.5, quantity: 2),
        CartItemModel(
          productId: 'p-2',
          name: 'Notebook',
          price: 4.0,
          quantity: 1,
        ),
      ],
      totalPrice: 23.0,
      shippingAddress: '14 Nile St, Cairo',
      phone: '01001234567',
      status: status,
      createdAt: DateTime(2026, 10, 31, 12, 30),
    );

void main() {
  late _MockOrdersCubit cubit;

  setUp(() {
    cubit = _MockOrdersCubit();
    // The details screen calls loadOrderDetails from didChangeDependencies;
    // an unstubbed Future<void> method on a MockCubit returns null.
    when(() => cubit.loadOrderDetails(any())).thenAnswer((_) async {});
  });

  Widget app({String? orderId, String? routeArguments}) =>
      // Same ScreenUtil setup as the real app (lib/e_commerce_app.dart) —
      // TextStyles use .sp, which needs ScreenUtilInit before building.
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MaterialApp(
          onGenerateRoute: (settings) => MaterialPageRoute(
            settings: routeArguments != null
                ? RouteSettings(
                    name: '/orderDetailsScreen', arguments: routeArguments)
                : settings,
            builder: (_) => BlocProvider<OrdersCubit>.value(
              value: cubit,
              child: OrderDetailsScreen(orderId: orderId),
            ),
          ),
          initialRoute: '/orderDetailsScreen',
        ),
      );

  testWidgets('shows items, quantities, purchase-time prices, delivery info '
      'and status', (tester) async {
    whenListen(
      cubit,
      const Stream<OrdersState<List<OrderModel>>>.empty(),
      initialState: OrdersState<List<OrderModel>>.orderDetailsLoaded(_order()),
    );

    await tester.pumpWidget(app(orderId: 'order-1'));

    // Purchase-time item data (PRD §4: stored at purchase time).
    expect(find.text('Mug'), findsOneWidget);
    expect(find.text('Notebook'), findsOneWidget);
    expect(find.text('2 x \$9.50'), findsOneWidget);
    expect(find.text('1 x \$4.00'), findsOneWidget);
    expect(find.text('\$19.00'), findsOneWidget);
    expect(find.text('\$4.00'), findsOneWidget);
    // Delivery info.
    expect(find.text('Address: 14 Nile St, Cairo'), findsOneWidget);
    expect(find.text('Phone: 01001234567'), findsOneWidget);
    // Total + status chip.
    expect(find.text('\$23.00'), findsOneWidget);
    expect(find.text('shipped'), findsOneWidget);
    // Creation timestamp.
    expect(find.text('2026-10-31 – 12:30'), findsOneWidget);
  });

  testWidgets('shows a spinner while the order is loading', (tester) async {
    whenListen(
      cubit,
      const Stream<OrdersState<List<OrderModel>>>.empty(),
      initialState:
          const OrdersState<List<OrderModel>>.orderDetailsLoading(),
    );

    await tester.pumpWidget(app(orderId: 'order-1'));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error message when the order fails to load',
      (tester) async {
    whenListen(
      cubit,
      const Stream<OrdersState<List<OrderModel>>>.empty(),
      initialState: const OrdersState<List<OrderModel>>.orderDetailsError(
        ApiErrorModel(message: 'Order not found.'),
      ),
    );

    await tester.pumpWidget(app(orderId: 'order-1'));

    expect(find.text('Order not found.'), findsOneWidget);
  });

  testWidgets('requests the order id from the route arguments when the '
      'constructor arg is absent', (tester) async {
    whenListen(
      cubit,
      const Stream<OrdersState<List<OrderModel>>>.empty(),
      initialState:
          const OrdersState<List<OrderModel>>.orderDetailsLoading(),
    );

    await tester.pumpWidget(app(routeArguments: 'order-77'));
    await tester.pump();

    // ScreenUtilInit mounts the subtree once before and once after its
    // ScreenUtil init (verified with a probe: [mount, didChangeDeps] x2 in
    // the first frame), so the request fires twice. The contract under test
    // is *that* the route argument is requested, not how many times.
    verify(() => cubit.loadOrderDetails('order-77'));
  });
}



