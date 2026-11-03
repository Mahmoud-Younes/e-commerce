import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_result.dart';
import '../models/login_request_body.dart';

/// Firebase Auth replaces doc_doc's dio ApiService: the repo is the seam the
/// feature talks to, errors come back as [ApiResult.failure] (PRD §1).
class LoginRepo {
  LoginRepo();

  Future<ApiResult<User>> login(LoginRequestBody loginRequestBody) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginRequestBody.email,
        password: loginRequestBody.password,
      );
      return ApiResult.success(credential.user!);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
