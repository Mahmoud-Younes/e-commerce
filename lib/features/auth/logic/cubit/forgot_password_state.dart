import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/networking/api_error_model.dart';

part 'forgot_password_state.freezed.dart';

@freezed
class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState.initial() = _Initial;

  const factory ForgotPasswordState.forgotPasswordLoading() =
      ForgotPasswordLoading;
  const factory ForgotPasswordState.forgotPasswordSuccess(
      String successMessage) = ForgotPasswordSuccess;
  const factory ForgotPasswordState.forgotPasswordError(
      ApiErrorModel apiErrorModel) = ForgotPasswordError;
}
