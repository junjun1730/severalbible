import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/scripture/domain/entities/scripture.dart';
import 'package:severalbible/features/scripture/presentation/widgets/scripture_card.dart';

void main() {
  late Scripture testScripture;
  late Scripture premiumScripture;

  setUp(() {
    testScripture = Scripture(
      id: 'test-id-1',
      book: 'John',
      chapter: 3,
      verse: 16,
      content: 'For God so loved the world that he gave his one and only Son, '
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
      home: Scaffold(
        body: ScriptureCard(scripture: scripture),
      ),
    );
  }

  group('ScriptureCard Widget', () {
    testWidgets('renders scripture reference', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      expect(find.text('John 3:16'), findsOneWidget);
    });

    testWidgets('renders scripture content', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      expect(
        find.textContaining('For God so loved the world'),
        findsOneWidget,
      );
    });

    testWidgets('renders book, chapter, and verse info',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      // The reference should contain book, chapter:verse
      expect(find.text('John 3:16'), findsOneWidget);
    });

    testWidgets('shows premium badge for premium scriptures',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(premiumScripture));

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('does not show premium badge for non-premium scriptures',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      expect(find.byIcon(Icons.star), findsNothing);
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

    testWidgets('renders category tag when present',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      expect(find.text('hope'), findsOneWidget);
    });

    testWidgets('does not render category tag when null',
        (WidgetTester tester) async {
      final scriptureWithoutCategory = Scripture(
        id: 'test-id-3',
        book: 'Genesis',
        chapter: 1,
        verse: 1,
        content: 'In the beginning God created the heavens and the earth.',
        reference: 'Genesis 1:1',
        isPremium: false,
        category: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createWidgetUnderTest(scriptureWithoutCategory));

      // Category chip should not be present
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('has gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testScripture));

      // Should have a container with gradient decoration
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);
    });
  });
}
