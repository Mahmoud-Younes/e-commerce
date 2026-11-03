// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: _createdAtFromJson(json['createdAt']),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'title': instance.title,
      'body': instance.body,
      'orderId': instance.orderId,
      'isRead': instance.isRead,
      'createdAt': _createdAtToJson(instance.createdAt),
    };
