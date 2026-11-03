import 'package:json_annotation/json_annotation.dart';

/// Order lifecycle statuses (PRD §4: "pending, confirmed, preparing,
/// shipped, delivered, and cancelled").
///
/// The Firestore `status` field stores [value] (the lowercase name), so the
/// mapping is stable regardless of Dart-side serialization; [mapper.fromFirestore]
/// falls back to [OrderStatus.pending] for unknown values.
@JsonEnum(valueField: 'value')
enum OrderStatus {
  pending('pending'),
  confirmed('confirmed'),
  preparing('preparing'),
  shipped('shipped'),
  delivered('delivered'),
  cancelled('cancelled');

  const OrderStatus(this.value);

  /// The string persisted in the Firestore `status` field (PRD §7).
  final String value;
}

/// Firestore <-> enum mapping for [OrderStatus].
class OrderStatusMapper {
  OrderStatusMapper._();

  /// Parses the Firestore `status` field. Unknown/null values fall back to
  /// [OrderStatus.pending] instead of throwing, so legacy or partially
  /// written docs never crash the orders screens.
  static OrderStatus fromFirestore(String? value) {
    for (final status in OrderStatus.values) {
      if (status.value == value) return status;
    }
    return OrderStatus.pending;
  }
}
