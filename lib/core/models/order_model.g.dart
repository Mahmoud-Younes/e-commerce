// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: json['id'] as String? ?? '',
  userId: json['userId'] as String? ?? '',
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
  shippingAddress: json['shippingAddress'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  status: json['status'] == null
      ? OrderStatus.pending
      : OrderStatusMapper.fromFirestore(json['status'] as String?),
  createdAt: _createdAtFromJson(json['createdAt']),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'items': _itemsToJson(instance.items),
      'totalPrice': instance.totalPrice,
      'shippingAddress': instance.shippingAddress,
      'phone': instance.phone,
      'status': _statusToJson(instance.status),
      'createdAt': _createdAtToJson(instance.createdAt),
    };
