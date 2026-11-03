import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../data/models/product_doc.dart';
import 'favorite_heart_button.dart';

/// Catalog card (PRD §2: image, name, price). Tapping it opens the details
/// screen with the product's document ID as the route argument. The heart
/// overlay delegates to [FavoriteHeartButton] (favorites via `get_it`).
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.productDoc});

  final ProductDoc productDoc;

  static String formatPrice(double price) => '${price.toStringAsFixed(2)} EGP';

  @override
  Widget build(BuildContext context) {
    final product = productDoc.product;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: ColorsManager.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        onTap: () => context.pushNamed(
          Routes.productDetailsScreen,
          arguments: productDoc.id,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ProductImage(imageUrl: product.imageUrl),
                  Positioned(
                    top: 4.h,
                    right: 2.w,
                    child: FavoriteHeartButton(
                      productId: productDoc.id,
                      size: 18.r,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.font14DarkGrayRegular.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    formatPrice(product.price),
                    style: TextStyles.font13GreenSemiBold,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const _ImagePlaceholder();
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, _) => const _ImagePlaceholder(),
      errorWidget: (_, _, _) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorsManager.lightGray,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 32.r,
        color: ColorsManager.gray,
      ),
    );
  }
}
