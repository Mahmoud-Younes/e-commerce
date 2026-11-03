import 'package:flutter/material.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/models/cart_item_model.dart';
import '../../../../core/theming/styles.dart';

/// Cart lines shown on the checkout screen (PRD §4: products, quantities and
/// total price).
class CheckoutItemsList extends StatelessWidget {
  const CheckoutItemsList({super.key, required this.items});

  final List<CartItemModel> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => verticalSpace(10),
      itemBuilder: (context, index) {
        final item = items[index];
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.isEmpty ? 'Product' : item.name,
                    style: TextStyles.font14DarkGrayRegular,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '\$${item.price.toStringAsFixed(2)} x ${item.quantity}',
                    style: TextStyles.font13GrayRegular,
                  ),
                ],
              ),
            ),
            Text(
              '\$${item.subtotal.toStringAsFixed(2)}',
              style: TextStyles.font14DarkGrayRegular,
            ),
          ],
        );
      },
    );
  }
}
