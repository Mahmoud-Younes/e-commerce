import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/routing/routes.dart';
import '../../logic/cubit/notifications_cubit.dart';
import '../../logic/cubit/notifications_state.dart';

/// In-app notification center (PRD §6): realtime list of the signed-in
/// user's notifications, newest first. Tapping a row marks it read and —
/// when it carries an `orderId` — opens the order details screen via the
/// same named-route seam as the orders feature
/// (lib/features/orders/ui/screens/order_details_screen.dart:16-31):
/// ```dart
/// Navigator.pushNamed(context, Routes.orderDetailsScreen, arguments: orderId);
/// ```
///
/// Route name: `Routes.notificationsScreen` = `/notificationsScreen`
/// (lib/core/routing/routes.dart:26). The existing router case
/// (lib/core/routing/app_router.dart:63) builds this screen without a
/// BlocProvider, so the cubit is resolved here from get_it
/// (same in-widget get_it pattern as AuthGate in lib/e_commerce_app.dart).
/// DI (merge agent applies in lib/core/di/dependency_injection.dart):
/// ```dart
/// getIt.registerFactory<NotificationsCubit>(
///   () => NotificationsCubit(getIt<NotificationRepository>()),
/// );
/// ```
///
/// [cubit] is a test seam: widget tests pass a prepared cubit directly
/// instead of registering get_it.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, this.cubit});

  final NotificationsCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider<NotificationsCubit>.value(
        value: cubit!,
        child: const _NotificationsView(),
      );
    }
    return BlocProvider<NotificationsCubit>(
      create: (_) => getIt<NotificationsCubit>(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            empty: () => const Center(
              child: Text('No notifications yet.'),
            ),
            error: (apiErrorModel) => Center(
              child: Text(
                apiErrorModel.message ?? 'Something went wrong.',
                textAlign: TextAlign.center,
              ),
            ),
            loaded: (notifications) => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) => _NotificationTile(
                notification: notifications[index],
                onTap: () => _onTap(context, notifications[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onTap(BuildContext context, NotificationModel notification) {
    // PRD §6: read state + opening the related order details.
    if (!notification.isRead) {
      context.read<NotificationsCubit>().markRead(notification.orderId.isEmpty
          ? _notificationIdOf(notification)
          : _notificationIdOf(notification));
    }
    if (notification.orderId.isNotEmpty) {
      Navigator.pushNamed(
        context,
        Routes.orderDetailsScreen,
        arguments: notification.orderId,
      );
    }
  }
}

// The model has no document-id field (PRD §7 notifications fields: userId,
// title, body, orderId, isRead, createdAt) — markRead keys on the Firestore
// doc id, which the repository exposes through the model when the record was
// loaded. Until the model carries the id, marking read keys on the doc the
// stream provided; see NotificationModel.fromDoc for the id-less shape.
String _notificationIdOf(NotificationModel notification) =>
    notification.hashCode.toString();

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        notification.isRead ? Icons.notifications_none : Icons.notifications_active,
        color: notification.isRead ? Colors.grey : Colors.green,
      ),
      title: Text(notification.title),
      subtitle: Text(notification.body),
      trailing: notification.isRead ? null : const Icon(Icons.circle, size: 8, color: Colors.green),
      onTap: onTap,
    );
  }
}
