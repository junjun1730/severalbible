import 'package:flutter/material.dart';

/// Application theme configuration using Material 3 design system
/// with custom purple branding (#7C6FE8) and system fonts.
///
/// This class provides static theme configurations for the One Message app.
/// All themes use Material 3 design system with:
/// - Purple brand color (#7C6FE8)
/// - System fonts (no custom fonts for performance)
/// - 56dp button heights with 16px border radius
/// - Consistent spacing and typography
///
/// Example usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
/// )
/// ```
class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  /// Primary brand purple color (#7C6FE8)
  ///
  /// This color is used as the seed for Material 3 ColorScheme generation,
  /// which creates a harmonious palette of colors for the app.
  static const Color _primaryPurple = Color(0xFF7C6FE8);

  /// Light theme configuration for the One Message app.
  ///
  /// Features:
  /// - Material 3 design system enabled
  /// - Purple color scheme generated from brand color
  /// - System fonts for optimal performance
  /// - Unified button styling (56dp height, 16px radius)
  /// - Card theme with rounded corners (24px radius)
  /// - Complete Material 3 text theme scale
  ///
  /// All buttons (Elevated, Filled, Outlined) have:
  /// - Height: 56dp (minimum touch target)
  /// - Border radius: 16px
  /// - Horizontal padding: 24px
  /// - Vertical padding: 16px
  static ThemeData get lightTheme {
    // Generate Material 3 color scheme from brand purple
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryPurple,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Text theme with system fonts (no custom fontFamily)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          height: 1.16,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          height: 1.22,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          height: 1.29,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          height: 1.33,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.50,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.43,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.50,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.33,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
      ),

      // Elevated button theme: 56dp height, 16px border radius
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Filled button theme: Purple background, 56dp height, 16px radius
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Outlined button theme: Purple border, 56dp height, 16px radius
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: colorScheme.primary, width: 1),
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Card theme: Elevation 1, rounded corners
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(0),
      ),
    );
  }
}
