import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/helpers/extensions.dart';
import '../../../../core/models/cart_item_model.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../logic/cubit/cart_cubit.dart';
import '../../logic/cubit/cart_state.dart';
import '../widgets/cart_item_card.dart';

/// Cart screen (PRD §3). The cubit comes from get_it and starts streaming
/// `users/{uid}/cart` for the signed-in user; the merge agent registers
/// `CartCubit`/`CartRepository` in `dependency_injection.dart`.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      // No signed-in user — the router only reaches here for customers.
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your cart.')),
      );
    }
    return BlocProvider<CartCubit>(
      create: (_) => getIt<CartCubit>()..start(userId),
      child: const CartView(),
    );
  }
}

/// The cart body states (loading / empty / loaded) plus transient write
/// errors surfaced as a SnackBar. Kept as a separate const widget so widget
/// tests can pump it under `BlocProvider.value` with a mocked cubit.
class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: BlocConsumer<CartCubit, CartState>(
        listenWhen: (previous, current) =>
            current is CartError && previous is! CartError,
        listener: (context, state) {
          state.whenOrNull(
            error: (apiErrorModel) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      apiErrorModel.message ?? 'Something went wrong.',
                    ),
                  ),
                );
            },
          );
        },
        builder: (context, state) {
          return state.whenOrNull(
                loaded: (items) => _CartLoadedBody(items: items),
                empty: () => const _CartEmptyBody(),
                error: (apiErrorModel) => _CartErrorBody(
                  message: apiErrorModel.message ?? 'Something went wrong.',
                ),
              ) ??
              const Center(
                key: Key('cartLoading'),
                child: CircularProgressIndicator(),
              );
        },
      ),
    );
  }
}

class _CartLoadedBody extends StatelessWidget {
  final List<CartItemModel> items;
  const _CartLoadedBody({required this.items});

  double get _total => items.fold(0.0, (sum, item) => sum + item.subtotal);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => CartItemCard(
              item: items[index],
              onIncrease: cubit.increaseQuantity,
              onDecrease: cubit.decreaseQuantity,
              onRemove: (item) => cubit.removeItem(item.productId),
            ),
          ),
        ),
        Container(
          key: const Key('cartTotalBar'),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: const BoxDecoration(
            color: ColorsManager.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total', style: TextStyles.font14GrayRegular),
                      Text(
                        _total.toStringAsFixed(2),
                        key: const Key('cartTotal'),
                        style: TextStyles.font18DarkGreenBold,
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  key: const Key('cartCheckoutButton'),
                  onPressed: () => context.pushNamed(Routes.checkoutScreen),
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CartEmptyBody extends StatelessWidget {
  const _CartEmptyBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('cartEmpty'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: ColorsManager.gray,
          ),
          const SizedBox(height: 12),
          Text('Your cart is empty', style: TextStyles.font18DarkGreenBold),
          const SizedBox(height: 4),
          Text(
            'Browse the catalog and add products to your cart.',
            style: TextStyles.font14GrayRegular,
          ),
        ],
      ),
    );
  }
}

class _CartErrorBody extends StatelessWidget {
  final String message;
  const _CartErrorBody({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('cartError'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyles.font14DarkGrayRegular,
        ),
      ),
    );
  }
}
