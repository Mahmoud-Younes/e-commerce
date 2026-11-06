import 'dart:async';

import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:e_commerce_app/features/products/data/datasources/product_catalog_data_source.dart';
import 'package:e_commerce_app/features/products/data/models/product_doc.dart';
import 'package:e_commerce_app/features/products/logic/cubit/products_cubit.dart';
import 'package:e_commerce_app/features/products/ui/screens/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductCatalogDataSource extends Mock
    implements ProductCatalogDataSource {}

void main() {
  late MockProductCatalogDataSource dataSource;
  late StreamController<List<ProductDoc>> controller;
  ProductsCubit? cubit;

  ProductDoc doc(
    String id, {
    required String name,
    required String category,
    required double price,
  }) =>
      ProductDoc(
        id: id,
        product: ProductModel(
          name: name,
          price: price,
          category: category,
          stock: 4,
        ),
      );

  // The cubit is created inside the test body (pumpScreen) — not in setUp —
  // so its stream subscription lives in the test's FakeAsync zone and stream
  // events are delivered to `BlocBuilder` on `tester.pump`.
  Future<void> pumpScreen(WidgetTester tester) async {
    cubit = ProductsCubit(dataSource);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        child: MaterialApp(
          home: BlocProvider<ProductsCubit>.value(
            value: cubit!,
            child: const ProductsScreen(),
          ),
        ),
      ),
    );
  }

  /// Adds [docs] to the catalog stream and lets the delivery chain settle:
  /// controller → cubit onData → `emit` → BlocBuilder. Each `pump` advances
  /// the FakeAsync clock and flushes the microtask chain — a bare
  /// `await Future.delayed(...)` would deadlock testWidgets because fake
  /// timers only fire when the clock advances.
  Future<void> emitCatalog(
    WidgetTester tester,
    List<ProductDoc> docs,
  ) async {
    controller.add(docs);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  setUp(() {
    dataSource = MockProductCatalogDataSource();
    controller = StreamController<List<ProductDoc>>();
    when(() => dataSource.streamCatalog()).thenAnswer((_) => controller.stream);
  });

  tearDown(() async {
    cubit?.close();
    controller.close();
  });

  testWidgets('shows a loading spinner before the first catalog emission',
      (tester) async {
    await pumpScreen(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders product cards with name and price after the catalog '
      'loads', (tester) async {
    await pumpScreen(tester);
    await emitCatalog(tester, [
      doc('p1', name: 'Running Shoes', category: 'Fashion', price: 99.5),
      doc('p2', name: 'Laptop', category: 'Electronics', price: 1299),
    ]);

    expect(find.text('Running Shoes'), findsOneWidget);
    expect(find.text('99.50 EGP'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('1299.00 EGP'), findsOneWidget);
  });

  testWidgets('searching by name filters the grid (PRD §2)',
      (tester) async {
    await pumpScreen(tester);
    await emitCatalog(tester, [
      doc('p1', name: 'Running Shoes', category: 'Fashion', price: 99.5),
      doc('p2', name: 'Laptop', category: 'Electronics', price: 1299),
    ]);

    await tester.enterText(find.byType(TextField), 'LAP');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Running Shoes'), findsNothing);
  });

  testWidgets('tapping a category chip browses that category (PRD §2)',
      (tester) async {
    await pumpScreen(tester);
    await emitCatalog(tester, [
      doc('p1', name: 'Running Shoes', category: 'Fashion', price: 99.5),
      doc('p2', name: 'Laptop', category: 'Electronics', price: 1299),
    ]);

    await tester.tap(find.text('Electronics'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Running Shoes'), findsNothing);
  });

  testWidgets('search with no matches shows the empty state (PRD §9 clear '
      'empty state)', (tester) async {
    await pumpScreen(tester);
    await emitCatalog(tester, [
      doc('p1', name: 'Running Shoes', category: 'Fashion', price: 99.5),
    ]);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('No products match "zzz".'), findsOneWidget);
  });

  testWidgets('a catalog stream error shows the error state with a retry '
      'button (PRD §9 clear error state)', (tester) async {
    await pumpScreen(tester);
    controller.addError(Exception('stream blew up'));
    // Pumps advance the FakeAsync clock so the error reaches the cubit —
    // a bare `await Future.delayed(...)` would deadlock testWidgets.
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('stream blew up'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}



