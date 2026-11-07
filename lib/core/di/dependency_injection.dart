import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/admin/data/repos/admin_orders_source.dart';
import '../../features/admin/data/repos/admin_products_source.dart';
import '../../features/admin/data/repos/admin_role_guard.dart';
import '../../features/admin/data/upload/admin_image_uploader.dart';
import '../../features/admin/logic/cubit/admin_orders_cubit.dart';
import '../../features/admin/logic/cubit/admin_products_cubit.dart';
import '../../features/auth/data/repos/login_repo.dart';
import '../../features/auth/data/repos/profile_repo.dart';
import '../../features/auth/data/repos/register_repo.dart';
import '../../features/auth/logic/cubit/forgot_password_cubit.dart';
import '../../features/auth/logic/cubit/login_cubit.dart';
import '../../features/auth/logic/cubit/profile_cubit.dart';
import '../../features/auth/logic/cubit/register_cubit.dart';
import '../../features/cart/data/repos/cart_repo_impl.dart';
import '../../features/cart/logic/cubit/cart_cubit.dart';
import '../../features/checkout/logic/cubit/checkout_cubit.dart';
import '../../features/favorites/data/repos/favorites_repository_impl.dart';
import '../../features/favorites/logic/cubit/favorites_cubit.dart';
import '../../features/notifications/data/repos/notification_repository_impl.dart';
import '../../features/notifications/data/services/fcm_service.dart';
import '../../features/notifications/logic/cubit/notifications_cubit.dart';
import '../../features/orders/data/repos/order_repository_impl.dart';
import '../../features/orders/logic/cubit/orders_cubit.dart';
import '../../features/products/data/datasources/product_catalog_data_source.dart';
import '../../features/products/data/repos/product_repository_impl.dart';
import '../../features/products/logic/cubit/product_details_cubit.dart';
import '../../features/products/logic/cubit/products_cubit.dart';
import '../../core/repositories/cart_repository.dart';
import '../../core/repositories/favorites_repository.dart';
import '../../core/repositories/notification_repository.dart';
import '../../core/repositories/order_repository.dart';
import '../../core/repositories/product_repository.dart';

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
  // (edits inside this banner only)

  // catalog (PRD §2) — the live Firestore catalog feeds ProductsCubit.
  getIt.registerLazySingleton<ProductCatalogDataSource>(
    () => ProductCatalogDataSourceImpl(FirebaseFirestore.instance),
  );
  getIt.registerFactory<ProductsCubit>(() => ProductsCubit(getIt()));

  // product details — resolves one product by its document ID.
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(FirebaseFirestore.instance),
  );
  getIt.registerFactory<ProductDetailsCubit>(
    () => ProductDetailsCubit(getIt<ProductRepository>()),
  );

  // favorites (PRD §2) — positional repo args per FavoritesCubit's contract.
  getIt.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl());
  getIt.registerFactory<FavoritesCubit>(() => FavoritesCubit(getIt(), getIt()));

  // cart (PRD §3) — CartCubit(getIt<CartRepository>(), getIt<ProductRepository>()).
  getIt.registerLazySingleton<CartRepository>(() => CartRepositoryImpl());
  getIt.registerFactory<CartCubit>(() => CartCubit(getIt(), getIt()));

  // ============== END AGENT B: CATALOG & FAVORITES & CART ================

  // ================= AGENT C: CHECKOUT & ORDERS & ADMIN ==================
  // (edits inside this banner only)

  // orders (PRD §4) — OrderRepositoryImpl needs Firestore + CartRepository
  // (stock re-validation at order time).
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(FirebaseFirestore.instance, getIt()),
  );
  getIt.registerFactory<OrdersCubit>(() => OrdersCubit(getIt()));

  // checkout (PRD §4) — route passes CheckoutArgs (prefilled address/phone)
  // as param1; see CheckoutCubit's documented registration.
  getIt.registerFactoryParam<CheckoutCubit, CheckoutArgs?, void>((args, _) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return CheckoutCubit(
      getIt<CartRepository>(),
      getIt<OrderRepository>(),
      userId: uid,
      // checkout_screen casts route arguments as CheckoutArgs? (null when
      // pushed without prefill) — fall back to the cubit's const default.
      args: args ?? const CheckoutArgs(),
    );
  });

  // notifications (PRD §6) — in-app notification center + FCM plumbing.
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(),
  );
  getIt.registerFactory<NotificationsCubit>(() => NotificationsCubit(getIt()));
  getIt.registerLazySingleton<FcmService>(() => FcmService());

  // admin (PRD §5) — role guard reads users/{uid}.role; Firestore sources
  // stream products/orders for the admin dashboards; Supabase uploader is a
  // placeholder until real credentials land (isConfigured == false).
  getIt.registerLazySingleton<AdminRoleGuard>(
    () => FirebaseAdminRoleGuard(FirebaseAuth.instance, FirebaseFirestore.instance),
  );
  getIt.registerLazySingleton<AdminProductsSource>(
    () => FirestoreAdminProductsSource(FirebaseFirestore.instance),
  );
  getIt.registerLazySingleton<AdminOrdersSource>(
    () => FirestoreAdminOrdersSource(FirebaseFirestore.instance),
  );
  getIt.registerLazySingleton<AdminImageUploader>(() => SupabaseAdminImageUploader());
  getIt.registerFactory<AdminProductsCubit>(
    () => AdminProductsCubit(getIt(), getIt(), getIt(), getIt()),
  );
  getIt.registerFactory<AdminOrdersCubit>(
    () => AdminOrdersCubit(getIt(), getIt(), getIt()),
  );

  // =============== END AGENT C: CHECKOUT & ORDERS & ADMIN ================
}
