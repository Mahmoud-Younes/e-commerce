import '../networking/api_result.dart';

/// Favorites repository (PRD §2). Favorite docs live at
/// `users/{uid}/favorites/{productId}` (see `FirestorePaths.favoriteDoc`),
/// the product ID being the document ID — toggle is add/delete of that doc.
///
/// get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`):
/// ```dart
/// getIt.registerLazySingleton<FavoritesRepository>(
///   () => FavoritesRepositoryImpl(),
/// );
/// ```
///
/// Conventions: one-shot writes return [ApiResult] (failures via
/// `ApiErrorHandler.handle`, never thrown); realtime reads return plain
/// `Stream`s.
abstract class FavoritesRepository {
  /// Live stream of the product IDs the user has favorited (PRD §2).
  Stream<List<String>> streamFavoriteIds(String userId);

  /// Add the product to favorites if absent, remove it if present
  /// (PRD §2: add/remove from Favorites).
  Future<ApiResult<void>> toggle(String userId, String productId);
}
