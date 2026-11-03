import 'package:flutter/material.dart';

import '../../../../core/helpers/extensions.dart';
import '../../../../core/routing/routes.dart';

/// TODO: implemented in the catalog slice (PRD §2).
/// The profile icon is a temporary entry point (stage 1 e2e access).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => context.pushNamed(Routes.profileScreen),
          ),
        ],
      ),
      body: const Center(child: Text('Home — coming next')),
    );
  }
}
