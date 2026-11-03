import '../models/product_model.dart';
import '../networking/api_result.dart';

/// Catalog repository (PRD §2).
///
/// get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`):
/// ```dart
/// getIt.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl());
/// ```
///
/// Conventions (match `ProfileRepo` in features/auth):
/// - one-shot reads/writes return [ApiResult] — failures are produced by
///   `ApiErrorHandler.handle(error)`, never thrown;
/// - realtime queries return plain `Stream`s (data is emitted as it changes;
///   Firestore errors surface on the stream for the Cubit to catch).
abstract class ProductRepository {
  /// Live stream of all products, newest first (PRD §2: home screen cards).
  Stream<List<ProductModel>> streamAll();

  /// Live stream of products in one category (PRD §2: browse by category).
  Stream<List<ProductModel>> streamByCategory(String category);

  /// Search products by name (case-insensitive, client-side filter over the
  /// catalog snapshot), optionally narrowed to one category (PRD §2).
  Future<ApiResult<List<ProductModel>>> search(
    String query, {
    String? category,
  });

  /// Fetch a single product by document ID (product details, PRD §2).
  Future<ApiResult<ProductModel>> getById(String productId);

  /// Create a product document (Admin, PRD §2, §5). Returns the new product
  /// with the Firestore-assigned document ID.
  Future<ApiResult<ProductModel>> create(ProductModel product);

  /// Update an existing product document (Admin, PRD §5).
  Future<ApiResult<void>> update(ProductModel product);

  /// Delete a product document (Admin, PRD §5).
  Future<ApiResult<void>> delete(String productId);
}
