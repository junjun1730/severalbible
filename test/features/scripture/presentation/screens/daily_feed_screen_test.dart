import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:severalbible/features/scripture/domain/entities/scripture.dart';
import 'package:severalbible/features/scripture/presentation/screens/daily_feed_screen.dart';
import 'package:severalbible/features/scripture/presentation/providers/scripture_providers.dart';
import 'package:severalbible/features/scripture/presentation/widgets/scripture_card.dart';
import 'package:severalbible/features/scripture/presentation/widgets/page_indicator.dart';
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
      child: const MaterialApp(
        home: DailyFeedScreen(),
      ),
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
      child: const MaterialApp(
        home: DailyFeedScreen(),
      ),
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
      child: const MaterialApp(
        home: DailyFeedScreen(),
      ),
    );
  }

  group('DailyFeedScreen', () {
    testWidgets('shows loading indicator on initial load',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoadingWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders PageView with scriptures',
        (WidgetTester tester) async {
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

    testWidgets('shows empty state when no scriptures',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDataWidget(scriptures: []));
      await tester.pumpAndSettle();

      expect(find.textContaining('No scriptures'), findsOneWidget);
    });
  });
}
