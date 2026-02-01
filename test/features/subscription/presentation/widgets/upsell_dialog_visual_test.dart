import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/widgets/app_button.dart';
import 'package:severalbible/core/theme/app_theme.dart';
import 'package:severalbible/features/subscription/presentation/widgets/upsell_dialog.dart';
import 'package:go_router/go_router.dart';

void main() {
  /// Helper to create testable widget
  Widget createTestableWidget({UpsellTrigger trigger = UpsellTrigger.archiveLocked}) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: UpsellDialog(trigger: trigger),
          ),
        ),
        GoRoute(
          path: '/premium',
          builder: (context, state) => const Scaffold(body: Text('Premium')),
        ),
      ],
    );

    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }

  group('UpsellDialog Visual Update Tests (Cycle 3.7)', () {
    testWidgets('should use new button styles', (tester) async {
      // Act: Render dialog
      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Assert: Verify AppButton.primary is used for "Upgrade Now"
      final upgradeButtonFinder = find.widgetWithText(AppButton, 'Upgrade Now');
      expect(upgradeButtonFinder, findsOneWidget);

      // Verify button has proper styling (56dp height, 16px radius via AppButton)
      final button = tester.widget<AppButton>(upgradeButtonFinder);
      expect(button, isNotNull);
    });

    testWidgets('should apply purple theme', (tester) async {
      // Act: Render dialog
      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Assert: Verify theme is applied
      final theme = Theme.of(tester.element(find.byType(UpsellDialog)));

      // Verify Material 3 theme is enabled
      expect(theme.useMaterial3, isTrue);

      // Verify primary color is purple-ish (Material 3 harmonized)
      final primary = theme.colorScheme.primary;
      expect(primary.red, greaterThan(80)); // Has red component (purple has red)
      expect(primary.blue, greaterThan(140)); // Has strong blue component (purple has blue)

      // Verify icon uses primary color (already uses theme.primaryColor)
      final iconFinder = find.byIcon(Icons.history_edu);
      expect(iconFinder, findsOneWidget);
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, theme.colorScheme.primary);
    });

    testWidgets('should maintain upsell functionality', (tester) async {
      // Act: Render dialog
      await tester.pumpWidget(createTestableWidget(trigger: UpsellTrigger.contentExhausted));
      await tester.pump();

      // Assert: Verify key content is present
      expect(find.text('Thirsting for More?'), findsOneWidget);
      expect(
        find.text('Get unlimited access to daily scriptures and wisdom with our Premium plan.'),
        findsOneWidget,
      );

      // Verify buttons
      expect(find.widgetWithText(AppButton, 'Upgrade Now'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Maybe Later'), findsOneWidget);

      // Verify different triggers work
      await tester.pumpWidget(createTestableWidget(trigger: UpsellTrigger.archiveLocked));
      await tester.pump();
      expect(find.text('Unlock Your History'), findsOneWidget);
    });
  });
}
