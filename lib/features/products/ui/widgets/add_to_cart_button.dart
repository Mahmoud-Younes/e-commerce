import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/models/cart_item_model.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/networking/api_result.dart';
import '../../../../core/repositories/cart_repository.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/widgets/app_button.dart';
import 'user_context.dart';

/// "Add to Cart" action on the product details screen (PRD §3: add a product
/// to the cart from its details screen).
///
/// Resolves [CartRepository] through `get_it` at tap time; the merge agent
/// registers it (`CartRepositoryImpl`) in the DI setup. Adds one unit of the
/// product; quantity editing lives in the cart feature.
class AddToCartButton extends StatefulWidget {
  const AddToCartButton({
    super.key,
    required this.productId,
    required this.product,
    this.auth,
  });

  final String productId;
  final ProductModel product;

  /// Injectable for tests (`firebase_auth_mocks`); defaults to the real
  /// `FirebaseAuth.instance`.
  final FirebaseAuth? auth;

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  bool _busy = false;

  Future<void> _add() async {
    if (_busy) return;
    if (!widget.product.inStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This product is out of stock.')),
      );
      return;
    }
    setState(() => _busy = true);

    final messenger = ScaffoldMessenger.of(context);
    final uid = currentUserId(auth: widget.auth);
    if (uid == null) {
      if (mounted) setState(() => _busy = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Please sign in to add items to your cart.')),
      );
      return;
    }

    try {
      final response = await getIt<CartRepository>().add(
        uid,
        CartItemModel(
          productId: widget.productId,
          name: widget.product.name,
          price: widget.product.price,
          quantity: 1,
        ),
      );
      response.when(
        success: (_) => messenger.showSnackBar(
          const SnackBar(
            content: Text('Added to cart'),
            backgroundColor: ColorsManager.mainGreen,
          ),
        ),
        failure: (apiErrorModel) => messenger.showSnackBar(
          SnackBar(content: Text(apiErrorModel.message ?? 'Error')),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }

    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: 'Add to Cart',
      isLoading: _busy,
      onPressed: widget.product.inStock ? _add : null,
      backgroundColor: widget.product.inStock
          ? ColorsManager.mainGreen
          : ColorsManager.gray,
    );
  }
}
