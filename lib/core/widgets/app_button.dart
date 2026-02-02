import 'package:flutter/material.dart';

/// Unified button system for One Message app.
///
/// Provides consistent button styling across the app with Material 3 design.
/// All buttons have:
/// - Height: 56dp (minimum touch target)
/// - Border radius: 16px
/// - Proper disabled and loading states
/// - Optional icon support
/// - Interactive states: hover elevation, ripple effects, focus indicators
///
/// Example usage:
/// ```dart
/// // Primary button (FilledButton with purple background)
/// AppButton.primary(
///   onPressed: () => print('Tapped'),
///   text: 'Continue',
/// )
///
/// // Secondary button (OutlinedButton)
/// AppButton.secondary(
///   onPressed: () => print('Tapped'),
///   text: 'Cancel',
/// )
///
/// // Text button
/// AppButton.text(
///   onPressed: () => print('Tapped'),
///   text: 'Skip',
/// )
///
/// // With icon
/// AppButton.primary(
///   onPressed: () {},
///   text: 'Add',
///   icon: Icons.add,
/// )
///
/// // Loading state
/// AppButton.primary(
///   onPressed: () {},
///   text: 'Loading...',
///   isLoading: true,
/// )
///
/// // Full width
/// AppButton.primary(
///   onPressed: () {},
///   text: 'Sign In',
///   fullWidth: true,
/// )
/// ```
class AppButton extends StatelessWidget {
  /// Creates a primary button (FilledButton with purple background).
  factory AppButton.primary({
    required VoidCallback? onPressed,
    required String text,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
    Key? key,
  }) {
    return AppButton._(
      onPressed: onPressed,
      text: text,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
      buttonType: _ButtonType.primary,
      key: key,
    );
  }

  /// Creates a secondary button (OutlinedButton).
  factory AppButton.secondary({
    required VoidCallback? onPressed,
    required String text,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
    Key? key,
  }) {
    return AppButton._(
      onPressed: onPressed,
      text: text,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
      buttonType: _ButtonType.secondary,
      key: key,
    );
  }

  /// Creates a text button (TextButton).
  factory AppButton.text({
    required VoidCallback? onPressed,
    required String text,
    IconData? icon,
    bool isLoading = false,
    bool fullWidth = false,
    Key? key,
  }) {
    return AppButton._(
      onPressed: onPressed,
      text: text,
      icon: icon,
      isLoading: isLoading,
      fullWidth: fullWidth,
      buttonType: _ButtonType.text,
      key: key,
    );
  }

  const AppButton._({
    required this.onPressed,
    required this.text,
    required this.buttonType,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    super.key,
  });

  /// Callback when button is pressed.
  /// If null, button is disabled.
  /// If [isLoading] is true, this is ignored.
  final VoidCallback? onPressed;

  /// Text to display on the button.
  final String text;

  /// Optional icon to display before text.
  final IconData? icon;

  /// Whether button is in loading state.
  /// When true, shows CircularProgressIndicator and disables button.
  final bool isLoading;

  /// Whether button should expand to full width of parent.
  final bool fullWidth;

  /// Internal button type.
  final _ButtonType buttonType;

  /// Button height following Material 3 specifications.
  static const double _buttonHeight = 56.0;

  /// Button border radius.
  static const double _borderRadius = 16.0;

  /// Horizontal padding inside button.
  static const double _horizontalPadding = 24.0;

  /// Vertical padding inside button.
  static const double _verticalPadding = 16.0;

  @override
  Widget build(BuildContext context) {
    // Button is disabled if onPressed is null or isLoading is true
    final effectiveOnPressed = (isLoading || onPressed == null) ? null : onPressed;

    final buttonChild = _buildButtonChild();

    final button = switch (buttonType) {
      _ButtonType.primary => FilledButton(
          onPressed: effectiveOnPressed,
          style: _buildButtonStyle(),
          child: buttonChild,
        ),
      _ButtonType.secondary => OutlinedButton(
          onPressed: effectiveOnPressed,
          style: _buildButtonStyle(),
          child: buttonChild,
        ),
      _ButtonType.text => TextButton(
          onPressed: effectiveOnPressed,
          style: _buildButtonStyle(),
          child: buttonChild,
        ),
    };

    // Wrap in SizedBox for full width if needed
    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  /// Builds the button child widget (icon + text or loading spinner).
  Widget _buildButtonChild() {
    // Show loading spinner when loading
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    // Show icon + text if icon is provided
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    // Show only text
    return Text(text);
  }

  /// Builds the button style with consistent sizing, radius, and interactive states.
  ///
  /// Includes:
  /// - Hover elevation changes (desktop/web)
  /// - Visible ripple effect on tap
  /// - Focus indicators for keyboard navigation
  ButtonStyle _buildButtonStyle() {
    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        const Size(0, _buttonHeight),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(
          horizontal: _horizontalPadding,
          vertical: _verticalPadding,
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
      ),
      // Elevation changes on hover for desktop/web
      // Primary buttons get subtle lift on hover
      elevation: _buildElevation(),
      // Overlay color controls ripple effect and focus/hover overlays
      overlayColor: _buildOverlayColor(),
    );
  }

  /// Builds elevation property with hover state support.
  ///
  /// Primary buttons:
  /// - Default: 1dp elevation
  /// - Hovered: 3dp elevation (subtle lift)
  /// - Pressed: 1dp elevation
  /// - Disabled: 0dp elevation
  ///
  /// Secondary and text buttons maintain flat appearance.
  WidgetStateProperty<double>? _buildElevation() {
    if (buttonType != _ButtonType.primary) {
      // Secondary and text buttons remain flat
      return null;
    }

    return WidgetStateProperty.resolveWith<double>((states) {
      if (states.contains(WidgetState.disabled)) {
        return 0.0;
      }
      if (states.contains(WidgetState.hovered)) {
        return 3.0; // Subtle lift on hover
      }
      if (states.contains(WidgetState.pressed)) {
        return 1.0; // Return to lower elevation when pressed
      }
      return 1.0; // Default elevation
    });
  }

  /// Builds overlay color for ripple effect and interaction states.
  ///
  /// Provides visible feedback for:
  /// - Tap/press (ripple effect)
  /// - Hover (subtle highlight)
  /// - Focus (keyboard navigation indicator)
  WidgetStateProperty<Color> _buildOverlayColor() {
    return WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.pressed)) {
        // Visible ripple effect on press
        return Colors.white.withOpacity(0.2);
      }
      if (states.contains(WidgetState.hovered)) {
        // Subtle highlight on hover
        return Colors.white.withOpacity(0.1);
      }
      if (states.contains(WidgetState.focused)) {
        // Focus indicator for keyboard navigation
        return Colors.white.withOpacity(0.15);
      }
      // No overlay for default state
      return Colors.transparent;
    });
  }
}

/// Internal enum for button type.
enum _ButtonType {
  primary,
  secondary,
  text,
}
