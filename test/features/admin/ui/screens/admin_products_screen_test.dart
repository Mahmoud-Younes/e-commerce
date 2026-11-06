import 'package:bloc_test/bloc_test.dart';
import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/features/admin/data/repos/admin_products_source.dart';
import 'package:e_commerce_app/features/admin/logic/cubit/admin_products_cubit.dart';
import 'package:e_commerce_app/features/admin/logic/cubit/admin_products_state.dart';
import 'package:e_commerce_app/features/admin/ui/screens/admin_products_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAdminProductsCubit extends MockCubit<AdminProductsState>
    implements AdminProductsCubit {}

AdminProductEntry entry(String id, String name) => AdminProductEntry(
  productId: id,
  product: ProductModel(name: name, price: 99.5, category: 'Fashion'),
);

void main() {
  late _MockAdminProductsCubit cubit;

  setUp(() {
    cubit = _MockAdminProductsCubit();
  });

  Widget app() => ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    child: MaterialApp(
      home: BlocProvider<AdminProductsCubit>.value(
        value: cubit,
        child: const AdminProductsScreen(),
      ),
    ),
  );

  group('AdminProductsScreen', () {
    testWidgets('calls loadProducts and shows a spinner while loading', (
      tester,
    ) async {
      whenListen(
        cubit,
        const Stream<AdminProductsState>.empty(),
        initialState: const AdminProductsState.productsLoading(),
      );

      await tester.pumpWidget(app());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      verify(() => cubit.loadProducts()).called(1);
    });

    testWidgets('renders each product with name, price and stock', (
      tester,
    ) async {
      whenListen(
        cubit,
        const Stream<AdminProductsState>.empty(),
        initialState: AdminProductsState.productsSuccess([
          entry('p-1', 'Running Shoes'),
          entry('p-2', 'Laptop'),
        ]),
      );

      await tester.pumpWidget(app());

      expect(find.text('Running Shoes'), findsOneWidget);
      expect(find.text('Laptop'), findsOneWidget);
      expect(find.textContaining('\$99.50'), findsNWidgets(2));
      expect(find.textContaining('stock 0'), findsNWidgets(2));
    });

    testWidgets('shows the empty state when the catalog is empty', (
      tester,
    ) async {
      whenListen(
        cubit,
        const Stream<AdminProductsState>.empty(),
        initialState: const AdminProductsState.productsSuccess([]),
      );

      await tester.pumpWidget(app());

      expect(find.textContaining('No products yet'), findsOneWidget);
    });

    testWidgets('shows the error message with a Retry button on failure', (
      tester,
    ) async {
      whenListen(
        cubit,
        const Stream<AdminProductsState>.empty(),
        initialState: const AdminProductsState.productsError(
          ApiErrorModel(message: 'Firestore is unreachable.'),
        ),
      );

      await tester.pumpWidget(app());

      expect(find.text('Firestore is unreachable.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('delete asks for confirmation FIRST and only calls '
        'deleteProduct after confirming', (tester) async {
      whenListen(
        cubit,
        const Stream<AdminProductsState>.empty(),
        initialState: AdminProductsState.productsSuccess([
          entry('p-1', 'Running Shoes'),
        ]),
      );
      when(() => cubit.deleteProduct(any())).thenAnswer((_) async {});

      await tester.pumpWidget(app());

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();

      // Confirmation dialog is up; the cubit has NOT been called yet.
      expect(find.text('Delete product?'), findsOneWidget);
      verifyNever(() => cubit.deleteProduct(any()));

      // Confirming the dialog triggers the cubit with the right product ID.
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
      verify(() => cubit.deleteProduct('p-1')).called(1);
    });

    testWidgets('cancelling the delete dialog never calls the cubit', (
      tester,
    ) async {
      whenListen(
        cubit,
        const Stream<AdminProductsState>.empty(),
        initialState: AdminProductsState.productsSuccess([
          entry('p-1', 'Running Shoes'),
        ]),
      );

      await tester.pumpWidget(app());

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => cubit.deleteProduct(any()));
    });

    testWidgets('surfaces the writeUnauthorized message as a snackbar '
        '(non-admin cannot delete, PRD §5)', (tester) async {
      whenListen(
        cubit,
        Stream.fromIterable(<AdminProductsState>[
          AdminProductsState.productsSuccess([entry('p-1', 'Running Shoes')]),
          const AdminProductsState.writeUnauthorized(
            ApiErrorModel(message: 'Only admins can perform this action.'),
          ),
        ]),
        initialState: const AdminProductsState.productsLoading(),
      );

      await tester.pumpWidget(app());
      // pumpAndSettle never settles here: while in writeUnauthorized the
      // screen's builder falls back to a CircularProgressIndicator (see
      // AdminProductsScreen._listOrSpinner), which schedules frames forever.
      // Bounded pumps still deliver the stream states and the snackbar.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Only admins can perform this action.'), findsOneWidget);
    });
  });
}



