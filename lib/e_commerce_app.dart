import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/dependency_injection.dart';
import 'core/helpers/constants.dart';
import 'core/routing/app_router.dart';
import 'core/theming/colors.dart';
import 'features/admin/ui/screens/admin_dashboard_screen.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/auth/logic/cubit/login_cubit.dart';
import 'features/auth/ui/screens/login_screen.dart';
import 'features/catalog/ui/screens/home_screen.dart';

class ECommerceApp extends StatelessWidget {
  final AppRouter appRouter;
  const ECommerceApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title: 'E-Commerce',
        theme: ThemeData(
          primaryColor: ColorsManager.mainGreen,
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        onGenerateRoute: appRouter.generateRoute,
        home: const AuthGate(),
      ),
    );
  }
}

/// Boot-flow gate (PRD §1): auth state → role from Firestore → Customer UI or
/// Admin dashboard. The role is trusted from the server-side user document, so
/// regular users cannot grant themselves Admin from the app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingView();
        }
        final user = snapshot.data;
        if (user == null) {
          return BlocProvider(
            create: (context) => getIt<LoginCubit>(),
            child: const LoginScreen(),
          );
        }
        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection(Collections.users)
              .doc(user.uid)
              .get(),
          builder: (context, docSnap) {
            if (docSnap.connectionState != ConnectionState.done) {
              return const _LoadingView();
            }
            final doc = docSnap.data;
            final UserModel userModel;
            if (doc == null || !doc.exists || doc.data() == null) {
              // Self-heal (register race: authStateChanges can fire before the
              // user doc lands): create the doc from the auth profile so the
              // role lookup always lands on a real document.
              userModel = UserModel(
                name: user.displayName ?? 'User',
                email: user.email ?? '',
              );
              FirebaseFirestore.instance
                  .collection(Collections.users)
                  .doc(user.uid)
                  .set(userModel.toJson());
            } else {
              userModel = UserModel.fromJson(doc.data()!);
            }
            return userModel.isAdmin
                ? const AdminDashboardScreen()
                : const HomeScreen();
          },
        );
      },
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
