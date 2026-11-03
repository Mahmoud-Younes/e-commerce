import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/helpers/constants.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';

/// Role guard for every admin write (PRD §2/§5: "Protect Admin actions using
/// trusted authorization" + §1: "Regular users must not be able to grant
/// themselves Admin privileges from the app").
///
/// The role is read from the server-side `users/{uid}` document
/// ([UserFields.role] == [UserRoleValues.admin]) before the Cubit performs
/// ANY admin write (product create/update/delete, order status update,
/// cancellation). Firestore Security Rules re-check this server-side in a
/// later stage (PRD §8 stage 7) — this guard is the client-side first gate,
/// not a replacement for the rules.
///
/// get_it registration (merge agent applies it):
/// ```dart
/// getIt.registerLazySingleton<AdminRoleGuard>(
///   () => FirebaseAdminRoleGuard(FirebaseAuth.instance, FirebaseFirestore.instance),
/// );
/// ```
abstract class AdminRoleGuard {
  /// [ApiResult.success] when the signed-in user's Firestore doc has the
  /// admin role; [ApiResult.failure] otherwise (not signed in, doc missing,
  /// or role is not admin).
  Future<ApiResult<void>> ensureAdmin();
}

class FirebaseAdminRoleGuard implements AdminRoleGuard {
  FirebaseAdminRoleGuard(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<ApiResult<void>> ensureAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const ApiResult.failure(
          ApiErrorModel(message: 'You must be signed in to do that.'),
        );
      }
      final doc = await _firestore
          .collection(Collections.users)
          .doc(user.uid)
          .get();
      final role = doc.data()?[UserFields.role] as String?;
      if (role != UserRoleValues.admin) {
        return const ApiResult.failure(
          ApiErrorModel(message: 'Only admins can perform this action.'),
        );
      }
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
