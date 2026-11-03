import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/admin/ui/screens/admin_dashboard_screen.dart';
import '../../features/admin/ui/screens/admin_product_form_screen.dart';
import '../../features/auth/logic/cubit/forgot_password_cubit.dart';
import '../../features/auth/logic/cubit/login_cubit.dart';
import '../../features/auth/logic/cubit/profile_cubit.dart';
import '../../features/auth/logic/cubit/register_cubit.dart';
import '../../features/auth/ui/screens/forgot_password_screen.dart';
import '../../features/auth/ui/screens/login_screen.dart';
import '../../features/auth/ui/screens/profile_screen.dart';
import '../../features/auth/ui/screens/register_screen.dart';
import '../di/dependency_injection.dart';
import '../../features/cart/ui/screens/cart_screen.dart';
import '../../features/catalog/ui/screens/home_screen.dart';
import '../../features/catalog/ui/screens/product_details_screen.dart';
import '../../features/catalog/ui/screens/products_screen.dart';
import '../../features/checkout/ui/screens/checkout_screen.dart';
import '../../features/checkout/ui/screens/order_success_screen.dart';
import '../../features/favorites/ui/screens/favorites_screen.dart';
import '../../features/notifications/ui/screens/notifications_screen.dart';
import '../../features/orders/ui/screens/my_orders_screen.dart';
import '../../features/orders/ui/screens/order_details_screen.dart';
import 'routes.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    // arguments can be passed to any screen like this ( arguments as ClassName )
    // and read back with `settings.arguments`.

    switch (settings.name) {
      // ==================== AGENT A: AUTH & NOTIFICATIONS ====================
      // (edits inside this banner only)
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<LoginCubit>(),
            child: const LoginScreen(),
          ),
        );
      case Routes.registerScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<RegisterCubit>(),
            child: const RegisterScreen(),
          ),
        );
      case Routes.forgotPasswordScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<ForgotPasswordCubit>(),
            child: const ForgotPasswordScreen(),
          ),
        );
      case Routes.profileScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<ProfileCubit>(),
            child: const ProfileScreen(),
          ),
        );
      case Routes.notificationsScreen:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      // ================== END AGENT A: AUTH & NOTIFICATIONS ==================

      // ================ AGENT B: CATALOG & FAVORITES & CART ==================
      // (edits inside this banner only)
      case Routes.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case Routes.productsScreen:
        return MaterialPageRoute(builder: (_) => const ProductsScreen());
      case Routes.productDetailsScreen:
        return MaterialPageRoute(
            builder: (_) => const ProductDetailsScreen());
      case Routes.favoritesScreen:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case Routes.cartScreen:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      // ============== END AGENT B: CATALOG & FAVORITES & CART ================

      // ================= AGENT C: CHECKOUT & ORDERS & ADMIN ==================
      // (edits inside this banner only)
      case Routes.checkoutScreen:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case Routes.orderSuccessScreen:
        return MaterialPageRoute(builder: (_) => const OrderSuccessScreen());
      case Routes.myOrdersScreen:
        return MaterialPageRoute(builder: (_) => const MyOrdersScreen());
      case Routes.orderDetailsScreen:
        return MaterialPageRoute(builder: (_) => const OrderDetailsScreen());
      case Routes.adminDashboardScreen:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case Routes.adminProductFormScreen:
        return MaterialPageRoute(
            builder: (_) => const AdminProductFormScreen());
      // =============== END AGENT C: CHECKOUT & ORDERS & ADMIN ================

      default:
        return null;
    }
  }
}
