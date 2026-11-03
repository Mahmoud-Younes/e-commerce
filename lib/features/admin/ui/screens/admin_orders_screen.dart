import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/extensions.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/theming/styles.dart';
import '../../logic/cubit/admin_orders_cubit.dart';
import '../../logic/cubit/admin_orders_state.dart';
import '../admin_routes.dart';
import '../widgets/admin_order_status_chip.dart';

/// Admin incoming-orders list (PRD §5: "View incoming orders with order ID,
/// customer, total, and status"). Tapping a row opens
/// [AdminOrderDetailsScreen] via the `adminOrderDetails` route (see
/// `../admin_routes.dart` — merge agent passes the orderId as arguments).
///
/// Route: `adminOrders` → `/adminOrders` (merge agent wires
/// [AdminOrdersCubit] via get_it).
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminOrdersCubit>().loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders', style: TextStyles.font18DarkGreenBold),
      ),
      body: BlocBuilder<AdminOrdersCubit, AdminOrdersState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            ordersLoading: () =>
                const Center(child: CircularProgressIndicator()),
            ordersError: (error) => _ErrorView(
              message: error.message ?? 'Could not load orders.',
              onRetry: () => context.read<AdminOrdersCubit>().loadOrders(),
            ),
            ordersSuccess: (orders, customerNames) => orders.isEmpty
                ? Center(
                    child: Text(
                      'No orders yet.',
                      style: TextStyles.font14GrayRegular,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async =>
                        context.read<AdminOrdersCubit>().loadOrders(),
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => verticalSpace(8),
                      itemBuilder: (context, index) => _OrderTile(
                        order: orders[index],
                        customerName:
                            customerNames[orders[index].userId] ??
                            orders[index].userId,
                        onTap: () => _openDetails(context, orders[index]),
                      ),
                    ),
                  ),
            // Write states keep the list on screen; the stream refreshes it.
            orderDetailsLoading: () => _listOrSpinner(state),
            orderDetailsSuccess: (_) => _listOrSpinner(state),
            orderDetailsError: (_) => _listOrSpinner(state),
            statusUpdateLoading: () => _listOrSpinner(state),
            statusUpdateSuccess: (_, _) => _listOrSpinner(state),
            statusUpdateError: (_) => _listOrSpinner(state),
            writeUnauthorized: (_) => _listOrSpinner(state),
          );
        },
      ),
    );
  }

  Widget _listOrSpinner(AdminOrdersState state) {
    return state.maybeWhen(
      ordersSuccess: (orders, customerNames) => orders.isEmpty
          ? const SizedBox.shrink()
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) => _OrderTile(
                order: orders[index],
                customerName:
                    customerNames[orders[index].userId] ?? orders[index].userId,
              ),
            ),
      orElse: () => const Center(child: CircularProgressIndicator()),
    );
  }

  /// Pushes `adminOrderDetails` with the orderId as arguments — the merge
  /// agent's router case reads `settings.arguments as String`.
  void _openDetails(BuildContext context, OrderModel order) {
    context.pushNamed(AdminRoutes.adminOrderDetails, arguments: order.id);
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({
    required this.order,
    required this.customerName,
    this.onTap,
  });

  final OrderModel order;
  final String customerName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: Color(0xFFEDEDED)),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          '#${order.id}',
          style: TextStyles.font14DarkGrayRegular.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '$customerName • \$${order.totalPrice.toStringAsFixed(2)}',
          style: TextStyles.font13GrayRegular,
        ),
        trailing: AdminOrderStatusChip(status: order.status),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: TextStyles.font14DarkGrayRegular),
          verticalSpace(12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
