import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/order_model.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/styles.dart';
import '../../logic/cubit/orders_cubit.dart';
import '../../logic/cubit/orders_state.dart';
import '../widgets/order_status_chip.dart';

/// My Orders screen (PRD §4): realtime list of the signed-in customer's
/// orders, newest first. Each row shows the creation date, the total price
/// and a colored status chip; tapping a row opens the order details.
///
/// Route name: `Routes.myOrdersScreen` = `/myOrdersScreen`
/// (lib/core/routing/routes.dart:22). Router case for the merge agent
/// (lib/core/routing/app_router.dart):
/// ```dart
/// case Routes.myOrdersScreen:
///   return MaterialPageRoute(
///     builder: (_) => BlocProvider(
///       create: (_) => getIt<OrdersCubit>(),
///       child: const MyOrdersScreen(),
///     ),
///   );
/// ```
/// DI (lib/core/di/dependency_injection.dart):
/// ```dart
/// getIt.registerFactory<OrdersCubit>(() => OrdersCubit(getIt()));
/// ```
///
/// Pushing the details screen from a row:
/// ```dart
/// Navigator.pushNamed(context, Routes.orderDetailsScreen, arguments: order.id);
/// ```
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().loadMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: BlocBuilder<OrdersCubit, OrdersState<List<OrderModel>>>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            ordersLoading: () =>
                const Center(child: CircularProgressIndicator()),
            ordersEmpty: () => const Center(
              child: Text('No orders yet.'),
            ),
            ordersError: (apiErrorModel) => Center(
              child: Text(
                apiErrorModel.message ?? 'Something went wrong.',
                textAlign: TextAlign.center,
              ),
            ),
            ordersLoaded: (orders) => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) => _OrderCard(
                order: orders[index],
                onTap: () => Navigator.pushNamed(
                  context,
                  Routes.orderDetailsScreen,
                  arguments: orders[index].id,
                ),
              ),
            ),
            // The details screen states belong to OrderDetailsScreen.
            orderDetailsLoading: () => const SizedBox.shrink(),
            orderDetailsLoaded: (_) => const SizedBox.shrink(),
            orderDetailsError: (_) => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        title: Text(
          DateFormat('yyyy-MM-dd – HH:mm').format(order.createdAt),
          style: TextStyles.font14DarkGrayRegular,
        ),
        subtitle: Text(
          '\$${order.totalPrice.toStringAsFixed(2)}',
          style: TextStyles.font13GreenSemiBold,
        ),
        trailing: OrderStatusChip(status: order.status),
      ),
    );
  }
}
