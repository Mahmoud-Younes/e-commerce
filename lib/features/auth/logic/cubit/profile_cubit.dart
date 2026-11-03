import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/networking/api_result.dart';
import '../../data/models/user_model.dart';
import '../../data/repos/profile_repo.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState<UserModel>> {
  final ProfileRepo _profileRepo;
  // Positional repo arg: DI registers ProfileCubit(getIt()).
  ProfileCubit(this._profileRepo) : super(const ProfileState.initial());

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void loadProfile() async {
    emit(const ProfileState.profileLoading());
    final response = await _profileRepo.getUser();
    response.when(success: (user) {
      // Prefill the form fields from the Firestore user doc before the
      // success state swaps the spinner for the form.
      nameController.text = user.name;
      phoneController.text = user.phone;
      addressController.text = user.address;
      emit(ProfileState.profileSuccess(user));
    }, failure: (apiErrorModel) {
      emit(ProfileState.profileError(apiErrorModel));
    });
  }

  void updateProfile() async {
    emit(const ProfileState.profileUpdateLoading());
    final response = await _profileRepo.updateProfile(
      name: nameController.text.trim(),
      phone: phoneController.text.trim(),
      address: addressController.text.trim(),
    );
    response.when(success: (data) {
      emit(
        const ProfileState.profileUpdateSuccess('Profile updated successfully'),
      );
    }, failure: (apiErrorModel) {
      emit(ProfileState.profileUpdateError(apiErrorModel));
    });
  }

  Future<void> logout() async {
    // Deliberately no emit after sign-out begins: AuthGate (authStateChanges)
    // swaps the tree to LoginScreen and this screen unmounts.
    await _profileRepo.logout();
  }
}
