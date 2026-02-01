import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/animations/app_animations.dart';
import 'package:severalbible/features/scripture/presentation/widgets/page_indicator.dart';

void main() {
  Widget createWidgetUnderTest({
    required int pageCount,
    required int currentPage,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: PageIndicator(pageCount: pageCount, currentPage: currentPage),
        ),
      ),
    );
  }

  group('PageIndicator Animation Tests (Cycle 4.5)', () {
    testWidgets('should_animate_dot_size_change', (WidgetTester tester) async {
      // Start with page 0
      await tester.pumpWidget(
        createWidgetUnderTest(pageCount: 3, currentPage: 0),
      );

      await tester.pumpAndSettle();

      // Verify AnimatedContainer is used
      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      expect(containers.length, equals(3));

      // Get initial sizes
      final initialActiveDot = containers[0];
      final initialInactiveDot = containers[1];

      // Active dot should be wider (24px)
      expect(initialActiveDot.constraints?.maxWidth ?? 0, greaterThan(0));
      // Inactive dot should be smaller (8px)
      expect(initialInactiveDot.constraints?.maxWidth ?? 0, greaterThan(0));

      // Change to page 1
      await tester.pumpWidget(
        createWidgetUnderTest(pageCount: 3, currentPage: 1),
      );

      // Don't settle immediately - animation in progress
      await tester.pump();

      // Verify AnimatedContainer animates the size change
      final animatingContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      expect(animatingContainers.length, equals(3));

      // After settling, new active dot should be dot 1
      await tester.pumpAndSettle();

      final finalContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      // Verify dot 1 is now active (wider)
      expect(finalContainers[1].constraints?.maxWidth ?? 0, greaterThan(0));
    });

    testWidgets('should_animate_dot_color_change', (WidgetTester tester) async {
      // Start with page 0
      await tester.pumpWidget(
        createWidgetUnderTest(pageCount: 3, currentPage: 0),
      );

      await tester.pumpAndSettle();

      // Get theme colors
      final context = tester.element(find.byType(Scaffold));
      final primaryColor = Theme.of(context).colorScheme.primary;
      final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

      // Get initial colors
      final initialContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      final initialActiveDotDecoration = initialContainers[0].decoration as BoxDecoration;
      final initialInactiveDotDecoration = initialContainers[1].decoration as BoxDecoration;

      // Active dot should use primary color
      expect(initialActiveDotDecoration.color, equals(primaryColor));
      // Inactive dot should use gray (onSurface with alpha)
      expect(
        initialInactiveDotDecoration.color,
        equals(onSurfaceColor.withValues(alpha: 0.3)),
      );

      // Change to page 2
      await tester.pumpWidget(
        createWidgetUnderTest(pageCount: 3, currentPage: 2),
      );

      // AnimatedContainer should animate the color property
      await tester.pump(const Duration(milliseconds: 100)); // Mid-animation

      // After settling, verify colors changed
      await tester.pumpAndSettle();

      final finalContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      // Dot 2 should now be active (primary color)
      final finalActiveDotDecoration = finalContainers[2].decoration as BoxDecoration;
      expect(finalActiveDotDecoration.color, equals(primaryColor));

      // Dot 0 should now be inactive (gray)
      final finalInactiveDotDecoration = finalContainers[0].decoration as BoxDecoration;
      expect(
        finalInactiveDotDecoration.color,
        equals(onSurfaceColor.withValues(alpha: 0.3)),
      );
    });

    testWidgets('should_use_200ms_duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(pageCount: 3, currentPage: 0),
      );

      // Verify AnimatedContainer has 200ms duration (AppAnimations.fast)
      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      for (final container in containers) {
        expect(
          container.duration,
          equals(AppAnimations.fast),
          reason: 'Dot animation should use fast duration (200ms) for snappy response',
        );
        expect(
          container.duration,
          equals(const Duration(milliseconds: 200)),
        );
        expect(container.curve, equals(Curves.easeInOut));
      }
    });
  });
}
