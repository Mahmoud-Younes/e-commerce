import 'package:e_commerce_app/core/networking/api_error_model.dart';
import 'package:e_commerce_app/core/networking/api_result.dart';
import 'package:e_commerce_app/features/auth/data/models/login_request_body.dart';
import 'package:e_commerce_app/features/auth/data/repos/login_repo.dart';
import 'package:e_commerce_app/features/auth/logic/cubit/login_cubit.dart';
import 'package:e_commerce_app/features/auth/logic/cubit/login_state.dart';
import 'package:e_commerce_app/features/notifications/data/services/fcm_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records `getTokenAndSave` calls (review M1). FcmService's constructor only
/// takes nullable injectables, so this subclass runs on the host with no
/// Firebase plugin channels involved.
class RecordingFcmService extends FcmService {
  final List<String?> savedFor = [];

  @override
  Future<String?> getTokenAndSave([String? userId]) async {
    savedFor.add(userId);
    return userId;
  }
}

/// Simulates an FCM failure (PRD §6 best-effort path): the cubit must not
/// surface it, the launch-time fallback in main.dart retries on next start.
class ThrowingFcmService extends FcmService {
  @override
  Future<String?> getTokenAndSave([String? userId]) async {
    throw Exception('fcm unavailable');
  }
}

/// Serves a canned result without touching FirebaseAuth.
class FakeLoginRepo extends LoginRepo {
  FakeLoginRepo(this.result);

  final ApiResult<User> result;

  @override
  Future<ApiResult<User>> login(LoginRequestBody loginRequestBody) async =>
      result;
}

void main() {
  final user = MockUser(uid: 'uid-1');

  LoginCubit buildCubit(ApiResult<User> result, FcmService fcm) {
    final cubit = LoginCubit(FakeLoginRepo(result), fcm);
    cubit.emailController.text = 'user@app.com';
    cubit.passwordController.text = 'Passw0rd!';
    return cubit;
  }

  /// `emitLoginStates` is declared `void ... async` (fire-and-forget from UI
  /// callbacks), so tests flush the microtask queue instead of awaiting it.
  Future<void> pumpStates() => Future<void>.delayed(Duration.zero);

  test('login success emits success and saves the FCM token for the user',
      () async {
    final fcm = RecordingFcmService();
    final cubit = buildCubit(ApiResult<User>.success(user), fcm);

    cubit.emitLoginStates();
    await pumpStates();

    expect(cubit.state, isA<LoginSuccess<User>>());
    // Review M1: the fire-and-forget save targets the signed-in uid so the
    // fresh token lands immediately, not only on the next app relaunch.
    expect(fcm.savedFor, ['uid-1']);
  });

  test('login failure emits error and does not attempt a token save', () async {
    final fcm = RecordingFcmService();
    final cubit = buildCubit(
      ApiResult<User>.failure(const ApiErrorModel(message: 'invalid')),
      fcm,
    );

    cubit.emitLoginStates();
    await pumpStates();

    expect(cubit.state, isA<LoginError>());
    expect(fcm.savedFor, isEmpty);
  });

  test('token-save errors are swallowed and still emit success', () async {
    final cubit = buildCubit(ApiResult<User>.success(user), ThrowingFcmService());

    cubit.emitLoginStates();
    await pumpStates();

    expect(cubit.state, isA<LoginSuccess<User>>());
  });
}
