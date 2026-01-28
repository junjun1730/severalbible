import 'package:flutter/material.dart';

/// Application typography design tokens.
///
/// This class defines the complete Material 3 text theme scale for the One Message app.
/// All text styles use system fonts (Roboto on Android, SF Pro on iOS) for optimal
/// performance and native feel.
///
/// Typography Scale:
/// - Display: Large decorative text (48sp - 36sp)
/// - Headline: Section headers (32sp - 24sp)
/// - Title: Prominent text (22sp - 14sp)
/// - Body: Main content text (16sp - 12sp) with 1.5-1.6 line height for readability
/// - Label: Button and UI labels (14sp - 11sp)
///
/// Example usage:
/// ```dart
/// Text(
///   'Scripture Text',
///   style: AppTypography.textTheme.bodyLarge,
/// )
/// ```
class AppTypography {
  AppTypography._(); // Private constructor to prevent instantiation

  // ============================================================================
  // FONT SIZE CONSTANTS
  // ============================================================================

  /// Display text font sizes
  static const double displayLargeSize = 57.0;
  static const double displayMediumSize = 45.0;
  static const double displaySmallSize = 36.0;

  /// Headline text font sizes
  static const double headlineLargeSize = 32.0;
  static const double headlineMediumSize = 28.0;
  static const double headlineSmallSize = 24.0;

  /// Title text font sizes
  static const double titleLargeSize = 22.0;
  static const double titleMediumSize = 16.0;
  static const double titleSmallSize = 14.0;

  /// Body text font sizes
  static const double bodyLargeSize = 16.0;
  static const double bodyMediumSize = 14.0;
  static const double bodySmallSize = 12.0;

  /// Label text font sizes
  static const double labelLargeSize = 14.0;
  static const double labelMediumSize = 12.0;
  static const double labelSmallSize = 11.0;

  // ============================================================================
  // LINE HEIGHT CONSTANTS
  // ============================================================================

  /// Line heights for display text (tighter for large text)
  static const double displayLineHeight = 1.12;

  /// Line heights for headline text
  static const double headlineLineHeight = 1.25;

  /// Line heights for title text
  static const double titleLineHeight = 1.4;

  /// Line heights for body text (optimal for Korean text readability)
  static const double bodyLineHeight = 1.5;

  /// Line heights for label text
  static const double labelLineHeight = 1.4;

  // ============================================================================
  // TEXT THEME
  // ============================================================================

  /// Complete Material 3 text theme with system fonts.
  ///
  /// All text styles use:
  /// - System default fonts (Roboto on Android, SF Pro on iOS)
  /// - Appropriate line heights for readability (1.5-1.6 for body text)
  /// - Material 3 font weight conventions
  ///
  /// Font Weights:
  /// - Regular (400): Body text, display text
  /// - Medium (500): Labels, buttons, titles
  /// - Bold (700): Strong emphasis (if needed)
  static TextTheme get textTheme => const TextTheme(
        // Display styles: Large decorative text
        displayLarge: TextStyle(
          fontSize: displayLargeSize,
          fontWeight: FontWeight.w400,
          height: displayLineHeight,
          letterSpacing: -0.25,
        ),
        displayMedium: TextStyle(
          fontSize: displayMediumSize,
          fontWeight: FontWeight.w400,
          height: 1.16,
          letterSpacing: 0,
        ),
        displaySmall: TextStyle(
          fontSize: displaySmallSize,
          fontWeight: FontWeight.w400,
          height: 1.22,
          letterSpacing: 0,
        ),

        // Headline styles: Section headers
        headlineLarge: TextStyle(
          fontSize: headlineLargeSize,
          fontWeight: FontWeight.w400,
          height: headlineLineHeight,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontSize: headlineMediumSize,
          fontWeight: FontWeight.w400,
          height: 1.29,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          fontSize: headlineSmallSize,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: 0,
        ),

        // Title styles: Prominent text
        titleLarge: TextStyle(
          fontSize: titleLargeSize,
          fontWeight: FontWeight.w400,
          height: 1.27,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          fontSize: titleMediumSize,
          fontWeight: FontWeight.w500,
          height: titleLineHeight,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontSize: titleSmallSize,
          fontWeight: FontWeight.w500,
          height: 1.43,
          letterSpacing: 0.1,
        ),

        // Body styles: Main content text (optimized for Korean readability)
        bodyLarge: TextStyle(
          fontSize: bodyLargeSize,
          fontWeight: FontWeight.w400,
          height: bodyLineHeight,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: bodyMediumSize,
          fontWeight: FontWeight.w400,
          height: 1.43,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: bodySmallSize,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: 0.4,
        ),

        // Label styles: Button and UI labels
        labelLarge: TextStyle(
          fontSize: labelLargeSize,
          fontWeight: FontWeight.w500,
          height: labelLineHeight,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: labelMediumSize,
          fontWeight: FontWeight.w500,
          height: 1.33,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: labelSmallSize,
          fontWeight: FontWeight.w500,
          height: 1.45,
          letterSpacing: 0.5,
        ),
      );

  /// Creates a text style with custom properties.
  ///
  /// Useful for creating one-off text styles that match the design system.
  ///
  /// Example:
  /// ```dart
  /// Text(
  ///   'Custom text',
  ///   style: AppTypography.custom(
  ///     fontSize: 18,
  ///     fontWeight: FontWeight.w600,
  ///     color: AppColors.primary,
  ///   ),
  /// )
  /// ```
  static TextStyle custom({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }
}
