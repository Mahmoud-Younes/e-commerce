import 'package:e_commerce_app/core/models/cart_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartItemModel round-trip', () {
    test('toJson -> fromJson preserves all fields', () {
      const item = CartItemModel(
        productId: 'p-42',
        name: 'Espresso Machine',
        price: 249.99,
        quantity: 3,
      );

      final decoded = CartItemModel.fromJson(item.toJson());

      expect(decoded.productId, item.productId);
      expect(decoded.name, item.name);
      expect(decoded.price, item.price);
      expect(decoded.quantity, item.quantity);
    });

    test('missing fields fall back to defaults', () {
      final decoded = CartItemModel.fromJson(<String, dynamic>{});

      expect(decoded.productId, '');
      expect(decoded.name, '');
      expect(decoded.price, 0.0);
      expect(decoded.quantity, 1);
    });

    test('subtotal is price * quantity', () {
      const item = CartItemModel(productId: 'p-42', price: 10.5, quantity: 4);

      expect(item.subtotal, 42.0);
    });
  });
}



