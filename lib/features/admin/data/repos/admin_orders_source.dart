import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/helpers/constants.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_result.dart';

/// Admin-side read seam over ALL incoming orders (PRD §5: "View incoming
/// orders with order ID, customer, total, and status").
///
/// Why this exists next to `OrderRepository` (NOT instead of it): the core
/// interface only exposes `streamUserOrders(userId)` — the admin needs the
/// whole `orders` collection plus the customer display name, which lives on
/// the `users/{uid}` doc, not the order doc.
///
/// get_it registration (merge agent applies it):
/// ```dart
/// getIt.registerLazySingleton<AdminOrdersSource>(
///   () => FirestoreAdminOrdersSource(FirebaseFirestore.instance),
/// );
/// ```
abstract class AdminOrdersSource {
  /// Live stream of every order, newest first (PRD §5).
  Stream<List<OrderModel>> streamAllOrders();

  /// Display names for the given order owners, keyed by userId. Missing docs
  /// fall back to the userId itself so the list never shows a blank customer.
  Future<ApiResult<Map<String, String>>> customerNames(
    Set<String> userIds,
  );
}

class FirestoreAdminOrdersSource implements AdminOrdersSource {
  FirestoreAdminOrdersSource(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<OrderModel>> streamAllOrders() {
    return _firestore
        .collection(FirestorePaths.orders)
        .orderBy(OrderFields.createdAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(OrderModel.fromDoc).toList());
  }

  @override
  Future<ApiResult<Map<String, String>>> customerNames(
    Set<String> userIds,
  ) async {
    try {
      final names = <String, String>{};
      for (final userId in userIds) {
        final doc = await _firestore
            .collection(Collections.users)
            .doc(userId)
            .get();
        names[userId] =
            (doc.data()?[UserFields.name] as String?) ?? userId;
      }
      return ApiResult.success(names);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
