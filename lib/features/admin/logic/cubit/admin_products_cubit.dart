import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/product_localized_text.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/repositories/product_repository.dart';
import '../../data/repos/admin_products_source.dart';
import '../../data/repos/admin_role_guard.dart';
import '../../data/upload/admin_image_uploader.dart';
import 'admin_products_state.dart';

/// Admin product management (PRD §2 create/edit/delete + §5 dashboard).
///
/// get_it registration (merge agent applies it in
/// `lib/core/di/dependency_injection.dart`, AGENT C banner):
/// ```dart
/// getIt.registerFactory<AdminProductsCubit>(() => AdminProductsCubit(
///       getIt<ProductRepository>(),
///       getIt<AdminRoleGuard>(),
///       getIt<AdminImageUploader>(),
///       getIt<AdminProductsSource>(),
///     ));
/// ```
///
/// Route names this feature documents for the router (merge agent):
/// - `adminProducts`      → `/adminProducts`   → AdminProductsScreen
/// - (existing) `/adminProductFormScreen` → AdminProductFormScreen with
///   `settings.arguments as AdminProductEntry?` (null = create mode; the
///   entry carries the document ID the update path needs, which
///   [ProductModel] deliberately does not).
///
/// Write safety: EVERY write (create/update/delete) first asks
/// [AdminRoleGuard.ensureAdmin]; a non-admin gets
/// [AdminProductsState.writeUnauthorized] and the repository is never called.
class AdminProductsCubit extends Cubit<AdminProductsState> {
  AdminProductsCubit(
    this._productRepository,
    this._roleGuard,
    this._imageUploader,
    this._productsSource,
  ) : super(const AdminProductsState.initial());

  final ProductRepository _productRepository;
  final AdminRoleGuard _roleGuard;
  final AdminImageUploader _imageUploader;
  final AdminProductsSource _productsSource;

  StreamSubscription<List<AdminProductEntry>>? _catalogSubscription;

  /// Document ID of the product being edited (null in create mode). Set by
  /// [startEditing] when the form screen passes an [AdminProductEntry].
  String? _editingProductId;

  // Product form controllers + key (same pattern as LoginCubit/ProfileCubit).
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nameArController = TextEditingController();
  final descriptionController = TextEditingController();
  final descriptionArController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();
  final stockController = TextEditingController();
  final imageUrlController = TextEditingController();
  bool isAvailable = true;

  void setIsAvailable(bool value) => isAvailable = value;

  /// Realtime catalog for the dashboard list (with document IDs so edit and
  /// delete can address the right product).
  void loadProducts() {
    emit(const AdminProductsState.productsLoading());
    _catalogSubscription?.cancel();
    _catalogSubscription = _productsSource.streamAllWithIds().listen(
          (entries) =>
              emit(AdminProductsState.productsSuccess(entries)),
          onError: (Object error) => emit(
            AdminProductsState.productsError(ApiErrorHandler.handle(error)),
          ),
        );
  }

  /// Prefills the form for edit mode; call with null for create mode. The
  /// Arabic fields (nameAr/descriptionAr) prefill from the product's stored
  /// Arabic variants — empty when absent. [productId] records which document
  /// an update addresses (ProductModel carries no id field).
  void startEditing(ProductModel product, {String? productId}) {
    _editingProductId = productId;
    nameController.text = product.name;
    nameArController.text = product.nameAr ?? '';
    descriptionController.text = product.description;
    descriptionArController.text = product.descriptionAr ?? '';
    priceController.text = product.price == 0 ? '' : product.price.toString();
    categoryController.text = product.category;
    stockController.text = product.stock.toString();
    imageUrlController.text = product.imageUrl;
    isAvailable = product.isAvailable;
  }

  void resetForm() {
    _editingProductId = null;
    nameController.clear();
    nameArController.clear();
    descriptionController.clear();
    descriptionArController.clear();
    priceController.clear();
    categoryController.clear();
    stockController.clear();
    imageUrlController.clear();
    isAvailable = true;
  }

  /// Field-level validation mirrored in the form's validators. Returns the
  /// error message, or null when the payload is valid (PRD §2: name,
  /// description, price, imageUrl, category, stock, availability).
  ///
  /// The Arabic fields are OPTIONAL (bilingual contract): empty values are
  /// never validated; only a non-empty `nameAr` must satisfy the same
  /// minimum-length rule as the English name.
  String? validateProduct(ProductModel product) {
    if (product.name.trim().length < 2) {
      return 'Product name must be at least 2 characters.';
    }
    final nameAr = product.nameAr?.trim() ?? '';
    if (nameAr.isNotEmpty && nameAr.length < 2) {
      return 'Arabic product name must be at least 2 characters.';
    }
    if (product.price <= 0) {
      return 'Price must be greater than 0.';
    }
    if (product.category.trim().isEmpty) {
      return 'Category is required.';
    }
    if (product.stock < 0) {
      return 'Stock cannot be negative.';
    }
    final url = product.imageUrl.trim();
    if (url.isNotEmpty && !url.startsWith('http')) {
      return 'Image URL must start with http(s):// or be left empty.';
    }
    return null;
  }

