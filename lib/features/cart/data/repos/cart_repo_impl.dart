import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/models/cart_item_model.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/repositories/cart_repository.dart';

/// Firestore-backed [CartRepository] (PRD §3, §7).
///
/// One document per cart line at `users/{uid}/cart/{productId}` — the product
/// ID is the document ID (PRD §7), which makes add/remove idempotent upserts.
/// The doc payload carries `productId` and `quantity` per PRD §7, plus the
/// denormalized `name`/`price` from [CartItemModel] so the cart screen can
/// render subtotals without joining the `products` collection; `validateStock`
/// always re-checks against the live product doc before an order is created,
/// so stale denormalized values can never reach an order (PRD §3, §4).
class CartRepositoryImpl implements CartRepository {
  final FirebaseFirestore _db;

  /// [firestore] is injectable so tests can pass `FakeFirebaseFirestore`
  /// instead of touching `FirebaseFirestore.instance`.
  CartRepositoryImpl({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _cart(String userId) =>
      _db.collection(FirestorePaths.cartCollection(userId));

  @override
  Stream<List<CartItemModel>> streamCart(String userId) {
    return _cart(userId).snapshots().asyncMap((snapshot) async {
      final items = <CartItemModel>[];
      for (final doc in snapshot.docs) {
        // The document ID is the source of truth for the product ID (PRD §7).
        final data = <String, dynamic>{...doc.data()};
        data['productId'] = doc.id;
        items.add(CartItemModel.fromJson(data));
      }
      return items;
    });
  }

  @override
  Future<ApiResult<void>> add(String userId, CartItemModel item) async {
    try {
      final docRef = _cart(userId).doc(item.productId);
      final existing = await docRef.get();
      // Upsert: bump the quantity when the product is already in the cart
      // (PRD §3: "Add a product to the cart"), otherwise insert a new line.
      final quantity = existing.exists
          ? (existing.data()?['quantity'] as int? ?? 0) + item.quantity
          : item.quantity;
      await docRef.set(
        item.copyWith(productId: docRef.id, quantity: quantity).toJson(),
      );
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<void>> updateQuantity(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
      final docRef = _cart(userId).doc(productId);
      if (quantity <= 0) {
        // PRD §3: decreasing to 0 removes the line.
        await docRef.delete();
      } else {
        // Merge keeps the denormalized name/price already on the doc.
        await docRef.set({
          'productId': productId,
          'quantity': quantity,
        }, SetOptions(merge: true));
      }
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<void>> remove(String userId, String productId) async {
    try {
      await _cart(userId).doc(productId).delete();
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<void>> clear(String userId) async {
    try {
      final snapshot = await _cart(userId).get();
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<List<CartItemModel>>> validateStock(String userId) async {
    try {
      final snapshot = await _cart(userId).get();
      if (snapshot.docs.isEmpty) {
        return const ApiResult.failure(
          ApiErrorModel(message: 'Your cart is empty.'),
        );
      }

      final items = <CartItemModel>[];
      final problems = <String>[];
      for (final doc in snapshot.docs) {
        final data = <String, dynamic>{...doc.data()};
        data['productId'] = doc.id;
        final item = CartItemModel.fromJson(data);
        items.add(item);

        final productSnap = await _db
            .collection(FirestorePaths.products)
            .doc(item.productId)
            .get();
        if (!productSnap.exists) {
          problems.add('"${_displayName(item, null)}" is no longer available.');
          continue;
        }
        final product = ProductModel.fromDoc(productSnap);
        if (!product.isAvailable) {
          problems.add('"${_displayName(item, product)}" is out of stock.');
        } else if (item.quantity > product.stock) {
          problems.add(
            'Only ${product.stock} left of "${_displayName(item, product)}".',
          );
        }
      }

      if (problems.isNotEmpty) {
        return ApiResult.failure(ApiErrorModel(message: problems.join(' ')));
      }
      return ApiResult.success(items);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  /// Prefer the live product name; fall back to the denormalized cart name.
  static String _displayName(CartItemModel item, ProductModel? product) {
    if (product != null && product.name.isNotEmpty) return product.name;
    if (item.name.isNotEmpty) return item.name;
    return item.productId;
  }
}
