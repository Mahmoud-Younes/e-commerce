import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/product_model.dart';
import '../../../../core/networking/api_error_model.dart';

part 'product_details_state.freezed.dart';

/// Product-details states (PRD §2: show images, name, description, price,
/// category, available stock).
@freezed
class ProductDetailsState with _$ProductDetailsState {
  const factory ProductDetailsState.initial() = ProductDetailsInitial;

  const factory ProductDetailsState.detailsLoading() = ProductDetailsLoading;

  const factory ProductDetailsState.detailsLoaded(ProductModel product) =
      ProductDetailsLoaded;

  const factory ProductDetailsState.detailsError(ApiErrorModel apiErrorModel) =
      ProductDetailsError;
}
