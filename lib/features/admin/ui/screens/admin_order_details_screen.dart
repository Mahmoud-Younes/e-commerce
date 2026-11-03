import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/models/order_model.dart';
import '../../../../core/theming/styles.dart';
import '../../logic/cubit/admin_orders_cubit.dart';
import '../../logic/cubit/admin_orders_state.dart';
import '../../logic/order_status_flow.dart';
import '../widgets/admin_order_status_chip.dart';

/// Admin order review (PRD §5: "Open an order to review its items,
/// quantities, and delivery information" + status updates).
///
/// Route: `adminOrderDetails` → `/adminOrderDetails` with
/// `settings.arguments as String` = orderId (merge agent wires
/// [AdminOrdersCubit] via get_it and the screen calls [openOrder]).
class AdminOrderDetailsScreen extends StatefulWidget {
  const AdminOrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<AdminOrderDetailsScreen> createState() =>
      _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminOrdersCubit>().openOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details', style: TextStyles.font18DarkGreenBold),
      ),
      body: BlocConsumer<AdminOrdersCubit, AdminOrdersState>(
        listenWhen: (previous, current) =>
            current is AdminOrderStatusUpdateError ||
            current is AdminOrdersWriteUnauthorized,
        listener: (context, state) {
          state.whenOrNull(
            statusUpdateError: (error) => _showSnackBar(
              context,
              error.message ?? 'Status update failed.',
            ),
            writeUnauthorized: (error) =>
                _showSnackBar(context, error.message ?? 'Not allowed.'),
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            ordersLoading: () => const SizedBox.shrink(),
            ordersSuccess: (_, _) => const SizedBox.shrink(),
            ordersError: (_) => const SizedBox.shrink(),
            orderDetailsLoading: () =>
                const Center(child: CircularProgressIndicator()),
            orderDetailsError: (error) => _ErrorView(
              message: error.message ?? 'Could not load the order.',
              onRetry: () =>
                  context.read<AdminOrdersCubit>().openOrder(widget.orderId),
            ),
            orderDetailsSuccess: (order) => _OrderDetailsView(order: order),
            // Status-write states keep the loaded order on screen; the
            // success state itself re-renders the view with the new status.
            statusUpdateLoading: () => state.maybeWhen(
              orderDetailsSuccess: (order) =>
                  _OrderDetailsView(order: order, writeInProgress: true),
              orElse: () => const Center(child: CircularProgressIndicator()),
            ),
            statusUpdateSuccess: (updatedOrder, _) =>
                _OrderDetailsView(order: updatedOrder),
            statusUpdateError: (_) => state.maybeWhen(
              orderDetailsSuccess: (order) => _OrderDetailsView(order: order),
              orElse: () => const SizedBox.shrink(),
            ),
            writeUnauthorized: (_) => state.maybeWhen(
              orderDetailsSuccess: (order) => _OrderDetailsView(order: order),
              orElse: () => const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _OrderDetailsView extends StatelessWidget {
  const _OrderDetailsView({required this.order, this.writeInProgress = false});

  final OrderModel order;
  final bool writeInProgress;

  @override
  Widget build(BuildContext context) {
    final next = OrderStatusFlow.next(order.status);
    final canCancel = OrderStatusFlow.canCancel(order.status);

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<AdminOrdersCubit>().openOrder(order.id),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${order.id}',
                  style: TextStyles.font14DarkGrayRegular.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AdminOrderStatusChip(status: order.status),
            ],
          ),
          verticalSpace(16),
          Text(
            'Delivery information',
            style: TextStyles.font14DarkGrayRegular.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          verticalSpace(4),
          Text(
            'Address: ${order.shippingAddress.isEmpty ? '—' : order.shippingAddress}\n'
            'Phone: ${order.phone.isEmpty ? '—' : order.phone}',
            style: TextStyles.font13GrayRegular,
          ),
          verticalSpace(16),
          Text(
            'Items',
            style: TextStyles.font14DarkGrayRegular.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          verticalSpace(4),
          ...order.items.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(item.name, style: TextStyles.font13GrayRegular),
              subtitle: Text(
                '\$${item.price.toStringAsFixed(2)} × ${item.quantity}',
                style: TextStyles.font13GrayRegular,
              ),
              trailing: Text(
                '\$${item.subtotal.toStringAsFixed(2)}',
                style: TextStyles.font13GrayRegular,
              ),
            ),
          ),
          const Divider(),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              'Total: \$${order.totalPrice.toStringAsFixed(2)}',
              style: TextStyles.font14DarkGrayRegular.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          verticalSpace(24),
          if (writeInProgress)
            const Center(child: CircularProgressIndicator())
          else ...[
            if (next != null)
              FilledButton(
                // Business rule ([OrderStatusFlow]): the button only ever
                // offers the EXACT next step — pending → confirmed →
                // preparing → shipped → delivered; no jumping. Updates of a
                // final order are rejected in the Cubit as well.
                onPressed: () => context
                    .read<AdminOrdersCubit>()
                    .updateOrderStatus(order, next),
                child: Text('Advance to ${next.value}'),
              ),
            if (next != null && canCancel) verticalSpace(8),
            if (canCancel)
              // Business rule: cancellation is allowed ONLY while the order
              // is still pending (before confirmed) — see
              // [OrderStatusFlow.canCancel]. The Cubit rejects it afterwards.
              OutlinedButton(
                onPressed: () =>
                    context.read<AdminOrdersCubit>().cancelOrder(order),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD32F2F),
                ),
                child: const Text('Cancel order'),
              ),
            if (next == null && !canCancel)
              Center(
                child: Text(
                  'This order is final — its status cannot change.',
                  style: TextStyles.font13GrayRegular,
                ),
              ),
          ],
        ],
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
