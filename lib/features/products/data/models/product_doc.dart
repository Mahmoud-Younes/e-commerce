import '../../../../core/models/product_model.dart';

/// A catalog entry paired with its Firestore document ID.
///
/// [ProductModel] deliberately carries no `id` field (the product ID is the
/// Firestore document ID, read via `doc.id` — see the ProductModel docs), so
/// the raw `List<ProductModel>` streams on `ProductRepository` cannot tell the
/// UI which document each product came from. The catalog Cubit needs that ID
/// to navigate to details and to drive the favorites/cart buttons
/// (PRD §2), hence this thin wrapper lives in the products data layer.
///
/// Equality compares every [ProductModel] field (ProductModel itself has no
/// `==`), so a price/stock change on the same document ID still counts as a
/// new state and triggers rebuilds.
class ProductDoc {
  final String id;
  final ProductModel product;

  const ProductDoc({required this.id, required this.product});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductDoc &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          product.name == other.product.name &&
          product.description == other.product.description &&
          product.price == other.product.price &&
          product.imageUrl == other.product.imageUrl &&
          product.category == other.product.category &&
          product.stock == other.product.stock &&
          product.isAvailable == other.product.isAvailable;

  @override
  int get hashCode => Object.hash(id, product.name, product.description,
      product.price, product.imageUrl, product.category, product.stock,
      product.isAvailable);
}
