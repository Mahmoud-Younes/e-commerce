import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/networking/api_error_model.dart';
import '../../data/models/favorite_item.dart';

part 'favorites_state.freezed.dart';

@freezed
class FavoritesState with _$FavoritesState {
  const factory FavoritesState.initial() = _Initial;

  /// While the first favorites snapshot is being resolved into products.
  const factory FavoritesState.loading() = FavoritesLoading;

  /// Empty favorites list (PRD §9: clear empty state).
  const factory FavoritesState.empty() = FavoritesEmpty;

  /// Favorited products with their details, newest removals reflected live.
  const factory FavoritesState.loaded(List<FavoriteItem> items) =
      FavoritesLoaded;

  /// Stream or details-fetch failure (PRD §9: clear error state).
  const factory FavoritesState.error(ApiErrorModel apiErrorModel) =
      FavoritesError;
}
