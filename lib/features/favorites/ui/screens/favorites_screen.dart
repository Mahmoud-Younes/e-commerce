import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/theming/styles.dart';
import '../../data/models/favorite_item.dart';
import '../../logic/cubit/favorites_cubit.dart';
import '../../logic/cubit/favorites_state.dart';

/// Favorites screen (PRD §2). Named route: `Routes.favoritesScreen`
/// ('/favoritesScreen', lib/core/routing/routes.dart:14) — registered by the
/// merge agent in `lib/core/routing/app_router.dart` (case Routes.favoritesScreen).
///
/// The route builds `const FavoritesScreen()`, so the screen provides its own
/// [BlocProvider]: it resolves the cubit from get_it (registered as
/// `FavoritesCubit(getIt(), getIt())`, see [FavoritesCubit]) and starts it with
/// the signed-in user's uid. Tests inject [cubit] and [userId] directly and
/// never touch FirebaseAuth.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, this.userId, this.cubit});

  /// Signed-in user's uid. Defaults to `FirebaseAuth.instance.currentUser`
  /// when not injected (production path — router passes nothing).
  final String? userId;

  /// Injectable cubit for widget tests; production resolves it from get_it.
  final FavoritesCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: BlocProvider<FavoritesCubit>(
        create: (_) => (cubit ?? getIt<FavoritesCubit>())..start(uid ?? ''),
        child: _FavoritesBody(userId: uid ?? ''),
      ),
    );
  }
}

class _FavoritesBody extends StatelessWidget {
  const _FavoritesBody({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          empty: () => const _FavoritesEmptyView(),
          loaded: (items) => _FavoritesListView(
            items: items,
            userId: userId,
          ),
          error: (apiErrorModel) => _FavoritesErrorView(
            message: apiErrorModel.message ?? 'Something went wrong.',
          ),
        );
      },
    );
  }
}

class _FavoritesEmptyView extends StatelessWidget {
  const _FavoritesEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('favoritesEmpty'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text('No favorites yet', style: TextStyles.font18DarkGreenBold),
          const SizedBox(height: 4),
          Text(
            'Products you add to favorites will appear here.',
            style: TextStyles.font14GrayRegular,
          ),
        ],
      ),
    );
  }
}

class _FavoritesListView extends StatelessWidget {
  const _FavoritesListView({required this.items, required this.userId});

  final List<FavoriteItem> items;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const ValueKey('favoritesList'),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return _FavoriteTile(
          item: item,
          userId: userId,
        );
      },
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  const _FavoriteTile({required this.item, required this.userId});

  final FavoriteItem item;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final ProductModel product = item.product;
    return ListTile(
      key: ValueKey('favorite-${item.productId}'),
      leading: product.imageUrl.isEmpty
          ? const Icon(Icons.image_outlined)
          : Image.network(
              product.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.image_outlined),
            ),
      title: Text(product.name, style: TextStyles.font14DarkGrayRegular),
      subtitle: Text(
        '\$${product.price.toStringAsFixed(2)}',
        style: TextStyles.font14GrayRegular,
      ),
      trailing: IconButton(
        key: ValueKey('remove-${item.productId}'),
        tooltip: 'Remove from favorites',
        icon: const Icon(Icons.favorite),
        color: Theme.of(context).colorScheme.error,
        onPressed: () =>
            context.read<FavoritesCubit>().removeFavorite(userId, item.productId),
      ),
    );
  }
}

class _FavoritesErrorView extends StatelessWidget {
  const _FavoritesErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('favoritesError'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
