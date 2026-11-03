import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/extensions.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../logic/cubit/profile_cubit.dart';
import '../../logic/cubit/profile_state.dart';

/// Surfaces load/update errors and the update success as dialogs. The load
/// and update loading states are inline (spinner / button), and logout needs
/// no dialog — AuthGate swaps the tree via authStateChanges.
class ProfileBlocListener extends StatelessWidget {
  const ProfileBlocListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) =>
          current is ProfileError ||
          current is ProfileUpdateError ||
          current is ProfileUpdateSuccess,
      listener: (context, state) {
        state.whenOrNull(
          profileError: (apiErrorModel) {
            setupErrorState(context, apiErrorModel);
          },
          profileUpdateError: (apiErrorModel) {
            setupErrorState(context, apiErrorModel);
          },
          profileUpdateSuccess: (successMessage) {
            setupSuccessState(context, successMessage);
          },
        );
      },
      child: const SizedBox.shrink(),
    );
  }

  void setupErrorState(BuildContext context, ApiErrorModel apiErrorModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.error,
          color: Colors.red,
          size: 32,
        ),
        content: Text(
          apiErrorModel.message ?? 'Something went wrong.',
          style: TextStyles.font14DarkGrayRegular,
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: Text(
              'Got it',
              style: TextStyles.font13GreenSemiBold,
            ),
          ),
        ],
      ),
    );
  }

  void setupSuccessState(BuildContext context, String successMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: ColorsManager.mainGreen,
          size: 32,
        ),
        title: Text(
          'Success',
          style: TextStyles.font18DarkGreenBold,
        ),
        content: Text(
          successMessage,
          style: TextStyles.font14DarkGrayRegular,
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: Text(
              'Got it',
              style: TextStyles.font13GreenSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}
