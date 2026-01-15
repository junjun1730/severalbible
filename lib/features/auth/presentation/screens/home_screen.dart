import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_providers.dart';
import '../../domain/user_tier.dart';
import '../widgets/onboarding_popup.dart';
import '../../../../core/router/app_router.dart';

/// Home screen - Daily scripture feed
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndShowOnboarding();
  }

  Future<void> _checkAndShowOnboarding() async {
    // Small delay to let the screen build
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final tierAsync = ref.read(currentUserTierProvider);
    tierAsync.whenData((tier) {
      if (tier == UserTier.guest && mounted) {
        showOnboardingPopup(
          context,
          onSignIn: () => context.go(AppRoutes.login),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tierAsync = ref.watch(currentUserTierProvider);
    final isLoggedIn = ref.watch(isLoggedInProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('One Message'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final authRepo = ref.read(authRepositoryProvider);
                await authRepo.signOut();
                if (mounted) {
                  context.go(AppRoutes.login);
                }
              },
            ),
        ],
      ),
      body: tierAsync.when(
        data: (tier) => _buildContent(tier),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(UserTier tier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to One Message',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Your tier: ${tier.name}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            _getScriptureCount(tier),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getScriptureCount(UserTier tier) {
    switch (tier) {
      case UserTier.guest:
        return 'You can read 1 scripture per day';
      case UserTier.member:
        return 'You can read 3 scriptures per day';
      case UserTier.premium:
        return 'You have unlimited access';
    }
  }
}
