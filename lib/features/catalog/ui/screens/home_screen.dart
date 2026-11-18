import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/extensions.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../products/logic/cubit/products_cubit.dart';
import '../../../products/logic/cubit/products_state.dart';
import '../../../products/ui/widgets/product_card.dart';

/// Customer home (PRD §2 entry): the catalog, favorites and cart are reached
/// from here; the profile icon remains the stage-1 e2e access point.
///
/// The body greets the user, offers a search shortcut and category chips into
/// the products screen, and previews the live catalog as horizontal cards.
/// The preview reads the [ProductsCubit] the router wraps this screen in —
/// the same live catalog stream the products screen listens to, with a fresh
/// search/filter state.
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
      body: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back 👋', style: TextStyles.font24BlackBold),
          SizedBox(height: 4.h),
          Text(
            'Find your next favorite product',
            style: TextStyles.font14GrayRegular,
          ),
          verticalSpace(16),
          _SearchShortcut(
            onTap: () => context.pushNamed(Routes.productsScreen),
          ),
          verticalSpace(12),
          BlocBuilder<ProductsCubit, ProductsState>(
            buildWhen: (previous, current) =>
                current is ProductsLoaded || current is ProductsEmpty,
            builder: (context, state) {
              final categories = state.maybeWhen(
                productsLoaded: (_, categories, _, _) => categories,
                productsEmpty: (categories, _, _) => categories,
                orElse: () => const <String>[],
              );
              if (categories.isEmpty) return const SizedBox.shrink();
              return _CategoryShortcuts(
                categories: categories,
                onSelected: (_) => context.pushNamed(Routes.productsScreen),
              );
            },
          ),
          verticalSpace(16),
          Text('Featured products', style: TextStyles.font18DarkGreenBold),
          verticalSpace(8),
          BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, state) => state.maybeWhen(
              // `initial` (pre-first-emission) and `productsLoading` (retry)
              // both show the spinner (PRD §9 clear loading state).
              initial: () => const _FeaturedLoading(),
              productsLoading: () => const _FeaturedLoading(),
              productsLoaded: (products, _, _, _) {
                final preview = products.take(6).toList();
                if (preview.isEmpty) return const SizedBox.shrink();
                return SizedBox(
                  height: 210.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: preview.length,
                    separatorBuilder: (_, _) => SizedBox(width: 12.w),
                    itemBuilder: (context, index) => SizedBox(
                      width: 150.w,
                      child: ProductCard(productDoc: preview[index]),
                    ),
                  ),
                );
              },
              // The products screen owns catalog errors (retry UI); home
              // simply hides the preview instead of duplicating the noise.
              orElse: () => const SizedBox.shrink(),
            ),
          ),
          verticalSpace(16),
          // Kept as the primary catalog CTA — the e2e suite targets this
          // exact label (`getByRole('button', 'Browse Products')`).
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pushNamed(Routes.productsScreen),
              child: const Text('Browse Products'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only search bar that opens the products screen, where the live
/// search field takes over (PRD §2). Styled after the products screen's
/// search field so the hand-off feels continuous.
class _SearchShortcut extends StatelessWidget {
  const _SearchShortcut({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: ColorsManager.lightGray),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: ColorsManager.gray),
            SizedBox(width: 8.w),
            // Expanded: a bare Text inside a Row gets unbounded width and
            // never wraps, overflowing instead.
            Expanded(
              child: Text(
                'Search products by name...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.font14GrayRegular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category chips straight from the live catalog (same keys the products
/// screen filters by); tapping one opens the products screen.
class _CategoryShortcuts extends StatelessWidget {
  const _CategoryShortcuts({required this.categories, required this.onSelected});

  final List<String> categories;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            onTap: () => onSelected(category),
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: ColorsManager.lightGray),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyles.font13GrayRegular,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedLoading extends StatelessWidget {
  const _FeaturedLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210.h,
      child: const Center(
        child: CircularProgressIndicator(color: ColorsManager.mainGreen),
      ),
    );
  }
}
