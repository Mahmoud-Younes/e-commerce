// `flutter_bloc` re-exports `package:bloc/bloc.dart` (Cubit lives there), so
// the direct `bloc` import (not a declared dependency) is avoided.
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/networking/api_result.dart';
import '../../../../core/repositories/product_repository.dart';
import 'product_details_state.dart';

/// Product-details cubit (PRD §2): fetches one product by document ID through
/// [ProductRepository.getById]. The document ID comes from the route
/// arguments; the favorites/cart buttons on the details screen use it too.
class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this._productRepository)
    : super(const ProductDetailsState.initial());

  final ProductRepository _productRepository;

  Future<void> loadProduct(String productId) async {
    emit(const ProductDetailsState.detailsLoading());
    final response = await _productRepository.getById(productId);
    response.when(
      success: (product) =>
          emit(ProductDetailsState.detailsLoaded(product)),
      failure: (apiErrorModel) =>
          emit(ProductDetailsState.detailsError(apiErrorModel)),
    );
  }
}
