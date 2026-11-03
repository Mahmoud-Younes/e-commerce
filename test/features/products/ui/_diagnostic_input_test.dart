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

ProductDoc doc(String id,
        {required String name, required String category, required double price}) =>
    ProductDoc(
      id: id,
      product: ProductModel(name: name, price: price, category: category, stock: 4),
    );

void main() {
  testWidgets('B: ProductsScreen search via direct cubit call (no enterText)',
      (tester) async {
    final dataSource = MockProductCatalogDataSource();
    final controller = StreamController<List<ProductDoc>>();
    when(() => dataSource.streamCatalog()).thenAnswer((_) => controller.stream);
    final cubit = ProductsCubit(dataSource);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        child: MaterialApp(
          home: BlocProvider<ProductsCubit>.value(
            value: cubit,
            child: const ProductsScreen(),
          ),
        ),
      ),
    );

    controller.add([
      doc('p1', name: 'Running Shoes', category: 'Fashion', price: 99.5),
      doc('p2', name: 'Laptop', category: 'Electronics', price: 1299),
    ]);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Running Shoes'), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);

    cubit.search('LAP');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Laptop'), findsOneWidget);
    expect(find.text('Running Shoes'), findsNothing);

    await cubit.close();
    await controller.close();
  });
}
