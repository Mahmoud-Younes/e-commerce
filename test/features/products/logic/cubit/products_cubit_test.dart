import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:e_commerce_app/features/products/data/datasources/product_catalog_data_source.dart';
import 'package:e_commerce_app/features/products/data/models/product_doc.dart';
import 'package:e_commerce_app/features/products/logic/cubit/products_cubit.dart';
import 'package:e_commerce_app/features/products/logic/cubit/products_state.dart';

class MockProductCatalogDataSource extends Mock
    implements ProductCatalogDataSource {}

ProductDoc doc(
  String id, {
  String name = 'Shoes',
  String category = 'Fashion',
  double price = 99.5,
}) =>
    ProductDoc(
      id: id,
      product: ProductModel(
        name: name,
        price: price,
        category: category,
        stock: 3,
      ),
    );

void main() {
  late MockProductCatalogDataSource dataSource;
  late StreamController<List<ProductDoc>> controller;

  setUp(() {
    dataSource = MockProductCatalogDataSource();
    controller = StreamController<List<ProductDoc>>();
    when(() => dataSource.streamCatalog()).thenAnswer((_) => controller.stream);
  });

  tearDown(() async {
    controller.close();
  });

  group('ProductsCubit — catalog stream', () {
    blocTest<ProductsCubit, ProductsState>(
      'emits loaded with sorted categories when the catalog stream emits',
      build: () => ProductsCubit(dataSource),
      act: (_) => controller.add([
        doc('p1', name: 'Shoes', category: 'Fashion'),
        doc('p2', name: 'Laptop', category: 'Electronics'),
      ]),
      expect: () => [
        ProductsState.productsLoaded(
          products: [
            doc('p1', name: 'Shoes', category: 'Fashion'),
            doc('p2', name: 'Laptop', category: 'Electronics'),
          ],
          categories: ['Electronics', 'Fashion'],
        ),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'emits an error state when the catalog stream errors',
      build: () => ProductsCubit(dataSource),
      act: (_) => controller.addError(Exception('stream blew up')),
      // The loading state used to be emitted in the cubit constructor, before
      // bloc_test subscribes (bloc >=8 does not replay to late listeners),
      // so it is not part of the captured emissions.
      expect: () => [isA<ProductsError>()],
    );
  });

  group('ProductsCubit — browse by category (PRD §2)', () {
    blocTest<ProductsCubit, ProductsState>(
      'selectCategory filters the loaded products and keeps all chips',
      build: () => ProductsCubit(dataSource),
      act: (cubit) async {
        controller.add([
          doc('p1', name: 'Shoes', category: 'Fashion'),
          doc('p2', name: 'Laptop', category: 'Electronics'),
        ]);
        await Future<void>.delayed(Duration.zero);
        cubit.selectCategory('Electronics');
      },
      expect: () => [
        isA<ProductsLoaded>(),
        predicate<ProductsLoaded>(
          (state) =>
              state.products.length == 1 &&
              state.products.first.id == 'p2' &&
              state.selectedCategory == 'Electronics' &&
              state.categories.length == 2,
          'only the Electronics product, all categories kept',
        ),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'selectCategory(null) clears the filter',
      build: () => ProductsCubit(dataSource),
      act: (cubit) async {
        controller.add([
          doc('p1', name: 'Shoes', category: 'Fashion'),
          doc('p2', name: 'Laptop', category: 'Electronics'),
        ]);
        await Future<void>.delayed(Duration.zero);
        cubit.selectCategory('Electronics');
        await Future<void>.delayed(Duration.zero);
        cubit.selectCategory(null);
      },
      expect: () => [
        isA<ProductsLoaded>(),
        isA<ProductsLoaded>(),
        predicate<ProductsLoaded>(
          (state) =>
              state.products.length == 2 && state.selectedCategory == null,
          'all products again',
        ),
      ],
    );
  });

  group('ProductsCubit — search by name composed with category (PRD §2)', () {
    blocTest<ProductsCubit, ProductsState>(
      'search filters names case-insensitively',
      build: () => ProductsCubit(dataSource),
      act: (cubit) async {
        controller.add([
          doc('p1', name: 'Shoes', category: 'Fashion'),
          doc('p2', name: 'Laptop', category: 'Electronics'),
        ]);
        await Future<void>.delayed(Duration.zero);
        cubit.search('LAP');
      },
      expect: () => [
        isA<ProductsLoaded>(),
        predicate<ProductsLoaded>(
          (state) =>
              state.products.length == 1 && state.products.first.id == 'p2',
          'only Laptop matches case-insensitively',
        ),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'search composes with the selected category',
      build: () => ProductsCubit(dataSource),
      act: (cubit) async {
        controller.add([
          doc('p1', name: 'Shoes', category: 'Fashion'),
          doc('p2', name: 'Laptop', category: 'Electronics'),
        ]);
        await Future<void>.delayed(Duration.zero);
        cubit.selectCategory('Electronics');
        await Future<void>.delayed(Duration.zero);
        cubit.search('shoes');
      },
      expect: () => [
        isA<ProductsLoaded>(),
        isA<ProductsLoaded>(),
        isA<ProductsEmpty>(),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'search with no matches emits the empty state with the query echoed',
      build: () => ProductsCubit(dataSource),
      act: (cubit) async {
        controller.add([doc('p1', name: 'Shoes', category: 'Fashion')]);
        await Future<void>.delayed(Duration.zero);
        cubit.search('zzz');
      },
      expect: () => [
        isA<ProductsLoaded>(),
        predicate<ProductsEmpty>(
          (state) => state.searchQuery == 'zzz',
          'empty state carrying the search query',
        ),
      ],
    );
  });
}



