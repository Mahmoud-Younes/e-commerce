import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/core/repositories/product_repository.dart';
import 'package:e_commerce_app/features/products/logic/cubit/product_details_cubit.dart';
import 'package:e_commerce_app/features/products/logic/cubit/product_details_state.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repo;

  setUp(() {
    repo = MockProductRepository();
  });

  blocTest<ProductDetailsCubit, ProductDetailsState>(
    'emits loading then loaded when getById succeeds',
    build: () {
      when(() => repo.getById('p1')).thenAnswer(
        (_) async => ApiResult.success(
          const ProductModel(
            name: 'Shoes',
            description: 'Nice shoes',
            price: 99.5,
            category: 'Fashion',
            stock: 5,
          ),
        ),
      );
      return ProductDetailsCubit(repo);
    },
    act: (cubit) => cubit.loadProduct('p1'),
    expect: () => [
      isA<ProductDetailsLoading>(),
      isA<ProductDetailsLoaded>().having(
        (state) => state.product.name,
        'product name',
        'Shoes',
      ),
    ],
  );

  blocTest<ProductDetailsCubit, ProductDetailsState>(
    'emits loading then error when getById fails',
    build: () {
      when(() => repo.getById('missing')).thenAnswer(
        (_) async => ApiResult.failure(
          const ApiErrorModel(message: 'Product not found.'),
        ),
      );
      return ProductDetailsCubit(repo);
    },
    act: (cubit) => cubit.loadProduct('missing'),
    expect: () => [
      isA<ProductDetailsLoading>(),
      isA<ProductDetailsError>().having(
        (state) => state.apiErrorModel.message,
        'error message',
        'Product not found.',
      ),
    ],
  );
}



