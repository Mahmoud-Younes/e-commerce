import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/core/repositories/product_repository.dart';
import 'package:e_commerce_app/features/admin/data/repos/admin_products_source.dart';
import 'package:e_commerce_app/features/admin/data/upload/admin_image_uploader.dart';
import 'package:e_commerce_app/features/admin/logic/cubit/admin_products_cubit.dart';
import 'package:e_commerce_app/features/admin/logic/cubit/admin_products_state.dart';
import 'package:e_commerce_app/features/admin/data/repos/admin_role_guard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockProductRepository extends Mock implements ProductRepository {}

class _MockAdminRoleGuard extends Mock implements AdminRoleGuard {}

class _MockAdminImageUploader extends Mock implements AdminImageUploader {}

class _MockAdminProductsSource extends Mock implements AdminProductsSource {}

void main() {
  late _MockProductRepository productRepository;
  late _MockAdminRoleGuard roleGuard;
  late _MockAdminImageUploader imageUploader;
  late _MockAdminProductsSource productsSource;
  late StreamController<List<AdminProductEntry>> catalogController;

  final product = const ProductModel(
    name: 'Running Shoes',
    description: 'Comfortable shoes',
    price: 99.5,
    category: 'Fashion',
    stock: 5,
  );

  setUpAll(() {
    // mocktail needs fallback values for every custom type used with any().
    registerFallbackValue(const ProductModel(name: 'fallback'));
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    productRepository = _MockProductRepository();
    roleGuard = _MockAdminRoleGuard();
    imageUploader = _MockAdminImageUploader();
    productsSource = _MockAdminProductsSource();
    catalogController = StreamController<List<AdminProductEntry>>();
    // Admin by default — the "not admin" group overrides this.
    when(() => roleGuard.ensureAdmin())
        .thenAnswer((_) async => const ApiResult.success(null));
  });

  tearDown(() async {
    catalogController.close();
  });

  AdminProductsCubit buildCubit() => AdminProductsCubit(
    productRepository,
    roleGuard,
    imageUploader,
    productsSource,
  );

  group('AdminProductsCubit.loadProducts (dashboard catalog stream)', () {
    blocTest<AdminProductsCubit, AdminProductsState>(
      'emits [productsLoading, productsSuccess] when the stream yields entries',
      build: () {
        when(() => productsSource.streamAllWithIds())
            .thenAnswer((_) => catalogController.stream);
        return buildCubit();
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => <dynamic>[
        const AdminProductsState.productsLoading(),
        predicate<AdminProductsState>((state) {
          final success = state as AdminProductsSuccess;
          return success.entries.single.productId == 'p-1' &&
              success.entries.single.product.name == 'Running Shoes';
        }, 'productsSuccess carrying the entry with its document ID'),
      ],
    );

    blocTest<AdminProductsCubit, AdminProductsState>(
      'emits [productsLoading, productsError] when the stream fails',
      build: () {
        when(() => productsSource.streamAllWithIds())
            .thenAnswer((_) => Stream.error(Exception('firestore down')));
        return buildCubit();
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => <dynamic>[
        const AdminProductsState.productsLoading(),
        isA<AdminProductsError>(),
      ],
    );
  });

  group('AdminProductsCubit.validateProduct (PRD §2 payload fields)', () {
    test('accepts a complete valid product', () {
      expect(buildCubit().validateProduct(product), isNull);
    });

    test('rejects a too-short name', () {
      expect(
        buildCubit().validateProduct(
          const ProductModel(name: ' A ', price: 10, category: 'Fashion'),
        ),
        contains('name'),
      );
    });

    test('rejects a non-positive price', () {
      expect(
        buildCubit().validateProduct(
          const ProductModel(name: 'Shoes', price: 0),
        ),
        contains('Price'),
      );
    });

    test('rejects an empty category', () {
      expect(
        buildCubit().validateProduct(
          const ProductModel(name: 'Shoes', price: 10),
        ),
        contains('Category'),
      );
    });

    test('rejects a non-http image URL', () {
      expect(
        buildCubit().validateProduct(
          const ProductModel(
            name: 'Shoes',
            price: 10,
            category: 'Fashion',
            imageUrl: 'ftp://example.com/x.png',
          ),
        ),
        contains('Image URL'),
      );
    });
  });

  group('AdminProductsCubit.submitProduct — create (PRD §2, §5)', () {
    blocTest<AdminProductsCubit, AdminProductsState>(
      'emits [submitLoading, submitSuccess] and calls repository.create '
      'for an admin with a valid product',
      build: () {
        when(() => productRepository.create(any()))
            .thenAnswer((_) async => ApiResult.success(product));
        return buildCubit();
      },
      act: (cubit) => cubit.submitProduct(product: product),
      verify: (_) {
        final captured = verify(() => productRepository.create(captureAny()))
            .captured;
        expect(captured.single as ProductModel, product);
      },
      expect: () => <dynamic>[
        const AdminProductsState.submitLoading(),
        const AdminProductsState.submitSuccess('Product saved.'),
      ],
    );

    blocTest<AdminProductsCubit, AdminProductsState>(
      'emits submitError without touching the repository for an invalid '
      'payload (validation happens before the role gate)',
      build: () {
        when(() => roleGuard.ensureAdmin()).thenAnswer(
          (_) async => const ApiResult.failure(
            ApiErrorModel(message: 'Only admins can perform this action.'),
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.submitProduct(
        product: const ProductModel(name: 'X', price: 0, category: ''),
      ),
      verify: (_) {
        verifyNever(() => productRepository.create(any()));
        verifyNever(() => roleGuard.ensureAdmin());
      },
      expect: () => <dynamic>[
        predicate<AdminProductSubmitError>(
          (state) => state.apiErrorModel.message!.contains('name'),
          'submitError with the name validation message',
        ),
      ],
    );

    blocTest<AdminProductsCubit, AdminProductsState>(
      'routes an update through AdminProductsSource.update when '
      'existingProductId is given',
      build: () {
        when(() => productsSource.update(any(), any()))
            .thenAnswer((_) async => const ApiResult.success(null));
        return buildCubit();
      },
      act: (cubit) =>
          cubit.submitProduct(product: product, existingProductId: 'p-9'),
      verify: (_) {
        final captured = verify(
          () => productsSource.update(captureAny(), captureAny()),
        ).captured;
        expect(captured[0], 'p-9');
        expect(captured[1] as ProductModel, product);
        verifyNever(() => productRepository.create(any()));
      },
      expect: () => <dynamic>[
        const AdminProductsState.submitLoading(),
        const AdminProductsState.submitSuccess('Product saved.'),
      ],
    );

    blocTest<AdminProductsCubit, AdminProductsState>(
      'emits submitError when the repository create fails',
      build: () {
        when(() => productRepository.create(any())).thenAnswer(
          (_) async => const ApiResult.failure(
            ApiErrorModel(message: 'Permission denied.'),
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.submitProduct(product: product),
      expect: () => <dynamic>[
        const AdminProductsState.submitLoading(),
        const AdminProductsState.submitError(
          ApiErrorModel(message: 'Permission denied.'),
        ),
      ],
    );
  });

  group('AdminProductsCubit — role guard (PRD §1/§5: role == admin only)', () {
    blocTest<AdminProductsCubit, AdminProductsState>(
      'REJECTS the write for a NON-ADMIN: emits writeUnauthorized and the '
      'repository is never called',
      build: () {
        when(() => roleGuard.ensureAdmin()).thenAnswer(
          (_) async => const ApiResult.failure(
            ApiErrorModel(message: 'Only admins can perform this action.'),
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.submitProduct(product: product),
      verify: (_) => verifyNever(() => productRepository.create(any())),
      expect: () => <dynamic>[
        const AdminProductsState.submitLoading(),
        const AdminProductsState.writeUnauthorized(
          ApiErrorModel(message: 'Only admins can perform this action.'),
        ),
      ],
    );

    blocTest<AdminProductsCubit, AdminProductsState>(
      'REJECTS delete for a non-admin: emits writeUnauthorized and the '
      'repository is never called',
      build: () {
        when(() => roleGuard.ensureAdmin()).thenAnswer(
          (_) async => const ApiResult.failure(
            ApiErrorModel(message: 'Only admins can perform this action.'),
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.deleteProduct('p-1'),
      verify: (_) => verifyNever(() => productRepository.delete(any())),
      expect: () => <dynamic>[
        const AdminProductsState.deleteLoading(),
        const AdminProductsState.writeUnauthorized(
          ApiErrorModel(message: 'Only admins can perform this action.'),
        ),
      ],
    );

    blocTest<AdminProductsCubit, AdminProductsState>(
      'an image upload through a not-configured AdminImageUploader surfaces '
      'submitError instead of calling the repository (placeholder '
      'SupabaseConfig — TODO owner, see AdminImageUploader)',
      build: () {
        when(
          () => imageUploader.upload(
            bytes: any(named: 'bytes'),
            fileName: any(named: 'fileName'),
          ),
        ).thenAnswer(
          (_) async => const ApiResult.failure(
            ApiErrorModel(
              message:
                  'Image upload is not configured yet. Enter an image URL '
                  'manually.',
            ),
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.submitProduct(
        product: product,
        imageBytes: Uint8List.fromList([1, 2, 3]),
      ),
      verify: (_) => verifyNever(() => productRepository.create(any())),
      expect: () => <dynamic>[
        const AdminProductsState.submitLoading(),
        const AdminProductsState.submitError(
          ApiErrorModel(
            message:
                'Image upload is not configured yet. Enter an image URL '
                'manually.',
          ),
        ),
      ],
    );

    test('a configured uploader replaces the manual imageUrl field', () async {
      when(() => productRepository.create(any()))
          .thenAnswer((_) async => ApiResult.success(product));
      when(
        () => imageUploader.upload(
          bytes: any(named: 'bytes'),
          fileName: any(named: 'fileName'),
        ),
      ).thenAnswer(
        (_) async => const ApiResult.success('https://cdn.example.com/p.png'),
      );

      final cubit = buildCubit();
      await cubit.submitProduct(
        product: product,
        imageBytes: Uint8List.fromList([1, 2, 3]),
        imageFileName: 'shoes.png',
      );

      final captured = verify(() => productRepository.create(captureAny()))
          .captured;
      expect(
        (captured.single as ProductModel).imageUrl,
        'https://cdn.example.com/p.png',
      );
      cubit.close();
    });
  });

  group('AdminProductsCubit.deleteProduct (after the UI confirmation)', () {
    blocTest<AdminProductsCubit, AdminProductsState>(
      'emits [deleteLoading, deleteSuccess] and calls repository.delete '
      'for an admin',
      build: () {
        when(() => productRepository.delete(any()))
            .thenAnswer((_) async => const ApiResult.success(null));
        return buildCubit();
      },
      act: (cubit) => cubit.deleteProduct('p-1'),
      verify: (_) => verify(() => productRepository.delete('p-1')).called(1),
      expect: () => <dynamic>[
        const AdminProductsState.deleteLoading(),
        const AdminProductsState.deleteSuccess('Product deleted.'),
      ],
    );

    blocTest<AdminProductsCubit, AdminProductsState>(
      'emits [deleteLoading, deleteError] when the repository fails',
      build: () {
        when(() => productRepository.delete(any())).thenAnswer(
          (_) async => const ApiResult.failure(
            ApiErrorModel(message: 'Permission denied.'),
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.deleteProduct('p-1'),
      expect: () => <dynamic>[
        const AdminProductsState.deleteLoading(),
        const AdminProductsState.deleteError(
          ApiErrorModel(message: 'Permission denied.'),
        ),
      ],
    );
  });
}



