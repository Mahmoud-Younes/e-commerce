import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/order_model.dart';
import '../../../../core/networking/api_error_model.dart';

part 'orders_state.freezed.dart';

/// States for the orders feature (My Orders list + order details screen).
/// Consumed via the generated `when`/`maybeWhen` members from this file
/// (same seam as `profile_state.dart` in the auth feature).
@freezed
class OrdersState<T> with _$OrdersState<T> {
  const factory OrdersState.initial() = _Initial;

  // ---- My Orders list (stream-backed) ----
  const factory OrdersState.ordersLoading() = OrdersLoading;
  const factory OrdersState.ordersLoaded(List<OrderModel> orders) =
      OrdersLoaded<T>;
  const factory OrdersState.ordersEmpty() = OrdersEmpty;
  const factory OrdersState.ordersError(ApiErrorModel apiErrorModel) =
      OrdersError;

  // ---- Order details screen (one-shot read) ----
  const factory OrdersState.orderDetailsLoading() = OrderDetailsLoading;
  const factory OrdersState.orderDetailsLoaded(OrderModel order) =
      OrderDetailsLoaded<T>;
  const factory OrdersState.orderDetailsError(ApiErrorModel apiErrorModel) =
      OrderDetailsError;
}
