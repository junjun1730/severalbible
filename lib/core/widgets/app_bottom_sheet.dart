import 'package:flutter/material.dart';
import 'package:severalbible/core/animations/app_animations.dart';

/// Material 3 bottom sheet utility for modal presentations.
///
/// Provides a consistent bottom sheet design with:
/// - Rounded top corners (24px radius)
/// - Drag handle for dismissing
/// - Safe area padding
/// - Customizable height
///
/// Example usage:
/// ```dart
/// AppBottomSheet.show(
///   context: context,
///   builder: (context) => MyContent(),
/// );
///
/// // With custom height
/// AppBottomSheet.show(
///   context: context,
///   maxHeight: 400,
///   builder: (context) => MyContent(),
/// );
/// ```
class AppBottomSheet {
  AppBottomSheet._();

  /// Default border radius for top corners.
  static const double _borderRadius = 24.0;

  /// Default max height as percentage of screen height.
  static const double _defaultMaxHeightFraction = 0.9;

  /// Shows a modal bottom sheet with Material 3 design and slide-up animation.
  ///
  /// Parameters:
  /// - [context]: Build context for navigation
  /// - [builder]: Function that builds the sheet content
  /// - [maxHeight]: Optional custom max height (defaults to 90% of screen)
  /// - [isDismissible]: Whether sheet can be dismissed by tapping outside (default: true)
  /// - [enableDrag]: Whether sheet can be dismissed by dragging (default: true)
  ///
  /// Returns a Future that resolves when the sheet is dismissed.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    double? maxHeight,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveMaxHeight = maxHeight ?? screenHeight * _defaultMaxHeightFraction;

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: AppAnimations.normal,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: _BottomSheetContent<T>(
            maxHeight: effectiveMaxHeight,
            enableDrag: enableDrag,
            builder: builder,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1), // Start from bottom
            end: Offset.zero, // End at final position
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: AppAnimations.easeOut,
            ),
          ),
          child: child,
        );
      },
    );
  }
}

/// Private bottom sheet content widget.
///
/// Wraps the user content in a Material 3 styled container
/// with rounded top corners, drag handle, and safe area.
class _BottomSheetContent<T> extends StatelessWidget {
  const _BottomSheetContent({
    required this.maxHeight,
    required this.enableDrag,
    required this.builder,
  });

  final double maxHeight;
  final bool enableDrag;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBottomSheet._borderRadius),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const _DragHandle(),

            // Content
            Flexible(
              child: builder(context),
            ),
          ],
        ),
      ),
    );

    // Wrap in GestureDetector for drag-to-dismiss if enabled
    if (enableDrag) {
      return GestureDetector(
        onVerticalDragUpdate: (details) {
          // Dismiss if dragged down significantly
          if (details.primaryDelta != null && details.primaryDelta! > 10) {
            Navigator.of(context).pop();
          }
        },
        child: content,
      );
    }

    return content;
  }
}

/// Private drag handle widget for bottom sheets.
///
/// Displays a centered gray rounded bar at the top of the sheet
/// to indicate that it can be dragged to dismiss.
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  /// Width of the drag handle.
  static const double _handleWidth = 32.0;

  /// Height of the drag handle.
  static const double _handleHeight = 4.0;

  /// Border radius of the drag handle.
  static const double _handleRadius = 2.0;

  /// Vertical padding around the drag handle.
  static const double _verticalPadding = 12.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
      child: Center(
        child: Container(
          width: _handleWidth,
          height: _handleHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(_handleRadius),
          ),
        ),
      ),
    );
  }
}
