import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/helpers/extensions.dart';
import '../../../../core/helpers/product_localized_text.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../data/repos/admin_products_source.dart';
import '../../logic/cubit/admin_products_cubit.dart';
import '../../logic/cubit/admin_products_state.dart';

/// Admin product create/edit form (PRD §2, §5). Create mode when pushed
/// without arguments; edit mode when pushed with an [AdminProductEntry]
/// (document ID + product) — the ID is what the update path addresses,
/// [ProductModel] deliberately carries none.
///
/// Route: `adminProductFormScreen` → `/adminProductFormScreen`. The router
/// pushes this screen WITHOUT a BlocProvider (see `app_router.dart`), so the
/// screen provides its own [AdminProductsCubit] (a get_it factory) and
/// [BlocProvider] disposes it on pop.
///
/// Bilingual contract: the Arabic name/description are OPTIONAL inputs;
/// there is NO free-text Arabic category field — `categoryAr` is derived
/// from the selected canonical category via [kCategoryArLabels] at save
/// time (in [AdminProductsCubit.submitProduct]).
class AdminProductFormScreen extends StatelessWidget {
  const AdminProductFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminProductsCubit>(),
      child: const _AdminProductFormBody(),
    );
  }
}

class _AdminProductFormBody extends StatefulWidget {
  const _AdminProductFormBody();

  @override
  State<_AdminProductFormBody> createState() => _AdminProductFormBodyState();
}

class _AdminProductFormBodyState extends State<_AdminProductFormBody> {
  bool _initialized = false;

  /// Category dropdown value — kept as local UI state (mirrored into the
  /// cubit's `categoryController`) because the cubit only holds
  /// non-emitting controller state for the form.
  String? _selectedCategory;

