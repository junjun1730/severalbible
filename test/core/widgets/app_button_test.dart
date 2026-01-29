import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/widgets/app_button.dart';

void main() {
  group('AppButton.primary', () {
    testWidgets('should create primary button with 56dp height',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              onPressed: () {},
              text: 'Primary Button',
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final buttonStyle = button.style;

      // Verify minimum size (height should be 56dp)
      final size = buttonStyle?.minimumSize?.resolve({});
      expect(size?.height, equals(56.0));

      // Verify border radius (16px)
      final shape = buttonStyle?.shape?.resolve({});
      expect(shape, isA<RoundedRectangleBorder>());
      final roundedShape = shape as RoundedRectangleBorder;
      expect(
        roundedShape.borderRadius,
        equals(BorderRadius.circular(16)),
      );
    });
  });

  group('AppButton.secondary', () {
    testWidgets('should create secondary button with 56dp height',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.secondary(
              onPressed: () {},
              text: 'Secondary Button',
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final buttonStyle = button.style;

      // Verify minimum size (height should be 56dp)
      final size = buttonStyle?.minimumSize?.resolve({});
      expect(size?.height, equals(56.0));

      // Verify border radius (16px)
      final shape = buttonStyle?.shape?.resolve({});
      expect(shape, isA<RoundedRectangleBorder>());
      final roundedShape = shape as RoundedRectangleBorder;
      expect(
        roundedShape.borderRadius,
        equals(BorderRadius.circular(16)),
      );
    });
  });

  group('AppButton.text', () {
    testWidgets('should create text button with proper styling',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.text(
              onPressed: () {},
              text: 'Text Button',
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button, isNotNull);

      // Text buttons should have proper padding
      final buttonStyle = button.style;
      final padding = buttonStyle?.padding?.resolve({});
      expect(padding, isNotNull);
    });
  });

  group('AppButton disabled state', () {
    testWidgets('should handle disabled state when onPressed is null',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              onPressed: null, // Disabled
              text: 'Disabled Button',
            ),
          ),
        ),
      );

      // Assert
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      // Button should not be tappable
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      // No error should occur when tapping disabled button
    });
  });

  group('AppButton loading state', () {
    testWidgets('should show CircularProgressIndicator when loading',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              onPressed: () {},
              text: 'Loading Button',
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Text should not be visible when loading
      expect(find.text('Loading Button'), findsNothing);
    });

    testWidgets('should disable onPressed when loading',
        (WidgetTester tester) async {
      var tapCount = 0;

      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              onPressed: () {
                tapCount++;
              },
              text: 'Loading Button',
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert - button should be disabled during loading
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      // Attempting to tap should not trigger callback
      await tester.tap(find.byType(FilledButton));
      await tester.pump(); // Use pump() instead of pumpAndSettle() for loading states
      expect(tapCount, equals(0));
    });
  });

  group('AppButton with icon', () {
    testWidgets('should support icon with text',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              onPressed: () {},
              text: 'Button with Icon',
              icon: Icons.add,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Button with Icon'), findsOneWidget);

      // Icon and text should both be visible
      final icon = tester.widget<Icon>(find.byIcon(Icons.add));
      expect(icon, isNotNull);
    });
  });

  group('AppButton full width', () {
    testWidgets('should apply full width when specified',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: AppButton.primary(
                onPressed: () {},
                text: 'Full Width Button',
                fullWidth: true,
              ),
            ),
          ),
        ),
      );

      // Assert
      // Button should expand to parent width
      final buttonFinder = find.byType(FilledButton);
      expect(buttonFinder, findsOneWidget);

      // The button should be wrapped in a SizedBox with full width
      final buttonSize = tester.getSize(buttonFinder);
      expect(buttonSize.width, equals(300.0));
    });
  });
}
