import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/cart_item_model.dart';
import '../../../../core/networking/api_error_model.dart';

part 'checkout_state.freezed.dart';

/// States of the checkout flow (PRD §4): cart summary loads from the live
/// cart stream, then Place Order runs stock validation → order creation →
/// cart clear.
@freezed
class CheckoutState with _$CheckoutState {
  const factory CheckoutState.initial() = _Initial;

  const factory CheckoutState.checkoutLoading() = CheckoutLoading;

  /// Cart lines + their running total, kept live via `streamCart`.
  const factory CheckoutState.checkoutLoaded({
    required List<CartItemModel> items,
    required double totalPrice,
  }) = CheckoutLoaded;

  /// Place Order is in flight (stock validation / order write / cart clear);
  /// keeps the last cart summary so the screen stays rendered.
  const factory CheckoutState.orderPlacing({
    required List<CartItemModel> items,
    required double totalPrice,
  }) = OrderPlacing;

  /// Order document created; carries the Firestore-assigned order ID.
  const factory CheckoutState.orderSuccess(String orderId) = OrderSuccess;

  const factory CheckoutState.checkoutError(ApiErrorModel apiErrorModel) =
      CheckoutError;
}
