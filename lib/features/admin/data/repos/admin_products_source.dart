import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/repositories/product_repository.dart';

/// One catalog entry with its Firestore document ID.
///
/// Needed because [ProductModel] deliberately carries no ID (the ID is the
/// document ID) and `ProductRepository.streamAll()` returns bare
/// [ProductModel]s — but the admin dashboard must know WHICH document to
/// edit/delete, so this source pairs each product with its `doc.id`.
class AdminProductEntry {
  final String productId;
  final ProductModel product;

  const AdminProductEntry({required this.productId, required this.product});
}

/// Admin-side read/update seam over the `products` collection (PRD §2, §5).
///
/// Why this exists next to [ProductRepository] (NOT instead of it):
/// - Creates and deletes go through [ProductRepository] (`create`, `delete`)
///   exactly as the feature slice requires.
/// - `ProductRepository.update(ProductModel)` carries no document ID and
///   [ProductModel] has no id field, so a plain update cannot address the
///   right document — this source adds the id-parameterized
///   [update] until the core interface grows `update(String id, ProductModel)`.
///
/// get_it registration (merge agent applies it):
/// ```dart
/// getIt.registerLazySingleton<AdminProductsSource>(
///   () => FirestoreAdminProductsSource(FirebaseFirestore.instance),
/// );
/// ```
abstract class AdminProductsSource {
  /// Live stream of the whole catalog WITH document IDs, newest docs first.
  Stream<List<AdminProductEntry>> streamAllWithIds();

  /// Update the product document [productId] (Admin, PRD §2/§5).
  Future<ApiResult<void>> update(String productId, ProductModel product);
}

class FirestoreAdminProductsSource implements AdminProductsSource {
  FirestoreAdminProductsSource(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<AdminProductEntry>> streamAllWithIds() {
    return _firestore
        .collection(FirestorePaths.products)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AdminProductEntry(
                  productId: doc.id,
                  product: ProductModel.fromDoc(doc),
                ),
              )
              .toList(),
        );
  }

  @override
  Future<ApiResult<void>> update(
    String productId,
    ProductModel product,
  ) async {
    try {
      await _firestore.doc(FirestorePaths.productDoc(productId)).update(
            product.toJson(),
          );
      return ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
