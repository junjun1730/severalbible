import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/theme/app_typography.dart';

void main() {
  group('AppTypography', () {
    late TextTheme textTheme;

    setUp(() {
      textTheme = AppTypography.textTheme;
    });

    test('should_define_display_text_styles', () {
      // Arrange & Act
      final displayLarge = textTheme.displayLarge;
      final displayMedium = textTheme.displayMedium;
      final displaySmall = textTheme.displaySmall;

      // Assert
      expect(displayLarge, isNotNull);
      expect(displayMedium, isNotNull);
      expect(displaySmall, isNotNull);

      // Verify proper hierarchy (decreasing font sizes)
      expect(displayLarge!.fontSize, greaterThan(displayMedium!.fontSize!));
      expect(displayMedium.fontSize, greaterThan(displaySmall!.fontSize!));

      // Verify font weight is defined
      expect(displayLarge.fontWeight, isNotNull);
      expect(displayMedium.fontWeight, isNotNull);
      expect(displaySmall.fontWeight, isNotNull);

      // Verify line height is defined
      expect(displayLarge.height, isNotNull);
      expect(displayMedium.height, isNotNull);
      expect(displaySmall.height, isNotNull);
    });

    test('should_define_headline_text_styles', () {
      // Arrange & Act
      final headlineLarge = textTheme.headlineLarge;
      final headlineMedium = textTheme.headlineMedium;
      final headlineSmall = textTheme.headlineSmall;

      // Assert
      expect(headlineLarge, isNotNull);
      expect(headlineMedium, isNotNull);
      expect(headlineSmall, isNotNull);

      // Verify proper hierarchy (decreasing font sizes)
      expect(headlineLarge!.fontSize, greaterThan(headlineMedium!.fontSize!));
      expect(headlineMedium.fontSize, greaterThan(headlineSmall!.fontSize!));

      // Verify font weight is defined
      expect(headlineLarge.fontWeight, isNotNull);
    });

    test('should_define_body_text_styles', () {
      // Arrange & Act
      final bodyLarge = textTheme.bodyLarge;
      final bodyMedium = textTheme.bodyMedium;
      final bodySmall = textTheme.bodySmall;

      // Assert - all body styles exist
      expect(bodyLarge, isNotNull);
      expect(bodyMedium, isNotNull);
      expect(bodySmall, isNotNull);

      // Verify line height for readability (Korean text needs 1.5-1.6)
      expect(bodyLarge!.height, greaterThanOrEqualTo(1.4));
      expect(bodyLarge.height, lessThanOrEqualTo(1.7));

      expect(bodyMedium!.height, greaterThanOrEqualTo(1.4));
      expect(bodyMedium.height, lessThanOrEqualTo(1.7));

      // Verify proper hierarchy
      expect(bodyLarge.fontSize, greaterThan(bodyMedium.fontSize!));
      expect(bodyMedium.fontSize, greaterThan(bodySmall!.fontSize!));
    });

    test('should_define_label_text_styles', () {
      // Arrange & Act
      final labelLarge = textTheme.labelLarge;
      final labelMedium = textTheme.labelMedium;
      final labelSmall = textTheme.labelSmall;

      // Assert - all label styles exist
      expect(labelLarge, isNotNull);
      expect(labelMedium, isNotNull);
      expect(labelSmall, isNotNull);

      // Verify proper hierarchy
      expect(labelLarge!.fontSize, greaterThan(labelMedium!.fontSize!));
      expect(labelMedium.fontSize, greaterThan(labelSmall!.fontSize!));

      // Label styles should have medium weight (for buttons)
      expect(labelLarge.fontWeight, equals(FontWeight.w500));
      expect(labelMedium.fontWeight, equals(FontWeight.w500));
      expect(labelSmall.fontWeight, equals(FontWeight.w500));
    });

    test('should_use_system_font_family', () {
      // Assert - system fonts means fontFamily is null or default
      final bodyFont = textTheme.bodyLarge?.fontFamily;
      final headlineFont = textTheme.headlineMedium?.fontFamily;

      // Should be null or default system font (Roboto on Android, SF Pro on iOS)
      expect(
        bodyFont == null || bodyFont == 'Roboto' || bodyFont == '.SF Pro Text',
        isTrue,
      );
      expect(
        headlineFont == null ||
            headlineFont == 'Roboto' ||
            headlineFont == '.SF Pro Text',
        isTrue,
      );
    });
  });
}
