import 'package:get_it/get_it.dart';

import '../../features/auth/data/repos/login_repo.dart';
import '../../features/auth/data/repos/profile_repo.dart';
import '../../features/auth/data/repos/register_repo.dart';
import '../../features/auth/logic/cubit/forgot_password_cubit.dart';
import '../../features/auth/logic/cubit/login_cubit.dart';
import '../../features/auth/logic/cubit/profile_cubit.dart';
import '../../features/auth/logic/cubit/register_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // ============================ SHARED SERVICES ============================
  // (Firebase/Firestore singletons are accessed via FirebaseAuth.instance etc.
  //  directly in repos, following the Firebase SDK pattern — no dio layer.)
  // =========================================================================

  // ==================== AGENT A: AUTH & NOTIFICATIONS ====================
  // (register repos as registerLazySingleton, cubits as registerFactory)

  // login
  getIt.registerLazySingleton<LoginRepo>(() => LoginRepo());
  getIt.registerFactory<LoginCubit>(() => LoginCubit(getIt()));

  // register
  getIt.registerLazySingleton<RegisterRepo>(() => RegisterRepo());
  getIt.registerFactory<RegisterCubit>(() => RegisterCubit());

  // profile & logout & forgot password
  getIt.registerLazySingleton<ProfileRepo>(() => ProfileRepo());
  getIt.registerFactory<ProfileCubit>(() => ProfileCubit(getIt()));
  getIt.registerFactory<ForgotPasswordCubit>(() => ForgotPasswordCubit());

  // ================== END AGENT A: AUTH & NOTIFICATIONS ==================

  // ================ AGENT B: CATALOG & FAVORITES & CART ==================
  // (register repos as registerLazySingleton, cubits as registerFactory)

  // ============== END AGENT B: CATALOG & FAVORITES & CART ================

  // ================= AGENT C: CHECKOUT & ORDERS & ADMIN ==================
  // (register repos as registerLazySingleton, cubits as registerFactory)

  // =============== END AGENT C: CHECKOUT & ORDERS & ADMIN ================
}
