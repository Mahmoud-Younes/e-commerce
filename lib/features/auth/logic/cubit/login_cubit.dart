import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/networking/api_result.dart';
import '../../../notifications/data/services/fcm_service.dart';
import '../../data/models/login_request_body.dart';
import '../../data/repos/login_repo.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState<User>> {
  final LoginRepo _loginRepo;
  final FcmService _fcmService;
  LoginCubit(this._loginRepo, this._fcmService)
      : super(const LoginState.initial());

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void emitLoginStates() async {
    emit(const LoginState.loginLoading());
    final response = await _loginRepo.login(
      LoginRequestBody(
        email: emailController.text,
        password: passwordController.text,
      ),
    );
    response.when(success: (user) {
      emit(LoginState.loginSuccess(user));
      // Review M1 (PRD §6 push delivery): persist the FCM token right after
      // auth so a freshly logged-in user is push-deliverable — without this
      // the token only lands via the launch-time fallback
      // (FcmService.initialize in main.dart) on the next app relaunch.
      unawaited(_saveFcmToken(user.uid));
      // AuthGate (authStateChanges) swaps the tree to the role-based home —
      // no manual navigation needed after success.
    }, failure: (apiErrorModel) {
      emit(LoginState.loginError(apiErrorModel));
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
