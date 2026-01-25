import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';
import '../../../auth/providers/auth_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPremiumAsync = ref.watch(hasPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Subscription Section
          _buildSectionHeader(context, 'Subscription'),
          hasPremiumAsync.when(
            data: (hasPremium) => hasPremium
                ? _buildManageSubscriptionTile(context)
                : _buildUpgradeTile(context),
            loading: () => const ListTile(
              leading: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              title: Text('Loading...'),
            ),
            error: (_, __) => _buildUpgradeTile(context),
          ),

          const Divider(height: 32),

          // Account Section
          _buildSectionHeader(context, 'Account'),
          _buildSignOutTile(context, ref),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUpgradeTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.star, color: Colors.amber),
      title: const Text('Upgrade to Premium'),
      subtitle: const Text('Unlock all features'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.push(AppRoutes.premium);
      },
    );
  }

  Widget _buildManageSubscriptionTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.card_membership, color: Colors.green),
      title: const Text('Manage Subscription'),
      subtitle: const Text('View or cancel your subscription'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context.push(AppRoutes.manageSubscription);
      },
    );
  }

  Widget _buildSignOutTile(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isLoggedIn = user != null;
    final isAnonymous = user?.isAnonymous ?? false;

    // Show Sign In if not logged in or if anonymous user
    if (!isLoggedIn || isAnonymous) {
      return ListTile(
        leading: const Icon(Icons.login, color: Colors.blue),
        title: const Text('Sign In / Register'),
        onTap: () => context.go(AppRoutes.login),
      );
    }

    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('Sign Out'),
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        );

        if (confirmed == true && context.mounted) {
          final authRepo = ref.read(authRepositoryProvider);
          final result = await authRepo.signOut();

          if (context.mounted) {
            result.fold(
              (error) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sign out failed: $error')),
              ),
              (_) => context.go(AppRoutes.login),
            );
          }
        }
      },
    );
  }
}
