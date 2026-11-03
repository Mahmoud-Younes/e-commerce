import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/models/order_status.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/repositories/cart_repository.dart';
import '../../../../core/repositories/order_repository.dart';

/// Firestore-backed [OrderRepository] (PRD §4). Order docs live at
/// `orders/{orderId}` ([FirestorePaths.orderDoc]); items are stored as a list
/// inside the order doc with the product name/price at purchase time
/// ([OrderModel.items]).
///
/// get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`):
/// ```dart
/// getIt.registerLazySingleton<CartRepository>(() => CartRepositoryImpl());
/// getIt.registerLazySingleton<OrderRepository>(
///   () => OrderRepositoryImpl(
///     FirebaseFirestore.instance,
///     getIt<CartRepository>(),
///   ),
/// );
/// ```
///
/// [FirebaseFirestore] and [CartRepository] are injected so tests can pass
/// `FakeFirebaseFirestore` and a mocktail [CartRepository] mock directly.
class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._firestore, this._cartRepository);

  final FirebaseFirestore _firestore;
  final CartRepository _cartRepository;

  @override
  Stream<List<OrderModel>> streamUserOrders(String userId) {
    return _firestore
        .collection(FirestorePaths.orders)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true) // newest first (PRD §4)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(OrderModel.fromDoc).toList());
  }

  @override
  Future<ApiResult<OrderModel>> getById(String orderId) async {
    try {
      final doc = await _firestore
          .doc(FirestorePaths.orderDoc(orderId))
          .get();
      if (!doc.exists) {
        return ApiResult.failure(
          const ApiErrorModel(message: 'Order not found.'),
        );
      }
      return ApiResult.success(OrderModel.fromDoc(doc));
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<String>> createOrder(OrderModel order) async {
    try {
      // PRD §4: the order is created as pending with the creation timestamp
      // taken now, regardless of what the caller's payload carries — the
      // customer never sets trust fields.
      final payload = order
          .copyWith(status: OrderStatus.pending, createdAt: DateTime.now())
          .toJson();
      // Order items already carry the name/price at purchase time; persist
      // the payload as-is.
      final batch = _firestore.batch();
      final orderDocRef = _firestore.collection(FirestorePaths.orders).doc();
      batch.set(orderDocRef, payload);
      await batch.commit();

      // PRD §4: "After a successful order, clear the cart" — delegated to
      // [CartRepository.clear]. Deliberately non-fatal: once the order doc is
      // committed, reporting failure would push callers to re-place a
      // duplicate order. A stale cart is recoverable; a duplicate order is
      // not.
      await _cartRepository.clear(order.userId);

      return ApiResult.success(orderDocRef.id);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<void>> updateStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore
          .doc(FirestorePaths.orderDoc(orderId))
          .update({'status': status.value});
      return ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
