import 'package:bloc_test/bloc_test.dart';
import 'package:e_commerce_app/core/models/cart_item_model.dart';
import 'package:e_commerce_app/core/models/order_model.dart';
import 'package:e_commerce_app/core/models/order_status.dart';
import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/features/admin/logic/cubit/admin_orders_cubit.dart';
import 'package:e_commerce_app/features/admin/logic/cubit/admin_orders_state.dart';
import 'package:e_commerce_app/features/admin/ui/screens/admin_order_details_screen.dart';
import 'package:e_commerce_app/features/admin/ui/screens/admin_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAdminOrdersCubit extends MockCubit<AdminOrdersState>
    implements AdminOrdersCubit {}

OrderModel order({
  required String id,
  required OrderStatus status,
  required DateTime createdAt,
  String userId = 'user-1',
}) => OrderModel(
  id: id,
  userId: userId,
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
  late _MockAdminOrdersCubit cubit;

  setUp(() {
    cubit = _MockAdminOrdersCubit();
  });

  Widget app() => ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    child: MaterialApp(
      routes: {
        // The details route carries the orderId as arguments, exactly as
        // the merge agent's router case will (see admin_routes.dart).
        '/adminOrderDetails': (context) => BlocProvider<AdminOrdersCubit>.value(
          value: cubit,
          child: AdminOrderDetailsScreen(
            orderId: (ModalRoute.of(context)!.settings.arguments as String),
          ),
        ),
      },
      home: BlocProvider<AdminOrdersCubit>.value(
        value: cubit,
        child: const AdminOrdersScreen(),
      ),
    ),
  );

  group('AdminOrdersScreen (PRD §5: ID, customer, total, status)', () {
    testWidgets('calls loadOrders and shows a spinner while loading', (
      tester,
    ) async {
      whenListen(
        cubit,
        const Stream<AdminOrdersState>.empty(),
        initialState: const AdminOrdersState.ordersLoading(),
      );

      await tester.pumpWidget(app());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      verify(() => cubit.loadOrders()).called(1);
    });

    testWidgets('renders each order with its ID, customer name, total and '
        'status chip', (tester) async {
      whenListen(
        cubit,
        const Stream<AdminOrdersState>.empty(),
        initialState: AdminOrdersState.ordersSuccess(
          [
            order(
              id: 'order-1',
              status: OrderStatus.pending,
              createdAt: DateTime(2026, 10, 31, 12, 30),
            ),
            order(
              id: 'order-2',
              userId: 'user-2',
              status: OrderStatus.delivered,
              createdAt: DateTime(2026, 10, 1, 9, 0),
            ),
          ],
          {'user-1': 'Mahmoud Younes', 'user-2': 'Sara Ali'},
        ),
      );

      await tester.pumpWidget(app());

      expect(find.text('#order-1'), findsOneWidget);
      expect(find.text('#order-2'), findsOneWidget);
      expect(find.text('Mahmoud Younes • \$19.00'), findsOneWidget);
      expect(find.text('Sara Ali • \$19.00'), findsOneWidget);
      expect(find.text('pending'), findsOneWidget);
      expect(find.text('delivered'), findsOneWidget);
    });

    testWidgets('falls back to the raw userId when the customer name is '
        'missing', (tester) async {
      whenListen(
        cubit,
        const Stream<AdminOrdersState>.empty(),
        initialState: AdminOrdersState.ordersSuccess([
          order(
            id: 'order-1',
            status: OrderStatus.pending,
            createdAt: DateTime(2026, 10, 31, 12, 30),
          ),
        ], const <String, String>{}),
      );

      await tester.pumpWidget(app());

      expect(find.text('user-1 • \$19.00'), findsOneWidget);
    });

    testWidgets('shows the empty state when there are no orders', (
      tester,
    ) async {
      whenListen(
        cubit,
        const Stream<AdminOrdersState>.empty(),
        initialState: const AdminOrdersState.ordersSuccess([], {}),
      );

      await tester.pumpWidget(app());

      expect(find.text('No orders yet.'), findsOneWidget);
    });

    testWidgets('tapping an order pushes adminOrderDetails with its ID as '
        'arguments', (tester) async {
      whenListen(
        cubit,
        const Stream<AdminOrdersState>.empty(),
        initialState: AdminOrdersState.ordersSuccess(
          [
            order(
              id: 'order-42',
              status: OrderStatus.pending,
              createdAt: DateTime(2026, 10, 31, 12, 30),
            ),
          ],
          {'user-1': 'Mahmoud Younes'},
        ),
      );
      // openOrder is the details screen's initState call. NOTE: do NOT call
      // whenListen again here — a second call would clobber the
      // ordersSuccess state stub above and the list would never render.
      when(() => cubit.openOrder(any())).thenAnswer((_) async {});

      await tester.pumpWidget(app());
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      // The details screen opened and fetched the right order.
      expect(find.text('Order Details'), findsOneWidget);
      verify(() => cubit.openOrder('order-42')).called(1);
    });

    testWidgets('shows the error message with a Retry button on failure', (
      tester,
    ) async {
      whenListen(
        cubit,
        const Stream<AdminOrdersState>.empty(),
        initialState: const AdminOrdersState.ordersError(
          ApiErrorModel(message: 'Firestore is unreachable.'),
        ),
      );

      await tester.pumpWidget(app());

      expect(find.text('Firestore is unreachable.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}



