import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/repositories/favorites_repository.dart';

/// The only implementation of [FavoritesRepository] (PRD §2/§7): favorites
/// live at `users/{uid}/favorites/{productId}`, the product ID being the
/// document ID (see `FirestorePaths.favoriteDoc`), so toggle = add/delete of
/// that one doc and the stream maps doc IDs straight to product IDs.
///
/// get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`):
/// ```dart
/// getIt.registerLazySingleton<FavoritesRepository>(
///   () => FavoritesRepositoryImpl(),
/// );
/// ```
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FirebaseFirestore _firestore;

  FavoritesRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<String>> streamFavoriteIds(String userId) {
    // Realtime read (repo convention: plain Stream, errors surface on the
    // stream for the Cubit to catch). The product ID is the doc ID (PRD §7).
    return _firestore
        .collection(FirestorePaths.favoritesCollection(userId))
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  @override
  Future<ApiResult<void>> toggle(String userId, String productId) async {
    try {
      final docRef =
          _firestore.doc(FirestorePaths.favoriteDoc(userId, productId));
      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.delete();
      } else {
        // PRD §7: favorites store a productId per item; the doc ID already
        // is the productId, the field keeps the payload self-describing.
        await docRef.set(<String, dynamic>{'productId': productId});
      }
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
