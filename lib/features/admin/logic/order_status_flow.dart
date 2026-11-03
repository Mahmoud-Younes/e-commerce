import '../../../core/models/order_status.dart';

/// Business rules for the order lifecycle, enforced in the admin feature
/// (PRD §5: "Update order status from pending to confirmed, preparing,
/// shipped, and delivered" + "Allow order cancellation according to the
/// app's business rules").
///
/// The two rules this app implements (server-side Firestore rules come in a
/// later stage — PRD §5 last bullet — so the UI layer is the first gate):
///
/// 1. SEQUENTIAL ADVANCE ONLY: an order moves one step at a time through
///    pending → confirmed → preparing → shipped → delivered. Jumping ahead
///    (e.g. pending → shipped), moving backwards, or updating a final order
///    is rejected by [next] returning null / by the Cubit emitting an error.
/// 2. CANCEL ONLY BEFORE CONFIRMED: an order can be cancelled only while it
///    is still `pending` ([canCancel]). Once the admin confirms it, the
///    fulfilment flow owns the order and it can no longer be cancelled from
///    the dashboard; `delivered` and `cancelled` are terminal states.
class OrderStatusFlow {
  OrderStatusFlow._();

  /// The forward lifecycle in strict order (no `cancelled` — that is a side
  /// exit from `pending`, not a step).
  static const List<OrderStatus> progression = <OrderStatus>[
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];

  /// The only status an order may advance to from [current], or null when
  /// [current] is final (delivered/cancelled) or not on the progression
  /// (defensive). Used both to validate explicit requests and to drive the
  /// "Advance to X" button, so the UI can never offer a jump.
  static OrderStatus? next(OrderStatus current) {
    final index = progression.indexOf(current);
    if (index < 0 || index == progression.length - 1) return null;
    return progression[index + 1];
  }

  /// Cancellation business rule: allowed only while the order is still
  /// pending — i.e. before it is confirmed (PRD §5).
  static bool canCancel(OrderStatus current) =>
      current == OrderStatus.pending;

  /// Whether the order still has a next step on the progression.
  static bool canAdvance(OrderStatus current) => next(current) != null;
}
