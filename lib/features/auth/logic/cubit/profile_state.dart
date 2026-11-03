import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/networking/api_error_model.dart';
import '../../data/models/user_model.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState<T> with _$ProfileState<T> {
  const factory ProfileState.initial() = _Initial;

  const factory ProfileState.profileLoading() = ProfileLoading;
  const factory ProfileState.profileSuccess(UserModel user) = ProfileSuccess<T>;
  const factory ProfileState.profileUpdateLoading() = ProfileUpdateLoading;
  const factory ProfileState.profileUpdateSuccess(String successMessage) =
      ProfileUpdateSuccess<T>;
  const factory ProfileState.profileError(ApiErrorModel apiErrorModel) =
      ProfileError;
  const factory ProfileState.profileUpdateError(ApiErrorModel apiErrorModel) =
      ProfileUpdateError;
}
