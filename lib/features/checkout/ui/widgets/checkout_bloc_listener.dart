import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routing/routes.dart';
import '../../logic/cubit/checkout_cubit.dart';
import '../../logic/cubit/checkout_state.dart';

/// Navigates to the order success screen on success. Success only: errors
/// are rendered inline by the builder below (full-screen error view with a
/// Retry), so a dialog would duplicate.
class CheckoutBlocListener extends StatelessWidget {
  const CheckoutBlocListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckoutCubit, CheckoutState>(
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
      child: child,
    );
  }
}
