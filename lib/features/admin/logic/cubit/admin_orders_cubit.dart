import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/order_model.dart';
import '../../../../core/models/order_status.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/repositories/order_repository.dart';
import '../../data/repos/admin_orders_source.dart';
import '../../data/repos/admin_role_guard.dart';
import '../order_status_flow.dart';
import 'admin_orders_state.dart';

/// Admin order management (PRD §5): list incoming orders, open one to review
/// its items/quantities/delivery info, and move its status forward.
///
/// get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`, AGENT C banner):
/// ```dart
/// getIt.registerFactory<AdminOrdersCubit>(() => AdminOrdersCubit(
///       getIt<OrderRepository>(),
///       getIt<AdminOrdersSource>(),
///       getIt<AdminRoleGuard>(),
///     ));
/// ```
///
/// Route names this feature documents for the router (merge agent):
/// - `adminOrders`        → `/adminOrders`        → AdminOrdersScreen
/// - `adminOrderDetails`  → `/adminOrderDetails`  → AdminOrderDetailsScreen
///   with `settings.arguments as String` = orderId.
///
/// Business rules (see [OrderStatusFlow], PRD §5):
/// - status updates must follow pending → confirmed → preparing → shipped →
///   delivered ONE STEP at a time; any jump is rejected before the
///   repository is called;
/// - cancellation is allowed ONLY while the order is still `pending`
///   (before confirmed); delivered/cancelled are terminal.
/// Every write first passes [AdminRoleGuard.ensureAdmin] — a non-admin gets
/// [AdminOrdersState.writeUnauthorized] and the repository is never called.
class AdminOrdersCubit extends Cubit<AdminOrdersState> {
  AdminOrdersCubit(
    this._orderRepository,
    this._ordersSource,
    this._roleGuard,
  ) : super(const AdminOrdersState.initial());

  final OrderRepository _orderRepository;
  final AdminOrdersSource _ordersSource;
  final AdminRoleGuard _roleGuard;

  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  /// Realtime stream of ALL incoming orders, newest first, plus the
  /// customer display names for the list tiles (PRD §5).
  void loadOrders() {
    emit(const AdminOrdersState.ordersLoading());
    _ordersSubscription?.cancel();
    _ordersSubscription = _ordersSource.streamAllOrders().listen(
      (orders) async {
        final names = await _ordersSource.customerNames(
          orders.map((order) => order.userId).toSet(),
        );
        names.whenOrNull(
          success: (customerNames) => emit(
            AdminOrdersState.ordersSuccess(orders, customerNames),
          ),
          failure: (apiErrorModel) =>
              emit(AdminOrdersState.ordersError(apiErrorModel)),
        );
      },
      onError: (Object error) =>
          emit(AdminOrdersState.ordersError(ApiErrorHandler.handle(error))),
    );
  }

  /// Load one order for review (items, quantities, delivery info).
  Future<void> openOrder(String orderId) async {
    emit(const AdminOrdersState.orderDetailsLoading());
    final response = await _orderRepository.getById(orderId);
    response.when(
      success: (order) =>
          emit(AdminOrdersState.orderDetailsSuccess(order)),
      failure: (apiErrorModel) =>
          emit(AdminOrdersState.orderDetailsError(apiErrorModel)),
    );
  }

  /// Move an order's status forward. [newStatus] must be EXACTLY the next
  /// step of the order's current status per [OrderStatusFlow.next] — any
  /// jump (e.g. pending → shipped), backwards move, or update of a final
  /// order is rejected here without touching the repository.
  Future<void> updateOrderStatus(
    OrderModel order,
    OrderStatus newStatus,
  ) async {
    final allowed = OrderStatusFlow.next(order.status);
    if (allowed != newStatus) {
      // Business rule: no jumping outside the sequential lifecycle.
      emit(AdminOrdersState.statusUpdateError(
        ApiErrorModel(
          message: allowed == null
              ? 'Order is already final (${order.status.value}); '
                  'its status cannot change.'
              : 'From ${order.status.value} the order can only move to '
                  '${allowed.value}.',
        ),
      ));
      return;
    }
    await _writeStatus(order, newStatus);
  }

  /// Cancel an order. Business rule (PRD §5): allowed ONLY while the order
  /// is still pending — i.e. before it is confirmed. After that the
  /// fulfilment flow owns the order and cancellation is rejected.
  Future<void> cancelOrder(OrderModel order) async {
    if (!OrderStatusFlow.canCancel(order.status)) {
      emit(AdminOrdersState.statusUpdateError(
        const ApiErrorModel(
          message:
              'Only pending orders can be cancelled — the order was already '
              'confirmed.',
        ),
      ));
      return;
    }
    await _writeStatus(order, OrderStatus.cancelled);
  }

  /// Shared tail of both writes: role gate, then repository update.
  Future<void> _writeStatus(OrderModel order, OrderStatus newStatus) async {
    emit(const AdminOrdersState.statusUpdateLoading());

    final guard = await _roleGuard.ensureAdmin();
    ApiErrorModel? denial;
    guard.whenOrNull(failure: (apiErrorModel) => denial = apiErrorModel);
    if (denial != null) {
      emit(AdminOrdersState.writeUnauthorized(denial!));
      return;
    }

    final response =
        await _orderRepository.updateStatus(order.id, newStatus);
    response.when(
      success: (_) => emit(
        AdminOrdersState.statusUpdateSuccess(
          order.copyWith(status: newStatus),
          'Order is now ${newStatus.value}.',
        ),
      ),
      failure: (apiErrorModel) =>
          emit(AdminOrdersState.statusUpdateError(apiErrorModel)),
    );
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
