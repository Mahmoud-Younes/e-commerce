import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import 'cart_item_model.dart';
import 'order_status.dart';

part 'order_model.g.dart';

DateTime _createdAtFromJson(Object? value) {
  // Firestore writes [Timestamp]; int millis and ISO strings are accepted
  // for test fakes / older payloads. Missing field falls back to the epoch.
  if (value is Timestamp) return value.toDate();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.parse(value);
  return DateTime.fromMillisecondsSinceEpoch(0);
}

Object? _createdAtToJson(DateTime value) => Timestamp.fromDate(value);

String _statusToJson(OrderStatus status) => status.value;

Object? _itemsToJson(List<CartItemModel> items) =>
    items.map((item) => item.toJson()).toList();

/// Firestore `orders/{orderId}` document (PRD §4, §7). Items are stored as a
/// list inside the order document (PRD §7 note: list vs subcollection); each
/// [CartItemModel] carries the name/price at purchase time.
@JsonSerializable()
class OrderModel {
  /// The order ID (`orders/{orderId}`); empty for not-yet-created orders
  /// before Firestore assigns the document ID.
  @JsonKey(defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String userId;

  @JsonKey(defaultValue: <CartItemModel>[], toJson: _itemsToJson)
  final List<CartItemModel> items;

  @JsonKey(defaultValue: 0.0)
  final double totalPrice;

  @JsonKey(defaultValue: '')
  final String shippingAddress;

  @JsonKey(defaultValue: '')
  final String phone;

  /// Unknown/null Firestore values map to [OrderStatus.pending] via
  /// [OrderStatusMapper.fromFirestore] instead of throwing.
  @JsonKey(
    fromJson: OrderStatusMapper.fromFirestore,
    toJson: _statusToJson,
  )
  final OrderStatus status;

  @JsonKey(fromJson: _createdAtFromJson, toJson: _createdAtToJson)
  final DateTime createdAt;

  const OrderModel({
    this.id = '',
    required this.userId,
    this.items = const [],
    this.totalPrice = 0.0,
    this.shippingAddress = '',
    this.phone = '',
    this.status = OrderStatus.pending,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  factory OrderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      OrderModel.fromJson({
        ...?doc.data(),
        'id': doc.id,
      });

  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    double? totalPrice,
    String? shippingAddress,
    String? phone,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
