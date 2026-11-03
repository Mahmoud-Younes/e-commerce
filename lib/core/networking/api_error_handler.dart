import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_error_model.dart';

/// Replaces doc_doc's dio error handler: maps Firebase/Supabase exceptions to
/// a user-readable [ApiErrorModel]. Repos throw [AppException]; cubits catch
/// it and turn it into an error state.
class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class ApiErrorHandler {
  static ApiErrorModel handle(Object error) {
    if (error is FirebaseAuthException) {
      return ApiErrorModel(message: _authMessage(error.code, error.message));
    }
    if (error is FirebaseException) {
      return ApiErrorModel(
          message: error.message ?? 'A Firebase error occurred.');
    }
    if (error is AuthException) {
      return ApiErrorModel(message: error.message);
    }
    if (error is PostgrestException) {
      return ApiErrorModel(message: error.message);
    }
    if (error is StorageException) {
      return ApiErrorModel(message: error.message);
    }
    if (error is AppException) {
      return ApiErrorModel(message: error.message);
    }
    return ApiErrorModel(message: error.toString());
  }

  static String _authMessage(String code, String? fallback) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return fallback ?? 'An authentication error occurred.';
    }
  }
}
