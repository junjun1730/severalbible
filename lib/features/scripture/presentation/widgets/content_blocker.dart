import 'package:flutter/material.dart';
import '../../../auth/domain/user_tier.dart';

/// Widget that blocks content and prompts user action based on tier
class ContentBlocker extends StatelessWidget {
  final UserTier tier;
  final VoidCallback onAction;

  const ContentBlocker({super.key, required this.tier, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLockIcon(context),
          const SizedBox(height: 24),
          _buildTitle(context),
          const SizedBox(height: 12),
          _buildSubtitle(context),
          const SizedBox(height: 24),
          _buildBenefitsList(context),
          const SizedBox(height: 32),
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildLockIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.lock_outline,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final title = tier == UserTier.guest
        ? 'Log in to Continue'
        : 'Upgrade to Premium';

    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final subtitle = tier == UserTier.guest
        ? 'Sign in to receive 3 times more grace daily'
        : 'Get unlimited access to all scriptures';

    return Text(
      subtitle,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBenefitsList(BuildContext context) {
    final benefits = tier == UserTier.guest
        ? ['3 scriptures daily', 'Prayer note feature', 'Scripture history']
        : [
            'Unlimited scriptures',
            'Premium exclusive content',
            'Unlimited prayer archives',
          ];

    return Column(
      children: benefits
          .map((benefit) => _buildBenefitItem(context, benefit))
          .toList(),
    );
  }

  Widget _buildBenefitItem(BuildContext context, String benefit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(benefit, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final buttonText = tier == UserTier.guest
        ? 'Sign In'
        : 'Upgrade to Premium';

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onAction,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
