import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/models/cart_item_model.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../logic/cubit/checkout_cubit.dart';
import '../../logic/cubit/checkout_state.dart';
import '../widgets/checkout_form.dart';
import '../widgets/checkout_items_list.dart';

/// Checkout screen (PRD §4): cart items + total, editable delivery address
/// and phone (prefilled from the profile through [CheckoutArgs] — the
/// router passes them from `settings.arguments`), Cash on Delivery only,
/// and a Place Order button.
///
/// Expected route wiring (merge agent, `lib/core/routing/app_router.dart`):
/// ```dart
/// case Routes.checkoutScreen:
///   return MaterialPageRoute(
///     builder: (_) => BlocProvider(
///       create: (_) => getIt<CheckoutCubit>(
///         param1: settings.arguments as CheckoutArgs?,
///       )..loadCheckout(),
///       child: const CheckoutScreen(),
///     ),
///   );
/// ```
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: BlocListener<CheckoutCubit, CheckoutState>(
        // Success only: errors are rendered inline by the builder below
        // (full-screen error view with a Retry), so a dialog would duplicate.
        listenWhen: (previous, current) => current is OrderSuccess,
        listener: (context, state) {
          state.whenOrNull(
            orderSuccess: (orderId) {
              Navigator.pushReplacementNamed(
                context,
                Routes.orderSuccessScreen,
                arguments: orderId,
              );
            },
          );
        },
        child: BlocBuilder<CheckoutCubit, CheckoutState>(
          builder: (context, state) {
            return switch (state) {
              CheckoutLoaded(:final items, :final totalPrice) ||
              OrderPlacing(
                :final items,
                :final totalPrice,
              ) => _CheckoutContent(items: items, totalPrice: totalPrice),
              CheckoutError(:final apiErrorModel) => _CheckoutErrorView(
                apiErrorModel: apiErrorModel,
              ),
              _ => const Center(child: CircularProgressIndicator()),
            };
          },
        ),
      ),
    );
  }
}

class _CheckoutErrorView extends StatelessWidget {
  const _CheckoutErrorView({required this.apiErrorModel});

  final ApiErrorModel apiErrorModel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              apiErrorModel.message ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: TextStyles.font14GrayRegular,
            ),
            verticalSpace(16),
            TextButton(
              onPressed: () => context.read<CheckoutCubit>().loadCheckout(),
              child: Text('Retry', style: TextStyles.font13GreenSemiBold),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutContent extends StatelessWidget {
  const _CheckoutContent({required this.items, required this.totalPrice});

  final List<CartItemModel> items;
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    final isPlacing = context.watch<CheckoutCubit>().state is OrderPlacing;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckoutItemsList(items: items),
          verticalSpace(16),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyles.font18DarkGreenBold),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: TextStyles.font18DarkGreenBold,
              ),
            ],
          ),
          verticalSpace(24),
          Text('Delivery details', style: TextStyles.font14DarkGrayRegular),
          verticalSpace(8),
          const CheckoutForm(),
          verticalSpace(24),
          const _CashOnDeliveryTile(),
          verticalSpace(24),
          AppButton(
            text: 'Place Order (Cash on Delivery)',
            isLoading: isPlacing,
            onPressed: isPlacing
                ? null
                : () {
                    final cubit = context.read<CheckoutCubit>();
                    if (cubit.formKey.currentState?.validate() ?? false) {
                      cubit.placeOrder();
                    }
                  },
          ),
        ],
      ),
    );
  }
}

class _CashOnDeliveryTile extends StatelessWidget {
  const _CashOnDeliveryTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: ColorsManager.lightGreen,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined, color: ColorsManager.mainGreen),
          horizontalSpace(12),
          Expanded(
            child: Text(
              'Cash on Delivery — pay when your order arrives.',
              style: TextStyles.font14DarkGrayRegular,
            ),
          ),
        ],
      ),
    );
  }
}
