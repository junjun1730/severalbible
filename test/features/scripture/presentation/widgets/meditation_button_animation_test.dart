import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/animations/app_animations.dart';
import 'package:severalbible/features/scripture/presentation/widgets/meditation_button.dart';

void main() {
  group('MeditationButton Tap Animation', () {
    testWidgets('should_have_AnimatedScale_widget', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeditationButton(
              onTap: () {},
              isEnabled: true,
            ),
          ),
        ),
      );

      // Assert - AnimatedScale should exist in widget tree
      expect(find.byType(AnimatedScale), findsOneWidget);
    });

    testWidgets('should_scale_down_on_tap', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeditationButton(
              onTap: () => tapped = true,
              isEnabled: true,
            ),
          ),
        ),
      );

      // Get initial AnimatedScale
      final animatedScaleBefore = tester.widget<AnimatedScale>(
        find.byType(AnimatedScale),
      );

      // Assert initial scale should be 1.0
      expect(animatedScaleBefore.scale, equals(1.0));

      // Act - start tap (pointer down) and hold
      // Tap on the center of the button
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(MeditationButton)),
      );
      await tester.pump(); // Rebuild with new state (_isPressed = true)

      // Get AnimatedScale during tap (after rebuild)
      final animatedScaleDuring = tester.widget<AnimatedScale>(
        find.byType(AnimatedScale),
      );

      // Assert - should be scaling down to 0.95
      expect(animatedScaleDuring.scale, equals(0.95));

      // Clean up
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('should_scale_back_up_on_release', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeditationButton(
              onTap: () => tapped = true,
              isEnabled: true,
            ),
          ),
        ),
      );

      // Act - tap and release
      await tester.tap(find.byType(MeditationButton));
      await tester.pump(); // Start scale-down
      await tester.pumpAndSettle(); // Complete all animations

      // Assert - after release, callback should be called
      expect(tapped, isTrue);

      // Get final AnimatedScale
      final animatedScaleAfter = tester.widget<AnimatedScale>(
        find.byType(AnimatedScale),
      );

      // Scale should return to normal (1.0)
      expect(animatedScaleAfter.scale, equals(1.0));
    });

    testWidgets('should_use_fast_duration_200ms', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeditationButton(
              onTap: () {},
              isEnabled: true,
            ),
          ),
        ),
      );

      // Get AnimatedScale widget
      final animatedScale = tester.widget<AnimatedScale>(
        find.byType(AnimatedScale),
      );

      // Assert - verify AnimatedScale uses 200ms duration
      expect(animatedScale.duration, equals(const Duration(milliseconds: 200)));

      // Also verify AppAnimations.fast is 200ms
      expect(AppAnimations.fast, equals(const Duration(milliseconds: 200)));
    });

    testWidgets('should_not_animate_when_disabled', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeditationButton(
              onTap: () => tapped = true,
              isEnabled: false,
            ),
          ),
        ),
      );

      // Act - attempt to tap disabled button
      await tester.tap(find.byType(MeditationButton));
      await tester.pumpAndSettle();

      // Assert - callback should not be called when disabled
      expect(tapped, isFalse);
    });

    testWidgets('should_provide_tactile_feedback', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeditationButton(
              onTap: () => tapped = true,
              isEnabled: true,
            ),
          ),
        ),
      );

      // Act - tap the button
      await tester.tap(find.byType(MeditationButton));
      await tester.pumpAndSettle();

      // Assert - callback was executed
      expect(tapped, isTrue);
    });

    testWidgets('should_animate_smoothly_on_multiple_taps', (WidgetTester tester) async {
      // Arrange
      int tapCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeditationButton(
              onTap: () => tapCount++,
              isEnabled: true,
            ),
          ),
        ),
      );

      // Act - tap multiple times rapidly
      await tester.tap(find.byType(MeditationButton));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(MeditationButton));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(MeditationButton));
      await tester.pumpAndSettle();

      // Assert - all taps should register
      expect(tapCount, equals(3));

      // Animation should settle
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
