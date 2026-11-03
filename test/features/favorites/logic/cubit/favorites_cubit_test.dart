import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/core/repositories/favorites_repository.dart';
import 'package:e_commerce_app/core/repositories/product_repository.dart';
import 'package:e_commerce_app/features/favorites/data/models/favorite_item.dart';
import 'package:e_commerce_app/features/favorites/logic/cubit/favorites_cubit.dart';
import 'package:e_commerce_app/features/favorites/logic/cubit/favorites_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  const product1 = ProductModel(name: 'Espresso', price: 10.0);
  const product2 = ProductModel(name: 'Grinder', price: 20.0);

  late MockFavoritesRepository favoritesRepo;
  late MockProductRepository productRepo;
  late StreamController<List<String>> idsController;

  /// Lets the synchronous `start()` subscription attach and the async
  /// details-fetch chain (listen event -> Future.wait -> emit) fully settle.
  Future<void> flush() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  FavoritesCubit buildCubit() => FavoritesCubit(favoritesRepo, productRepo);

  setUp(() {
    favoritesRepo = MockFavoritesRepository();
    productRepo = MockProductRepository();
    // Broadcast: `close()` on a never-listened single-subscription controller
    // never completes, which would hang tearDown in the plain `test()`s below
    // whose cubit never subscribes (start('') bails early / removeFavorite).
    idsController = StreamController<List<String>>.broadcast();

    when(() => favoritesRepo.streamFavoriteIds(any()))
        .thenAnswer((_) => idsController.stream);
    when(() => productRepo.getById('p1'))
        .thenAnswer((_) async => ApiResult.success(product1));
    when(() => productRepo.getById('p2'))
        .thenAnswer((_) async => ApiResult.success(product2));
  });

  tearDown(() async {
    idsController.close();
  });

  group('FavoritesCubit', () {
    test('start with empty userId emits error, never subscribes', () async {
      final cubit = buildCubit();

      cubit.start('');

      expect(cubit.state, isA<FavoritesError>());
      expect(
        (cubit.state as FavoritesError).apiErrorModel.message,
        'Not authenticated',
      );
      verifyNever(() => favoritesRepo.streamFavoriteIds(any()));
      cubit.close();
    });

    blocTest<FavoritesCubit, FavoritesState>(
      'emits loading then empty when the favorites list is empty',
      build: buildCubit,
      act: (cubit) async {
        cubit.start('user-1');
        await flush();
        idsController.add(const []);
        await flush();
      },
      expect: () => [
        const FavoritesState.loading(),
        const FavoritesState.empty(),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'emits loading then loaded with details fetched via ProductRepository',
      build: buildCubit,
      act: (cubit) async {
        cubit.start('user-1');
        await flush();
        idsController.add(const ['p1', 'p2']);
        await flush();
      },
      expect: () => [
        const FavoritesState.loading(),
        const FavoritesState.loaded([
          FavoriteItem(productId: 'p1', product: product1),
          FavoriteItem(productId: 'p2', product: product2),
        ]),
      ],
      verify: (_) {
        verify(() => productRepo.getById('p1')).called(1);
        verify(() => productRepo.getById('p2')).called(1);
      },
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'keeps successfully fetched products when some details fail',
      build: buildCubit,
      setUp: () {
        when(() => productRepo.getById('p2')).thenAnswer(
          (_) async => const ApiResult.failure(
            ApiErrorModel(message: 'product missing'),
          ),
        );
      },
      act: (cubit) async {
        cubit.start('user-1');
        await flush();
        idsController.add(const ['p1', 'p2']);
        await flush();
      },
      expect: () => [
        const FavoritesState.loading(),
        const FavoritesState.loaded([
          FavoriteItem(productId: 'p1', product: product1),
        ]),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'emits error when every details fetch fails',
      build: buildCubit,
      setUp: () {
        when(() => productRepo.getById('p1')).thenAnswer(
          (_) async =>
              const ApiResult.failure(ApiErrorModel(message: 'not found')),
        );
      },
      act: (cubit) async {
        cubit.start('user-1');
        await flush();
        idsController.add(const ['p1']);
        await flush();
      },
      expect: () => [
        const FavoritesState.loading(),
        const FavoritesState.error(ApiErrorModel(message: 'not found')),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'emits error when the favorites stream itself fails',
      build: buildCubit,
      act: (cubit) async {
        cubit.start('user-1');
        await flush();
        idsController.addError(Exception('firestore down'));
        await flush();
      },
      expect: () => [
        const FavoritesState.loading(),
        isA<FavoritesError>(),
      ],
    );

    blocTest<FavoritesCubit, FavoritesState>(
      'live updates: a shorter snapshot after removal repaints without loading',
      build: buildCubit,
      act: (cubit) async {
        cubit.start('user-1');
        await flush();
        idsController.add(const ['p1', 'p2']);
        await flush();
        idsController.add(const ['p2']);
        await flush();
      },
      expect: () => [
        const FavoritesState.loading(),
        const FavoritesState.loaded([
          FavoriteItem(productId: 'p1', product: product1),
          FavoriteItem(productId: 'p2', product: product2),
        ]),
        const FavoritesState.loaded([
          FavoriteItem(productId: 'p2', product: product2),
        ]),
      ],
    );

    test('removeFavorite toggles the product doc through the repository',
        () async {
      when(() => favoritesRepo.toggle(any(), any()))
          .thenAnswer((_) async => const ApiResult.success(null));
      final cubit = buildCubit();

      await cubit.removeFavorite('user-1', 'p1');

      verify(() => favoritesRepo.toggle('user-1', 'p1')).called(1);
      cubit.close();
    });

    test('close cancels the live subscription', () async {
      final cubit = buildCubit();
      cubit.start('user-1');

      cubit.close();

      expect(idsController.hasListener, isFalse);
    });
  });
}



