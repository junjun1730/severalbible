import 'package:flutter/material.dart';

/// Reusable Material 3 button for meditation entry
///
/// This button provides a consistent, full-width interface for users to
/// leave meditation notes on scripture cards.
class MeditationButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onTap;

  const MeditationButton({
    super.key,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isEnabled ? onTap : null,
      icon: const Icon(Icons.edit_note),
      label: const Text('Leave Meditation'),
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
