import '../models/cart_item_model.dart';
import '../networking/api_result.dart';

/// Cart repository (PRD §3). Cart docs live at `users/{uid}/cart/{productId}`
/// (see `FirestorePaths.cartDoc`), the product ID being the document ID.
///
/// get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`):
/// ```dart
/// getIt.registerLazySingleton<CartRepository>(() => CartRepositoryImpl());
/// ```
///
/// Conventions: one-shot writes return [ApiResult] (failures via
/// `ApiErrorHandler.handle`, never thrown); realtime reads return plain
/// `Stream`s. [userId] is passed explicitly so implementations work with
/// `FakeFirebaseFirestore` in tests.
abstract class CartRepository {
  /// Live stream of the signed-in user's cart lines (PRD §3: cart persists
  /// in Firestore across app restarts).
  Stream<List<CartItemModel>> streamCart(String userId);

  /// Add a product to the cart, or bump its quantity if already present
  /// (upsert on the productId doc).
  Future<ApiResult<void>> add(String userId, CartItemModel item);

  /// Set the quantity of one cart line; a quantity of 0 may remove the line
  /// (PRD §3: increase/decrease quantity).
  Future<ApiResult<void>> updateQuantity(
    String userId,
    String productId,
    int quantity,
  );

  /// Remove one cart line (PRD §3: remove item).
  Future<ApiResult<void>> remove(String userId, String productId);

  /// Empty the whole cart (PRD §4: clear after successful order).
  Future<ApiResult<void>> clear(String userId);

  /// Re-check every cart line against the live product docs (availability +
  /// stock) before creating an order (PRD §3: "Validate product availability
  /// and stock before creating an order"). Failure carries a message naming
  /// the offending items.
  Future<ApiResult<List<CartItemModel>>> validateStock(String userId);
}
