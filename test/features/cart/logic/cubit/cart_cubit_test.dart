import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/core/models/cart_item_model.dart';
import 'package:e_commerce_app/core/models/product_model.dart';
import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/core/repositories/cart_repository.dart';
import 'package:e_commerce_app/core/repositories/product_repository.dart';
import 'package:e_commerce_app/features/cart/logic/cubit/cart_cubit.dart';
import 'package:e_commerce_app/features/cart/logic/cubit/cart_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepository extends Mock implements CartRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockCartRepository cartRepo;
  late MockProductRepository productRepo;
  late CartCubit cubit;

  const userId = 'u1';
  final line = const CartItemModel(
    productId: 'p1',
    name: 'T-Shirt',
    price: 50.0,
    quantity: 2,
  );

  setUpAll(() {
    registerFallbackValue(
      const CartItemModel(productId: 'fallback', quantity: 1),
    );
  });

  setUp(() {
    cartRepo = MockCartRepository();
    productRepo = MockProductRepository();
    cubit = CartCubit(cartRepo, productRepo);
    registerFallbackValue(const ProductModel(name: 'fallback'));

    // The cubit targets `userId` for every write after start().
    when(() => cartRepo.streamCart(any()))
        .thenAnswer((_) => const Stream.empty());
    when(() => cartRepo.updateQuantity(any(), any(), any()))
        .thenAnswer((_) async => const ApiResult<void>.success(null));
    when(() => cartRepo.remove(any(), any()))
        .thenAnswer((_) async => const ApiResult<void>.success(null));
    when(() => cartRepo.clear(any()))
        .thenAnswer((_) async => const ApiResult<void>.success(null));
  });

  group('CartCubit.start (live stream)', () {
    blocTest<CartCubit, CartState>(
      'emits loading then loaded with the streamed lines',
      setUp: () {
        when(() => cartRepo.streamCart(userId))
            .thenAnswer((_) => Stream.value([line]));
      },
      build: () => cubit,
      act: (cubit) => cubit.start(userId),
      expect: () => [
        isA<CartLoading>(),
        isA<CartLoaded>().having((s) => s.items, 'items', [line]),
      ],
    );

    test('loaded state computes the total price from the lines', () async {
      when(() => cartRepo.streamCart(userId))
          .thenAnswer((_) => Stream.value([line, line]));
      cubit.start(userId);
      await Future<void>.delayed(Duration.zero);

      final state = cubit.state as CartLoaded;
      expect(state.total, 200.0); // (50 * 2) + (50 * 2)
    });

    blocTest<CartCubit, CartState>(
      'emits empty when the cart has no lines',
      setUp: () {
        when(() => cartRepo.streamCart(userId))
            .thenAnswer((_) => Stream.value(<CartItemModel>[]));
      },
      build: () => cubit,
      act: (cubit) => cubit.start(userId),
      expect: () => [isA<CartLoading>(), isA<CartEmpty>()],
    );

    blocTest<CartCubit, CartState>(
      'emits error when the stream fails',
      setUp: () {
        when(() => cartRepo.streamCart(userId)).thenAnswer(
          // FirebaseException's constructor is not const in the current
          // firebase_core version, so this cannot be a const expression.
          (_) => Stream.error(
            FirebaseException(plugin: 'firestore', message: 'boom'),
          ),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.start(userId),
      expect: () => [
        isA<CartLoading>(),
        isA<CartError>().having(
          (s) => s.apiErrorModel.message,
          'message',
          'boom',
        ),
      ],
    );
  });

  group('CartCubit.increaseQuantity (never exceeds stock)', () {
    blocTest<CartCubit, CartState>(
      'writes quantity + 1 when the stock allows it',
      setUp: () {
        when(() => productRepo.getById('p1')).thenAnswer(
          (_) async => ApiResult.success(
            const ProductModel(name: 'T-Shirt', price: 50, stock: 10),
          ),
        );
      },
      build: () => cubit,
      act: (cubit) async {
        cubit.start(userId);
        await cubit.increaseQuantity(line);
      },
      expect: () => [isA<CartLoading>()],
      verify: (_) {
        verify(() => cartRepo.updateQuantity(userId, 'p1', 3)).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'emits an error and does not write when the stock is reached',
      setUp: () {
        when(() => productRepo.getById('p1')).thenAnswer(
          (_) async => ApiResult.success(
            const ProductModel(name: 'T-Shirt', price: 50, stock: 2),
          ),
        );
      },
      build: () => cubit,
      act: (cubit) async {
        cubit.start(userId);
        await cubit.increaseQuantity(line); // quantity 2, stock 2
      },
      expect: () => [
        isA<CartLoading>(),
        isA<CartError>().having(
          (s) => s.apiErrorModel.message,
          'message',
          contains('2'),
        ),
      ],
      verify: (_) {
        verifyNever(() => cartRepo.updateQuantity(any(), any(), any()));
      },
    );

    blocTest<CartCubit, CartState>(
      'emits an error when the product is not available',
      setUp: () {
        when(() => productRepo.getById('p1')).thenAnswer(
          (_) async => ApiResult.success(
            const ProductModel(name: 'T-Shirt', stock: 10, isAvailable: false),
          ),
        );
      },
      build: () => cubit,
      act: (cubit) async {
        cubit.start(userId);
        await cubit.increaseQuantity(line);
      },
      expect: () => [isA<CartLoading>(), isA<CartError>()],
      verify: (_) {
        verifyNever(() => cartRepo.updateQuantity(any(), any(), any()));
      },
    );

    blocTest<CartCubit, CartState>(
      'emits an error when fetching the product fails',
      setUp: () {
        when(() => productRepo.getById('p1')).thenAnswer(
          (_) async => const ApiResult<ProductModel>.failure(
            ApiErrorModel(message: 'network down'),
          ),
        );
      },
      build: () => cubit,
      act: (cubit) async {
        cubit.start(userId);
        await cubit.increaseQuantity(line);
      },
      expect: () => [
        isA<CartLoading>(),
        isA<CartError>().having(
          (s) => s.apiErrorModel.message,
          'message',
          'network down',
        ),
      ],
    );
  });

  group('CartCubit.decreaseQuantity', () {
    blocTest<CartCubit, CartState>(
      'decrements the quantity while it stays above 1',
      build: () => cubit,
      act: (cubit) async {
        cubit.start(userId);
        await cubit.decreaseQuantity(line.copyWith(quantity: 3));
      },
      expect: () => [isA<CartLoading>()],
      verify: (_) {
        verify(() => cartRepo.updateQuantity(userId, 'p1', 2)).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'removes the line when the quantity reaches 0',
      build: () => cubit,
      act: (cubit) async {
        cubit.start(userId);
        await cubit.decreaseQuantity(line.copyWith(quantity: 1));
      },
      expect: () => [isA<CartLoading>()],
      verify: (_) {
        verify(() => cartRepo.remove(userId, 'p1')).called(1);
        verifyNever(() => cartRepo.updateQuantity(any(), any(), any()));
      },
    );
  });

  group('CartCubit one-shot operations', () {
    blocTest<CartCubit, CartState>(
      'addItem delegates to the repository add',
      setUp: () {
        when(() => cartRepo.add(any(), any()))
            .thenAnswer((_) async => const ApiResult<void>.success(null));
      },
      build: () => cubit,
      act: (cubit) async {
        cubit.start(userId);
        await cubit.addItem(line);
      },
      expect: () => [isA<CartLoading>()],
      verify: (_) {
        verify(() => cartRepo.add(userId, line)).called(1);
      },
    );

    blocTest<CartCubit, CartState>(
      'surfaces a failed write as an error state',
      setUp: () {
        when(() => cartRepo.remove(any(), any())).thenAnswer(
          (_) async => const ApiResult<void>.failure(
            ApiErrorModel(message: 'permission denied'),
          ),
        );
      },
      build: () => cubit,
      act: (cubit) async {
        cubit.start(userId);
        await cubit.removeItem('p1');
      },
      expect: () => [
        isA<CartLoading>(),
        isA<CartError>().having(
          (s) => s.apiErrorModel.message,
          'message',
          'permission denied',
        ),
      ],
    );

    blocTest<CartCubit, CartState>(
      'clearCart empties the whole cart',
      build: () => cubit,
      act: (cubit) async {
        cubit.start(userId);
        await cubit.clearCart();
      },
      expect: () => [isA<CartLoading>()],
      verify: (_) {
        verify(() => cartRepo.clear(userId)).called(1);
      },
    );
  });
}



