import 'dart:async';

import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/core/repositories/favorites_repository.dart';
import 'package:e_commerce_app/core/repositories/product_repository.dart';
import 'package:e_commerce_app/features/favorites/logic/cubit/favorites_cubit.dart';
import 'package:e_commerce_app/features/favorites/ui/screens/favorites_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  final MockFavoritesRepository favoritesRepo = MockFavoritesRepository();
  final MockProductRepository productRepo = MockProductRepository();
  late StreamController<List<String>> idsController;

  const espresso = ProductModel(
    name: 'Espresso Machine',
    price: 249.99,
    imageUrl: 'https://example.com/espresso.png',
  );
  const grinder = ProductModel(name: 'Coffee Grinder', price: 59.0);

  Future<void> flush() async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }

  setUp(() {
    // Broadcast: `close()` on a never-listened single-subscription controller
    // never completes, which would hang tearDown in tests whose cubit
    // subscribes to an overridden stream (e.g. the spinner test) instead.
    idsController = StreamController<List<String>>.broadcast();
    when(() => favoritesRepo.streamFavoriteIds(any()))
        .thenAnswer((_) => idsController.stream);
    when(() => favoritesRepo.toggle(any(), any()))
        .thenAnswer((_) async => const ApiResult.success(null));
    when(() => productRepo.getById('p1'))
        .thenAnswer((_) async => ApiResult.success(espresso));
    when(() => productRepo.getById('p2'))
        .thenAnswer((_) async => ApiResult.success(grinder));
  });

  tearDown(() async {
    idsController.close();
  });

  FavoritesCubit buildCubit() => FavoritesCubit(favoritesRepo, productRepo);

  Future<void> pumpScreen(
    WidgetTester tester, {
    required FavoritesCubit cubit,
  }) async {
    await tester.pumpWidget(
      MaterialApp(home: FavoritesScreen(userId: 'user-1', cubit: cubit)),
    );
    await flush();
  }

  group('FavoritesScreen widget', () {
    testWidgets('shows a spinner while the first snapshot resolves',
        (tester) async {
      // Never completes: keeps the cubit in loading.
      when(() => favoritesRepo.streamFavoriteIds(any())).thenAnswer(
        (_) => const Stream<List<String>>.empty(),
      );

      await tester.pumpWidget(
        MaterialApp(home: FavoritesScreen(userId: 'user-1', cubit: buildCubit())),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // pumpAndSettle would never settle: the spinner animates forever —
      // pump a bounded duration instead to flush pending frames/tasks.
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('shows the empty state when there are no favorites',
        (tester) async {
      await pumpScreen(tester, cubit: buildCubit());
      idsController.add(const []);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('favoritesEmpty')), findsOneWidget);
      expect(find.text('No favorites yet'), findsOneWidget);
    });

    testWidgets('shows the error state when the stream fails', (tester) async {
      await pumpScreen(tester, cubit: buildCubit());
      idsController.addError(Exception('firestore down'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('favoritesError')), findsOneWidget);
    });

    testWidgets('lists the favorited products with name and price',
        (tester) async {
      await pumpScreen(tester, cubit: buildCubit());
      idsController.add(const ['p1', 'p2']);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('favoritesList')), findsOneWidget);
      expect(find.text('Espresso Machine'), findsOneWidget);
      expect(find.text('\$249.99'), findsOneWidget);
      expect(find.text('Coffee Grinder'), findsOneWidget);
      expect(find.byKey(const ValueKey('favorite-p1')), findsOneWidget);
      expect(find.byKey(const ValueKey('favorite-p2')), findsOneWidget);
    });

    testWidgets('remove button toggles the doc and the list repaints live',
        (tester) async {
      await pumpScreen(tester, cubit: buildCubit());
      idsController.add(const ['p1', 'p2']);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('remove-p1')));
      await tester.pump();
      verify(() => favoritesRepo.toggle('user-1', 'p1')).called(1);

      // The live stream re-emits the shorter list after the toggle.
      idsController.add(const ['p2']);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('favorite-p1')), findsNothing);
      expect(find.text('Espresso Machine'), findsNothing);
      expect(find.text('Coffee Grinder'), findsOneWidget);
    });

    testWidgets('broken image URLs fall back to an icon, tile still renders',
        (tester) async {
      when(() => productRepo.getById('p1')).thenAnswer(
        (_) async => ApiResult.success(
          const ProductModel(
            name: 'Broken Image',
            price: 5,
            imageUrl: 'https://example.com/broken.png',
          ),
        ),
      );

      await tester.runAsync(() async {
        await pumpScreen(tester, cubit: buildCubit());
        idsController.add(const ['p1']);
        await tester.pumpAndSettle();
      });

      expect(find.text('Broken Image'), findsOneWidget);
    });
  });
}



