import 'package:flutter/material.dart';

/// Enum to specify which side the navigation arrow is on
enum NavigationSide { left, right }

/// A circular navigation arrow button for scripture card navigation
///
/// This widget provides a visually consistent navigation button that appears
/// on the left or right side of scripture cards. It features:
/// - Semi-transparent background for overlay visibility
/// - White icon for high contrast
/// - Disabled state with reduced opacity
/// - Proper accessibility labels
/// - Material touch target size (48x48dp)
class NavigationArrowButton extends StatelessWidget {
  /// The icon to display (typically arrow icons)
  final IconData icon;

  /// Callback when the button is pressed
  final VoidCallback onPressed;

  /// Whether the button is enabled
  final bool isEnabled;

  /// Which side of the screen this button is on (affects accessibility label)
  final NavigationSide side;

  const NavigationArrowButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.isEnabled,
    required this.side,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      constraints: const BoxConstraints(
        minWidth: 48,
        minHeight: 48,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: isEnabled ? onPressed : null,
        tooltip: side == NavigationSide.left ? 'Previous' : 'Next',
        iconSize: 24,
      ),
    );

    // Wrap in Opacity widget when disabled
    if (!isEnabled) {
      return Opacity(
        opacity: 0.3,
        child: button,
      );
    }

    return button;
  }
}
