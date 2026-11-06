import 'package:bloc_test/bloc_test.dart';
import 'package:e_commerce_app/core/models/cart_item_model.dart';
import 'package:e_commerce_app/core/models/order_model.dart';
import 'package:e_commerce_app/core/models/order_status.dart';
import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/features/admin/logic/cubit/admin_orders_cubit.dart';
import 'package:e_commerce_app/features/admin/logic/cubit/admin_orders_state.dart';
import 'package:e_commerce_app/features/admin/ui/screens/admin_order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAdminOrdersCubit extends MockCubit<AdminOrdersState>
    implements AdminOrdersCubit {}

OrderModel orderWithStatus(OrderStatus status) => OrderModel(
  id: 'order-1',
  userId: 'user-1',
  items: const [
    CartItemModel(productId: 'p-1', name: 'Mug', price: 9.5, quantity: 2),
    CartItemModel(productId: 'p-2', name: 'Poster', price: 4.0, quantity: 1),
  ],
  totalPrice: 23.0,
  shippingAddress: '14 Nile St, Cairo',
  phone: '01001234567',
  status: status,
  createdAt: DateTime(2026, 10, 31, 12, 30),
);

void main() {
  late _MockAdminOrdersCubit cubit;

  setUpAll(() {
    // mocktail needs a fallback for every custom type used with any() —
    // updateOrderStatus(order, status) and cancelOrder(order) both appear.
    registerFallbackValue(
      OrderModel(userId: 'fallback', createdAt: DateTime(2026)),
    );
    registerFallbackValue(OrderStatus.pending);
  });

  setUp(() {
    cubit = _MockAdminOrdersCubit();
  });

  Widget app() => ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    child: MaterialApp(
      home: BlocProvider<AdminOrdersCubit>.value(
        value: cubit,
        child: const AdminOrderDetailsScreen(orderId: 'order-1'),
      ),
    ),
  );

  Future<void> pumpLoaded(WidgetTester tester, OrderStatus status) async {
    whenListen(
      cubit,
      const Stream<AdminOrdersState>.empty(),
      initialState: AdminOrdersState.orderDetailsSuccess(
        orderWithStatus(status),
      ),
    );
    when(() => cubit.openOrder(any())).thenAnswer((_) async {});
    await tester.pumpWidget(app());
    await tester.pump();
  }

  group('AdminOrderDetailsScreen (PRD §5: review items/delivery info)', () {
    testWidgets('calls openOrder with the route argument on init', (
      tester,
    ) async {
      when(() => cubit.openOrder(any())).thenAnswer((_) async {});
      whenListen(
        cubit,
        const Stream<AdminOrdersState>.empty(),
        initialState: const AdminOrdersState.orderDetailsLoading(),
      );

      await tester.pumpWidget(app());

      verify(() => cubit.openOrder('order-1')).called(1);
    });

    testWidgets('shows the order items with quantity, unit price and '
        'subtotal, plus the delivery information', (tester) async {
      await pumpLoaded(tester, OrderStatus.pending);

      expect(find.text('Mug'), findsOneWidget);
      expect(find.text('Poster'), findsOneWidget);
      expect(find.text('\$9.50 × 2'), findsOneWidget);
      expect(find.text('\$4.00 × 1'), findsOneWidget);
      expect(find.text('\$19.00'), findsOneWidget); // Mug subtotal
      expect(find.text('Total: \$23.00'), findsOneWidget);
      expect(find.textContaining('Address: 14 Nile St, Cairo'), findsOneWidget);
      expect(find.textContaining('Phone: 01001234567'), findsOneWidget);
    });

    testWidgets('a PENDING order offers exactly ONE advance step '
        '(confirmed) plus the cancel button', (tester) async {
      await pumpLoaded(tester, OrderStatus.pending);

      expect(find.text('Advance to confirmed'), findsOneWidget);
      // The item list makes the content slightly taller than the default
      // 800x600 test surface: the cancel button is built but sits just
      // below the fold, so look past the viewport boundary.
      expect(find.text('Cancel order', skipOffstage: false), findsOneWidget);
      // No skipping: no other step is offered.
      expect(
        find.textContaining('Advance to preparing', skipOffstage: false),
        findsNothing,
      );
      expect(
        find.textContaining('Advance to shipped', skipOffstage: false),
        findsNothing,
      );
      expect(
        find.textContaining('Advance to delivered', skipOffstage: false),
        findsNothing,
      );
    });

    testWidgets('a CONFIRMED order offers preparing and NO cancel button '
        '(cancellation is only allowed before confirmed)', (tester) async {
      await pumpLoaded(tester, OrderStatus.confirmed);

      expect(find.text('Advance to preparing'), findsOneWidget);
      expect(find.text('Cancel order'), findsNothing);
    });

    testWidgets('a DELIVERED (final) order offers no actions', (tester) async {
      await pumpLoaded(tester, OrderStatus.delivered);

      expect(find.textContaining('Advance to'), findsNothing);
      expect(find.text('Cancel order'), findsNothing);
      expect(
        find.text('This order is final — its status cannot change.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping the advance button calls updateOrderStatus with '
        'the EXACT next step — never a jump', (tester) async {
      when(() => cubit.updateOrderStatus(any(), any()))
          .thenAnswer((_) async {});
      await pumpLoaded(tester, OrderStatus.pending);

      // The action buttons sit just below the fold of the default test
      // surface (800x600) — reveal before tapping, else the tap misses.
      await tester.ensureVisible(
        find.text('Advance to confirmed', skipOffstage: false),
      );
      await tester.pump();
      await tester.tap(find.text('Advance to confirmed'));
      await tester.pump();

      final captured = verify(
        () => cubit.updateOrderStatus(captureAny(), captureAny()),
      ).captured;
      expect((captured[0] as OrderModel).id, 'order-1');
      expect(captured[1], OrderStatus.confirmed);
    });

    testWidgets('tapping Cancel order calls cancelOrder (pending order only)', (
      tester,
    ) async {
      when(() => cubit.cancelOrder(any())).thenAnswer((_) async {});
      await pumpLoaded(tester, OrderStatus.pending);

      // The cancel button sits just below the fold of the default test
      // surface — scroll it into view before tapping (skipOffstage so the
      // finder sees the built-but-not-painted element).
      await tester.ensureVisible(
        find.text('Cancel order', skipOffstage: false),
      );
      await tester.pump();
      await tester.tap(find.text('Cancel order'));
      await tester.pump();

      final captured = verify(() => cubit.cancelOrder(captureAny())).captured;
      expect((captured.single as OrderModel).id, 'order-1');
    });

    testWidgets('shows the error snackbar when a status update is rejected '
        '(e.g. a jump outside the sequence)', (tester) async {
      // Feed the states through whenListen's stream: MockCubit.emit is an
      // unstubbed mocktail method (a silent no-op), so emitted states never
      // reach the BlocConsumer — the stream is the only delivery channel.
      whenListen(
        cubit,
        Stream.fromIterable(const <AdminOrdersState>[
          AdminOrdersState.statusUpdateError(
            ApiErrorModel(
              message: 'From pending the order can only move to confirmed.',
            ),
          ),
        ]),
        initialState: AdminOrdersState.orderDetailsSuccess(
          orderWithStatus(OrderStatus.pending),
        ),
      );
      when(() => cubit.openOrder(any())).thenAnswer((_) async {});
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(
        find.text('From pending the order can only move to confirmed.'),
        findsOneWidget,
      );
    });

    testWidgets('shows the writeUnauthorized snackbar when a non-admin '
        'tries to write (PRD §5 role protection)', (tester) async {
      whenListen(
        cubit,
        Stream.fromIterable(const <AdminOrdersState>[
          AdminOrdersState.writeUnauthorized(
            ApiErrorModel(message: 'Only admins can perform this action.'),
          ),
        ]),
        initialState: AdminOrdersState.orderDetailsSuccess(
          orderWithStatus(OrderStatus.pending),
        ),
      );
      when(() => cubit.openOrder(any())).thenAnswer((_) async {});
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(find.text('Only admins can perform this action.'), findsOneWidget);
    });

    testWidgets('re-renders with the new status after a successful update', (
      tester,
    ) async {
      whenListen(
        cubit,
        Stream.fromIterable(<AdminOrdersState>[
          AdminOrdersState.statusUpdateSuccess(
            orderWithStatus(OrderStatus.confirmed),
            'Order is now confirmed.',
          ),
        ]),
        initialState: AdminOrdersState.orderDetailsSuccess(
          orderWithStatus(OrderStatus.pending),
        ),
      );
      when(() => cubit.openOrder(any())).thenAnswer((_) async {});
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(find.text('confirmed'), findsOneWidget);
      expect(find.text('Advance to preparing'), findsOneWidget);
    });
  });
}



