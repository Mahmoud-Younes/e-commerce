import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../data/models/product_doc.dart';
import '../../logic/cubit/products_cubit.dart';
import '../../logic/cubit/products_state.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/product_card.dart';

/// Catalog screen (PRD §2): all products as cards (image, name, price),
/// search by name and browse by category, composed together. The router wraps
/// this screen in a `BlocProvider<ProductsCubit>` (created via `get_it`).
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products', style: TextStyles.font18DarkGreenBold),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
            child: _SearchField(
              onChanged: (query) => context.read<ProductsCubit>().search(query),
            ),
          ),
          verticalSpace(8),
          BlocBuilder<ProductsCubit, ProductsState>(
            buildWhen: (previous, current) =>
                current is ProductsLoaded || current is ProductsEmpty,
            builder: (context, state) {
              final chips = state.maybeWhen(
                productsLoaded: (products, categories, _, _) => categories,
                productsEmpty: (categories, _, _) => categories,
                orElse: () => const <String>[],
              );
              final selected = state.maybeWhen(
                productsLoaded: (_, _, selectedCategory, _) => selectedCategory,
                productsEmpty: (_, selectedCategory, _) => selectedCategory,
                orElse: () => null,
              );
              if (chips.isEmpty && selected == null) {
                return const SizedBox.shrink();
              }
              return CategoryFilterChips(
                categories: chips,
                selectedCategory: selected,
                onSelected: (category) =>
                    context.read<ProductsCubit>().selectCategory(category),
              );
            },
          ),
          verticalSpace(8),
          Expanded(
            child: BlocBuilder<ProductsCubit, ProductsState>(
              // freezed-4 unions are consumed as extension methods (.when /
              // .maybeWhen) — the generated union classes are not sealed, so
              // exhaustive switch expressions are not available on them.
              builder: (context, state) => state.maybeWhen(
                // `initial` (pre-first-emission) and `productsLoading` (retry)
                // both show the spinner (PRD §9 clear loading state).
                initial: () => const Center(
                  child: CircularProgressIndicator(
                    color: ColorsManager.mainGreen,
                  ),
                ),
                productsLoading: () => const Center(
                  child: CircularProgressIndicator(
                    color: ColorsManager.mainGreen,
                  ),
                ),
                productsLoaded: (products, _, _, _) =>
                    ProductsGrid(products: products),
                productsEmpty: (categories, selectedCategory, searchQuery) =>
                    _EmptyView(
                  searchQuery: searchQuery,
                  selectedCategory: selectedCategory,
                ),
                productsError: (apiErrorModel) => _ErrorView(
                  message: apiErrorModel.message ?? 'Something went wrong.',
                  onRetry: () => context.read<ProductsCubit>().refresh(),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Search bar (PRD §2: search for products by name). A plain [TextField] is
/// used because `AppTextFormField` (a validator-first widget) has no
/// `onChanged` API and `lib/core/widgets` is shared with parallel agents.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search products by name...',
        prefixIcon: const Icon(Icons.search, color: ColorsManager.gray),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: ColorsManager.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(
            color: ColorsManager.mainGreen,
            width: 1.3,
          ),
        ),
      ),
    );
  }
}

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({super.key, required this.products});

  final List<ProductDoc> products;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) =>
          ProductCard(productDoc: products[index]),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.searchQuery, required this.selectedCategory});

  final String searchQuery;
  final String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final message = searchQuery.trim().isNotEmpty
        ? 'No products match "${searchQuery.trim()}".'
        : selectedCategory != null
        ? 'No products in "$selectedCategory" yet.'
        : 'No products available yet.';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined,
              size: 48.r, color: ColorsManager.gray),
          verticalSpace(12),
          Text(message, style: TextStyles.font14GrayRegular),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.r, color: ColorsManager.red),
          verticalSpace(12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyles.font14GrayRegular,
            ),
          ),
          verticalSpace(12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, color: ColorsManager.mainGreen),
            label: Text(
              'Retry',
              style: TextStyles.font13GreenSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}
