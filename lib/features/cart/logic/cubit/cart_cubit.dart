import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/cart_item_model.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/repositories/cart_repository.dart';
import '../../../../core/repositories/product_repository.dart';
import 'cart_state.dart';

/// Live cart cubit (PRD §3). Holds one active Firestore subscription via
/// [CartRepository.streamCart]; every quantity change / removal is a one-shot
/// write through [CartRepository] whose next snapshot re-emits the loaded
/// state, so the UI is always a live projection of `users/{uid}/cart`.
///
/// get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`):
/// ```dart
/// getIt.registerFactory<CartCubit>(() => CartCubit(getIt<CartRepository>(), getIt<ProductRepository>()));
/// ```
class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepo;
  final ProductRepository _productRepo;

  /// Set by [start]; every subsequent cart operation targets this user.
  String? _userId;
  StreamSubscription<List<CartItemModel>>? _cartSub;

  CartCubit(this._cartRepo, this._productRepo)
    : super(const CartState.initial());

  /// Subscribe to the user's cart (PRD §3: cart persists in Firestore and
  /// stays in sync live). Call once when the screen is created.
  void start(String userId) {
    _userId = userId;
    _cartSub?.cancel();
    emit(const CartState.loading());
    _cartSub = _cartRepo
        .streamCart(userId)
        .listen(
          (items) {
            if (isClosed) return;
            if (items.isEmpty) {
              emit(const CartState.empty());
            } else {
              emit(CartState.loaded(items));
            }
          },
          onError: (Object error) {
            if (isClosed) return;
            emit(CartState.error(ApiErrorHandler.handle(error)));
          },
        );
  }

  /// Add a product (used by product details; PRD §3: add to cart).
  Future<void> addItem(CartItemModel item) =>
      _runWrite(() => _cartRepo.add(_requireUserId(), item));

  /// Bump the quantity by 1, capped by the live product stock (the ask's
  /// invariant: the quantity never exceeds the stock). Re-checks
  /// availability against the product doc before writing.
  Future<void> increaseQuantity(CartItemModel item) async {
    final response = await _productRepo.getById(item.productId);
    response.whenOrNull(
      failure: (apiErrorModel) => _emitError(apiErrorModel),
      success: (product) async {
        if (!product.isAvailable) {
          _emitError(
            const ApiErrorModel(
              message: 'This product is no longer available.',
            ),
          );
          return;
        }
        if (item.quantity + 1 > product.stock) {
          _emitError(
            ApiErrorModel(
              message: product.stock <= 0
                  ? 'This product is out of stock.'
                  : 'Only ${product.stock} in stock.',
            ),
          );
          return;
        }
        await _runWrite(
          () => _cartRepo.updateQuantity(
            _requireUserId(),
            item.productId,
            item.quantity + 1,
          ),
        );
      },
    );
  }

  /// Drop the quantity by 1; reaching 0 removes the line (PRD §3).
  Future<void> decreaseQuantity(CartItemModel item) async {
    if (item.quantity <= 1) {
      await removeItem(item.productId);
      return;
    }
    await _runWrite(
      () => _cartRepo.updateQuantity(
        _requireUserId(),
        item.productId,
        item.quantity - 1,
      ),
    );
  }

  /// Remove one cart line (PRD §3).
  Future<void> removeItem(String productId) =>
      _runWrite(() => _cartRepo.remove(_requireUserId(), productId));

  /// Empty the cart (PRD §4: after a successful order).
  Future<void> clearCart() =>
      _runWrite(() => _cartRepo.clear(_requireUserId()));

  String _requireUserId() {
    final userId = _userId;
    if (userId == null) {
      throw StateError('CartCubit.start(userId) must be called first.');
    }
    return userId;
  }

  /// One-shot writes never throw: a failure is surfaced as [CartError] and
  /// the live stream immediately re-emits the loaded state afterwards.
  Future<void> _runWrite(Future<ApiResult<void>> Function() write) async {
    final response = await write();
    response.whenOrNull(failure: _emitError);
  }

  void _emitError(ApiErrorModel apiErrorModel) {
    if (isClosed) return;
    emit(CartState.error(apiErrorModel));
  }

  @override
  Future<void> close() {
    _cartSub?.cancel();
    return super.close();
  }
}
