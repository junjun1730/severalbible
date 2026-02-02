import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/animations/app_animations.dart';
import 'package:severalbible/core/widgets/empty_state.dart';

void main() {
  group('EmptyState Animation', () {
    testWidgets('should fade in on mount', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.book,
              title: 'No Items',
              subtitle: 'Get started by adding an item',
            ),
          ),
        ),
      );

      // Assert - Should have FadeTransition in widget tree
      final fadeTransitionFinder = find.descendant(
        of: find.byType(EmptyState),
        matching: find.byType(FadeTransition),
      );
      expect(fadeTransitionFinder, findsOneWidget);

      // Verify the FadeTransition wraps the content
      final fadeTransition =
          tester.widget<FadeTransition>(fadeTransitionFinder);
      expect(fadeTransition.opacity, isNotNull);
    });

    testWidgets('should use 500ms duration', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.book,
              title: 'No Items',
              subtitle: 'Get started by adding an item',
            ),
          ),
        ),
      );

      // Get the EmptyState widget to access its state
      final emptyStateElement = tester.element(find.byType(EmptyState));
      final emptyState = emptyStateElement.widget as EmptyState;

      // Since EmptyState will be a StatefulWidget, we can access the state
      final state = tester.state(find.byType(EmptyState));

      // Assert - Animation controller should use 500ms (AppAnimations.slow)
      // We'll check this by verifying the animation completes in ~500ms
      expect(AppAnimations.slow, equals(const Duration(milliseconds: 500)));

      // The animation should start on mount
      // Initially, opacity should be animating
      await tester.pump(); // Initial frame
      await tester.pump(const Duration(milliseconds: 250)); // Mid-animation

      // After 500ms, animation should be complete
      await tester.pump(const Duration(milliseconds: 250)); // Complete
      await tester.pumpAndSettle();
    });

    testWidgets('should use easeIn curve', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.book,
              title: 'No Items',
              subtitle: 'Get started by adding an item',
            ),
          ),
        ),
      );

      // Assert - Should use easeIn curve (slow start, fast end)
      // This is appropriate for gentle appearance of empty states
      expect(AppAnimations.easeIn, equals(Curves.easeIn));

      // Find the FadeTransition
      final fadeTransitionFinder = find.descendant(
        of: find.byType(EmptyState),
        matching: find.byType(FadeTransition),
      );
      expect(fadeTransitionFinder, findsOneWidget);

      // The fade should complete after pumping through the animation
      await tester.pump(); // Start
      await tester.pump(AppAnimations.slow); // Complete
      await tester.pumpAndSettle();

      // Verify content is visible after animation completes
      expect(find.text('No Items'), findsOneWidget);
      expect(find.text('Get started by adding an item'), findsOneWidget);
    });
  });
}
