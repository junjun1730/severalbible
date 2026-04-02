import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/providers/auth_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // GitHub Pages URLs
  static const String privacyPolicyUrl =
      'https://junjun1730.github.io/severalbible/privacy_policy.html';
  static const String termsOfServiceUrl =
      'https://junjun1730.github.io/severalbible/terms_of_service.html';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modal Header
          _buildModalHeader(context),

          // Settings Content
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 16),

                // Account Section
                _buildSectionHeader(context, 'Account'),
                _buildSignOutTile(context, ref),

                const Divider(height: 32),

                // Legal Section
                _buildSectionHeader(context, 'Legal'),
                _buildLegalTile(
                  context,
                  title: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                  url: privacyPolicyUrl,
                ),
                _buildLegalTile(
                  context,
                  title: 'Terms of Service',
                  icon: Icons.description_outlined,
                  url: termsOfServiceUrl,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Modal header with title and close button
  Widget _buildModalHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
      child: Row(
        children: [
          Text(
            '설정',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
          ),
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
              (error) {
                debugPrint('❌ [SettingsScreen] Sign out failed: $error');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sign out failed: $error')),
                );
              },
              (_) => context.go(AppRoutes.login),
            );
          }
        }
      },
    );
  }

  Widget _buildLegalTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String url,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.open_in_new, size: 20),
      onTap: () => _launchURL(context, url, title),
    );
  }

  Future<void> _launchURL(
    BuildContext context,
    String url,
    String title,
  ) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('❌ [SettingsScreen] Could not open URL: $url');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $title')),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [SettingsScreen] Error launching URL ($url): $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $title')),
        );
      }
    }
  }
}
