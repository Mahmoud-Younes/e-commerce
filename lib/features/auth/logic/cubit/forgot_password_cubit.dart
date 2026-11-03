import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/networking/api_result.dart';
import '../../data/repos/profile_repo.dart';
import 'forgot_password_state.dart';

/// Non-generic state (no data payload): success only carries the message.
/// The repo defaults internally because DI registers this cubit with no
/// constructor args; the optional param keeps it injectable for tests.
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({ProfileRepo? profileRepo})
      : _profileRepo = profileRepo ?? ProfileRepo(),
        super(const ForgotPasswordState.initial());

  final ProfileRepo _profileRepo;

  TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void emitForgotPasswordStates() async {
    emit(const ForgotPasswordState.forgotPasswordLoading());
    final response =
        await _profileRepo.sendPasswordReset(emailController.text.trim());
    response.when(success: (data) {
      emit(
        const ForgotPasswordState.forgotPasswordSuccess(
          'Password reset email sent',
        ),
      );
    }, failure: (apiErrorModel) {
      emit(ForgotPasswordState.forgotPasswordError(apiErrorModel));
    });
  }
}
