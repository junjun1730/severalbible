import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:severalbible/features/auth/domain/user_tier.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';
import 'package:severalbible/features/scripture/domain/entities/scripture.dart';
import 'package:severalbible/features/scripture/presentation/providers/scripture_providers.dart';
import 'package:severalbible/features/scripture/presentation/screens/daily_feed_screen.dart';
import 'package:severalbible/features/subscription/presentation/widgets/upsell_dialog.dart';

// Mock dependencies if needed, or use real ones for full integration
// For this level of test, we might want to override providers to control state

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Widget createSubject({
    required UserTier tier,
    required List<Scripture> scriptures,
  }) {
    return ProviderScope(
      overrides: [
        currentUserTierProvider.overrideWith((ref) => Future.value(tier)),
        dailyScripturesProvider.overrideWith((ref) => scriptures),
        // Stub other necessary providers
      ],
      child: const MaterialApp(home: DailyFeedScreen()),
    );
  }

  // Dummy data
  final testScriptures = List.generate(
    5,
    (index) => Scripture(
      id: 'scripture_$index',
      reference: 'John 3:${index + 1}',
      content: 'For God so loved the world...',
      book: 'John',
      chapter: 3,
      verse: index + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  );

  testWidgets('shows upsell dialog when member tries to view 4th scripture', (
    tester,
  ) async {
    // Phase 4 requirement: Free users (members) are limited to 3 scriptures
    // So swiping to the 4th (index 3) should trigger something, or the list should be capped/blocked

    // Note: The current implementation of DailyFeedScreen uses a ContentBlocker for the end of the list.
    // We need to verify that interaction with this blocker (or limits) triggers the UpsellDialog.

    await tester.pumpWidget(
      createSubject(
        tier: UserTier.member,
        scriptures: testScriptures
            .take(3)
            .toList(), // Limit to 3 for test scenario
      ),
    );
    await tester.pumpAndSettle();

    // Swipe through scriptures
    // 1 -> 2
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    // 2 -> 3
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    // 3 -> Blocker/Limit
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    // Now we should see the blocker or limit message
    // And tapping the action button should show upsell

    // Verify ContentBlocker is shown
    expect(find.text('Upgrade to Premium'), findsAtLeastNWidgets(1));

    // Tap the Upgrade button
    // There are two "Upgrade to Premium" texts: Title and Button.
    // We want the button, which is usually the last one or inside an ElevatedButton
    await tester.tap(find.widgetWithText(ElevatedButton, 'Upgrade to Premium'));
    await tester.pumpAndSettle();

    // Verify UpsellDialog is shown
    expect(find.byType(UpsellDialog), findsOneWidget);
    expect(find.text('Thirsting for More?'), findsOneWidget);
    expect(find.text('Upgrade Now'), findsOneWidget);
  });
}
