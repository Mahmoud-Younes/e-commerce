import 'package:flutter/material.dart';

import '../../../../core/models/order_status.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';

/// Colored chip for an order's status on the admin dashboard. Kept local to
/// the admin feature (the customer-side one lives in features/orders) so the
/// two features stay decoupled.
class AdminOrderStatusChip extends StatelessWidget {
  const AdminOrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.value,
        style: TextStyles.font13GrayRegular.copyWith(
          color: _textColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _backgroundColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange.shade50;
      case OrderStatus.confirmed:
        return Colors.blue.shade50;
      case OrderStatus.preparing:
        return Colors.deepPurple.shade50;
      case OrderStatus.shipped:
        return Colors.indigo.shade50;
      case OrderStatus.delivered:
        return ColorsManager.lightGreen;
      case OrderStatus.cancelled:
        return Colors.red.shade50;
    }
  }

  Color _textColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange.shade800;
      case OrderStatus.confirmed:
        return Colors.blue.shade800;
      case OrderStatus.preparing:
        return Colors.deepPurple.shade700;
      case OrderStatus.shipped:
        return Colors.indigo.shade700;
      case OrderStatus.delivered:
        return ColorsManager.mainGreen;
      case OrderStatus.cancelled:
        return ColorsManager.red;
    }
  }
}