  /// Create or update a product. The English fields come in via [product]
  /// (built by the form from its controllers); the optional Arabic fields
  /// always come from this cubit's own controllers:
  /// - `nameAr` / `descriptionAr`: saved when non-empty (trimmed), `null`
  ///   otherwise — a cleared field also clears on Firestore `update()`
  ///   (toJson serializes the explicit null);
  /// - `categoryAr`: never a free-text input — derived from the selected
  ///   canonical category via [kCategoryArLabels] at save time (`null` when
  ///   the category has no Arabic label).
  ///
  /// When [imageBytes] is provided the image is uploaded through
  /// [AdminImageUploader] — which refuses placeholder Supabase config, so
  /// the manual [ProductModel.imageUrl] field stays the fallback (TODO for
  /// the owner, see [AdminImageUploader]).
  ///
  /// [existingProductId] addresses the update; when omitted, the ID recorded
  /// by [startEditing] is used (form edit mode).
  Future<void> submitProduct({
    required ProductModel product,
    String? existingProductId,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    // Merge the optional Arabic fields BEFORE validating so the non-empty
    // `nameAr` rule applies to the same payload that gets written.
    final payload = ProductModel(
      name: product.name,
      nameAr: _optionalArabic(nameArController.text),
      description: product.description,
      descriptionAr: _optionalArabic(descriptionArController.text),
      price: product.price,
      imageUrl: product.imageUrl,
      category: product.category,
      categoryAr: categoryArLabel(product.category),
      stock: product.stock,
      isAvailable: product.isAvailable,
    );

    final validationError = validateProduct(payload);
    if (validationError != null) {
      emit(AdminProductsState.submitError(
        ApiErrorModel(message: validationError),
      ));
      return;
    }

    emit(const AdminProductsState.submitLoading());

    // Role gate BEFORE any write (PRD §5).
    final denied = await _guardDenial();
    if (denied != null) {
      emit(AdminProductsState.writeUnauthorized(denied));
      return;
    }

    var imageUrl = payload.imageUrl.trim();
    if (imageBytes != null) {
      final upload = await _imageUploader.upload(
        bytes: imageBytes,
        fileName: imageFileName ?? 'product.png',
      );
      var uploadedUrl = '';
      var uploadFailed = false;
      upload.whenOrNull(
        success: (url) => uploadedUrl = url,
        failure: (apiErrorModel) {
          uploadFailed = true;
          emit(AdminProductsState.submitError(apiErrorModel));
        },
      );
      if (uploadFailed) return;
      imageUrl = uploadedUrl;
    }

    final savedProduct = payload.copyWith(imageUrl: imageUrl);
    final updateId = existingProductId ?? _editingProductId;
    if (updateId == null) {
      final response = await _productRepository.create(savedProduct);
      response.when(
        success: (_) => _emitSubmitSuccess(),
        failure: (apiErrorModel) =>
            emit(AdminProductsState.submitError(apiErrorModel)),
      );
    } else {
      final response = await _productsSource.update(updateId, savedProduct);
      response.when(
        success: (_) => _emitSubmitSuccess(),
        failure: (apiErrorModel) =>
            emit(AdminProductsState.submitError(apiErrorModel)),
      );
    }
  }

  /// Arabic form values are optional: trimmed text, or `null` when empty.
  String? _optionalArabic(String raw) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _emitSubmitSuccess() {
    resetForm();
    emit(const AdminProductsState.submitSuccess('Product saved.'));
  }

  /// Runs the admin role guard; returns the failure model to surface (or
  /// null when the signed-in user is an admin and writes may proceed).
  Future<ApiErrorModel?> _guardDenial() async {
    final guard = await _roleGuard.ensureAdmin();
    ApiErrorModel? denial;
    guard.whenOrNull(
      failure: (apiErrorModel) => denial = apiErrorModel,
    );
    return denial;
  }

  /// Delete after the UI's confirmation dialog. Role-gated like every write.
  Future<void> deleteProduct(String productId) async {
    emit(const AdminProductsState.deleteLoading());

    final denied = await _guardDenial();
    if (denied != null) {
      emit(AdminProductsState.writeUnauthorized(denied));
      return;
    }

    final response = await _productRepository.delete(productId);
    response.when(
      success: (_) =>
          emit(const AdminProductsState.deleteSuccess('Product deleted.')),
      failure: (apiErrorModel) =>
          emit(AdminProductsState.deleteError(apiErrorModel)),
    );
  }

  @override
  Future<void> close() {
    _catalogSubscription?.cancel();
    nameController.dispose();
    nameArController.dispose();
    descriptionController.dispose();
    descriptionArController.dispose();
    priceController.dispose();
    categoryController.dispose();
    stockController.dispose();
    imageUrlController.dispose();
    return super.close();
  }
}
