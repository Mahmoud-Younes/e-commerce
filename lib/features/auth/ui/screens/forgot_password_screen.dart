import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/app_regex.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../logic/cubit/forgot_password_cubit.dart';
import '../../logic/cubit/forgot_password_state.dart';
import '../widgets/forgot_password_bloc_listener.dart';

/// Sends a Firebase password-reset email for the entered address (PRD §1).
/// Mirrors LoginScreen's scaffolding; the screen stays open after success so
/// the user can navigate back to login themselves.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset Password',
                  style: TextStyles.font24BlackBold,
                ),
                verticalSpace(8),
                Text(
                  'Enter your email and we will send you a reset link',
                  style: TextStyles.font14GrayRegular,
                ),
                verticalSpace(36),
                Form(
                  key: context.read<ForgotPasswordCubit>().formKey,
                  child: Column(
                    children: [
                      AppTextFormField(
                        controller:
                            context.read<ForgotPasswordCubit>().emailController,
                        hintText: 'Email',
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !AppRegex.isEmailValid(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      verticalSpace(24),
                      BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                        builder: (context, state) {
                          return AppButton(
                            text: 'Send Reset Link',
                            isLoading: state is ForgotPasswordLoading,
                            onPressed: () {
                              validateThenDoReset(context);
                            },
                          );
                        },
                      ),
                      const ForgotPasswordBlocListener(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void validateThenDoReset(BuildContext context) {
    if (context.read<ForgotPasswordCubit>().formKey.currentState!.validate()) {
      context.read<ForgotPasswordCubit>().emitForgotPasswordStates();
    }
  }
}
