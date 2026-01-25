import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_providers.dart';
import '../../domain/user_tier.dart';
import '../widgets/onboarding_popup.dart';
import '../../../../core/router/app_router.dart';
import '../../../scripture/presentation/screens/daily_feed_screen.dart';
import '../../../subscription/presentation/widgets/upsell_dialog.dart';

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

    final user = ref.read(currentUserProvider);
    final isAnonymous = user?.isAnonymous ?? false;

    // 1. If Anonymous, show Onboarding Popup (Sign in incentive)
    if (isAnonymous && mounted) {
      showOnboardingPopup(context, onSignIn: () => context.go(AppRoutes.login));
      return;
    }

    // 2. If Logged in but NOT Premium, optionally show Upsell
    // We check if they are still on "guest" tier which equates to free tier here
    final tierAsync = ref.read(currentUserTierProvider);
    tierAsync.whenData((tier) {
      if (tier == UserTier.guest && !isAnonymous && mounted) {
        // Show Upsell Dialog for logged-in free users
        showDialog(
          context: context,
          builder: (context) => UpsellDialog(
            trigger: UpsellTrigger.contentExhausted,
            // Using contentExhausted as a generic "Upgrade" entry point for now
          ),
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
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: tierAsync.when(
        data: (tier) => const DailyFeedScreen(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
