import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/product_model.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/repositories/favorites_repository.dart';
import '../../../../core/repositories/product_repository.dart';
import '../../data/models/favorite_item.dart';
import 'favorites_state.dart';

/// Live favorites (PRD §2): subscribes to [FavoritesRepository.streamFavoriteIds]
/// and resolves each favorite into a [FavoriteItem] through
/// [ProductRepository.getById]. Every snapshot (add/remove from any surface)
/// re-drives the loaded list, so the screen stays in sync without manual
/// refresh; the remove button only toggles the doc and lets the stream repaint.
///
/// get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`):
/// ```dart
/// getIt.registerFactory<FavoritesCubit>(
///   () => FavoritesCubit(getIt(), getIt()),
/// );
/// ```
class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _favoritesRepo;
  final ProductRepository _productRepo;

  // Positional repo args: DI registers FavoritesCubit(getIt(), getIt()).
  FavoritesCubit(this._favoritesRepo, this._productRepo)
      : super(const FavoritesState.initial());

  StreamSubscription<List<String>>? _idsSubscription;

  /// Starts the live favorites stream for [userId]. Call once per screen entry
  /// (the route supplies the signed-in user's uid). An empty [userId] means
  /// no authenticated user — surfaced as an error state, never an exception.
  void start(String userId) {
    if (userId.isEmpty) {
      emit(const FavoritesState.error(
        ApiErrorModel(message: 'Not authenticated'),
      ));
      return;
    }
    emit(const FavoritesState.loading());
    _idsSubscription?.cancel();
    _idsSubscription = _favoritesRepo.streamFavoriteIds(userId).listen(
      (ids) => _loadProducts(ids),
      onError: (Object error) {
        emit(FavoritesState.error(ApiErrorHandler.handle(error)));
      },
    );
  }

  /// Resolves the favorite IDs into full products. Subsequent snapshots (e.g.
  /// after a removal) skip the loading state so the list updates in place.
  Future<void> _loadProducts(List<String> ids) async {
    if (ids.isEmpty) {
      emit(const FavoritesState.empty());
      return;
    }
    final results = await Future.wait(
      ids.map((id) => _productRepo.getById(id)),
    );

    // Future.wait keeps order, so results[i] belongs to ids[i] — the pair
    // makes the FavoriteItem (ProductModel itself carries no doc ID).
    final items = <FavoriteItem>[];
    ApiErrorModel? firstError;
    for (var i = 0; i < results.length; i++) {
      results[i].when(
        success: (ProductModel product) => items.add(
          FavoriteItem(productId: ids[i], product: product),
        ),
        failure: (apiErrorModel) => firstError ??= apiErrorModel,
      );
    }

    // Copy into a local: `firstError` is assigned inside a closure above, so
    // it doesn't keep null-promotion and needs an explicit cast site.
    final error = firstError;
    if (items.isEmpty && error != null) {
      emit(FavoritesState.error(error));
      return;
    }
    emit(FavoritesState.loaded(items));
  }

  /// Removes [productId] from the user's favorites (PRD §2). The live stream
  /// re-emits the shorter list, which repaints the loaded state — no local
  /// list mutation here, so the screen always mirrors Firestore.
  Future<void> removeFavorite(String userId, String productId) async {
    await _favoritesRepo.toggle(userId, productId);
  }

  @override
  Future<void> close() async {
    await _idsSubscription?.cancel();
    return super.close();
  }
}
