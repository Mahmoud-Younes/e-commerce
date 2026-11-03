import 'package:flutter/material.dart';

import '../../../../core/models/cart_item_model.dart';
import '../../../../core/theming/styles.dart';

/// One line of an order's items list: product name, quantity and the price
/// captured at purchase time (PRD §4: historical orders must not change when
/// a product is edited later), plus the line subtotal.
class OrderItemTile extends StatelessWidget {
  const OrderItemTile({super.key, required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name.isEmpty ? item.productId : item.name,
              style: TextStyles.font14DarkGrayRegular,
            ),
          ),
          Text(
            '${item.quantity} x \$${item.price.toStringAsFixed(2)}',
            style: TextStyles.font13GrayRegular,
          ),
          const SizedBox(width: 12),
          Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
            style: TextStyles.font13GreenSemiBold,
          ),
        ],
      ),
    );
  }
}
