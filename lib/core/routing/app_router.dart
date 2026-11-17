import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/admin/logic/cubit/admin_orders_cubit.dart';
import '../../features/admin/logic/cubit/admin_products_cubit.dart';
import '../../features/admin/ui/screens/admin_dashboard_screen.dart';
import '../../features/admin/ui/screens/admin_order_details_screen.dart';
import '../../features/admin/ui/screens/admin_orders_screen.dart';
import '../../features/admin/ui/screens/admin_product_form_screen.dart';
import '../../features/admin/ui/screens/admin_products_screen.dart';
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
import '../../features/products/logic/cubit/product_details_cubit.dart';
import '../../features/products/logic/cubit/products_cubit.dart';
import '../../features/products/ui/screens/product_details_screen.dart';
import '../../features/products/ui/screens/products_screen.dart';
import '../../features/checkout/logic/cubit/checkout_cubit.dart';
import '../../features/checkout/ui/screens/checkout_screen.dart';
import '../../features/checkout/ui/screens/order_success_screen.dart';
import '../../features/favorites/ui/screens/favorites_screen.dart';
import '../../features/notifications/ui/screens/notifications_screen.dart';
import '../../features/orders/logic/cubit/orders_cubit.dart';
import '../../features/orders/ui/screens/my_orders_screen.dart';
import '../../features/orders/ui/screens/order_details_screen.dart';
import 'routes.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    // arguments can be passed to any screen like this ( arguments as ClassName )
    // and read back with `settings.arguments`.
    //
    // EVERY MaterialPageRoute below carries `settings: settings`: screens
    // that read `ModalRoute.of(context)?.settings.arguments` (product
    // details, order details, the admin product form) would otherwise see a
    // fresh RouteSettings with the pushed arguments stripped, leaving them
    // in their initial state forever (an empty details screen for every
    // catalog card tap).

    switch (settings.name) {
      // ==================== AGENT A: AUTH & NOTIFICATIONS ====================
      // (edits inside this banner only)
      case Routes.loginScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (context) => getIt<LoginCubit>(),
            child: const LoginScreen(),
          ),
        );
      case Routes.registerScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (context) => getIt<RegisterCubit>(),
            child: const RegisterScreen(),
          ),
        );
      case Routes.forgotPasswordScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (context) => getIt<ForgotPasswordCubit>(),
            child: const ForgotPasswordScreen(),
          ),
        );
      case Routes.profileScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (context) => getIt<ProfileCubit>(),
            child: const ProfileScreen(),
          ),
        );
      case Routes.notificationsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotificationsScreen(),
        );
      // ================== END AGENT A: AUTH & NOTIFICATIONS ==================

      // ================ AGENT B: CATALOG & FAVORITES & CART ==================
      // (edits inside this banner only)
      case Routes.homeScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );
      case Routes.productsScreen:
        // ProductsCubit subscribes to the live catalog stream in its
        // constructor, so a plain factory provider is enough (the screen
        // renders the initial-state spinner until the first snapshot).
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<ProductsCubit>(),
            child: const ProductsScreen(),
          ),
        );
      case Routes.productDetailsScreen:
        // The screen reads the productId route argument in
        // didChangeDependencies and calls loadProduct itself — no
        // provider-side initialization needed.
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<ProductDetailsCubit>(),
            child: const ProductDetailsScreen(),
          ),
        );
      case Routes.favoritesScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const FavoritesScreen(),
        );
      case Routes.cartScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CartScreen(),
        );
      // ============== END AGENT B: CATALOG & FAVORITES & CART ================

      // ================= AGENT C: CHECKOUT & ORDERS & ADMIN ==================
      // (edits inside this banner only)
      case Routes.checkoutScreen:
        // CheckoutArgs (prefilled address/phone) arrive as route arguments;
        // null when pushed without prefill (the cubit falls back to its
        // const default). Wiring per CheckoutScreen's doc comment.
        // A signed-out deep link must not build a CheckoutCubit with an
        // empty uid (order creation would be rejected by the rules) —
        // bounce to login instead of silently proceeding.
        if (FirebaseAuth.instance.currentUser == null) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => BlocProvider(
              create: (context) => getIt<LoginCubit>(),
              child: const LoginScreen(),
            ),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<CheckoutCubit>(
              param1: settings.arguments as CheckoutArgs?,
            )..loadCheckout(),
            child: const CheckoutScreen(),
          ),
        );
      case Routes.orderSuccessScreen:
        // The checkout bloc listener pushes the created order's ID — the
        // success screen shows it in its copy ('Order #<id> — pay cash …').
        final orderId = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => OrderSuccessScreen(
            orderId: orderId is String ? orderId : '',
          ),
        );
      case Routes.myOrdersScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<OrdersCubit>(),
            child: const MyOrdersScreen(),
          ),
        );
      case Routes.orderDetailsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<OrdersCubit>(),
            child: const OrderDetailsScreen(),
          ),
        );
      case Routes.adminDashboardScreen:
        // ProfileCubit backs the AppBar logout (admins never see the
        // customer Profile screen); its constructor has no side effects, so
        // a plain factory provider is enough.
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<ProfileCubit>(),
            child: const AdminDashboardScreen(),
          ),
        );
      case Routes.adminProductFormScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AdminProductFormScreen(),
        );
      case Routes.adminProducts:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminProductsCubit>(),
            child: const AdminProductsScreen(),
          ),
        );
      case Routes.adminOrders:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminOrdersCubit>(),
            child: const AdminOrdersScreen(),
          ),
        );
      case Routes.adminOrderDetails:
        final orderId = settings.arguments as String;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminOrdersCubit>(),
            child: AdminOrderDetailsScreen(orderId: orderId),
          ),
        );
      // =============== END AGENT C: CHECKOUT & ORDERS & ADMIN ================

      default:
        return null;
    }
  }
}
