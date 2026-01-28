import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    test('should_define_primary_purple_color', () {
      // Arrange & Act
      final primaryColor = AppColors.primary;

      // Assert - RGB values should match exactly
      expect(primaryColor, equals(const Color(0xFF7C6FE8)));
      expect(primaryColor.red, equals(124));
      expect(primaryColor.green, equals(111));
      expect(primaryColor.blue, equals(232));
    });

    test('should_define_surface_colors', () {
      // Assert - all surface colors should be defined
      expect(AppColors.surface, isNotNull);
      expect(AppColors.surfaceVariant, isNotNull);
      expect(AppColors.surfaceContainer, isNotNull);
      expect(AppColors.background, isNotNull);

      // Surface colors should be light (for light theme)
      expect(AppColors.surface.computeLuminance(), greaterThan(0.5));
      expect(AppColors.background.computeLuminance(), greaterThan(0.5));
    });

    test('should_define_text_colors', () {
      // Assert - all text colors should be defined
      expect(AppColors.onPrimary, isNotNull);
      expect(AppColors.onSurface, isNotNull);
      expect(AppColors.onBackground, isNotNull);

      // Text on primary (purple) should be light
      expect(AppColors.onPrimary.computeLuminance(), greaterThan(0.5));

      // Text on surface/background should be dark
      expect(AppColors.onSurface.computeLuminance(), lessThan(0.5));
      expect(AppColors.onBackground.computeLuminance(), lessThan(0.5));
    });

    test('should_define_semantic_colors', () {
      // Assert - all semantic colors should be defined
      expect(AppColors.success, isNotNull);
      expect(AppColors.warning, isNotNull);
      expect(AppColors.error, isNotNull);
      expect(AppColors.info, isNotNull);

      // Semantic colors should be recognizable
      // Success: green-ish (high green component)
      expect(AppColors.success.green, greaterThan(AppColors.success.red));
      expect(AppColors.success.green, greaterThan(AppColors.success.blue));

      // Warning: yellow/orange-ish (high red and green)
      expect(AppColors.warning.red, greaterThan(150));
      expect(AppColors.warning.green, greaterThan(100));

      // Error: red-ish (high red component)
      expect(AppColors.error.red, greaterThan(AppColors.error.green));
      expect(AppColors.error.red, greaterThan(AppColors.error.blue));

      // Info: blue-ish (high blue component)
      expect(AppColors.info.blue, greaterThan(AppColors.info.red));
      expect(AppColors.info.blue, greaterThan(AppColors.info.green));
    });

    test('should_define_gradient_colors_for_cards', () {
      // Assert - gradient colors should be defined
      expect(AppColors.primaryGradientStart, isNotNull);
      expect(AppColors.primaryGradientEnd, isNotNull);

      // Gradient colors should be purple-ish
      expect(AppColors.primaryGradientStart.blue, greaterThan(100));
      expect(AppColors.primaryGradientEnd.blue, greaterThan(100));

      // Start and end should be different colors
      expect(AppColors.primaryGradientStart, isNot(equals(AppColors.primaryGradientEnd)));
    });
  });
}
