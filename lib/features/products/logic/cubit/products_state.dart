import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/networking/api_error_model.dart';
import '../../data/models/product_doc.dart';

part 'products_state.freezed.dart';

/// Catalog states (PRD §2): loading / loaded / empty / error, with the active
/// filters echoed back so the UI can highlight the selected chip and search
/// field.
@freezed
class ProductsState with _$ProductsState {
  const factory ProductsState.initial() = ProductsInitial;

  const factory ProductsState.productsLoading() = ProductsLoading;

  const factory ProductsState.productsLoaded({
    required List<ProductDoc> products,
    /// Distinct categories across the whole catalog (chips stay complete
    /// while one category is selected).
    required List<String> categories,
    String? selectedCategory,
    @Default('') String searchQuery,
  }) = ProductsLoaded;

  const factory ProductsState.productsEmpty({
    required List<String> categories,
    String? selectedCategory,
    @Default('') String searchQuery,
  }) = ProductsEmpty;

  const factory ProductsState.productsError(ApiErrorModel apiErrorModel) =
      ProductsError;
}
