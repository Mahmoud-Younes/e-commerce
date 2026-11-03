import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../../core/helpers/constants.dart';

part 'user_model.g.dart';

/// Firestore `users/{uid}` document (PRD §7).
@JsonSerializable()
class UserModel {
  final String name;
  final String email;

  @JsonKey(defaultValue: '')
  final String phone;

  @JsonKey(defaultValue: '')
  final String address;

  @JsonKey(defaultValue: UserRoleValues.customer)
  final String role;

  /// map of `{token: true}` entries on the user doc (PRD: "device-token data
  /// if needed") — keyed map makes add/remove an O(1) field update.
  @JsonKey(defaultValue: {})
  final Map<String, bool> fcmTokens;

  const UserModel({
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.role = UserRoleValues.customer,
    this.fcmTokens = const {},
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      UserModel.fromJson(doc.data() ?? <String, dynamic>{});

  bool get isAdmin => role == UserRoleValues.admin;

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? role,
    Map<String, bool>? fcmTokens,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }
}
