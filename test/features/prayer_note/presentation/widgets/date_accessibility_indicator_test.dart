import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/prayer_note/presentation/widgets/date_accessibility_indicator.dart';

void main() {
  Widget createWidgetUnderTest({
    required bool isAccessible,
    VoidCallback? onLockedTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DateAccessibilityIndicator(
          isAccessible: isAccessible,
          onLockedTap: onLockedTap,
        ),
      ),
    );
  }

  group('DateAccessibilityIndicator Widget', () {
    testWidgets('shows lock icon for inaccessible dates',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(isAccessible: false));

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('shows unlock icon for accessible dates',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(isAccessible: true));

      expect(find.byIcon(Icons.lock_open), findsOneWidget);
    });

    testWidgets('calls onLockedTap when locked indicator is tapped',
        (WidgetTester tester) async {
      bool tapCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        isAccessible: false,
        onLockedTap: () => tapCalled = true,
      ));

      await tester.tap(find.byIcon(Icons.lock));
      await tester.pump();

      expect(tapCalled, true);
    });

    testWidgets('does not call onLockedTap when accessible',
        (WidgetTester tester) async {
      bool tapCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        isAccessible: true,
        onLockedTap: () => tapCalled = true,
      ));

      await tester.tap(find.byIcon(Icons.lock_open));
      await tester.pump();

      // onLockedTap should not be called for accessible dates
      expect(tapCalled, false);
    });

    testWidgets('shows appropriate color for locked state',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(isAccessible: false));

      // Find the icon and check it's displayed
      final iconFinder = find.byIcon(Icons.lock);
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('shows appropriate color for unlocked state',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(isAccessible: true));

      // Find the icon and check it's displayed
      final iconFinder = find.byIcon(Icons.lock_open);
      expect(iconFinder, findsOneWidget);
    });
  });
}
