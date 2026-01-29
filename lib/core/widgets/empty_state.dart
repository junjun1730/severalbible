import 'package:flutter/material.dart';
import 'package:severalbible/core/theme/app_spacing.dart';

/// Empty state component with minimal design.
///
/// Displays an icon in a rounded container, title, subtitle, and optional action button.
/// Used to show users when a list or collection is empty.
///
/// Design features:
/// - Icon in rounded square container with light purple background
/// - Title (headlineSmall, center-aligned)
/// - Subtitle (bodyMedium, gray, center-aligned)
/// - Optional action button
/// - 24px spacing between elements
/// - All content centered vertically and horizontally
///
/// Example usage:
/// ```dart
/// // Basic empty state
/// EmptyState(
///   icon: Icons.inbox,
///   title: 'No messages',
///   subtitle: 'Your inbox is empty',
/// )
///
/// // With action button
/// EmptyState(
///   icon: Icons.add_circle_outline,
///   title: 'No items',
///   subtitle: 'Get started by adding your first item',
///   actionButton: ElevatedButton(
///     onPressed: () => addItem(),
///     child: Text('Add Item'),
///   ),
/// )
/// ```
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionButton,
    super.key,
  });

  /// Icon to display in the rounded container.
  final IconData icon;

  /// Main title text (uses headlineSmall style).
  final String title;

  /// Subtitle text (uses bodyMedium style with gray color).
  final String subtitle;

  /// Optional action button shown below the subtitle.
  final Widget? actionButton;

  /// Size of the icon container.
  static const double _iconContainerSize = 80.0;

  /// Border radius of the icon container.
  static const double _iconContainerRadius = 20.0;

  /// Icon size inside the container.
  static const double _iconSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon in rounded container
          _IconContainer(
            icon: icon,
            size: _iconContainerSize,
            radius: _iconContainerRadius,
            iconSize: _iconSize,
            backgroundColor: colorScheme.primaryContainer,
            iconColor: colorScheme.primary,
          ),

          // Spacing between icon and title
          SizedBox(height: AppSpacing.lg),

          // Title
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          // Spacing between title and subtitle
          SizedBox(height: AppSpacing.md),

          // Subtitle with gray color
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Optional action button
          if (actionButton != null) ...[
            SizedBox(height: AppSpacing.lg),
            actionButton!,
          ],
        ],
      ),
    );
  }
}

/// Private widget for the icon container.
class _IconContainer extends StatelessWidget {
  const _IconContainer({
    required this.icon,
    required this.size,
    required this.radius,
    required this.iconSize,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final double size;
  final double radius;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}
