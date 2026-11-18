import 'dart:async';

import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:e_commerce_app/features/catalog/ui/screens/home_screen.dart';
import 'package:e_commerce_app/features/products/data/datasources/product_catalog_data_source.dart';
import 'package:e_commerce_app/features/products/data/models/product_doc.dart';
import 'package:e_commerce_app/features/products/logic/cubit/products_cubit.dart';
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

  // Same setup as the products screen test: the cubit is created inside the
  // test body so its catalog subscription lives in the test's FakeAsync zone
  // and stream events reach `BlocBuilder` on `tester.pump`.
  Future<void> pumpScreen(WidgetTester tester) async {
    cubit = ProductsCubit(dataSource);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        child: MaterialApp(
          home: BlocProvider<ProductsCubit>.value(
            value: cubit!,
            child: const HomeScreen(),
          ),
        ),
      ),
    );
  }

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
    controller = StreamController<List<ProductDoc>>.broadcast();
    when(() => dataSource.streamCatalog())
        .thenAnswer((_) => controller.stream);
    addTearDown(() => controller.close());
  });

  testWidgets('home shows greeting, search shortcut and catalog CTA',
      (tester) async {
    await pumpScreen(tester);
    await tester.pump();

    expect(find.text('Welcome back 👋'), findsOneWidget);
    expect(find.text('Find your next favorite product'), findsOneWidget);
    expect(find.text('Search products by name...'), findsOneWidget);
    expect(find.text('Browse Products'), findsOneWidget);
    expect(find.byTooltip('Notifications'), findsOneWidget);
    expect(find.byTooltip('Favorites'), findsOneWidget);
    expect(find.byTooltip('Cart'), findsOneWidget);
    expect(find.byTooltip('Profile'), findsOneWidget);
  });

  testWidgets('featured preview lists catalog products and category chips',
      (tester) async {
    await pumpScreen(tester);
    await emitCatalog(tester, [
      doc('p1', name: 'Green Tea 100 Bags', category: 'groceries', price: 85),
      doc(
        'p2',
        name: 'Wireless Headphones',
        category: 'electronics',
        price: 2450,
      ),
    ]);

    expect(find.text('Featured products'), findsOneWidget);
    // Two cards fit the horizontal preview without scrolling.
    expect(find.text('Green Tea 100 Bags'), findsOneWidget);
    expect(find.text('Wireless Headphones'), findsOneWidget);
    // One chip per distinct category, sorted.
    expect(find.text('electronics'), findsOneWidget);
    expect(find.text('groceries'), findsOneWidget);
  });

  testWidgets('featured preview caps at six products', (tester) async {
    await pumpScreen(tester);
    await emitCatalog(tester, [
      for (var i = 1; i <= 8; i++)
        doc(
          'p$i',
          name: 'Product $i',
          category: 'misc',
          price: (10 + i).toDouble(),
        ),
    ]);

    expect(find.text('Product 1'), findsOneWidget);
    // The horizontal list builds lazily — scroll it toward the end (the
    // featured ListView is the second ListView; the first holds the chips).
    // Only the first six docs are in the preview, so Product 7/8 stay
    // unreachable.
    await tester.scrollUntilVisible(
      find.text('Product 6'),
      400,
      scrollable: find
          .descendant(
            of: find.byType(ListView).at(1),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Product 6'), findsOneWidget);
    expect(find.text('Product 7'), findsNothing);
    expect(find.text('Product 8'), findsNothing);
  });
}
