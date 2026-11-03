import 'package:flutter/foundation.dart';

import '../../../../core/models/product_model.dart';

/// A single row on the favorites screen: the favorited product's ID (the doc
/// ID under `users/{uid}/favorites`, PRD §7) paired with its catalog details.
///
/// [ProductModel] deliberately does not carry its document ID (see its doc
/// comment: the ID is read via `doc.id`), so the Cubit pairs the two when it
/// fetches details through `ProductRepository.getById` — the UI needs the ID
/// to call `FavoritesCubit.removeFavorite`.
class FavoriteItem {
  final String productId;
  final ProductModel product;

  const FavoriteItem({required this.productId, required this.product});

  /// Value equality so [FavoritesState.loaded] can be compared in tests
  /// (freezed state equality delegates to item equality; [ProductModel] has
  /// no == itself, so we compare its serialized payload).
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteItem &&
          other.productId == productId &&
          mapEquals(other.product.toJson(), product.toJson());

  @override
  int get hashCode =>
      Object.hash(productId, Object.hashAllUnordered(product.toJson().keys));

  @override
  String toString() => 'FavoriteItem(productId: $productId, product: $product)';
}
