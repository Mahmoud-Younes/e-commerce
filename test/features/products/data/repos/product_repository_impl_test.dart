import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e_commerce_app/core/constants/firestore_paths.dart';
import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/features/products/data/repos/product_repository_impl.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ProductRepositoryImpl repo;

  ProductModel product({
    String name = 'Running Shoes',
    String description = 'Comfortable shoes',
    double price = 99.5,
    String imageUrl = 'https://example.com/shoes.png',
    String category = 'Fashion',
    int stock = 5,
    bool isAvailable = true,
  }) =>
      ProductModel(
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        category: category,
        stock: stock,
        isAvailable: isAvailable,
      );

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = ProductRepositoryImpl(firestore);
  });

  group('ProductRepositoryImpl — streams', () {
    test('streamAll emits the catalog live (empty first, then products)',
        () async {
      final expectation = expectLater(
        repo.streamAll(),
        // FakeFirebaseFirestore re-emits after every write: empty, one
        // product, then two.
        emitsInOrder([
          predicate<List<ProductModel>>((list) => list.isEmpty, 'empty'),
          predicate<List<ProductModel>>(
            (list) => list.length == 1 && list.first.name == 'Shoes',
            'one product',
          ),
          predicate<List<ProductModel>>(
            (list) => list.length == 2 && list.every((p) => p.name != ''),
            'two products',
          ),
        ]),
      );

      await firestore
          .collection(FirestorePaths.products)
          .add(product(name: 'Shoes').toJson());
      await firestore
          .collection(FirestorePaths.products)
          .add(product(name: 'Laptop').toJson());

      await expectation;
    });

    test('streamByCategory only emits products of that category', () async {
      final expectation = expectLater(
        repo.streamByCategory('Fashion'),
        // The Electronics write does not change the query result, and
        // FakeFirebaseFirestore does not re-emit an identical snapshot.
        emitsInOrder([
          predicate<List<ProductModel>>((list) => list.isEmpty, 'empty'),
          predicate<List<ProductModel>>(
            (list) =>
                list.length == 1 &&
                list.first.name == 'Shoes' &&
                list.first.category == 'Fashion',
            'only the Fashion product',
          ),
        ]),
      );

      await firestore
          .collection(FirestorePaths.products)
          .add(product(name: 'Shoes', category: 'Fashion').toJson());
      await firestore
          .collection(FirestorePaths.products)
          .add(product(name: 'Laptop', category: 'Electronics').toJson());

      await expectation;
    });
  });

  group('ProductRepositoryImpl — search (PRD §2: search by name + category)',
      () {
    setUp(() async {
      await firestore
          .collection(FirestorePaths.products)
          .add(product(name: 'T-Shirt', category: 'Men').toJson());
      await firestore
          .collection(FirestorePaths.products)
          .add(product(name: 't-shirt dress', category: 'Women').toJson());
      await firestore
          .collection(FirestorePaths.products)
          .add(product(name: 'Laptop', category: 'Electronics').toJson());
    });

    test('search matches names case-insensitively', () async {
      final result = await repo.search('SHIRT');

      expect(result, isA<Success<List<ProductModel>>>());
      final products = (result as Success<List<ProductModel>>).data;
      expect(products.map((p) => p.name), containsAll(['T-Shirt', 't-shirt dress']));
      expect(products, hasLength(2));
    });

    test('search narrows to one category when given', () async {
      final result = await repo.search('shirt', category: 'Women');

      final products = (result as Success<List<ProductModel>>).data;
      expect(products, hasLength(1));
      expect(products.first.category, 'Women');
    });

    test('search returns everything on an empty query', () async {
      final result = await repo.search('   ');

      expect((result as Success<List<ProductModel>>).data, hasLength(3));
    });
  });

  group('ProductRepositoryImpl — getById', () {
    test('returns the product for an existing doc ID', () async {
      final docRef = await firestore
          .collection(FirestorePaths.products)
          .add(product().toJson());

      final result = await repo.getById(docRef.id);

      expect(result, isA<Success<ProductModel>>());
      expect((result as Success<ProductModel>).data.name, 'Running Shoes');
    });

    test('returns a failure for a missing product', () async {
      final result = await repo.getById('missing-id');

      expect(result, isA<Failure<ProductModel>>());
      expect(
        (result as Failure<ProductModel>).apiErrorModel.message,
        'Product not found.',
      );
    });
  });

  group('ProductRepositoryImpl — create / update / delete (Admin, PRD §5)',
      () {
    test('create writes a products doc and succeeds', () async {
      final result = await repo.create(product());

      expect(result, isA<Success<ProductModel>>());
      final docs = await firestore.collection(FirestorePaths.products).get();
      expect(docs.docs, hasLength(1));
      expect(docs.docs.first.data()['name'], 'Running Shoes');
    });

    test('update writes the new fields when a productId is given', () async {
      final docRef = await firestore
          .collection(FirestorePaths.products)
          .add(product().toJson());

      final result = await repo.update(
        product(name: 'Updated Shoes', price: 120.0),
        productId: docRef.id,
      );

      expect(result, isA<Success<void>>());
      final doc = await firestore
          .doc(FirestorePaths.productDoc(docRef.id))
          .get();
      expect(doc.data()!['name'], 'Updated Shoes');
      expect(doc.data()!['price'], 120.0);
    });

    test('update fails with a clear message when no productId is given '
        '(ProductModel carries no id field)', () async {
      final result = await repo.update(product());

      expect(result, isA<Failure<void>>());
      expect(
        (result as Failure<void>).apiErrorModel.message,
        contains('productId'),
      );
    });

    test('delete removes the doc', () async {
      final docRef = await firestore
          .collection(FirestorePaths.products)
          .add(product().toJson());

      final result = await repo.delete(docRef.id);

      expect(result, isA<Success<void>>());
      final doc = await firestore
          .doc(FirestorePaths.productDoc(docRef.id))
          .get();
      expect(doc.exists, isFalse);
    });
  });
}



