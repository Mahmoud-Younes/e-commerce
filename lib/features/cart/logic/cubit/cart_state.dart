import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/cart_item_model.dart';
import '../../../../core/networking/api_error_model.dart';

part 'cart_state.freezed.dart';

/// Freezed-4 union for the cart screen (PRD §3). Consume it through the
/// generated pattern extensions (`state.whenOrNull(...)`) by importing this
/// file directly — same convention as the auth feature.
@freezed
class CartState with _$CartState {
  /// Freshly created cubit, before [CartCubit.start] subscribes.
  const factory CartState.initial() = _Initial;

  /// First cart snapshot not fetched yet.
  const factory CartState.loading() = CartLoading;

  /// Non-empty cart with live lines; [CartLoaded.total] is the cart total.
  const factory CartState.loaded(List<CartItemModel> items) = CartLoaded;

  /// Live snapshot confirmed there are no lines in the cart.
  const factory CartState.empty() = CartEmpty;

  /// A stream error or a failed one-shot operation (quantity change, removal…).
  const factory CartState.error(ApiErrorModel apiErrorModel) = CartError;
}

extension CartLoadedX on CartLoaded {
  /// Cart total price (PRD §3: "the cart's total price").
  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);
}
