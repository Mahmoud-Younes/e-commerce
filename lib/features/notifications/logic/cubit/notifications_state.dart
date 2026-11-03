import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/notification_model.dart';
import '../../../../core/networking/api_error_model.dart';

part 'notifications_state.freezed.dart';

/// States for the notifications feature (in-app notification center, PRD §6).
/// Consumed via the generated `when`/`maybeWhen` members from this file
/// (same seam as `orders_state.dart` in the orders feature).
@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState.initial() = NotificationsInitial;

  const factory NotificationsState.loading() = NotificationsLoading;

  const factory NotificationsState.loaded(
    List<NotificationModel> notifications,
  ) = NotificationsLoaded;

  const factory NotificationsState.empty() = NotificationsEmpty;

  const factory NotificationsState.error(ApiErrorModel apiErrorModel) =
      NotificationsError;
}