  bool _isAvailable = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final cubit = context.read<AdminProductsCubit>();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is AdminProductEntry) {
      cubit.startEditing(arguments.product, productId: arguments.productId);
      _selectedCategory = arguments.product.category.isEmpty
          ? null
          : arguments.product.category;
      _isAvailable = arguments.product.isAvailable;
    } else {
      cubit.resetForm();
      _selectedCategory = null;
      _isAvailable = true;
    }
  }

  void _save() {
    final cubit = context.read<AdminProductsCubit>();
    final valid = cubit.formKey.currentState?.validate() ?? false;
    if (!valid) return;
    cubit.submitProduct(
      product: ProductModel(
        name: cubit.nameController.text,
        description: cubit.descriptionController.text,
        price: double.tryParse(cubit.priceController.text.trim()) ?? 0,
        imageUrl: cubit.imageUrlController.text.trim(),
        category: _selectedCategory ?? '',
        stock: int.tryParse(cubit.stockController.text.trim()) ?? -1,
        isAvailable: _isAvailable,
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AdminProductsCubit>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Form', style: TextStyles.font18DarkGreenBold),
        centerTitle: true,
      ),
      body: BlocListener<AdminProductsCubit, AdminProductsState>(
        listenWhen: (previous, current) =>
            current is AdminProductSubmitSuccess ||
            current is AdminProductSubmitError ||
            current is AdminProductsWriteUnauthorized,
        listener: (context, state) {
          state.whenOrNull(
            submitSuccess: (message) {
              // Root-scoped messenger: the snackbar survives the pop.
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: ColorsManager.mainGreen,
                  ),
                );
              context.pop();
            },
            submitError: (error) =>
                _showSnackBar(context, error.message ?? 'Save failed.'),
            writeUnauthorized: (error) =>
                _showSnackBar(context, error.message ?? 'Not allowed.'),
          );
        },
        child: SafeArea(
          child: Form(
            key: cubit.formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextFormField(
                    controller: cubit.nameController,
                    hintText: 'Product name (English)',
                    validator: (value) =>
                        (value?.trim().length ?? 0) < 2
                            ? 'Product name must be at least 2 characters.'
                            : null,
                  ),
                  verticalSpace(12),
                  AppTextFormField(
                    key: const Key('adminFieldNameAr'),
                    controller: cubit.nameArController,
                    hintText: 'Product name (Arabic) — optional',
                    validator: _arabicNameValidator,
                  ),
                  verticalSpace(12),
                  AppTextFormField(
                    controller: cubit.descriptionController,
                    hintText: 'Description (English)',
                    maxLines: 3,
                  ),
                  verticalSpace(12),
                  AppTextFormField(
                    key: const Key('adminFieldDescriptionAr'),
                    controller: cubit.descriptionArController,
                    hintText: 'Description (Arabic) — optional',
                    maxLines: 3,
                  ),
                  verticalSpace(12),
                  AppTextFormField(
                    controller: cubit.priceController,
                    hintText: 'Price (EGP)',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) =>
                        (double.tryParse(value?.trim() ?? '') ?? 0) <= 0
                            ? 'Price must be greater than 0.'
                            : null,
                  ),
                  verticalSpace(12),
                  _CategoryDropdown(
                    selectedCategory: _selectedCategory,
                    currentCategory: cubit.categoryController.text,
                    onChanged: (category) {
                      setState(() => _selectedCategory = category);
                      cubit.categoryController.text = category ?? '';
                    },
                  ),
                  verticalSpace(12),
                  AppTextFormField(
                    controller: cubit.stockController,
                    hintText: 'Stock',
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        (int.tryParse(value?.trim() ?? '') ?? -1) < 0
                            ? 'Stock cannot be negative.'
                            : null,
                  ),
                  verticalSpace(12),
                  AppTextFormField(
                    controller: cubit.imageUrlController,
                    hintText: 'Image URL (optional)',
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      final url = value?.trim() ?? '';
                      if (url.isNotEmpty && !url.startsWith('http')) {
                        return 'Image URL must start with http(s):// or be '
                            'left empty.';
                      }
                      return null;
                    },
                  ),
                  verticalSpace(8),
                  SwitchListTile(
                    value: _isAvailable,
                    onChanged: (value) {
                      setState(() => _isAvailable = value);
                      cubit.setIsAvailable(value);
                    },
                    activeThumbColor: ColorsManager.mainGreen,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Available for sale',
                      style: TextStyles.font14DarkGrayRegular,
                    ),
                  ),
                  verticalSpace(16),
                  BlocBuilder<AdminProductsCubit, AdminProductsState>(
                    buildWhen: (previous, current) =>
                        current is AdminProductSubmitLoading ||
                        previous is AdminProductSubmitLoading,
                    builder: (context, state) => AppButton(
                      text: 'Save Product',
                      isLoading: state is AdminProductSubmitLoading,
                      onPressed: _save,
                    ),
                  ),
                  verticalSpace(24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Optional Arabic field: only a NON-EMPTY value is validated (mirrors
  /// [AdminProductsCubit.validateProduct]).
  String? _arabicNameValidator(String? value) {
    final nameAr = value?.trim() ?? '';
    if (nameAr.isNotEmpty && nameAr.length < 2) {
      return 'Arabic product name must be at least 2 characters.';
    }
    return null;
  }
}

/// Category selector over the CANONICAL categories ([kCategoryArLabels]
/// keys) — free-text categories cannot derive an Arabic label. A legacy
/// product edited with a category outside the map keeps its raw key as an
/// extra dropdown item (its Arabic label falls back to the key).
class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.selectedCategory,
    required this.currentCategory,
    required this.onChanged,
  });

  final String? selectedCategory;
  final String currentCategory;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final canonical = kCategoryArLabels.keys.toSet();
    final items = <String>{
      ...canonical,
      if (currentCategory.trim().isNotEmpty) currentCategory.trim(),
    }.toList()
      ..sort();

    return DropdownButtonFormField<String>(
      initialValue: selectedCategory,
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        filled: true,
        fillColor: ColorsManager.white,
        hintText: 'Category',
        hintStyle: TextStyles.font14GrayRegular,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(
            color: ColorsManager.lightGray,
            width: 1.3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(
            color: ColorsManager.mainGreen,
            width: 1.3,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: ColorsManager.red, width: 1.3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: ColorsManager.red, width: 1.3),
        ),
      ),
      hint: Text('Category', style: TextStyles.font14GrayRegular),
      items: items
          .map(
            (category) => DropdownMenuItem<String>(
              value: category,
              child: Text(category, style: TextStyles.font14DarkGrayRegular),
            ),
          )
          .toList(),
      validator: (value) =>
          (value == null || value.trim().isEmpty) ? 'Category is required.' : null,
      onChanged: onChanged,
    );
  }
}
