import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e_commerce_app/core/constants/firestore_paths.dart';
import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/features/admin/data/repos/admin_products_source.dart';

/// Admin-side seam over the `products` collection (PRD §2, §5): a live
/// catalog stream WITH document IDs, plus id-parameterized updates
/// (`ProductModel` carries no id, so `ProductRepository.update` alone cannot
/// address the right document).
void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreAdminProductsSource source;

  Map<String, dynamic> productJson({
    String name = 'Running Shoes',
    double price = 99.5,
    String category = 'Fashion',
    int stock = 5,
  }) => ProductModel(
    name: name,
    price: price,
    category: category,
    stock: stock,
  ).toJson();

  setUp(() {
    firestore = FakeFirebaseFirestore();
    source = FirestoreAdminProductsSource(firestore);
  });

  group('FirestoreAdminProductsSource.streamAllWithIds', () {
    test('emits products paired with their Firestore document IDs', () async {
      await firestore
          .collection(FirestorePaths.products)
          .add(productJson(name: 'Shoes'));
      await firestore
          .collection(FirestorePaths.products)
          .add(productJson(name: 'Laptop'));

      // The fake may emit an empty initial snapshot — wait for the
      // non-empty one.
      final entries = await source
          .streamAllWithIds()
          .firstWhere((list) => list.isNotEmpty);

      expect(entries, hasLength(2));
      // The stream's productIds are exactly the collection's document IDs.
      final realDocIds =
          (await firestore.collection(FirestorePaths.products).get()).docs
              .map((doc) => doc.id)
              .toSet();
      expect(entries.map((e) => e.productId).toSet(), realDocIds);
      expect(realDocIds, isNotEmpty);
    });

    test('maps every payload field through ProductModel', () async {
      await firestore
          .collection(FirestorePaths.products)
          .add(
            productJson(
              name: 'Desk Lamp',
              price: 45.0,
              category: 'Home',
              stock: 12,
            ),
          );

      final entries = await source
          .streamAllWithIds()
          .firstWhere((list) => list.isNotEmpty);
      final lamp = entries.single.product;
      expect(lamp.name, 'Desk Lamp');
      expect(lamp.price, 45.0);
      expect(lamp.category, 'Home');
      expect(lamp.stock, 12);
      expect(lamp.isAvailable, isTrue);
    });
  });

  group('FirestoreAdminProductsSource.update', () {
    test('writes the new fields to the addressed document', () async {
      final docRef = await firestore
          .collection(FirestorePaths.products)
          .add(productJson());

      final result = await source.update(
        docRef.id,
        const ProductModel(
          name: 'Updated Shoes',
          price: 120.0,
          category: 'Fashion',
          stock: 3,
        ),
      );

      expect(result, isA<Success<void>>());
      final doc = await firestore
          .doc(FirestorePaths.productDoc(docRef.id))
          .get();
      expect(doc.data()!['name'], 'Updated Shoes');
      expect(doc.data()!['price'], 120.0);
      expect(doc.data()!['stock'], 3);
    });

    test('fails cleanly (no throw) for a missing document ID', () async {
      final result = await source.update(
        'missing-id',
        const ProductModel(name: 'Ghost'),
      );

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).apiErrorModel.message, isNotNull);
    });
  });
}



