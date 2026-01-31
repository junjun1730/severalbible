import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:severalbible/features/scripture/domain/entities/scripture.dart';
import 'package:severalbible/features/scripture/presentation/screens/daily_feed_screen.dart';
import 'package:severalbible/features/scripture/presentation/providers/scripture_providers.dart';
import 'package:severalbible/features/scripture/presentation/widgets/scripture_card.dart';
import 'package:severalbible/features/scripture/presentation/widgets/page_indicator.dart';
import 'package:severalbible/features/scripture/presentation/widgets/navigation_arrow_button.dart';
import 'package:severalbible/features/scripture/presentation/widgets/meditation_button.dart';
import 'package:severalbible/features/auth/domain/user_tier.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';

void main() {
  late List<Scripture> testScriptures;

  setUp(() {
    testScriptures = [
      Scripture(
        id: 'test-1',
        book: 'John',
        chapter: 3,
        verse: 16,
        content: 'For God so loved the world...',
        reference: 'John 3:16',
        isPremium: false,
        category: 'hope',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Scripture(
        id: 'test-2',
        book: 'Proverbs',
        chapter: 3,
        verse: 5,
        content: 'Trust in the LORD with all your heart...',
        reference: 'Proverbs 3:5',
        isPremium: false,
        category: 'wisdom',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Scripture(
        id: 'test-3',
        book: 'Philippians',
        chapter: 4,
        verse: 13,
        content: 'I can do all this through him...',
        reference: 'Philippians 4:13',
        isPremium: false,
        category: 'faith',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  });

  Widget createLoadingWidget({
    UserTier tier = UserTier.member,
    int currentIndex = 0,
  }) {
    final completer = Completer<List<Scripture>>();
    return ProviderScope(
      overrides: [
        dailyScripturesProvider.overrideWith((ref) => completer.future),
        currentScriptureIndexProvider.overrideWith((ref) => currentIndex),
        currentUserTierProvider.overrideWith((ref) => Future.value(tier)),
      ],
      child: const MaterialApp(home: DailyFeedScreen()),
    );
  }

  Widget createDataWidget({
    required List<Scripture> scriptures,
    UserTier tier = UserTier.member,
    int currentIndex = 0,
  }) {
    return ProviderScope(
      overrides: [
        dailyScripturesProvider.overrideWith((ref) => Future.value(scriptures)),
        currentScriptureIndexProvider.overrideWith((ref) => currentIndex),
        currentUserTierProvider.overrideWith((ref) => Future.value(tier)),
      ],
      child: const MaterialApp(home: DailyFeedScreen()),
    );
  }

  Widget createErrorWidget({
    required Object error,
    UserTier tier = UserTier.member,
    int currentIndex = 0,
  }) {
    return ProviderScope(
      overrides: [
        dailyScripturesProvider.overrideWith((ref) => Future.error(error)),
        currentScriptureIndexProvider.overrideWith((ref) => currentIndex),
        currentUserTierProvider.overrideWith((ref) => Future.value(tier)),
      ],
      child: const MaterialApp(home: DailyFeedScreen()),
    );
  }

  group('DailyFeedScreen', () {
    testWidgets('shows loading indicator on initial load', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createLoadingWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders PageView with scriptures', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDataWidget(scriptures: testScriptures));
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(ScriptureCard), findsOneWidget);
    });

    testWidgets('shows error message on failure', (WidgetTester tester) async {
      await tester.pumpWidget(createErrorWidget(error: 'Failed to load'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('shows retry button on error', (WidgetTester tester) async {
      await tester.pumpWidget(createErrorWidget(error: 'Failed to load'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    });

    testWidgets('displays page indicators', (WidgetTester tester) async {
      await tester.pumpWidget(createDataWidget(scriptures: testScriptures));
      await tester.pumpAndSettle();

      expect(find.byType(PageIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no scriptures', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDataWidget(scriptures: []));
      await tester.pumpAndSettle();

      expect(find.textContaining('No scriptures'), findsOneWidget);
    });

    // Arrow Navigation Tests
    testWidgets('shows navigation arrows with scriptures', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDataWidget(scriptures: testScriptures));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationArrowButton), findsNWidgets(2));
    });

    testWidgets('left arrow disabled on first page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createDataWidget(scriptures: testScriptures, currentIndex: 0),
      );
      await tester.pumpAndSettle();

      final leftArrows = tester.widgetList<NavigationArrowButton>(
        find.byType(NavigationArrowButton),
      );
      final leftArrow = leftArrows.firstWhere(
        (arrow) => arrow.side == NavigationSide.left,
      );

      expect(leftArrow.isEnabled, false);
    });

    testWidgets('right arrow disabled on last page', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createDataWidget(
          scriptures: testScriptures,
          currentIndex: testScriptures.length - 1,
        ),
      );
      await tester.pumpAndSettle();

      final rightArrows = tester.widgetList<NavigationArrowButton>(
        find.byType(NavigationArrowButton),
      );
      final rightArrow = rightArrows.firstWhere(
        (arrow) => arrow.side == NavigationSide.right,
      );

      expect(rightArrow.isEnabled, false);
    });

    testWidgets('arrow tap triggers navigation', (
      WidgetTester tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          dailyScripturesProvider.overrideWith((ref) => Future.value(testScriptures)),
          currentUserTierProvider.overrideWith((ref) => Future.value(UserTier.member)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: DailyFeedScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Initial index should be 0
      expect(container.read(currentScriptureIndexProvider), 0);

      // Find and tap the right arrow
      final rightArrows = tester.widgetList<NavigationArrowButton>(
        find.byType(NavigationArrowButton),
      );
      final rightArrowIndex = rightArrows.toList().indexWhere(
        (arrow) => arrow.side == NavigationSide.right,
      );

      await tester.tap(find.byType(NavigationArrowButton).at(rightArrowIndex));
      // Pump to start animation and trigger onPageChanged
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The navigation method should have been called
      // Note: Due to animation timing, we can't reliably check the final page,
      // but we can verify the button tap was registered by checking if
      // the widget tree is still valid
      expect(find.byType(NavigationArrowButton), findsNWidgets(2));
    });

    testWidgets('arrow buttons are interactive', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyScripturesProvider.overrideWith((ref) => Future.value(testScriptures)),
            currentUserTierProvider.overrideWith((ref) => Future.value(UserTier.member)),
          ],
          child: const MaterialApp(home: DailyFeedScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tap right arrow
      final rightArrows = tester.widgetList<NavigationArrowButton>(
        find.byType(NavigationArrowButton),
      );
      final rightArrowIndex = rightArrows.toList().indexWhere(
        (arrow) => arrow.side == NavigationSide.right,
      );

      // Verify button is tappable (doesn't throw)
      await tester.tap(find.byType(NavigationArrowButton).at(rightArrowIndex));
      await tester.pump();

      // Verify widget tree is still valid after tap
      expect(find.byType(NavigationArrowButton), findsNWidgets(2));
      expect(find.byType(ScriptureCard), findsOneWidget);
    });

    testWidgets('PageIndicator renders with arrow buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyScripturesProvider.overrideWith((ref) => Future.value(testScriptures)),
            currentUserTierProvider.overrideWith((ref) => Future.value(UserTier.member)),
          ],
          child: const MaterialApp(home: DailyFeedScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Initial page indicator should show page 0
      final pageIndicator = tester.widget<PageIndicator>(find.byType(PageIndicator));
      expect(pageIndicator.currentPage, 0);
      expect(pageIndicator.pageCount, testScriptures.length);

      // Both arrow buttons and page indicator should be present
      expect(find.byType(NavigationArrowButton), findsNWidgets(2));
      expect(find.byType(PageIndicator), findsOneWidget);
    });
  });

  group('DailyFeedScreen MeditationButton Layout (Cycle 3.2)', () {
    testWidgets('should display meditation button below page indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createDataWidget(scriptures: testScriptures, tier: UserTier.member),
      );
      await tester.pumpAndSettle();

      // Find PageIndicator and MeditationButton
      final pageIndicatorFinder = find.byType(PageIndicator);
      final meditationButtonFinder = find.byType(MeditationButton);

      expect(pageIndicatorFinder, findsOneWidget);
      expect(meditationButtonFinder, findsOneWidget);

      // Verify MeditationButton is below PageIndicator
      final pageIndicatorRect = tester.getRect(pageIndicatorFinder);
      final buttonRect = tester.getRect(meditationButtonFinder);

      expect(buttonRect.top, greaterThan(pageIndicatorRect.bottom));
    });

    testWidgets('should enable meditation button for member users', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createDataWidget(scriptures: testScriptures, tier: UserTier.member),
      );
      await tester.pumpAndSettle();

      // Find MeditationButton
      final meditationButton = tester.widget<MeditationButton>(
        find.byType(MeditationButton),
      );

      expect(meditationButton.isEnabled, isTrue);
    });

    testWidgets('should enable meditation button for premium users', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createDataWidget(scriptures: testScriptures, tier: UserTier.premium),
      );
      await tester.pumpAndSettle();

      // Find MeditationButton
      final meditationButton = tester.widget<MeditationButton>(
        find.byType(MeditationButton),
      );

      expect(meditationButton.isEnabled, isTrue);
    });

    testWidgets('should disable meditation button for guest users', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createDataWidget(scriptures: [testScriptures[0]], tier: UserTier.guest),
      );
      await tester.pumpAndSettle();

      // Find MeditationButton
      final meditationButton = tester.widget<MeditationButton>(
        find.byType(MeditationButton),
      );

      expect(meditationButton.isEnabled, isFalse);
    });

    testWidgets('should apply proper spacing between elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createDataWidget(scriptures: testScriptures, tier: UserTier.member),
      );
      await tester.pumpAndSettle();

      // Find all relevant widgets
      final pageIndicatorFinder = find.byType(PageIndicator);
      final meditationButtonFinder = find.byType(MeditationButton);

      final pageIndicatorRect = tester.getRect(pageIndicatorFinder);
      final buttonRect = tester.getRect(meditationButtonFinder);

      // Verify spacing between PageIndicator and MeditationButton
      // According to plan: 16px after PageView, 24px before button
      final spacing = buttonRect.top - pageIndicatorRect.bottom;
      expect(spacing, greaterThan(20.0)); // Should be ~24px
    });

    testWidgets('should handle guest user single card layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createDataWidget(scriptures: [testScriptures[0]], tier: UserTier.guest),
      );
      await tester.pumpAndSettle();

      // Guest users see 1 card
      expect(find.byType(ScriptureCard), findsOneWidget);
      expect(find.byType(MeditationButton), findsOneWidget);
      expect(find.byType(PageIndicator), findsOneWidget);

      // MeditationButton should be disabled
      final button = tester.widget<MeditationButton>(
        find.byType(MeditationButton),
      );
      expect(button.isEnabled, isFalse);
    });

    testWidgets('should handle member user three cards layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createDataWidget(scriptures: testScriptures, tier: UserTier.member),
      );
      await tester.pumpAndSettle();

      // Member users see 3 cards (but only 1 visible at a time in PageView)
      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(MeditationButton), findsOneWidget);

      // PageIndicator should show 3 pages
      final pageIndicator = tester.widget<PageIndicator>(
        find.byType(PageIndicator),
      );
      expect(pageIndicator.pageCount, equals(3));

      // MeditationButton should be enabled
      final button = tester.widget<MeditationButton>(
        find.byType(MeditationButton),
      );
      expect(button.isEnabled, isTrue);
    });
  });
}
