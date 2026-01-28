import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    group('lightTheme', () {
      late ThemeData theme;

      setUp(() {
        theme = AppTheme.lightTheme;
      });

      test('should_create_light_theme_with_purple_seed_color', () {
        // Arrange & Act
        final colorScheme = theme.colorScheme;

        // Assert - Material 3 generates colors from seed, so check it's purple-ish
        // The primary color should have high blue/red components (purple range)
        expect(colorScheme.primary.blue, greaterThan(100));
        expect(colorScheme.primary.red, greaterThan(50));
        expect(colorScheme.primary, isNotNull);
      });

      test('should_use_material3_design_system', () {
        // Assert
        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme, isNotNull);
      });

      test('should_configure_system_fonts_without_google_fonts', () {
        // Assert - system fonts means fontFamily is null or default (Roboto/SF Pro)
        // We're just verifying no custom google_fonts package is used
        final bodyFont = theme.textTheme.bodyLarge?.fontFamily;
        final headlineFont = theme.textTheme.headlineMedium?.fontFamily;

        // Should be null or default system font (Roboto on Android, SF Pro on iOS)
        expect(bodyFont == null || bodyFont == 'Roboto' || bodyFont == '.SF Pro Text', isTrue);
        expect(headlineFont == null || headlineFont == 'Roboto' || headlineFont == '.SF Pro Text', isTrue);
      });

      test('should_define_text_theme_scale', () {
        // Arrange
        final textTheme = theme.textTheme;

        // Assert - verify key text styles exist
        expect(textTheme.displayLarge, isNotNull);
        expect(textTheme.headlineMedium, isNotNull);
        expect(textTheme.bodyLarge, isNotNull);
        expect(textTheme.bodyMedium, isNotNull);
        expect(textTheme.labelLarge, isNotNull);
      });

      test('should_configure_elevated_button_style', () {
        // Arrange
        final buttonStyle = theme.elevatedButtonTheme.style;

        // Assert
        final size = buttonStyle?.minimumSize?.resolve({});
        expect(size?.height, equals(56.0));

        final shape = buttonStyle?.shape?.resolve({}) as RoundedRectangleBorder?;
        final borderRadius = shape?.borderRadius as BorderRadius?;
        expect(borderRadius?.topLeft.x, equals(16.0));
      });

      test('should_configure_filled_button_style', () {
        // Arrange
        final buttonStyle = theme.filledButtonTheme.style;

        // Assert
        final size = buttonStyle?.minimumSize?.resolve({});
        expect(size?.height, equals(56.0));

        final backgroundColor = buttonStyle?.backgroundColor?.resolve({});
        expect(backgroundColor, equals(theme.colorScheme.primary));

        final shape = buttonStyle?.shape?.resolve({}) as RoundedRectangleBorder?;
        final borderRadius = shape?.borderRadius as BorderRadius?;
        expect(borderRadius?.topLeft.x, equals(16.0));
      });

      test('should_configure_outlined_button_style', () {
        // Arrange
        final buttonStyle = theme.outlinedButtonTheme.style;

        // Assert
        final size = buttonStyle?.minimumSize?.resolve({});
        expect(size?.height, equals(56.0));

        final side = buttonStyle?.side?.resolve({});
        expect(side?.color, equals(theme.colorScheme.primary));

        final shape = buttonStyle?.shape?.resolve({}) as RoundedRectangleBorder?;
        final borderRadius = shape?.borderRadius as BorderRadius?;
        expect(borderRadius?.topLeft.x, equals(16.0));
      });

      test('should_configure_card_theme', () {
        // Arrange
        final cardTheme = theme.cardTheme;

        // Assert
        expect(cardTheme.elevation, isNotNull);
        expect(cardTheme.shape, isNotNull);

        final shape = cardTheme.shape as RoundedRectangleBorder?;
        final borderRadius = shape?.borderRadius as BorderRadius?;
        expect(borderRadius, isNotNull);
      });
    });
  });
}
