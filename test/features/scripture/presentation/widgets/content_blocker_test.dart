import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/auth/domain/user_tier.dart';
import 'package:severalbible/features/scripture/presentation/widgets/content_blocker.dart';

void main() {
  Widget createWidgetUnderTest({
    required UserTier tier,
    VoidCallback? onAction,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ContentBlocker(
          tier: tier,
          onAction: onAction ?? () {},
        ),
      ),
    );
  }

  group('ContentBlocker Widget', () {
    testWidgets('displays blocker message for guest',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(tier: UserTier.guest));

      expect(
        find.textContaining('Log in'),
        findsWidgets,
      );
    });

    testWidgets('displays blocker message for member',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(tier: UserTier.member));

      expect(
        find.textContaining('Premium'),
        findsWidgets,
      );
    });

    testWidgets('shows CTA button based on tier - guest',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(tier: UserTier.guest));

      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
    });

    testWidgets('shows CTA button based on tier - member',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(tier: UserTier.member));

      expect(find.widgetWithText(ElevatedButton, 'Upgrade to Premium'),
          findsOneWidget);
    });

    testWidgets('guest blocker prompts login', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(tier: UserTier.guest));

      // Should have sign in related text
      expect(find.textContaining('Sign'), findsWidgets);
    });

    testWidgets('member blocker prompts premium upgrade',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(tier: UserTier.member));

      // Should have premium upgrade related text
      expect(find.textContaining('Premium'), findsWidgets);
    });

    testWidgets('displays benefit list', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(tier: UserTier.guest));

      // Should display benefits
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('calls onAction callback when CTA is tapped',
        (WidgetTester tester) async {
      var actionCalled = false;

      await tester.pumpWidget(createWidgetUnderTest(
        tier: UserTier.guest,
        onAction: () => actionCalled = true,
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(actionCalled, isTrue);
    });

    testWidgets('has lock icon', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(tier: UserTier.guest));

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });
  });
}
