import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e_commerce_app/core/models/cart_item_model.dart';
import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/features/cart/data/repos/cart_repo_impl.dart';

void main() {
  late FakeFirebaseFirestore db;
  late CartRepositoryImpl repo;

  const userId = 'u1';
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

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = CartRepositoryImpl(firestore: db);
  });

  Future<void> seedProduct(
    String id, {
    String name = 'Product',
    double price = 10.0,
    int stock = 10,
    bool isAvailable = true,
  }) async {
    await db
        .collection('products')
        .doc(id)
        .set(
          ProductModel(
            name: name,
            price: price,
            stock: stock,
            isAvailable: isAvailable,
          ).toJson(),
        );
  }

  Future<Map<String, dynamic>?> readCartDoc(String productId) async {
    final doc = await db.collection('users/$userId/cart').doc(productId).get();
    return doc.data();
  }

  group('CartRepositoryImpl.add (upsert on the productId doc)', () {
    test('inserts a new line with quantity as given', () async {
      final response = await repo.add(userId, line1);

      expect(response, isA<Success<void>>());
      final doc = await readCartDoc('p1');
      expect(doc, isNotNull);
      expect(doc!['productId'], 'p1');
      expect(doc['quantity'], 2);
      expect(doc['name'], 'T-Shirt');
    });

    test(
      'bumps the quantity when the product is already in the cart',
      () async {
        await repo.add(userId, line1);
        await repo.add(userId, line1.copyWith(quantity: 1));

        final doc = await readCartDoc('p1');
        expect(doc!['quantity'], 3, reason: 'PRD §3: add = upsert bump');
      },
    );
  });

  group('CartRepositoryImpl.updateQuantity', () {
    test('sets the quantity and keeps the line fields', () async {
      await repo.add(userId, line1);

      final response = await repo.updateQuantity(userId, 'p1', 5);

      expect(response, isA<Success<void>>());
      final doc = await readCartDoc('p1');
      expect(doc!['quantity'], 5);
      expect(doc['name'], 'T-Shirt');
    });

    test('removes the line when the quantity drops to 0', () async {
      await repo.add(userId, line1);

      await repo.updateQuantity(userId, 'p1', 0);

      expect(await readCartDoc('p1'), isNull);
    });
  });

  test('remove deletes the line document', () async {
    await repo.add(userId, line1);
    await repo.add(userId, line2);

    final response = await repo.remove(userId, 'p1');

    expect(response, isA<Success<void>>());
    expect(await readCartDoc('p1'), isNull);
    expect(await readCartDoc('p2'), isNotNull);
  });

  test('clear empties the whole cart', () async {
    await repo.add(userId, line1);
    await repo.add(userId, line2);

    final response = await repo.clear(userId);

    expect(response, isA<Success<void>>());
    final snapshot = await db.collection('users/$userId/cart').get();
    expect(snapshot.docs, isEmpty);
  });

  group('CartRepositoryImpl.streamCart (live)', () {
    test('emits the current cart then reflects live changes', () async {
      await repo.add(userId, line1);

      final emissions = <List<CartItemModel>>[];
      final sub = repo.streamCart(userId).listen(emissions.add);
      // First (immediate) snapshot.
      await pumpEventQueue();
      await repo.add(userId, line2);
      // Snapshot after the second write.
      await pumpEventQueue();
      await sub.cancel();

      expect(emissions, hasLength(2));
      expect(emissions[0], hasLength(1));
      expect(emissions[0].first.productId, 'p1');
      expect(emissions[1], hasLength(2));
    });

    test('uses the document ID as the product ID (PRD §7)', () async {
      await repo.add(userId, line1);

      final emissions = <List<CartItemModel>>[];
      final sub = repo.streamCart(userId).listen(emissions.add);
      await pumpEventQueue();
      await sub.cancel();

      expect(emissions.first.single.productId, 'p1');
      expect(emissions.first.single.subtotal, 100.0);
    });
  });

  group('CartRepositoryImpl.validateStock (PRD §3)', () {
    test('returns the cart lines when every line is in stock', () async {
      await repo.add(userId, line1);
      await repo.add(userId, line2);
      await seedProduct('p1', name: 'T-Shirt', stock: 5);
      await seedProduct('p2', name: 'Sneakers', stock: 1);

      final response = await repo.validateStock(userId);

      expect(response, isA<Success<List<CartItemModel>>>());
      final items = (response as Success<List<CartItemModel>>).data;
      expect(items.map((i) => i.productId), ['p1', 'p2']);
    });

    test('fails naming the item whose quantity exceeds the stock', () async {
      await repo.add(userId, line1.copyWith(quantity: 8));
      await seedProduct('p1', name: 'T-Shirt', stock: 5);

      final response = await repo.validateStock(userId);

      expect(response, isA<Failure<List<CartItemModel>>>());
      final message =
          (response as Failure<List<CartItemModel>>).apiErrorModel.message;
      expect(message, contains('T-Shirt'));
      expect(message, contains('5'));
    });

    test('fails when a product is not available anymore', () async {
      await repo.add(userId, line2);
      await seedProduct('p2', name: 'Sneakers', stock: 10, isAvailable: false);

      final response = await repo.validateStock(userId);

      expect(response, isA<Failure<List<CartItemModel>>>());
      final message =
          (response as Failure<List<CartItemModel>>).apiErrorModel.message;
      expect(message, contains('Sneakers'));
    });

    test('fails when the product document is missing', () async {
      await repo.add(userId, line1);

      final response = await repo.validateStock(userId);

      expect(response, isA<Failure<List<CartItemModel>>>());
      final message =
          (response as Failure<List<CartItemModel>>).apiErrorModel.message;
      expect(message, contains('no longer available'));
    });

    test('fails on an empty cart', () async {
      final response = await repo.validateStock(userId);

      expect(response, isA<Failure<List<CartItemModel>>>());
      expect(
        (response as Failure<List<CartItemModel>>).apiErrorModel.message,
        contains('empty'),
      );
    });
  });
}



