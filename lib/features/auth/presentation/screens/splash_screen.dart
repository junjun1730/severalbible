import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_providers.dart';
import '../../../../core/router/app_router.dart';

/// Splash screen shown at app launch
/// Checks auth state and navigates accordingly
class SplashScreen extends ConsumerStatefulWidget {
  /// Callback for navigation (used for testing)
  final void Function(bool isLoggedIn)? onAuthChecked;

  /// Whether to auto-navigate after auth check
  final bool autoNavigate;

  const SplashScreen({super.key, this.onAuthChecked, this.autoNavigate = true});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.autoNavigate) {
      _checkAuthAndNavigate();
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    // Small delay for splash display
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final isLoggedIn = ref.read(isLoggedInProvider);

    // Call callback if provided (for testing)
    widget.onAuthChecked?.call(isLoggedIn);

    if (widget.autoNavigate) {
      if (isLoggedIn) {
        // Check if user is anonymous
        final user = ref.read(currentUserProvider);
        if (user != null && !user.isAnonymous) {
          _navigateToHome();
        } else {
          _navigateToLogin();
        }
      } else {
        _navigateToLogin();
      }
    }
  }

  void _navigateToHome() {
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  void _navigateToLogin() {
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon placeholder
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                // App title
                Text(
                  'One Message',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                Text(
                  'Daily grace for your soul',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 48),
                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
