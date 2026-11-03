import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/order_model.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_error_model.dart';
// Imported directly: freezed pattern-match members (`when`) live in this
// library's part file and are invisible through transitive imports.
import '../../../../core/networking/api_result.dart';
import '../../../../core/repositories/order_repository.dart';
import 'orders_state.dart';

/// Cubit for the orders feature (PRD §4): drives both the My Orders list
/// (realtime stream from [OrderRepository.streamUserOrders]) and the order
/// details screen (one-shot [OrderRepository.getById]).
class OrdersCubit extends Cubit<OrdersState<List<OrderModel>>> {
  OrdersCubit(this._orderRepository) : super(const OrdersState.initial());

  final OrderRepository _orderRepository;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  /// Resolves the signed-in user and starts the My Orders stream. Called from
  /// [MyOrdersScreen] initState; unit tests use [loadOrders] with an explicit
  /// userId instead (keeps the cubit free of FirebaseAuth in tests).
  void loadMyOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(
        OrdersState.ordersError(
          const ApiErrorModel(message: 'Not authenticated'),
        ),
      );
      return;
    }
    loadOrders(user.uid);
  }

  /// Subscribes to the user's orders stream (newest first). Loading is
  /// emitted once; every Firestore snapshot re-emits loaded/empty so the
  /// list reflects live status changes.
  void loadOrders(String userId) {
    _ordersSubscription?.cancel();
    emit(const OrdersState.ordersLoading());
    _ordersSubscription = _orderRepository.streamUserOrders(userId).listen(
      (orders) {
        if (orders.isEmpty) {
          emit(const OrdersState.ordersEmpty());
        } else {
          emit(OrdersState.ordersLoaded(orders));
        }
      },
      onError: (Object error) {
        emit(OrdersState.ordersError(ApiErrorHandler.handle(error)));
      },
    );
  }

  /// Loads one order for the details screen (items, quantities, purchase-time
  /// prices, delivery info, status — PRD §4).
  Future<void> loadOrderDetails(String orderId) async {
    emit(const OrdersState.orderDetailsLoading());
    final result = await _orderRepository.getById(orderId);
    result.when(
      success: (order) => emit(OrdersState.orderDetailsLoaded(order)),
      failure: (apiErrorModel) =>
          emit(OrdersState.orderDetailsError(apiErrorModel)),
    );
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
