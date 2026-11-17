import 'package:flutter/material.dart';

import '../../../../core/helpers/extensions.dart';
import '../../../../core/routing/routes.dart';

/// Customer home (PRD §2 entry): the catalog, favorites and cart are reached
/// from here; the profile icon remains the stage-1 e2e access point.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            // The in-app notification center's only entry point (PRD §6) —
            // the screen exists and is routed, but nothing navigated to it.
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () => context.pushNamed(Routes.notificationsScreen),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Favorites',
            onPressed: () => context.pushNamed(Routes.favoritesScreen),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Cart',
            onPressed: () => context.pushNamed(Routes.cartScreen),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.pushNamed(Routes.profileScreen),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.pushNamed(Routes.productsScreen),
          child: const Text('Browse Products'),
        ),
      ),
    );
  }
}
