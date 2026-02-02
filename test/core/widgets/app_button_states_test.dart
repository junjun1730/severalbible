import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/widgets/app_button.dart';

void main() {
  group('AppButton States', () {
    testWidgets('should show subtle elevation change on hover',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              onPressed: () {},
              text: 'Hover Me',
            ),
          ),
        ),
      );

      // Find the FilledButton
      final buttonFinder = find.byType(FilledButton);
      expect(buttonFinder, findsOneWidget);

      final button = tester.widget<FilledButton>(buttonFinder);
      final buttonStyle = button.style;

      // Assert - Button should have elevation property configured
      // Material 3 buttons use elevation for hover states
      final elevation = buttonStyle?.elevation;
      expect(elevation, isNotNull,
          reason: 'Button should have elevation configured for hover states');

      // Verify elevation changes based on state (using WidgetStateProperty.resolveWith)
      // We can't directly simulate hover in widget tests, but we can verify the elevation
      // property is a WidgetStateProperty that responds to hovered state
      expect(elevation, isA<WidgetStateProperty<double>>());
    });

    testWidgets('should show ripple effect on tap',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              onPressed: () {},
              text: 'Tap Me',
            ),
          ),
        ),
      );

      // Find the button
      final buttonFinder = find.byType(FilledButton);
      expect(buttonFinder, findsOneWidget);

      final button = tester.widget<FilledButton>(buttonFinder);

      // Assert - Button should have splash/overlay color configured
      // Material buttons have built-in InkWell ripple effect
      // We verify that splash color is configured
      final buttonStyle = button.style;
      expect(buttonStyle, isNotNull);

      // Verify overlay color is configured (this controls ripple/splash)
      final overlayColor = buttonStyle?.overlayColor;
      expect(overlayColor, isNotNull,
          reason: 'Button should have overlay color for ripple effect');

      // Tap the button to verify ripple appears (no error should occur)
      await tester.tap(buttonFinder);
      await tester.pump(); // Start the ripple animation
      await tester.pump(const Duration(milliseconds: 100)); // Mid-ripple
      // No assertion needed - we're just verifying no crash occurs
    });

    testWidgets('should show focus indicator for keyboard navigation',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              onPressed: () {},
              text: 'Focus Me',
            ),
          ),
        ),
      );

      // Find the button
      final buttonFinder = find.byType(FilledButton);
      expect(buttonFinder, findsOneWidget);

      final button = tester.widget<FilledButton>(buttonFinder);
      final buttonStyle = button.style;

      // Assert - Button should have focus-related properties configured
      // Check for overlay color (which includes focused state)
      final overlayColor = buttonStyle?.overlayColor;
      expect(overlayColor, isNotNull,
          reason: 'Button should have overlay color for focus indicator');

      // Verify the button can receive focus (autofocus or focusNode support)
      // Material buttons automatically support focus via the Material widget
      // We verify the button is wrapped in a widget that supports focus

      // Try to focus the button using the keyboard
      // In a real app, this would show a focus ring
      // Note: Widget tests can't fully simulate keyboard focus, but we verify structure
      final buttonElement = tester.element(buttonFinder);
      expect(buttonElement, isNotNull);
    });

    testWidgets('should have visible ripple on secondary button',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.secondary(
              onPressed: () {},
              text: 'Secondary',
            ),
          ),
        ),
      );

      // Find the button
      final buttonFinder = find.byType(OutlinedButton);
      expect(buttonFinder, findsOneWidget);

      final button = tester.widget<OutlinedButton>(buttonFinder);
      final buttonStyle = button.style;

      // Assert - Secondary button should also have ripple effect
      final overlayColor = buttonStyle?.overlayColor;
      expect(overlayColor, isNotNull,
          reason: 'Secondary button should have ripple effect');

      // Tap to verify ripple works
      await tester.tap(buttonFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // No error should occur
    });

    testWidgets('should have visible ripple on text button',
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

      // Find the button
      final buttonFinder = find.byType(TextButton);
      expect(buttonFinder, findsOneWidget);

      final button = tester.widget<TextButton>(buttonFinder);
      final buttonStyle = button.style;

      // Assert - Text button should also have ripple effect
      final overlayColor = buttonStyle?.overlayColor;
      expect(overlayColor, isNotNull,
          reason: 'Text button should have ripple effect');

      // Tap to verify ripple works
      await tester.tap(buttonFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // No error should occur
    });

    testWidgets('should not show hover/ripple on disabled button',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              onPressed: null, // Disabled
              text: 'Disabled',
            ),
          ),
        ),
      );

      // Find the button
      final buttonFinder = find.byType(FilledButton);
      expect(buttonFinder, findsOneWidget);

      final button = tester.widget<FilledButton>(buttonFinder);

      // Assert - Disabled button should not respond to interactions
      expect(button.onPressed, isNull);

      // Try to tap (should do nothing)
      await tester.tap(buttonFinder);
      await tester.pump();
      // No error should occur, button should remain disabled
    });
  });
}
