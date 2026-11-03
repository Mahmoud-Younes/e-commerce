import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/networking/api_result.dart';
import '../../data/models/register_request_body.dart';
import '../../data/repos/register_repo.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState<User>> {
  final RegisterRepo _registerRepo;
  RegisterCubit({RegisterRepo? registerRepo})
      : _registerRepo = registerRepo ?? RegisterRepo(),
        super(const RegisterState.initial());

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void emitRegisterStates() async {
    emit(const RegisterState.registerLoading());
    final response = await _registerRepo.register(
      RegisterRequestBody(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
      ),
    );
    response.when(success: (user) {
      emit(RegisterState.registerSuccess(user));
      // AuthGate (authStateChanges) swaps the tree to the role-based home —
      // no manual navigation needed after success.
    }, failure: (apiErrorModel) {
      emit(RegisterState.registerError(apiErrorModel));
    });
  }
}
