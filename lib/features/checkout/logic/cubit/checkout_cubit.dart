import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/cart_item_model.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/models/order_status.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/repositories/cart_repository.dart';
import '../../../../core/repositories/order_repository.dart';
import 'checkout_state.dart';

/// Arguments the caller (cart screen / router) passes so the delivery
/// address and phone start prefilled from the user's profile (PRD §1/§4).
/// Both stay editable on the checkout form.
class CheckoutArgs {
  final String address;
  final String phone;
  const CheckoutArgs({this.address = '', this.phone = ''});
}

/// Checkout cubit (PRD §4).
///
/// Consumes the core abstractions only — [CartRepository] for the live cart
/// summary and `validateStock`, [OrderRepository] for `createOrder` — never
/// Firestore directly. get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`):
/// ```dart
/// getIt.registerFactoryParam<CheckoutCubit, CheckoutArgs?, void>((args, _) {
///   final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
///   return CheckoutCubit(
///     getIt<CartRepository>(),
///     getIt<OrderRepository>(),
///     userId: uid,
///     args: args,
///   );
/// });
/// ```
/// [userId] is a constructor param (instead of reading FirebaseAuth inside
/// the methods) so widget/unit tests run against mocktail mocks with no
/// Firebase initialization.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(
    this._cartRepository,
    this._orderRepository, {
    String? userId,
    CheckoutArgs args = const CheckoutArgs(),
  }) : userId = userId ?? FirebaseAuth.instance.currentUser?.uid ?? '',
       super(const CheckoutState.initial()) {
    addressController = TextEditingController(text: args.address);
    phoneController = TextEditingController(text: args.phone);
  }

  final CartRepository _cartRepository;
  final OrderRepository _orderRepository;

  /// Signed-in user's uid — `users/{uid}/cart` owner and `orders.userId`.
  final String userId;

  late final TextEditingController addressController;
  late final TextEditingController phoneController;
  final formKey = GlobalKey<FormState>();

  StreamSubscription<List<CartItemModel>>? _cartSub;

  /// Live cart summary (PRD §4: checkout shows products, quantities and
  /// total). Errors surfacing from the stream (network, permission) map to
  /// [CheckoutError] via [ApiErrorHandler.handle].
  void loadCheckout() {
    emit(const CheckoutState.checkoutLoading());
    _cartSub?.cancel();
    _cartSub = _cartRepository
        .streamCart(userId)
        .listen(
          (items) {
            emit(
              CheckoutState.checkoutLoaded(
                items: items,
                totalPrice: _totalOf(items),
              ),
            );
          },
          onError: (Object error) {
            emit(CheckoutState.checkoutError(ApiErrorHandler.handle(error)));
          },
        );
  }

  /// Place Order (PRD §4): validate stock at purchase time, then create the
  /// order document with the items as they looked at that moment (name and
  /// price snapshot inside each item so historical orders don't change when
  /// a product is edited later), `status = pending` and `createdAt = now`.
  Future<void> placeOrder() async {
    final current = state;
    final items = current is CheckoutLoaded
        ? current.items
        : const <CartItemModel>[];
    if (items.isEmpty) {
      emit(
        const CheckoutState.checkoutError(
          ApiErrorModel(message: 'Your cart is empty.'),
        ),
      );
      return;
    }
    emit(CheckoutState.orderPlacing(items: items, totalPrice: _totalOf(items)));

    // 1) Re-check every cart line against live product docs (PRD §3).
    final ApiResult<List<CartItemModel>> stockResult = await _cartRepository
        .validateStock(userId);
    final validated = stockResult.when(
      success: (validatedItems) => validatedItems,
      failure: (apiErrorModel) {
        // Transient stock shortfall or network failure — nothing was written.
        emit(CheckoutState.checkoutError(apiErrorModel));
        return null;
      },
    );
    if (validated == null) return;
    if (validated.isEmpty) {
      emit(
        const CheckoutState.checkoutError(
          ApiErrorModel(
            message: 'The items in your cart are no longer available.',
          ),
        ),
      );
      return;
    }

    // 2) Build the order with the purchase-time snapshot.
    final order = OrderModel(
      userId: userId,
      items: validated,
      totalPrice: _totalOf(validated),
      shippingAddress: addressController.text.trim(),
      phone: phoneController.text.trim(),
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );

    // 3) Create the order document.
    final ApiResult<String> orderResult = await _orderRepository.createOrder(
      order,
    );
    final String? orderId = orderResult.when(
      success: (id) => id,
      failure: (apiErrorModel) {
        emit(CheckoutState.checkoutError(apiErrorModel));
        return null;
      },
    );
    if (orderId == null || orderId.isEmpty) return;

    // 4) Clear the cart (PRD §4: "After a successful order, clear the cart").
    // The [OrderRepository.createOrder] seam takes only the order payload, so
    // the clear is a follow-up write rather than the same batch. If it fails
    // the order still exists — the customer must land on the success screen;
    // the leftover cart lines disappear on the next successful checkout.
    await _cartRepository.clear(userId);

    emit(CheckoutState.orderSuccess(orderId));
  }

  double _totalOf(List<CartItemModel> items) =>
      items.fold<double>(0, (sum, item) => sum + item.subtotal);

  @override
  Future<void> close() {
    _cartSub?.cancel();
    addressController.dispose();
    phoneController.dispose();
    return super.close();
  }
}
