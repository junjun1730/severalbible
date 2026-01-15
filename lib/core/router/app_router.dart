import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/home_screen.dart';
import '../../features/auth/providers/auth_providers.dart';

/// App routes
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
}

/// GoRouter configuration provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = ref.read(isLoggedInProvider);
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isLogin = state.matchedLocation == AppRoutes.login;

      // Allow splash screen always
      if (isSplash) return null;

      // If on login and logged in, go to home
      if (isLogin && isLoggedIn) return AppRoutes.home;

      return null;
    },
  );
});
