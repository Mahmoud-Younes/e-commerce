import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/extensions.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/theming/styles.dart';
import '../../../auth/logic/cubit/profile_cubit.dart';
import '../admin_routes.dart';

/// Admin hub (PRD §5). AuthGate (lib/e_commerce_app.dart) routes admins here
/// from the role on their Firestore user doc.
///
/// The AppBar logout is the admin's only sign-out path — admins never see
/// the customer Profile screen where the customer Logout button lives. It
/// reuses [ProfileCubit.logout] (AuthGate swaps the tree once signOut
/// completes); the router provides the cubit for this screen.
///
/// Routes for the merge agent (see `../admin_routes.dart` for the full
/// router snippets): pushes `adminProducts` (/adminProducts) and
/// `adminOrders` (/adminOrders).
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: TextStyles.font18DarkGreenBold),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<ProfileCubit>().logout(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AdminSectionCard(
              icon: Icons.inventory_2_outlined,
              title: 'Products',
              subtitle: 'Add, edit and delete catalog products.',
              onTap: () => context.pushNamed(AdminRoutes.adminProducts),
            ),
            verticalSpace(16),
            _AdminSectionCard(
              icon: Icons.receipt_long_outlined,
              title: 'Orders',
              subtitle: 'Review incoming orders and update their status.',
              onTap: () => context.pushNamed(AdminRoutes.adminOrders),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminSectionCard extends StatelessWidget {
  const _AdminSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Icon(icon, color: const Color(0xFF2E7D32)),
        title: Text(
          title,
          style: TextStyles.font16WhiteSemiBold.copyWith(
            color: const Color(0xFF14171A),
          ),
        ),
        subtitle: Text(subtitle, style: TextStyles.font14GrayRegular),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
