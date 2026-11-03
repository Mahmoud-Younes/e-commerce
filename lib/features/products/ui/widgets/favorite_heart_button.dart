import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/repositories/favorites_repository.dart';
import '../../../../core/theming/colors.dart';
import 'user_context.dart';

/// Favorite toggle on product cards and the details screen (PRD §2: add to /
/// remove from Favorites).
///
/// Resolves [FavoritesRepository] through `get_it` at tap time; the merge
/// agent registers it (`FavoritesRepositoryImpl`) in the DI setup. Toggling is
/// optimistic (the heart flips immediately and reverts on failure). The
/// current favorite state is not subscribed to here — the favorites feature
/// owns that stream; this button only drives `FavoritesRepository.toggle`.
class FavoriteHeartButton extends StatefulWidget {
  const FavoriteHeartButton({
    super.key,
    required this.productId,
    this.initiallyFavorite = false,
    this.size,
    this.auth,
  });

  final String productId;
  final bool initiallyFavorite;
  final double? size;

  /// Injectable for tests (`firebase_auth_mocks`); defaults to the real
  /// `FirebaseAuth.instance`.
  final FirebaseAuth? auth;

  @override
  State<FavoriteHeartButton> createState() => _FavoriteHeartButtonState();
}

class _FavoriteHeartButtonState extends State<FavoriteHeartButton> {
  late bool _isFavorite = widget.initiallyFavorite;
  bool _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() {
      _isFavorite = !_isFavorite;
      _busy = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final uid = currentUserId(auth: widget.auth);
    if (uid == null) {
      setState(() {
        _isFavorite = !_isFavorite;
        _busy = false;
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Please sign in to manage favorites.')),
      );
      return;
    }

    try {
      final response = await getIt<FavoritesRepository>().toggle(
        uid,
        widget.productId,
      );
      response.when(
        success: (_) {},
        failure: (apiErrorModel) {
          if (!mounted) return;
          setState(() => _isFavorite = !_isFavorite);
          messenger.showSnackBar(
            SnackBar(content: Text(apiErrorModel.message ?? 'Error')),
          );
        },
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isFavorite = !_isFavorite);
      messenger.showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }

    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = widget.size ?? 20.0;
    return IconButton(
      tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
      visualDensity: VisualDensity.compact,
      onPressed: _busy ? null : _toggle,
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? ColorsManager.red : ColorsManager.gray,
        size: iconSize,
      ),
    );
  }
}
