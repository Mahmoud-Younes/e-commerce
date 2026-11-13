import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/networking/api_result.dart';
import '../../../notifications/data/services/fcm_service.dart';
import '../../data/models/register_request_body.dart';
import '../../data/repos/register_repo.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState<User>> {
  final RegisterRepo _registerRepo;
  final FcmService _fcmService;
  RegisterCubit(this._registerRepo, this._fcmService)
      : super(const RegisterState.initial());

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
      // Review M1 (PRD §6 push delivery): persist the FCM token right after
      // the account is created so a brand-new user is push-deliverable from
      // their first session — without this the token only lands via the
      // launch-time fallback (FcmService.initialize in main.dart) on the
      // next app relaunch.
      unawaited(_saveFcmToken(user.uid));
      // AuthGate (authStateChanges) swaps the tree to the role-based home —
      // no manual navigation needed after success.
    }, failure: (apiErrorModel) {
      emit(RegisterState.registerError(apiErrorModel));
    });
  }

  Future<void> _saveFcmToken(String uid) async {
    try {
      await _fcmService.getTokenAndSave(uid);
    } catch (_) {
      // Best-effort: the launch-time fallback (FcmService.initialize in
      // main.dart) retries the token save on the next app start.
    }
  }
}
