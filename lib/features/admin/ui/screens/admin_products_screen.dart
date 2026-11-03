import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/extensions.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/styles.dart';
import '../../data/repos/admin_products_source.dart';
import '../../logic/cubit/admin_products_cubit.dart';
import '../../logic/cubit/admin_products_state.dart';

/// Admin product list (PRD §5: view/add/edit/delete products).
///
/// Route: `adminProducts` → `/adminProducts` (merge agent wires
/// [AdminProductsCubit] via get_it, see `../admin_routes.dart`).
class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminProductsCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products', style: TextStyles.font18DarkGreenBold),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(
          Routes.adminProductFormScreen,
          // No arguments = create mode (ProductModel? contract).
        ),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<AdminProductsCubit, AdminProductsState>(
        listenWhen: (previous, current) =>
            current is AdminProductDeleteSuccess ||
            current is AdminProductDeleteError ||
            current is AdminProductSubmitError ||
            current is AdminProductsWriteUnauthorized,
        listener: (context, state) {
          state.whenOrNull(
            deleteSuccess: (message) => _showSnackBar(context, message),
            deleteError: (error) =>
                _showSnackBar(context, error.message ?? 'Delete failed.'),
            submitError: (error) =>
                _showSnackBar(context, error.message ?? 'Save failed.'),
            writeUnauthorized: (error) =>
                _showSnackBar(context, error.message ?? 'Not allowed.'),
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            productsLoading: () =>
                const Center(child: CircularProgressIndicator()),
            productsError: (error) => _ErrorView(
              message: error.message ?? 'Could not load products.',
              onRetry: () => context.read<AdminProductsCubit>().loadProducts(),
            ),
            productsSuccess: (entries) => entries.isEmpty
                ? Center(
                    child: Text(
                      'No products yet. Tap + to add the first one.',
                      style: TextStyles.font14GrayRegular,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async =>
                        context.read<AdminProductsCubit>().loadProducts(),
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      itemCount: entries.length,
                      separatorBuilder: (_, _) => verticalSpace(8),
                      itemBuilder: (context, index) => _ProductTile(
                        entry: entries[index],
                        onEdit: () => context.pushNamed(
                          Routes.adminProductFormScreen,
                          arguments: entries[index].product,
                        ),
                        onDelete: () => _confirmDelete(context, entries[index]),
                      ),
                    ),
                  ),
            submitLoading: () => _listOrSpinner(state),
            submitSuccess: (_) => _listOrSpinner(state),
            submitError: (_) => _listOrSpinner(state),
            deleteLoading: () => _listOrSpinner(state),
            deleteSuccess: (_) => _listOrSpinner(state),
            deleteError: (_) => _listOrSpinner(state),
            writeUnauthorized: (_) => _listOrSpinner(state),
          );
        },
      ),
    );
  }

  /// Write states keep the list on screen (the stream refreshes it) — only
  /// the first frame before the first snapshot shows a bare view.
  Widget _listOrSpinner(AdminProductsState state) {
    return state.maybeWhen(
      productsSuccess: (entries) => entries.isEmpty
          ? const SizedBox.shrink()
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) =>
                  _ProductTile(entry: entries[index]),
            ),
      orElse: () => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Delete confirmation (PRD §5 destructive action) before
  /// [AdminProductsCubit.deleteProduct].
  void _confirmDelete(BuildContext context, AdminProductEntry entry) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
          '"${entry.product.name}" will be permanently removed from the '
          'catalog.',
          style: TextStyles.font14DarkGrayRegular,
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text('Cancel', style: TextStyles.font13GrayRegular),
          ),
          TextButton(
            onPressed: () {
              dialogContext.pop();
              context.read<AdminProductsCubit>().deleteProduct(entry.productId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.entry, this.onEdit, this.onDelete});

  final AdminProductEntry entry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final product = entry.product;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: Color(0xFFEDEDED)),
      ),
      child: ListTile(
        leading: const Icon(Icons.image_outlined, color: Color(0xFF757575)),
        title: Text(
          product.name,
          style: TextStyles.font14DarkGrayRegular.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${product.category} • \$${product.price.toStringAsFixed(2)} • '
          'stock ${product.stock}'
          '${product.isAvailable ? '' : ' • unavailable'}',
          style: TextStyles.font13GrayRegular,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFD32F2F)),
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ),
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
          Text(message, style: TextStyles.font14DarkGrayRegular),
          verticalSpace(12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
