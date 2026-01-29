import 'package:flutter/material.dart';
import 'app_spacing.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// BuildContext extensions for convenient theme access.
///
/// ## Available Extensions
/// - `context.spacing` - AppSpacing (spacing scale, dimensions)
/// - `context.colors` - AppColors (color palette, gradients)
/// - `context.textStyles` - AppTypography (text styles)
///
/// ## Usage Examples
/// ```dart
/// // Spacing access
/// Padding(
///   padding: EdgeInsets.all(context.spacing.md),
///   child: Container(
///     decoration: BoxDecoration(
///       borderRadius: BorderRadius.circular(context.spacing.cardRadius),
///     ),
///   ),
/// )
///
/// // Color access
/// Container(
///   color: context.colors.primary,
///   decoration: BoxDecoration(
///     gradient: context.colors.primaryGradient,
///   ),
/// )
///
/// // Typography access
/// Text(
///   'Title',
///   style: context.textStyles.textTheme.titleLarge,
/// )
/// ```
///
/// ## When to Use
/// - **Use extensions**: Inside Widget build methods (when you have BuildContext)
/// - **Use direct access**: Outside widgets (services, repositories, utilities)
///
/// ## Performance
/// Zero overhead - all extensions return static types. No object creation,
/// no memory allocation. All values are compile-time constants accessed directly
/// from the static classes (AppSpacing, AppColors, AppTypography).
///
/// ## Design Decision: Why Return Type?
/// These extensions return the Type (static class) rather than instances because:
/// - AppSpacing, AppColors, and AppTypography are stateless utility classes
/// - They only contain static members (no instance state)
/// - Returning Type has zero performance overhead
/// - Pattern: `context.spacing.md` directly accesses `AppSpacing.md`
extension ThemeExtensions on BuildContext {
  /// Access to spacing scale and dimensions.
  ///
  /// Provides consistent spacing values throughout the app.
  ///
  /// **Available properties:**
  /// - Spacing scale: `xs`, `sm`, `md`, `lg`, `xl`, `xxl`
  /// - Border radius: `cardRadius`, `buttonRadius`, `chipRadius`
  /// - Dimensions: `iconSize`, `appBarHeight`, `buttonHeight`
  ///
  /// **Example:**
  /// ```dart
  /// Padding(
  ///   padding: EdgeInsets.all(context.spacing.md),  // 16.0
  ///   child: ElevatedButton(...),  // Uses spacing.buttonHeight
  /// )
  /// ```
  Type get spacing => AppSpacing;

  /// Access to color palette and gradients.
  ///
  /// Provides the complete color system including brand colors,
  /// semantic colors, and gradients.
  ///
  /// **Available properties:**
  /// - Brand colors: `primary`, `primaryContainer`, `secondary`, etc.
  /// - Semantic colors: `error`, `success`, `warning`, `info`
  /// - Neutral colors: `neutral`, `neutralVariant`, `surface`, `background`
  /// - Gradients: `primaryGradient`, `surfaceGradient`, `cardGradient`
  ///
  /// **Example:**
  /// ```dart
  /// Container(
  ///   color: context.colors.primary,  // Purple #7C6FE8
  ///   decoration: BoxDecoration(
  ///     gradient: context.colors.primaryGradient,
  ///   ),
  /// )
  /// ```
  Type get colors => AppColors;

  /// Access to typography (text styles).
  ///
  /// Provides the complete Material 3 text style system.
  ///
  /// **Available properties:**
  /// - `textTheme`: Complete Material 3 TextTheme (displayLarge, titleLarge, etc.)
  /// - `baseTextStyle`: Base text style for custom extensions
  ///
  /// **Example:**
  /// ```dart
  /// Text(
  ///   'Title',
  ///   style: context.textStyles.textTheme.titleLarge,
  /// )
  /// Text(
  ///   'Body',
  ///   style: context.textStyles.textTheme.bodyMedium,
  /// )
  /// ```
  Type get textStyles => AppTypography;
}
