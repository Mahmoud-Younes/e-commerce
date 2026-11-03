import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/order_model.dart';
import '../../../../core/theming/styles.dart';
import '../../logic/cubit/orders_cubit.dart';
import '../../logic/cubit/orders_state.dart';
import '../widgets/order_item_tile.dart';
import '../widgets/order_status_chip.dart';

/// Order details screen (PRD §4): items with quantities and prices at
/// purchase time, delivery info (address + phone), total and the current
/// status chip.
///
/// Route name: `Routes.orderDetailsScreen` = `/orderDetailsScreen`
/// (lib/core/routing/routes.dart:23). The order ID arrives as
/// `settings.arguments` (a [String]) — pushed from MyOrdersScreen, the
/// notifications tap handler (PRD §6) or the admin dashboard (PRD §5).
///
/// Router case for the merge agent (lib/core/routing/app_router.dart):
/// ```dart
/// case Routes.orderDetailsScreen:
///   return MaterialPageRoute(
///     builder: (_) => BlocProvider(
///       create: (_) => getIt<OrdersCubit>(),
///       child: const OrderDetailsScreen(),
///     ),
///   );
/// ```
/// Tests may pass [orderId] directly to skip route arguments.
class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, this.orderId});

  final String? orderId;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _loadRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadRequested) return;
    _loadRequested = true;
    // Resolve once: constructor arg first, then the route arguments
    // (Navigator.pushNamed(..., arguments: orderId)).
    if (widget.orderId != null) {
      context.read<OrdersCubit>().loadOrderDetails(widget.orderId!);
    } else {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is String && arguments.isNotEmpty) {
        context.read<OrdersCubit>().loadOrderDetails(arguments);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: BlocBuilder<OrdersCubit, OrdersState<List<OrderModel>>>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            orderDetailsLoading: () =>
                const Center(child: CircularProgressIndicator()),
            orderDetailsLoaded: (order) => _OrderDetailsView(order: order),
            orderDetailsError: (apiErrorModel) => Center(
              child: Text(
                apiErrorModel.message ?? 'Could not load this order.',
                textAlign: TextAlign.center,
              ),
            ),
            // My Orders list states belong to MyOrdersScreen.
            ordersLoading: () => const SizedBox.shrink(),
            ordersLoaded: (_) => const SizedBox.shrink(),
            ordersEmpty: () => const SizedBox.shrink(),
            ordersError: (_) => const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class _OrderDetailsView extends StatelessWidget {
  const _OrderDetailsView({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('yyyy-MM-dd – HH:mm').format(order.createdAt),
              style: TextStyles.font14DarkGrayRegular,
            ),
            OrderStatusChip(status: order.status),
          ],
        ),
        const Divider(height: 24),
        Text('Items', style: TextStyles.font18DarkGreenBold),
        ...order.items.map((item) => OrderItemTile(item: item)),
        const Divider(height: 24),
        Text('Delivery', style: TextStyles.font18DarkGreenBold),
        const SizedBox(height: 8),
        Text('Address: ${order.shippingAddress}',
            style: TextStyles.font14DarkGrayRegular),
        Text('Phone: ${order.phone}',
            style: TextStyles.font14DarkGrayRegular),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: TextStyles.font18DarkGreenBold),
            Text(
              '\$${order.totalPrice.toStringAsFixed(2)}',
              style: TextStyles.font18DarkGreenBold,
            ),
          ],
        ),
      ],
    );
  }
}
