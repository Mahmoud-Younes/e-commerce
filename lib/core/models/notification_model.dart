import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

DateTime _createdAtFromJson(Object? value) {
  // Firestore writes [Timestamp]; int millis and ISO strings are accepted
  // for test fakes / older payloads. Missing field falls back to the epoch.
  if (value is Timestamp) return value.toDate();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.parse(value);
  return DateTime.fromMillisecondsSinceEpoch(0);
}

Object? _createdAtToJson(DateTime value) => Timestamp.fromDate(value);

/// Firestore `notifications/{notificationId}` document — the in-app
/// notification-center record (PRD §6 optional, §7). Tapping one opens the
/// related order-details screen via [orderId].
@JsonSerializable()
class NotificationModel {
  @JsonKey(defaultValue: '')
  final String userId;

  @JsonKey(defaultValue: '')
  final String title;

  @JsonKey(defaultValue: '')
  final String body;

  /// Related order to open when the notification is tapped (PRD §6);
  /// empty for promotional notifications.
  @JsonKey(defaultValue: '')
  final String orderId;

  @JsonKey(defaultValue: false)
  final bool isRead;

  @JsonKey(fromJson: _createdAtFromJson, toJson: _createdAtToJson)
  final DateTime createdAt;

  const NotificationModel({
    required this.userId,
    required this.title,
    this.body = '',
    this.orderId = '',
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  factory NotificationModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) =>
      NotificationModel.fromJson(doc.data() ?? <String, dynamic>{});

  NotificationModel copyWith({
    String? userId,
    String? title,
    String? body,
    String? orderId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      orderId: orderId ?? this.orderId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
