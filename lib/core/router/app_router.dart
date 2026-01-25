import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/home_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/subscription/presentation/screens/premium_landing_screen.dart';
import '../../features/subscription/presentation/screens/manage_subscription_screen.dart';

/// App routes
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const settings = '/settings';
  static const premium = '/premium';
  static const manageSubscription = '/manage-subscription';
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
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.premium,
        builder: (context, state) => const PremiumLandingScreen(),
      ),
      GoRoute(
        path: AppRoutes.manageSubscription,
        builder: (context, state) => const ManageSubscriptionScreen(),
      ),
      GoRoute(
        path: '/login-callback',
        redirect: (context, state) {
          // OAuth callback is processed by Supabase automatically via deep link
          // Redirect to home - the global redirect will handle auth state
          return AppRoutes.home;
        },
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn = ref.read(isLoggedInProvider);
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isLogin = state.matchedLocation == AppRoutes.login;
      final isCallback = state.matchedLocation.startsWith('/login-callback');

      // Allow splash screen & callback always
      if (isSplash || isCallback) return null;

      final user = ref.read(currentUserProvider);
      final isAnonymous = user?.isAnonymous ?? false;

      // If on login and logged in (and NOT anonymous), go to home
      // Anonymous users should be able to see the login screen to sign in/up

      if (isLogin && isLoggedIn && !isAnonymous) return AppRoutes.home;

      // Guard: If not logged in and not on a public route, go to Login
      // This ensures that when signing out, the user is forced to the login screen
      final isPublic = isSplash || isLogin || isCallback;
      if (!isLoggedIn && !isPublic) return AppRoutes.login;

      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authStateChangesProvider.stream),
    ),
  );
});

/// Converts a [Stream] into a [Listenable] for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
