/// Application spacing and dimension design tokens.
///
/// This class defines all spacing, padding, margin, and dimension values
/// used in the One Message app, following a 4px grid system for consistency.
///
/// Design System:
/// - 4px grid system (all values are multiples of 4)
/// - Material 3 touch target guidelines (minimum 48dp)
/// - Consistent spacing for visual hierarchy
/// - Responsive dimensions for different components
///
/// Example usage:
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(AppSpacing.md),
///   child: Text('Content'),
/// )
/// ```
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // ============================================================================
  // SPACING SCALE (4px grid system)
  // ============================================================================

  /// Extra small spacing (4dp)
  ///
  /// Used for:
  /// - Tight spacing between related elements
  /// - Icon padding
  /// - Minimal gaps
  static const double xs = 4.0;

  /// Small spacing (8dp)
  ///
  /// Used for:
  /// - Spacing between closely related items
  /// - List item internal padding
  /// - Compact layouts
  static const double sm = 8.0;

  /// Medium spacing (16dp)
  ///
  /// Used for:
  /// - Default spacing between UI elements
  /// - Card internal padding (horizontal)
  /// - Section margins
  static const double md = 16.0;

  /// Large spacing (24dp)
  ///
  /// Used for:
  /// - Spacing between major sections
  /// - Screen padding
  /// - Card internal padding (vertical)
  static const double lg = 24.0;

  /// Extra large spacing (32dp)
  ///
  /// Used for:
  /// - Large gaps between sections
  /// - Bottom navigation height
  /// - Modal padding
  static const double xl = 32.0;

  /// Extra extra large spacing (48dp)
  ///
  /// Used for:
  /// - Major section dividers
  /// - Empty state spacing
  /// - Large modal padding
  static const double xxl = 48.0;

  // ============================================================================
  // BUTTON DIMENSIONS
  // ============================================================================

  /// Standard button height (56dp)
  ///
  /// Meets Material 3 minimum touch target of 48dp.
  /// Used for all primary, secondary, and outlined buttons.
  static const double buttonHeight = 56.0;

  /// Button border radius (16px)
  ///
  /// Creates moderately rounded buttons that match the ui-sample design.
  static const double buttonRadius = 16.0;

  /// Button horizontal padding (24dp)
  ///
  /// Provides adequate spacing around button text.
  static const double buttonPaddingHorizontal = 24.0;

  /// Button vertical padding (16dp)
  ///
  /// Balances the 56dp height with text size.
  static const double buttonPaddingVertical = 16.0;

  /// Minimum touch target size (48dp)
  ///
  /// Material 3 minimum for accessibility.
  static const double minTouchTarget = 48.0;

  // ============================================================================
  // CARD DIMENSIONS
  // ============================================================================

  /// Card border radius (24px)
  ///
  /// Creates soft, rounded corners for scripture cards and content cards.
  /// Matches the ui-sample design.
  static const double cardRadius = 24.0;

  /// Card internal padding (24dp)
  ///
  /// Provides generous breathing room for card content.
  static const double cardPadding = 24.0;

  /// Card elevation (1dp)
  ///
  /// Subtle shadow for depth without being overwhelming.
  static const double cardElevation = 1.0;

  /// Card gap spacing (16dp)
  ///
  /// Space between cards in a list or grid.
  static const double cardGap = 16.0;

  // ============================================================================
  // MODAL DIMENSIONS
  // ============================================================================

  /// Modal/bottom sheet border radius (24px)
  ///
  /// Rounded corners for modals and bottom sheets.
  static const double modalRadius = 24.0;

  /// Modal maximum height ratio (0.9)
  ///
  /// Modals can take up to 90% of screen height, leaving space for status bar.
  static const double modalMaxHeightRatio = 0.9;

  /// Modal minimum height ratio (0.3)
  ///
  /// Minimum height for modals (30% of screen).
  static const double modalMinHeightRatio = 0.3;

  /// Modal drag handle width (40dp)
  ///
  /// Width of the drag handle indicator at the top of bottom sheets.
  static const double modalDragHandleWidth = 40.0;

  /// Modal drag handle height (4dp)
  ///
  /// Height of the drag handle indicator.
  static const double modalDragHandleHeight = 4.0;

  /// Modal horizontal padding (24dp)
  ///
  /// Side padding for modal content.
  static const double modalPaddingHorizontal = 24.0;

  /// Modal vertical padding (32dp)
  ///
  /// Top and bottom padding for modal content.
  static const double modalPaddingVertical = 32.0;

  // ============================================================================
  // SCREEN DIMENSIONS
  // ============================================================================

  /// Standard screen horizontal padding (24dp)
  ///
  /// Default side padding for screen content.
  static const double screenPaddingHorizontal = 24.0;

  /// Standard screen vertical padding (16dp)
  ///
  /// Default top/bottom padding for screen content.
  static const double screenPaddingVertical = 16.0;

  /// AppBar height (56dp)
  ///
  /// Standard Material 3 AppBar height.
  static const double appBarHeight = 56.0;

  // ============================================================================
  // ICON DIMENSIONS
  // ============================================================================

  /// Small icon size (16dp)
  static const double iconSizeSmall = 16.0;

  /// Medium icon size (24dp) - default
  static const double iconSizeMedium = 24.0;

  /// Large icon size (32dp)
  static const double iconSizeLarge = 32.0;

  /// Extra large icon size (48dp)
  static const double iconSizeXLarge = 48.0;

  /// Circular icon button size (48dp)
  ///
  /// For circular icon buttons (meets minimum touch target).
  static const double iconButtonSize = 48.0;

  /// Circular icon button radius (24px)
  ///
  /// Creates perfect circles for icon buttons.
  static const double iconButtonRadius = 24.0;

  // ============================================================================
  // PAGE INDICATOR DIMENSIONS
  // ============================================================================

  /// Page indicator dot size (8dp)
  static const double pageIndicatorDotSize = 8.0;

  /// Page indicator active dot size (10dp)
  static const double pageIndicatorActiveDotSize = 10.0;

  /// Page indicator dot spacing (8dp)
  static const double pageIndicatorDotSpacing = 8.0;
}
