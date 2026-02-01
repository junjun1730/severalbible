import 'package:flutter/material.dart';
import '../../../../core/widgets/app_button.dart';

/// Shows the onboarding popup to convert guest users to members
Future<void> showOnboardingPopup(
  BuildContext context, {
  VoidCallback? onSignIn,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => OnboardingPopup(onSignIn: onSignIn),
  );
}

/// Onboarding popup widget for guest user conversion
class OnboardingPopup extends StatelessWidget {
  final VoidCallback? onSignIn;

  const OnboardingPopup({super.key, this.onSignIn});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              'Unlock More Grace',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Message
            Text(
              'Sign in to receive 3x more daily grace and save your spiritual journey.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Benefits list
            _buildBenefitItem(
              context,
              icon: Icons.add_circle_outline,
              text: '3 scriptures per day (instead of 1)',
            ),
            const SizedBox(height: 8),
            _buildBenefitItem(
              context,
              icon: Icons.edit_note,
              text: 'Write and save prayer notes',
            ),
            const SizedBox(height: 8),
            _buildBenefitItem(
              context,
              icon: Icons.history,
              text: 'Access your spiritual archive',
            ),
            const SizedBox(height: 24),
            // Sign in button
            AppButton.primary(
              onPressed: () {
                Navigator.of(context).pop();
                onSignIn?.call();
              },
              text: 'Sign In Now',
              fullWidth: true,
            ),
            const SizedBox(height: 12),
            // Maybe later button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Maybe later',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}
