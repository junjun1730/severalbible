import 'package:flutter/material.dart';

/// Application color palette design tokens.
///
/// This class defines all colors used in the One Message app, organized by:
/// - Primary brand colors (purple)
/// - Surface colors (backgrounds, cards)
/// - Text colors (on various backgrounds)
/// - Semantic colors (success, warning, error, info)
/// - Gradient colors (for scripture cards)
///
/// All colors are immutable constants for optimal performance.
///
/// Example usage:
/// ```dart
/// Container(
///   color: AppColors.primary,
///   child: Text(
///     'Hello',
///     style: TextStyle(color: AppColors.onPrimary),
///   ),
/// )
/// ```
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ============================================================================
  // PRIMARY COLORS
  // ============================================================================

  /// Primary brand purple color (#7C6FE8)
  ///
  /// Used for:
  /// - Primary buttons
  /// - Active states
  /// - Key UI elements
  /// - Focus indicators
  static const Color primary = Color(0xFF7C6FE8);

  /// Secondary purple variant (#A29BF6)
  ///
  /// Used for:
  /// - Secondary buttons
  /// - Hover states
  /// - Less prominent UI elements
  static const Color secondary = Color(0xFFA29BF6);

  /// Tertiary light purple (#E8E6FE)
  ///
  /// Used for:
  /// - Background tints
  /// - Subtle highlights
  /// - Disabled states
  static const Color tertiary = Color(0xFFE8E6FE);

  // ============================================================================
  // SURFACE COLORS
  // ============================================================================

  /// Primary surface color (white)
  ///
  /// Used for:
  /// - Card backgrounds
  /// - Dialog backgrounds
  /// - Bottom sheets
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface variant (very light gray)
  ///
  /// Used for:
  /// - Elevated surfaces
  /// - Hover states on surfaces
  /// - Differentiated backgrounds
  static const Color surfaceVariant = Color(0xFFF5F5F7);

  /// Surface container (off-white)
  ///
  /// Used for:
  /// - Container backgrounds
  /// - Grouped content areas
  /// - Nested surfaces
  static const Color surfaceContainer = Color(0xFFFAFAFC);

  /// Background color (very light purple tint)
  ///
  /// Used for:
  /// - App background
  /// - Screen backgrounds
  /// - Behind all content
  static const Color background = Color(0xFFF8F8FC);

  // ============================================================================
  // TEXT COLORS
  // ============================================================================

  /// Text color on primary purple background (white)
  ///
  /// Used for:
  /// - Text on primary buttons
  /// - Text on purple backgrounds
  /// - High contrast on primary
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Text color on surface (dark gray)
  ///
  /// Used for:
  /// - Primary text on light backgrounds
  /// - Body text
  /// - Headlines
  static const Color onSurface = Color(0xFF1C1C1E);

  /// Text color on background (dark gray)
  ///
  /// Used for:
  /// - Text on app background
  /// - General text content
  static const Color onBackground = Color(0xFF1C1C1E);

  /// Medium emphasis text (gray)
  ///
  /// Used for:
  /// - Secondary text
  /// - Captions
  /// - Subtitles
  static const Color textMedium = Color(0xFF8E8E93);

  /// Low emphasis text (light gray)
  ///
  /// Used for:
  /// - Disabled text
  /// - Placeholder text
  /// - Hints
  static const Color textLow = Color(0xFFC7C7CC);

  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================

  /// Success color (green)
  ///
  /// Used for:
  /// - Success messages
  /// - Completion states
  /// - Positive feedback
  static const Color success = Color(0xFF34C759);

  /// Warning color (orange)
  ///
  /// Used for:
  /// - Warning messages
  /// - Cautionary states
  /// - Attention needed
  static const Color warning = Color(0xFFFF9500);

  /// Error color (red)
  ///
  /// Used for:
  /// - Error messages
  /// - Failed states
  /// - Destructive actions
  static const Color error = Color(0xFFFF3B30);

  /// Info color (blue)
  ///
  /// Used for:
  /// - Information messages
  /// - Helpful hints
  /// - Neutral feedback
  static const Color info = Color(0xFF007AFF);

  // ============================================================================
  // GRADIENT COLORS
  // ============================================================================

  /// Primary gradient start color (purple)
  ///
  /// Used for:
  /// - Scripture card gradients
  /// - Premium feature highlights
  /// - Visual interest
  static const Color primaryGradientStart = Color(0xFF9B8FF9);

  /// Primary gradient end color (light purple)
  ///
  /// Used for:
  /// - Scripture card gradients (end)
  /// - Premium feature highlights (end)
  /// - Smooth color transitions
  static const Color primaryGradientEnd = Color(0xFFD4CFFF);

  /// Creates a primary purple gradient
  ///
  /// Returns a [LinearGradient] from [primaryGradientStart] to [primaryGradientEnd].
  ///
  /// Example usage:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     gradient: AppColors.primaryGradient,
  ///   ),
  /// )
  /// ```
  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryGradientStart, primaryGradientEnd],
      );
}
