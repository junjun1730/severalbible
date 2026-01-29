import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/theme/app_spacing.dart';
import 'package:severalbible/core/theme/app_colors.dart';
import 'package:severalbible/core/theme/app_typography.dart';
import 'package:severalbible/core/theme/theme_extensions.dart';

void main() {
  group('ThemeExtensions', () {
    testWidgets('should_provide_spacing_extension_on_buildcontext',
        (WidgetTester tester) async {
      Type? capturedType;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedType = context.spacing;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedType, isNotNull);
      expect(capturedType, equals(AppSpacing));
    });

    testWidgets('should_provide_colors_extension_on_buildcontext',
        (WidgetTester tester) async {
      Type? capturedType;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedType = context.colors;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedType, isNotNull);
      expect(capturedType, equals(AppColors));
    });

    testWidgets('should_provide_typography_extension_on_buildcontext',
        (WidgetTester tester) async {
      Type? capturedType;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedType = context.textStyles;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedType, isNotNull);
      expect(capturedType, equals(AppTypography));
    });
  });
}
