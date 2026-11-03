import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/order_model.dart';
import '../../../../core/networking/api_error_model.dart';

part 'admin_orders_state.freezed.dart';

/// States of [AdminOrdersCubit]. Consume the union via the named variant
/// classes exported here (import THIS file, like the other features do).
@freezed
class AdminOrdersState with _$AdminOrdersState {
  const factory AdminOrdersState.initial() = _Initial;

  /// Incoming-orders stream states (PRD §5: ID, customer, total, status —
  /// [customerNames] maps order userId → display name for the list tiles).
  const factory AdminOrdersState.ordersLoading() = AdminOrdersLoading;
  const factory AdminOrdersState.ordersSuccess(
    List<OrderModel> orders,
    Map<String, String> customerNames,
  ) = AdminOrdersSuccess;
  const factory AdminOrdersState.ordersError(ApiErrorModel apiErrorModel) =
      AdminOrdersError;

  /// Single-order review states (PRD §5: "Open an order to review its items,
  /// quantities, and delivery information").
  const factory AdminOrdersState.orderDetailsLoading() =
      AdminOrderDetailsLoading;
  const factory AdminOrdersState.orderDetailsSuccess(OrderModel order) =
      AdminOrderDetailsSuccess;
  const factory AdminOrdersState.orderDetailsError(
    ApiErrorModel apiErrorModel,
  ) = AdminOrderDetailsError;

  /// Status-update states (sequential advance + cancellation).
  const factory AdminOrdersState.statusUpdateLoading() =
      AdminOrderStatusUpdateLoading;
  const factory AdminOrdersState.statusUpdateSuccess(
    OrderModel updatedOrder,
    String successMessage,
  ) = AdminOrderStatusUpdateSuccess;
  const factory AdminOrdersState.statusUpdateError(
    ApiErrorModel apiErrorModel,
  ) = AdminOrderStatusUpdateError;

  /// The admin role guard refused a write (status update or cancellation).
  const factory AdminOrdersState.writeUnauthorized(
    ApiErrorModel apiErrorModel,
  ) = AdminOrdersWriteUnauthorized;
}
