import 'package:flutter/material.dart';

import '../../../../core/models/cart_item_model.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';

/// One cart line: product info, quantity stepper (− / +) and per-line
/// subtotal (PRD §3: "Display each item's subtotal").
class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final void Function(CartItemModel item)? onIncrease;
  final void Function(CartItemModel item)? onDecrease;
  final void Function(CartItemModel item)? onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    this.onIncrease,
    this.onDecrease,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: ColorsManager.lightGray,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name.isEmpty ? item.productId : item.name,
                    key: Key('cartItemName_${item.productId}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.font13GreenSemiBold,
                  ),
                  const SizedBox(height: 4),
                  Text('Subtotal', style: TextStyles.font14DarkGrayRegular),
                  const SizedBox(height: 2),
                  Text(
                    item.subtotal.toStringAsFixed(2),
                    key: Key('cartItemSubtotal_${item.productId}'),
                    style: TextStyles.font13GreenSemiBold,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                IconButton(
                  key: Key('cartItemDecrease_${item.productId}'),
                  onPressed: onDecrease == null
                      ? null
                      : () => onDecrease!(item),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: ColorsManager.darkerGray,
                ),
                Text(
                  '${item.quantity}',
                  key: Key('cartItemQuantity_${item.productId}'),
                  style: TextStyles.font13GreenSemiBold,
                ),
                IconButton(
                  key: Key('cartItemIncrease_${item.productId}'),
                  onPressed: onIncrease == null
                      ? null
                      : () => onIncrease!(item),
                  icon: const Icon(Icons.add_circle_outline),
                  color: ColorsManager.mainGreen,
                ),
              ],
            ),
            IconButton(
              key: Key('cartItemRemove_${item.productId}'),
              onPressed: onRemove == null ? null : () => onRemove!(item),
              icon: const Icon(Icons.delete_outline),
              color: ColorsManager.red,
            ),
          ],
        ),
      ),
    );
  }
}
