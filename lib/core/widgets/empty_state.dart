import 'package:flutter/material.dart';
import 'package:severalbible/core/animations/app_animations.dart';
import 'package:severalbible/core/theme/app_spacing.dart';

/// Empty state component with minimal design and fade-in animation.
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
/// - Gentle fade-in animation on mount (500ms, easeIn curve)
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
class EmptyState extends StatefulWidget {
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
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.slow, // 500ms for gentle appearance
      vsync: this,
    );
    // Start fade-in animation on mount
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Wrap entire content in FadeTransition for gentle appearance
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.easeIn, // Slow start, fast end
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon in rounded container
            _IconContainer(
              icon: widget.icon,
              size: EmptyState._iconContainerSize,
              radius: EmptyState._iconContainerRadius,
              iconSize: EmptyState._iconSize,
              backgroundColor: colorScheme.primaryContainer,
              iconColor: colorScheme.primary,
            ),

            // Spacing between icon and title
            SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              widget.title,
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
                widget.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Optional action button
            if (widget.actionButton != null) ...[
              SizedBox(height: AppSpacing.lg),
              widget.actionButton!,
            ],
          ],
        ),
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
