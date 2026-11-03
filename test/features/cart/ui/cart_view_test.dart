import 'package:e_commerce_app/core/models/cart_item_model.dart';
import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/features/cart/logic/cubit/cart_cubit.dart';
import 'package:e_commerce_app/features/cart/logic/cubit/cart_state.dart';
import 'package:e_commerce_app/features/cart/ui/screens/cart_screen.dart';
import 'package:e_commerce_app/features/cart/ui/widgets/cart_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCartCubit extends Mock implements CartCubit {}

void main() {
  late MockCartCubit cubit;

  final line1 = const CartItemModel(
    productId: 'p1',
    name: 'T-Shirt',
    price: 50.0,
    quantity: 2,
  );
  final line2 = const CartItemModel(
    productId: 'p2',
    name: 'Sneakers',
    price: 300.0,
    quantity: 1,
  );

  setUpAll(() {
    registerFallbackValue(
      const CartItemModel(productId: 'fallback', quantity: 1),
    );
  });

  setUp(() {
    cubit = MockCartCubit();
    // BlocConsumer subscribes to the cubit stream; keep it silent.
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.close()).thenAnswer((_) async {});
    // The quantity/removal callbacks are non-nullable-Future tearoffs; stub
    // them so a tap does not blow up on an un-stubbed mock return.
    when(() => cubit.addItem(any())).thenAnswer((_) async {});
    when(() => cubit.increaseQuantity(any())).thenAnswer((_) async {});
    when(() => cubit.decreaseQuantity(any())).thenAnswer((_) async {});
    when(() => cubit.removeItem(any())).thenAnswer((_) async {});
    when(() => cubit.clearCart()).thenAnswer((_) async {});
  });

  Widget buildSubject(CartState state) {
    when(() => cubit.state).thenReturn(state);
    // Same ScreenUtil setup as the real app (lib/main.dart, lib/e_commerce_app.dart).
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, _) => BlocProvider<CartCubit>.value(
        value: cubit,
        child: const MaterialApp(home: CartView()),
      ),
    );
  }

  group('CartView', () {
    testWidgets('loaded: renders lines, subtotals and the cart total', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(CartState.loaded([line1, line2])));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('cartItemName_p1')), findsOneWidget);
      expect(find.byKey(const Key('cartItemQuantity_p1')), findsOneWidget);
      expect(find.byKey(const Key('cartItemSubtotal_p1')), findsOneWidget);
      // Subtotals: 50 * 2 = 100, 300 * 1 = 300.
      expect(find.text('100.00'), findsOneWidget);
      expect(find.text('300.00'), findsOneWidget);
      // Total: 100 + 300.
      expect(find.byKey(const Key('cartTotal')), findsOneWidget);
      expect(find.text('400.00'), findsOneWidget);
      expect(find.byKey(const Key('cartCheckoutButton')), findsOneWidget);
    });

    testWidgets('loaded: + delegates to increaseQuantity', (tester) async {
      await tester.pumpWidget(buildSubject(CartState.loaded([line1])));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cartItemIncrease_p1')));
      await tester.pumpAndSettle();

      verify(() => cubit.increaseQuantity(line1)).called(1);
    });

    testWidgets('loaded: trash icon delegates to removeItem', (tester) async {
      await tester.pumpWidget(buildSubject(CartState.loaded([line1])));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cartItemRemove_p1')));
      await tester.pumpAndSettle();

      verify(() => cubit.removeItem('p1')).called(1);
    });

    testWidgets('loaded: − delegates to decreaseQuantity', (tester) async {
      await tester.pumpWidget(buildSubject(CartState.loaded([line1])));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cartItemDecrease_p1')));
      await tester.pumpAndSettle();

      verify(() => cubit.decreaseQuantity(line1)).called(1);
    });

    testWidgets('empty: shows the empty-cart state', (tester) async {
      await tester.pumpWidget(buildSubject(const CartState.empty()));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('cartEmpty')), findsOneWidget);
      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.byKey(const Key('cartCheckoutButton')), findsNothing);
    });

    testWidgets('error: shows the error message in the body', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          const CartState.error(
            ApiErrorModel(message: 'Only 5 left of "T-Shirt".'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('cartError')), findsOneWidget);
      expect(find.text('Only 5 left of "T-Shirt".'), findsOneWidget);
    });

    testWidgets('loading: shows a progress indicator', (tester) async {
      await tester.pumpWidget(buildSubject(const CartState.loading()));
      await tester.pump();

      expect(find.byKey(const Key('cartLoading')), findsOneWidget);
    });
  });

  group('CartBadge', () {
    testWidgets('shows the counter when the cart is not empty', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(actions: [CartBadge(count: 3, onTap: () => taps++)]),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byKey(const Key('cartBadge')), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.byKey(const Key('cartBadge')));
      expect(taps, 1);
    });

    testWidgets('hides the counter when the cart is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(actions: [CartBadge(count: 0)]),
            body: const SizedBox.shrink(),
          ),
        ),
      );

      expect(find.byKey(const Key('cartBadge')), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });
  });
}



