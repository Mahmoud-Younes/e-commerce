import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/helpers/constants.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';
import '../models/user_model.dart';

/// Firestore-backed profile repo (PRD §1): reads/updates the `users/{uid}`
/// doc, signs the user out and triggers a password-reset email. Errors come
/// back as [ApiResult.failure] — same seam as [LoginRepo].
class ProfileRepo {
  ProfileRepo();

  Future<ApiResult<UserModel>> getUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return ApiResult.failure(
          const ApiErrorModel(message: 'Not authenticated'),
        );
      }
      final doc = await FirebaseFirestore.instance
          .collection(Collections.users)
          .doc(user.uid)
          .get();
      return ApiResult.success(UserModel.fromDoc(doc));
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  Future<ApiResult<void>> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return ApiResult.failure(
          const ApiErrorModel(message: 'Not authenticated'),
        );
      }
      await FirebaseFirestore.instance
          .collection(Collections.users)
          .doc(user.uid)
          .update({
        UserFields.name: name,
        UserFields.phone: phone,
        UserFields.address: address,
      });
      return ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }

  /// No [ApiResult] here: after sign-out AuthGate (authStateChanges) swaps
  /// the tree to LoginScreen automatically — no state or navigation needed.
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<ApiResult<void>> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
