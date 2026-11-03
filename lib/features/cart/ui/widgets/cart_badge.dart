import 'package:flutter/material.dart';

import '../../../../core/theming/colors.dart';

/// AppBar-ready cart counter badge (PRD §3). Drop it into
/// `AppBar(actions: [CartBadge(count: n, onTap: ...)])` from any feature —
/// it is purely presentational so callers keep control of the count source.
class CartBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const CartBadge({super.key, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('cartBadge'),
      onPressed: onTap,
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        backgroundColor: ColorsManager.mainGreen,
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}
