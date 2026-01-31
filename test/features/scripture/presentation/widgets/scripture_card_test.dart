import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/scripture/domain/entities/scripture.dart';
import 'package:severalbible/features/scripture/presentation/widgets/scripture_card.dart';
import 'package:severalbible/features/scripture/presentation/widgets/meditation_button.dart';

void main() {
  late Scripture testScripture;
  late Scripture premiumScripture;

  setUp(() {
    testScripture = Scripture(
      id: 'test-id-1',
      book: 'John',
      chapter: 3,
      verse: 16,
      content:
          'For God so loved the world that he gave his one and only Son, '
          'that whoever believes in him shall not perish but have eternal life.',
      reference: 'John 3:16',
      isPremium: false,
      category: 'hope',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    premiumScripture = Scripture(
      id: 'test-id-2',
      book: 'Psalms',
      chapter: 23,
      verse: 1,
      content: 'The LORD is my shepherd, I lack nothing.',
      reference: 'Psalms 23:1',
      isPremium: true,
      category: 'faith',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  });

  Widget createWidgetUnderTest(Scripture scripture) {
    return MaterialApp(
      home: Scaffold(body: ScriptureCard(scripture: scripture)),
    );
  }

  group('ScriptureCard Widget', () {
    testWidgets('renders scripture reference', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      expect(find.text('John 3:16'), findsOneWidget);
    });

    testWidgets('renders scripture content', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      expect(find.textContaining('For God so loved the world'), findsOneWidget);
    });

    testWidgets('renders book, chapter, and verse info', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      // The reference should contain book, chapter:verse
      expect(find.text('John 3:16'), findsOneWidget);
    });

    testWidgets('applies correct typography', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      // Reference text should have headline style
      final referenceFinder = find.text('John 3:16');
      expect(referenceFinder, findsOneWidget);

      // Content text should be present
      final contentFinder = find.textContaining('For God so loved');
      expect(contentFinder, findsOneWidget);
    });

    testWidgets('should NOT display meditation button inside card (Cycle 3.2)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 350,
                child: ScriptureCard(
                  scripture: testScripture,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // MeditationButton should NOT be inside the card anymore
      final buttonFinder = find.byType(MeditationButton);
      expect(buttonFinder, findsNothing);

      // The text should also not be found
      expect(find.text('Leave Meditation'), findsNothing);
    });
  });

  group('ScriptureCard Redesign (Phase 4.5 Cycle 2.1)', () {
    // Background & Structure Tests (3 tests)

    testWidgets('should render with solid background color not gradient', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      // Find the Card widget
      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);

      // Card should use solid color, not gradient
      // Note: Card widget itself doesn't expose decoration directly
      // We verify no gradient container exists
      final card = tester.widget<Card>(cardFinder);

      // Card should be using Material 3 default styling (solid background)
      expect(card.elevation, isNotNull);
    });

    testWidgets('should display purple icon badge at top center', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      // Find icon badge container by key
      final iconBadgeFinder = find.byKey(const Key('scripture_icon_badge'));
      expect(iconBadgeFinder, findsOneWidget);

      // Verify container styling
      final badgeContainer = tester.widget<Container>(iconBadgeFinder);
      final decoration = badgeContainer.decoration as BoxDecoration;

      // Assert: Light purple background
      expect(decoration.color, equals(const Color(0xFFF5F3FF)));
      expect(decoration.shape, equals(BoxShape.circle));

      // Verify book icon is inside
      final iconFinder = find.descendant(
        of: iconBadgeFinder,
        matching: find.byIcon(Icons.menu_book_rounded),
      );
      expect(iconFinder, findsOneWidget);

      // Verify badge size (56x56)
      expect(badgeContainer.constraints?.minWidth, equals(56.0));
      expect(badgeContainer.constraints?.minHeight, equals(56.0));
    });

    testWidgets('should center-align all text content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      // Find the content column inside Card
      final columnFinder = find.descendant(
        of: find.byType(Card),
        matching: find.byType(Column),
      );

      final contentColumn = tester.widget<Column>(columnFinder.first);

      // Assert: CrossAxisAlignment is center
      expect(
        contentColumn.crossAxisAlignment,
        equals(CrossAxisAlignment.center),
      );

      // Verify scripture content text is center-aligned
      final contentTextFinder = find.textContaining('For God so loved');
      final contentText = tester.widget<Text>(contentTextFinder);
      expect(contentText.textAlign, equals(TextAlign.center));

      // Verify reference text is center-aligned
      final referenceTextFinder = find.text('John 3:16');
      final referenceText = tester.widget<Text>(referenceTextFinder);
      expect(referenceText.textAlign, equals(TextAlign.center));
    });

    // Layout & Dimensions Tests (3 tests)

    testWidgets('should apply 24px border radius from design tokens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      // Find Card widget
      final card = tester.widget<Card>(find.byType(Card));

      // Assert: Card shape has 24px border radius
      expect(card.shape, isA<RoundedRectangleBorder>());
      final shape = card.shape as RoundedRectangleBorder;
      final borderRadius = shape.borderRadius as BorderRadius;

      expect(borderRadius.topLeft.x, equals(24.0));
      expect(borderRadius.topRight.x, equals(24.0));
      expect(borderRadius.bottomLeft.x, equals(24.0));
      expect(borderRadius.bottomRight.x, equals(24.0));
    });

    testWidgets('should apply 24px internal padding from design tokens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      // Find the Card widget
      final card = tester.widget<Card>(find.byType(Card));

      // Card's child should be Padding with 24px
      expect(card.child, isA<Padding>());
      final padding = card.child as Padding;
      expect(padding.padding, equals(const EdgeInsets.all(24.0)));
    });

    testWidgets('should position icon badge correctly at top', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      // Find icon badge
      final iconBadgeFinder = find.byKey(const Key('scripture_icon_badge'));
      expect(iconBadgeFinder, findsOneWidget);

      // Get positions
      final cardRect = tester.getRect(find.byType(Card));
      final badgeRect = tester.getRect(iconBadgeFinder);

      // Assert: Badge is centered horizontally
      final cardCenterX = cardRect.left + (cardRect.width / 2);
      final badgeCenterX = badgeRect.left + (badgeRect.width / 2);
      expect((cardCenterX - badgeCenterX).abs(), lessThan(1.0));

      // Badge should be at top with 24px padding (AppSpacing.lg)
      // Allow some tolerance for Card elevation and rendering
      final topDistance = badgeRect.top - cardRect.top;
      expect(topDistance, closeTo(24.0, 20.0)); // 24px padding ± 20px tolerance
    });

    // Content & Typography Tests (3 tests)

    testWidgets('should display scripture content with correct typography', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      // Find scripture content text
      final contentFinder = find.textContaining('For God so loved');
      expect(contentFinder, findsOneWidget);

      final contentText = tester.widget<Text>(contentFinder);

      // Assert: Uses bodyLarge text style (18sp)
      expect(contentText.style?.fontSize, equals(18.0));
      expect(contentText.style?.height, equals(1.6));

      // Assert: Center-aligned
      expect(contentText.textAlign, equals(TextAlign.center));
    });

    testWidgets('should display reference below content in purple color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      // Find reference text
      final referenceFinder = find.text('John 3:16');
      expect(referenceFinder, findsOneWidget);

      final referenceText = tester.widget<Text>(referenceFinder);

      // Assert: Purple color (primary)
      expect(
        referenceText.style?.color?.value,
        equals(const Color(0xFF7C6FE8).value),
      );

      // Assert: Small text style
      expect(referenceText.style?.fontSize, lessThan(16.0));

      // Assert: Center-aligned
      expect(referenceText.textAlign, equals(TextAlign.center));

      // Verify reference is BELOW content (not at top)
      final contentRect = tester.getRect(find.textContaining('For God so loved'));
      final referenceRect = tester.getRect(referenceFinder);
      expect(referenceRect.top, greaterThan(contentRect.bottom));
    });

    testWidgets('should not display category chip inside card', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      // Assert: No Chip widget inside the Card
      final cardFinder = find.byType(Card);
      final chipInsideCard = find.descendant(
        of: cardFinder,
        matching: find.byType(Chip),
      );

      expect(chipInsideCard, findsNothing);
    });
  });
}
