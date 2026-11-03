import '../models/order_model.dart';
import '../models/order_status.dart';
import '../networking/api_result.dart';

/// Orders repository (PRD §4, §5). Order docs live at `orders/{orderId}`
/// (see `FirestorePaths.orderDoc`).
///
/// get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`):
/// ```dart
/// getIt.registerLazySingleton<OrderRepository>(() => OrderRepositoryImpl());
/// ```
///
/// Conventions: one-shot reads/writes return [ApiResult] (failures via
/// `ApiErrorHandler.handle`, never thrown); realtime reads return plain
/// `Stream`s.
abstract class OrderRepository {
  /// Live stream of one customer's orders, newest first (PRD §4: My Orders).
  Stream<List<OrderModel>> streamUserOrders(String userId);

  /// Fetch a single order by ID (order details, PRD §4/§5).
  Future<ApiResult<OrderModel>> getById(String orderId);

  /// Create the order document (PRD §4: "create a new document in the orders
  /// collection"). Persists [OrderModel.items] with the name/price at
  /// purchase time. Returns the Firestore-assigned order ID; callers clear
  /// the cart and navigate to the success screen on success.
  Future<ApiResult<String>> createOrder(OrderModel order);

  /// Update the order status (Admin, PRD §5: pending → confirmed →
  /// preparing → shipped → delivered, plus cancellation per business rules).
  Future<ApiResult<void>> updateStatus(String orderId, OrderStatus status);
}
