import 'package:flutter/material.dart';

/// A widget that indicates whether a date's content is accessible
/// Shows lock icon for inaccessible dates (Member tier) and unlock for accessible
class DateAccessibilityIndicator extends StatelessWidget {
  final bool isAccessible;
  final VoidCallback? onLockedTap;

  const DateAccessibilityIndicator({
    super.key,
    required this.isAccessible,
    this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isAccessible) {
      return Icon(
        Icons.lock_open,
        size: 16,
        color: Theme.of(context).colorScheme.primary,
      );
    }

    return GestureDetector(
      onTap: onLockedTap,
      child: Icon(
        Icons.lock,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
