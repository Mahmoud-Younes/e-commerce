import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/helpers/constants.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_result.dart';
import '../models/register_request_body.dart';

/// Creates the Firebase Auth account, then writes the Firestore `users/{uid}`
/// doc (PRD §1/§7): the repo is the seam the feature talks to, errors come
/// back as [ApiResult.failure].
class RegisterRepo {
  RegisterRepo();

  Future<ApiResult<User>> register(
      RegisterRequestBody registerRequestBody) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: registerRequestBody.email,
        password: registerRequestBody.password,
      );
      await FirebaseFirestore.instance
          .collection(Collections.users)
          .doc(credential.user!.uid)
          .set({
        UserFields.name: registerRequestBody.name,
        UserFields.email: registerRequestBody.email,
        UserFields.phone: '',
        UserFields.address: '',
        UserFields.role: UserRoleValues.customer,
        UserFields.fcmTokens: <String, bool>{},
      });
      return ApiResult.success(credential.user!);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
