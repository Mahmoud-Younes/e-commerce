import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/extensions.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/widgets/app_button.dart';

/// Shown after the order document is created and the cart is cleared
/// (PRD §4: "After a successful order, clear the cart and show an
/// order-success screen"). [orderId] arrives as the route argument
/// (`Routes.orderSuccessScreen`, `settings.arguments`).
class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, this.orderId = ''});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Success'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: const BoxDecoration(
                  color: ColorsManager.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: ColorsManager.mainGreen,
                  size: 64,
                ),
              ),
              verticalSpace(24),
              Text(
                'Order placed successfully!',
                style: TextStyles.font24BlackBold,
                textAlign: TextAlign.center,
              ),
              verticalSpace(8),
              Text(
                orderId.isEmpty
                    ? 'Pay cash when your order arrives.'
                    : 'Order #$orderId — pay cash when your order arrives.',
                style: TextStyles.font14GrayRegular,
                textAlign: TextAlign.center,
              ),
              verticalSpace(36),
              AppButton(
                text: 'Continue Shopping',
                onPressed: () {
                  context.pushNamedAndRemoveUntil(
                    Routes.homeScreen,
                    predicate: (route) => false,
                  );
                },
              ),
              verticalSpace(12),
              TextButton(
                onPressed: () {
                  context.pushNamedAndRemoveUntil(
                    Routes.myOrdersScreen,
                    predicate: (route) => false,
                  );
                },
                child: Text(
                  'Track it in My Orders',
                  style: TextStyles.font13GreenSemiBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
