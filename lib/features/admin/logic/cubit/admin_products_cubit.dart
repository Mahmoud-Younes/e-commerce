import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
///   `settings.arguments as ProductModel?` (null = create mode).
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

  // Product form controllers + key (same pattern as LoginCubit/ProfileCubit).
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
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

  /// Prefills the form for edit mode; call with null for create mode.
  void startEditing(ProductModel product) {
    nameController.text = product.name;
    descriptionController.text = product.description;
    priceController.text = product.price == 0 ? '' : product.price.toString();
    categoryController.text = product.category;
    stockController.text = product.stock.toString();
    imageUrlController.text = product.imageUrl;
    isAvailable = product.isAvailable;
  }

  void resetForm() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    categoryController.clear();
    stockController.clear();
    imageUrlController.clear();
    isAvailable = true;
  }

  /// Field-level validation mirrored in the form's validators. Returns the
  /// error message, or null when the payload is valid (PRD §2: name,
  /// description, price, imageUrl, category, stock, availability).
  String? validateProduct(ProductModel product) {
    if (product.name.trim().length < 2) {
      return 'Product name must be at least 2 characters.';
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

  /// Create ([existingProductId] == null) or update a product. When
  /// [imageBytes] is provided the image is uploaded through
  /// [AdminImageUploader] — which refuses placeholder Supabase config, so
  /// the manual [ProductModel.imageUrl] field stays the fallback (TODO for
  /// the owner, see [AdminImageUploader]).
  Future<void> submitProduct({
    required ProductModel product,
    String? existingProductId,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    final validationError = validateProduct(product);
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

    var imageUrl = product.imageUrl.trim();
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

    final payload = product.copyWith(imageUrl: imageUrl);
    if (existingProductId == null) {
      final response = await _productRepository.create(payload);
      response.when(
        success: (_) => _emitSubmitSuccess(),
        failure: (apiErrorModel) =>
            emit(AdminProductsState.submitError(apiErrorModel)),
      );
    } else {
      final response =
          await _productsSource.update(existingProductId, payload);
      response.when(
        success: (_) => _emitSubmitSuccess(),
        failure: (apiErrorModel) =>
            emit(AdminProductsState.submitError(apiErrorModel)),
      );
    }
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
    descriptionController.dispose();
    priceController.dispose();
    categoryController.dispose();
    stockController.dispose();
    imageUrlController.dispose();
    return super.close();
  }
}
