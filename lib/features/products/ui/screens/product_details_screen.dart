import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../logic/cubit/product_details_cubit.dart';
import '../../logic/cubit/product_details_state.dart';
import '../widgets/add_to_cart_button.dart';
import '../widgets/favorite_heart_button.dart';
import '../widgets/product_card.dart';

/// Product details screen (PRD §2: images, name, description, price,
/// category, available stock). The route argument is the product's document
/// ID (pushed by [ProductCard]); the screen loads the product through
/// `ProductDetailsCubit` (provided above by the router via `get_it`).
class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? _productId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_productId == null) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is String && arguments.isNotEmpty) {
        _productId = arguments;
        context.read<ProductDetailsCubit>().loadProduct(arguments);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details',
            style: TextStyles.font18DarkGreenBold),
        centerTitle: true,
        actions: [
          BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
            buildWhen: (previous, current) =>
                current is ProductDetailsLoaded,
            builder: (context, state) {
              final product = state.maybeWhen(
                detailsLoaded: (product) => product,
                orElse: () => null,
              );
              if (product == null || _productId == null) {
                return const SizedBox.shrink();
              }
              return FavoriteHeartButton(productId: _productId!);
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
        // freezed-4 unions are consumed as extension methods (.when /
        // .maybeWhen) — the generated union classes are not sealed, so
        // exhaustive switch expressions are not available on them.
        builder: (context, state) => state.maybeWhen(
          detailsLoading: () => const Center(
            child: CircularProgressIndicator(
              color: ColorsManager.mainGreen,
            ),
          ),
          detailsLoaded: (product) => _ProductDetailsBody(product: product),
          detailsError: (apiErrorModel) => Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                apiErrorModel.message ?? 'Something went wrong.',
                textAlign: TextAlign.center,
                style: TextStyles.font14GrayRegular,
              ),
            ),
          ),
          orElse: () => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _ProductDetailsBody extends StatelessWidget {
  const _ProductDetailsBody({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 280.h,
            width: double.infinity,
            child: product.imageUrl.isEmpty
                ? const _DetailsImagePlaceholder()
                : CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const _DetailsImagePlaceholder(),
                    errorWidget: (_, _, _) => const _DetailsImagePlaceholder(),
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyles.font24BlackBold,
                ),
                verticalSpace(8),
                Row(
                  children: [
                    Text(
                      ProductCard.formatPrice(product.price),
                      style: TextStyles.font18DarkGreenBold,
                    ),
                    horizontalSpace(12),
                    if (product.category.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: ColorsManager.lightGreen,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyles.font13GreenSemiBold,
                        ),
                      ),
                  ],
                ),
                verticalSpace(12),
                Row(
                  children: [
                    Icon(
                      product.inStock
                          ? Icons.check_circle_outline
                          : Icons.highlight_off,
                      size: 18.r,
                      color: product.inStock
                          ? ColorsManager.mainGreen
                          : ColorsManager.red,
                    ),
                    horizontalSpace(6),
                    Text(
                      product.inStock
                          ? 'In stock (${product.stock} available)'
                          : 'Out of stock',
                      style: TextStyles.font14DarkGrayRegular.copyWith(
                        color: product.inStock
                            ? ColorsManager.mainGreen
                            : ColorsManager.red,
                      ),
                    ),
                  ],
                ),
                verticalSpace(16),
                if (product.description.isNotEmpty) ...[
                  Text(
                    'Description',
                    style: TextStyles.font14DarkGrayRegular.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  verticalSpace(8),
                  Text(
                    product.description,
                    style: TextStyles.font14GrayRegular,
                  ),
                  verticalSpace(16),
                ],
                AddToCartButton(
                  productId: productId is String ? productId : '',
                  product: product,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsImagePlaceholder extends StatelessWidget {
  const _DetailsImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorsManager.lightGray,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, size: 64.r, color: ColorsManager.gray),
    );
  }
}
