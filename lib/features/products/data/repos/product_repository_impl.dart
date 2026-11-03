import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/repositories/product_repository.dart';

/// Firestore-backed [ProductRepository] (PRD §2, §7). Product docs live at
/// `products/{productId}` ([FirestorePaths.productDoc]) — the product ID is
/// the document ID, carried outside [ProductModel] (the model has no `id`
/// field, see its doc comment).
///
/// get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`):
/// ```dart
/// getIt.registerLazySingleton<ProductRepository>(
///   () => ProductRepositoryImpl(FirebaseFirestore.instance),
/// );
/// ```
///
/// [FirebaseFirestore] is injected so tests pass `FakeFirebaseFirestore`
/// directly (same pattern as `OrderRepositoryImpl`).
class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<ProductModel>> streamAll() {
    // PRD §7 lists no timestamp field on `products`, so there is no
    // server-side "newest first" ordering to apply; documents are emitted in
    // Firestore default order.
    return _firestore
        .collection(FirestorePaths.products)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ProductModel.fromDoc).toList());
  }

  @override
  Stream<List<ProductModel>> streamByCategory(String category) {
    return _firestore
        .collection(FirestorePaths.products)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(ProductModel.fromDoc).toList());
  }

  @override
  Future<ApiResult<List<ProductModel>>> search(
    String query, {
    String? category,
  }) async {
    try {
      // Firestore has no case-insensitive `contains`; the filter is applied
      // client-side over the (optionally category-narrowed) snapshot.
      Query<Map<String, dynamic>> query_ = _firestore
          .collection(FirestorePaths.products);
      if (category != null) {
        query_ = query_.where('category', isEqualTo: category);
      }
      final snapshot = await query_.get();
      final needle = query.trim().toLowerCase();
      final products = snapshot.docs
          .map(ProductModel.fromDoc)
          .where(
            (product) =>
                needle.isEmpty ||
                product.name.toLowerCase().contains(needle),
          )
          .toList();
      return ApiResult.success(products);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<ProductModel>> getById(String productId) async {
    try {
      final doc = await _firestore
          .doc(FirestorePaths.productDoc(productId))
          .get();
      if (!doc.exists) {
        return ApiResult.failure(
          const ApiErrorModel(message: 'Product not found.'),
        );
      }
      return ApiResult.success(ProductModel.fromDoc(doc));
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<ProductModel>> create(ProductModel product) async {
    try {
      final docRef = _firestore.collection(FirestorePaths.products).doc();
      await docRef.set(product.toJson());
      // ProductModel carries no id field, so the Firestore-assigned document
      // ID cannot be attached to the returned model — callers (Admin) can
      // read it back via streamAll/search or use `docRef.id` semantics here.
      return ApiResult.success(product);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<void>> update(ProductModel product, {String? productId}) async {
    try {
      // ProductModel has no id field, so the document to update cannot be
      // derived from the payload alone — [productId] must be supplied. (An
      // optional named parameter on an override is legal Dart; callers going
      // through the abstract `ProductRepository` type see the base signature.)
      if (productId == null || productId.isEmpty) {
        return const ApiResult.failure(
          ApiErrorModel(
            message:
                'Updating a product requires its document ID (productId); '
                'ProductModel does not carry an id field.',
          ),
        );
      }
      await _firestore
          .doc(FirestorePaths.productDoc(productId))
          .update(product.toJson());
      return ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<void>> delete(String productId) async {
    try {
      await _firestore
          .doc(FirestorePaths.productDoc(productId))
          .delete();
      return ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
