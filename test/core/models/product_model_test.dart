import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductModel round-trip', () {
    test('toJson -> fromJson preserves all fields', () {
      const product = ProductModel(
        name: 'Espresso Machine',
        description: '15-bar pump machine',
        price: 249.99,
        imageUrl: 'https://example.com/espresso.png',
        category: 'kitchen',
        stock: 12,
        isAvailable: true,
      );

      final decoded = ProductModel.fromJson(product.toJson());

      expect(decoded.name, product.name);
      expect(decoded.description, product.description);
      expect(decoded.price, product.price);
      expect(decoded.imageUrl, product.imageUrl);
      expect(decoded.category, product.category);
      expect(decoded.stock, product.stock);
      expect(decoded.isAvailable, product.isAvailable);
    });

    test('missing fields fall back to defaults', () {
      final decoded = ProductModel.fromJson(<String, dynamic>{});

      expect(decoded.name, '');
      expect(decoded.description, '');
      expect(decoded.price, 0.0);
      expect(decoded.imageUrl, '');
      expect(decoded.category, '');
      expect(decoded.stock, 0);
      expect(decoded.isAvailable, isTrue);
    });

    test('inStock requires availability AND stock > 0', () {
      const outOfStock = ProductModel(name: 'a', stock: 0, isAvailable: true);
      const hidden = ProductModel(name: 'b', stock: 5, isAvailable: false);
      const available = ProductModel(name: 'c', stock: 5, isAvailable: true);

      expect(outOfStock.inStock, isFalse);
      expect(hidden.inStock, isFalse);
      expect(available.inStock, isTrue);
    });
  });
}



