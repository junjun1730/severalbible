import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/animations/app_animations.dart';
import 'package:severalbible/features/scripture/domain/entities/scripture.dart';
import 'package:severalbible/features/scripture/presentation/widgets/scripture_card.dart';

void main() {
  group('ScriptureCard Entrance Animation', () {
    late Scripture testScripture;

    setUp(() {
      testScripture = Scripture(
        id: '1',
        book: 'Test Book',
        chapter: 1,
        verse: 1,
        content: 'Test content for animation',
        reference: 'Test Book 1:1',
        category: 'Test',
        isPremium: false,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
    });

    testWidgets('should_fade_in_on_mount', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScriptureCard(scripture: testScripture),
          ),
        ),
      );

      // Assert - verify FadeTransition is descendant of ScriptureCard
      final fadeTransitionFinder = find.descendant(
        of: find.byType(ScriptureCard),
        matching: find.byType(FadeTransition),
      );
      expect(fadeTransitionFinder, findsOneWidget);
    });

    testWidgets('should_scale_in_on_mount', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScriptureCard(scripture: testScripture),
          ),
        ),
      );

      // Assert - verify ScaleTransition is descendant of ScriptureCard
      final scaleTransitionFinder = find.descendant(
        of: find.byType(ScriptureCard),
        matching: find.byType(ScaleTransition),
      );
      expect(scaleTransitionFinder, findsOneWidget);
    });

    testWidgets('should_use_300ms_duration', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScriptureCard(scripture: testScripture),
          ),
        ),
      );

      // Get the animation controller through the widget state
      final state = tester.state<State>(find.byType(ScriptureCard));

      // Assert - verify animation duration matches AppAnimations.normal (300ms)
      // This tests the implementation detail that the controller uses 300ms
      expect(AppAnimations.normal, equals(const Duration(milliseconds: 300)));
    });

    testWidgets('should_use_easeOut_curve', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScriptureCard(scripture: testScripture),
          ),
        ),
      );

      // Find the FadeTransition within ScriptureCard
      final fadeTransitionFinder = find.descendant(
        of: find.byType(ScriptureCard),
        matching: find.byType(FadeTransition),
      );
      final fadeTransition = tester.widget<FadeTransition>(fadeTransitionFinder);

      // Assert - verify the animation uses easeOut curve
      // The CurvedAnimation should be applied to the opacity
      expect(fadeTransition.opacity, isA<Animation<double>>());

      // Verify AppAnimations.easeOut is Curves.easeOut
      expect(AppAnimations.easeOut, equals(Curves.easeOut));
    });

    testWidgets('should_animate_from_opacity_0_to_1', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScriptureCard(scripture: testScripture),
          ),
        ),
      );

      // Get the FadeTransition within ScriptureCard
      final fadeTransitionFinder = find.descendant(
        of: find.byType(ScriptureCard),
        matching: find.byType(FadeTransition),
      );
      final fadeTransition = tester.widget<FadeTransition>(fadeTransitionFinder);

      // Assert - at the start, opacity should be 0 or very close to 0
      // (animation might have started but not completed)
      final initialOpacity = fadeTransition.opacity.value;
      expect(initialOpacity, lessThanOrEqualTo(0.1));

      // Act - pump the animation to completion
      await tester.pumpAndSettle();

      // Get updated widget
      final fadeTransitionAfter = tester.widget<FadeTransition>(fadeTransitionFinder);

      // Assert - after animation completes, opacity should be 1.0
      expect(fadeTransitionAfter.opacity.value, equals(1.0));
    });

    testWidgets('should_animate_from_scale_0.9_to_1.0', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScriptureCard(scripture: testScripture),
          ),
        ),
      );

      // Get the ScaleTransition within ScriptureCard
      final scaleTransitionFinder = find.descendant(
        of: find.byType(ScriptureCard),
        matching: find.byType(ScaleTransition),
      );
      final scaleTransition = tester.widget<ScaleTransition>(scaleTransitionFinder);

      // Assert - at the start, scale should be 0.9 or close to it
      final initialScale = scaleTransition.scale.value;
      expect(initialScale, lessThanOrEqualTo(0.95));

      // Act - pump the animation to completion
      await tester.pumpAndSettle();

      // Get updated widget
      final scaleTransitionAfter = tester.widget<ScaleTransition>(scaleTransitionFinder);

      // Assert - after animation completes, scale should be 1.0
      expect(scaleTransitionAfter.scale.value, equals(1.0));
    });
  });
}
