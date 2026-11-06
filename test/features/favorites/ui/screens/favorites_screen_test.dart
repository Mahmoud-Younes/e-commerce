import 'dart:async';

import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/core/repositories/favorites_repository.dart';
import 'package:e_commerce_app/core/repositories/product_repository.dart';
import 'package:e_commerce_app/features/favorites/logic/cubit/favorites_cubit.dart';
import 'package:e_commerce_app/features/favorites/ui/screens/favorites_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  // Advances the FakeAsync clock so timers/microtasks (stream delivery, the
  // cubit's async chain) settle. A bare `await Future.delayed(...)` would
  // deadlock testWidgets: fake timers only fire when the clock advances.
  Future<void> flush(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 20));
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
    // Mirror the app root (lib/e_commerce_app.dart:23) so flutter_screenutil's
    // `.sp` text styles used by the screen initialize instead of throwing
    // LateInitializationError under the test bindings.
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        child: MaterialApp(home: FavoritesScreen(userId: 'user-1', cubit: cubit)),
      ),
    );
    await flush(tester);
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
      await tester.pump();
      // network image to a bogus URL never settles under test bindings —
      // a bounded pump suffices; tile text/paint does not depend on image load.
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const ValueKey('favoritesEmpty')), findsOneWidget);
      expect(find.text('No favorites yet'), findsOneWidget);
    });

    testWidgets('shows the error state when the stream fails', (tester) async {
      await pumpScreen(tester, cubit: buildCubit());
      idsController.addError(Exception('firestore down'));
      await tester.pump();
      // network image to a bogus URL never settles under test bindings —
      // a bounded pump suffices; tile text/paint does not depend on image load.
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const ValueKey('favoritesError')), findsOneWidget);
    });

    testWidgets('lists the favorited products with name and price',
        (tester) async {
      await pumpScreen(tester, cubit: buildCubit());
      idsController.add(const ['p1', 'p2']);
      await tester.pump();
      // network image to a bogus URL never settles under test bindings —
      // a bounded pump suffices; tile text/paint does not depend on image load.
      await tester.pump(const Duration(seconds: 1));

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
      await tester.pump();
      // network image to a bogus URL never settles under test bindings —
      // a bounded pump suffices; tile text/paint does not depend on image load.
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byKey(const ValueKey('remove-p1')));
      await tester.pump();
      verify(() => favoritesRepo.toggle('user-1', 'p1')).called(1);

      // The live stream re-emits the shorter list after the toggle.
      idsController.add(const ['p2']);
      await tester.pump();
      // network image to a bogus URL never settles under test bindings —
      // a bounded pump suffices; tile text/paint does not depend on image load.
      await tester.pump(const Duration(seconds: 1));

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

      // flutter_test's binding replaces HttpClient with a fake that fails
      // immediately, so no tester.runAsync is needed — the image errors on
      // the next advanced clock tick and errorBuilder swaps in the icon.
      await pumpScreen(tester, cubit: buildCubit());
      idsController.add(const ['p1']);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Broken Image'), findsOneWidget);
    });
  });
}



