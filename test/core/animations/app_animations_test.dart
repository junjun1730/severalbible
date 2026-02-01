import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/animations/app_animations.dart';

void main() {
  group('AppAnimations', () {
    group('Duration Constants', () {
      test('should_define_standard_animation_durations', () {
        // Assert: Verify fast (200ms), normal (300ms), slow (500ms)
        expect(AppAnimations.fast, const Duration(milliseconds: 200));
        expect(AppAnimations.normal, const Duration(milliseconds: 300));
        expect(AppAnimations.slow, const Duration(milliseconds: 500));
      });
    });

    group('Curve Constants', () {
      test('should_define_standard_animation_curves', () {
        // Assert: Verify easeIn, easeOut, easeInOut curves
        expect(AppAnimations.easeIn, Curves.easeIn);
        expect(AppAnimations.easeOut, Curves.easeOut);
        expect(AppAnimations.easeInOut, Curves.easeInOut);
      });
    });

    group('Animation Builders', () {
      late AnimationController controller;

      setUp(() {
        controller = AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: const TestVSync(),
        );
      });

      tearDown(() {
        controller.dispose();
      });

      test('should_provide_fade_animation_builder', () {
        // Arrange
        final child = Container();

        // Act
        final fadeWidget = AppAnimations.fade(
          controller: controller,
          child: child,
        );

        // Assert: Verify FadeTransition is returned
        expect(fadeWidget, isA<FadeTransition>());
        expect(
          (fadeWidget as FadeTransition).opacity,
          isA<Animation<double>>(),
        );
      });

      test('should_provide_scale_animation_builder', () {
        // Arrange
        final child = Container();

        // Act
        final scaleWidget = AppAnimations.scale(
          controller: controller,
          child: child,
        );

        // Assert: Verify ScaleTransition is returned
        expect(scaleWidget, isA<ScaleTransition>());
        expect(
          (scaleWidget as ScaleTransition).scale,
          isA<Animation<double>>(),
        );
      });

      test('should_provide_slide_animation_builder', () {
        // Arrange
        final child = Container();
        const begin = Offset(0, 1);
        const end = Offset.zero;

        // Act
        final slideWidget = AppAnimations.slide(
          controller: controller,
          begin: begin,
          end: end,
          child: child,
        );

        // Assert: Verify SlideTransition is returned
        expect(slideWidget, isA<SlideTransition>());
        expect(
          (slideWidget as SlideTransition).position,
          isA<Animation<Offset>>(),
        );
      });
    });
  });
}

/// Test implementation of TickerProvider for AnimationController
class TestVSync implements TickerProvider {
  const TestVSync();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
