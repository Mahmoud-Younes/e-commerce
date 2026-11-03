/// Route names for the admin feature. FOR THE MERGE AGENT — register these in
/// `lib/core/routing/routes.dart` (Admin section) and wire the cases in
/// `lib/core/routing/app_router.dart` (AGENT C banner) exactly as below.
///
/// ```dart
/// // routes.dart (Admin section):
/// static const String adminProducts = '/adminProducts';
/// static const String adminOrders = '/adminOrders';
/// static const String adminOrderDetails = '/adminOrderDetails';
///
/// // app_router.dart (AGENT C banner) — replace the current adminDashboard /
/// // adminProductForm cases with provider-backed ones and add:
/// case Routes.adminProducts:
///   return MaterialPageRoute(
///     builder: (_) => BlocProvider(
///       create: (_) => getIt<AdminProductsCubit>(),
///       child: const AdminProductsScreen(),
///     ),
///   );
/// case Routes.adminOrders:
///   return MaterialPageRoute(
///     builder: (_) => BlocProvider(
///       create: (_) => getIt<AdminOrdersCubit>(),
///       child: const AdminOrdersScreen(),
///     ),
///   );
/// case Routes.adminOrderDetails:
///   final orderId = settings.arguments as String;
///   return MaterialPageRoute(
///     builder: (_) => BlocProvider(
///       create: (_) => getIt<AdminOrdersCubit>(),
///       child: AdminOrderDetailsScreen(orderId: orderId),
///     ),
///   );
/// ```
///
/// Pre-existing route contracts kept as-is:
/// - `/adminDashboardScreen` → [AdminDashboardScreen] (no arguments).
/// - `/adminProductFormScreen` → AdminProductFormScreen with
///   `settings.arguments as ProductModel?` (null = create mode) and
///   `getIt<AdminProductsCubit>()` provided above it.
class AdminRoutes {
  AdminRoutes._();

  static const String adminProducts = '/adminProducts';
  static const String adminOrders = '/adminOrders';
  static const String adminOrderDetails = '/adminOrderDetails';
}
