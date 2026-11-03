import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/notification_model.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/repositories/notification_repository.dart';
import 'notifications_state.dart';

/// Cubit for the notifications feature (PRD §6): drives the in-app
/// notification center with a realtime stream from
/// [NotificationRepository.streamUserNotifications] and one-shot
/// [NotificationRepository.markRead] writes.
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._notificationRepository)
      : super(const NotificationsState.initial());

  final NotificationRepository _notificationRepository;
  StreamSubscription<List<NotificationModel>>? _notificationsSubscription;

  /// Resolves the signed-in user and starts the notifications stream.
  /// Called from [NotificationsScreen] initState; unit tests use
  /// [loadNotificationsForUser] with an explicit userId instead (keeps the
  /// cubit free of FirebaseAuth in tests — same pattern as [OrdersCubit]).
  void loadNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(
        const NotificationsState.error(
          ApiErrorModel(message: 'Not authenticated'),
        ),
      );
      return;
    }
    loadNotificationsForUser(user.uid);
  }

  /// Subscribes to the user's notifications stream (newest first). Loading is
  /// emitted once; every Firestore snapshot re-emits loaded/empty so the
  /// center reflects live changes (new push → record → list updates).
  void loadNotificationsForUser(String userId) {
    _notificationsSubscription?.cancel();
    emit(const NotificationsState.loading());
    _notificationsSubscription =
        _notificationRepository.streamUserNotifications(userId).listen(
      (notifications) {
        if (notifications.isEmpty) {
          emit(const NotificationsState.empty());
        } else {
          emit(NotificationsState.loaded(notifications));
        }
      },
      onError: (Object error) {
        emit(NotificationsState.error(ApiErrorHandler.handle(error)));
      },
    );
  }

  /// Marks a notification as read (PRD §6). The realtime stream re-emits
  /// with `isRead: true`, so no local state surgery is needed; a write
  /// failure is deliberately non-fatal (the center stays usable).
  Future<void> markRead(String notificationId) async {
    await _notificationRepository.markRead(notificationId);
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
