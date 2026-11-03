import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:e_commerce_app/core/models/cart_item_model.dart';
import 'package:e_commerce_app/core/models/order_model.dart';
import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/core/repositories/cart_repository.dart';
import 'package:e_commerce_app/core/repositories/order_repository.dart';
import 'package:e_commerce_app/core/routing/routes.dart';
import 'package:e_commerce_app/features/checkout/logic/cubit/checkout_cubit.dart';
import 'package:e_commerce_app/features/checkout/logic/cubit/checkout_state.dart';
import 'package:e_commerce_app/features/checkout/ui/screens/checkout_screen.dart';
import 'package:e_commerce_app/features/checkout/ui/screens/order_success_screen.dart';

class MockCartRepository extends Mock implements CartRepository {}

class MockOrderRepository extends Mock implements OrderRepository {}

const List<CartItemModel> testItems = [
  CartItemModel(productId: 'p1', name: 'Sneakers', price: 9.0, quantity: 2),
];

Future<void> pumpScreen(
  WidgetTester tester, {
  required CheckoutCubit cubit,
}) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (_, _) => BlocProvider<CheckoutCubit>.value(
        value: cubit,
        child: MaterialApp(
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case Routes.orderSuccessScreen:
                return MaterialPageRoute(
                  builder: (_) => OrderSuccessScreen(
                    orderId: settings.arguments as String? ?? '',
                  ),
                );
            }
            return null;
          },
          home: const CheckoutScreen(),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Scrolls the [SingleChildScrollView] body down so the Place Order button is
/// inside the 800x600 test viewport, then taps it. Without the scroll the
/// tap offset lands outside the root render tree and the tap is dropped.
Future<void> tapPlaceOrder(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Place Order (Cash on Delivery)'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Place Order (Cash on Delivery)'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(OrderModel(userId: 'x', createdAt: DateTime(2024)));
  });

  late MockCartRepository cartRepository;
  late MockOrderRepository orderRepository;

  setUp(() {
    cartRepository = MockCartRepository();
    orderRepository = MockOrderRepository();
  });

  testWidgets(
    'renders cart items, total, editable address/phone form and Cash on '
    'Delivery',
    (tester) async {
      final cubit =
          CheckoutCubit(
            cartRepository,
            orderRepository,
            userId: 'user-1',
            args: const CheckoutArgs(
              address: '12 Main St',
              phone: '0100000000',
            ),
          )..emit(
            const CheckoutState.checkoutLoaded(
              items: testItems,
              totalPrice: 20,
            ),
          );
      addTearDown(cubit.close);

      await pumpScreen(tester, cubit: cubit);

      expect(find.text('Sneakers'), findsOneWidget);
      expect(find.text('\$9.00 x 2'), findsOneWidget);
      // Line subtotal ($9.00 x 2 = $18.00) and cart total ($20.00) are
      // distinct strings — the old $10.00 x 2 data made both render "$20.00".
      expect(find.text('\$18.00'), findsOneWidget);
      expect(find.text('\$20.00'), findsOneWidget);
      expect(find.text('Delivery details'), findsOneWidget);
      expect(
        find.text('Cash on Delivery — pay when your order arrives.'),
        findsOneWidget,
      );
      expect(find.text('Place Order (Cash on Delivery)'), findsOneWidget);
      // Prefilled, editable fields (PRD §1/§4).
      expect(find.text('12 Main St'), findsOneWidget);
      expect(find.text('0100000000'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    },
  );

  testWidgets('shows a spinner while the cart summary is loading', (
    tester,
  ) async {
    final cubit = CheckoutCubit(
      cartRepository,
      orderRepository,
      userId: 'user-1',
    );
    addTearDown(cubit.close);

    await pumpScreen(tester, cubit: cubit);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the error message and a Retry when checkout errors', (
    tester,
  ) async {
    final cubit =
        CheckoutCubit(cartRepository, orderRepository, userId: 'user-1')..emit(
          const CheckoutState.checkoutError(ApiErrorModel(message: 'offline')),
        );
    addTearDown(cubit.close);

    await pumpScreen(tester, cubit: cubit);

    expect(find.text('offline'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets(
    'blocks Place Order with empty form fields and never calls the repos',
    (tester) async {
      final cubit =
          CheckoutCubit(cartRepository, orderRepository, userId: 'user-1')
            ..emit(
              const CheckoutState.checkoutLoaded(
                items: testItems,
                totalPrice: 20,
              ),
            );
      addTearDown(cubit.close);

      await pumpScreen(tester, cubit: cubit);

      await tapPlaceOrder(tester);

      expect(find.text('Please enter a delivery address'), findsOneWidget);
      expect(find.text('Please enter a phone number'), findsOneWidget);
      verifyNever(() => cartRepository.validateStock(any()));
      verifyNever(() => orderRepository.createOrder(any()));
    },
  );

  testWidgets(
    'Place Order navigates to OrderSuccessScreen after stock validation, '
    'order creation and cart clear succeed',
    (tester) async {
      when(() => cartRepository.validateStock('user-1'))
          .thenAnswer((_) async => ApiResult.success(testItems));
      when(() => orderRepository.createOrder(any()))
          .thenAnswer((_) async => const ApiResult.success('order-42'));
      when(() => cartRepository.clear('user-1'))
          .thenAnswer((_) async => const ApiResult.success(null));

      final cubit =
          CheckoutCubit(
            cartRepository,
            orderRepository,
            userId: 'user-1',
            args: const CheckoutArgs(
              address: '12 Main St',
              phone: '0100000000',
            ),
          )..emit(
            const CheckoutState.checkoutLoaded(
              items: testItems,
              totalPrice: 20,
            ),
          );
      addTearDown(cubit.close);

      await pumpScreen(tester, cubit: cubit);

      await tapPlaceOrder(tester);

      expect(find.byType(OrderSuccessScreen), findsOneWidget);
      expect(find.text('Order placed successfully!'), findsOneWidget);
      expect(find.textContaining('order-42'), findsOneWidget);
      verify(() => orderRepository.createOrder(any())).called(1);
      verify(() => cartRepository.clear('user-1')).called(1);
    },
  );

  testWidgets(
    'Place Order keeps the checkout screen and shows the failure when stock '
    'validation fails',
    (tester) async {
      when(() => cartRepository.validateStock('user-1')).thenAnswer(
        (_) async => const ApiResult.failure(
          ApiErrorModel(message: 'Insufficient stock for: Sneakers'),
        ),
      );

      final cubit =
          CheckoutCubit(
            cartRepository,
            orderRepository,
            userId: 'user-1',
            args: const CheckoutArgs(
              address: '12 Main St',
              phone: '0100000000',
            ),
          )..emit(
            const CheckoutState.checkoutLoaded(
              items: testItems,
              totalPrice: 20,
            ),
          );
      addTearDown(cubit.close);

      await pumpScreen(tester, cubit: cubit);

      await tapPlaceOrder(tester);

      expect(find.byType(CheckoutScreen), findsOneWidget);
      expect(find.text('Insufficient stock for: Sneakers'), findsOneWidget);
      verifyNever(() => orderRepository.createOrder(any()));
      verifyNever(() => cartRepository.clear(any()));
    },
  );
}



