import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/models/product_model.dart';
import '../models/product_doc.dart';

/// Realtime, ID-carrying catalog feed used by `ProductsCubit`.
///
/// `ProductRepository.streamAll()` returns plain `List<ProductModel>` (per the
/// core interface), which drops the Firestore document ID. The catalog UI must
/// know each product's ID (details navigation, favorites/cart buttons), so the
/// Cubit reads through this data source instead; the documents themselves are
/// read from the same `products` collection ([FirestorePaths.products]).
///
/// get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`):
/// ```dart
/// getIt.registerLazySingleton<ProductCatalogDataSource>(
///   () => ProductCatalogDataSourceImpl(FirebaseFirestore.instance),
/// );
/// getIt.registerFactory<ProductsCubit>(
///   () => ProductsCubit(getIt<ProductCatalogDataSource>()),
/// );
/// ```
abstract class ProductCatalogDataSource {
  /// Live stream of the whole catalog with document IDs attached. Firestore
  /// errors surface on the stream for the Cubit to catch.
  Stream<List<ProductDoc>> streamCatalog();
}

class ProductCatalogDataSourceImpl implements ProductCatalogDataSource {
  ProductCatalogDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<ProductDoc>> streamCatalog() {
    // PRD §7 lists no createdAt field on `products`, so the stream emits the
    // documents in Firestore default order (no artificial ordering field).
    return _firestore
        .collection(FirestorePaths.products)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProductDoc(id: doc.id, product: ProductModel.fromDoc(doc)),
              )
              .toList(),
        );
  }
}
