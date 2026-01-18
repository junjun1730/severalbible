import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/prayer_note/domain/entities/prayer_note.dart';
import 'package:severalbible/features/prayer_note/presentation/widgets/prayer_note_card.dart';

void main() {
  late PrayerNote testNote;
  late PrayerNote noteWithScripture;

  setUp(() {
    testNote = PrayerNote(
      id: 'note-id-1',
      userId: 'user-id-1',
      content: 'This is a test meditation note that reflects on today\'s scripture.',
      createdAt: DateTime(2026, 1, 18, 10, 30),
      updatedAt: DateTime(2026, 1, 18, 10, 30),
    );

    noteWithScripture = PrayerNote(
      id: 'note-id-2',
      userId: 'user-id-1',
      scriptureId: 'scripture-id-1',
      content: 'My meditation on the word.',
      scriptureReference: 'John 3:16',
      scriptureContent: 'For God so loved the world...',
      createdAt: DateTime(2026, 1, 17, 9, 0),
      updatedAt: DateTime(2026, 1, 17, 9, 0),
    );
  });

  Widget createWidgetUnderTest(
    PrayerNote note, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PrayerNoteCard(
          note: note,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }

  group('PrayerNoteCard Widget', () {
    testWidgets('renders note content', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testNote));

      expect(
        find.text('This is a test meditation note that reflects on today\'s scripture.'),
        findsOneWidget,
      );
    });

    testWidgets('renders scripture reference when present',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(noteWithScripture));

      expect(find.text('John 3:16'), findsOneWidget);
    });

    testWidgets('does not show scripture reference when not present',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testNote));

      // Should not find John 3:16 since testNote has no scripture reference
      expect(find.text('John 3:16'), findsNothing);
    });

    testWidgets('renders created date', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testNote));

      // Date should be displayed in some format (e.g., Jan 18, 2026)
      expect(find.textContaining('Jan 18'), findsOneWidget);
    });

    testWidgets('shows edit button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testNote, onEdit: () {}));

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('shows delete button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testNote, onDelete: () {}));

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('calls onEdit callback when edit button is pressed',
        (WidgetTester tester) async {
      bool editCalled = false;
      await tester.pumpWidget(
        createWidgetUnderTest(testNote, onEdit: () => editCalled = true),
      );

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      expect(editCalled, true);
    });

    testWidgets('calls onDelete callback when delete button is pressed',
        (WidgetTester tester) async {
      bool deleteCalled = false;
      await tester.pumpWidget(
        createWidgetUnderTest(testNote, onDelete: () => deleteCalled = true),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(deleteCalled, true);
    });

    testWidgets('hides edit button when onEdit is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testNote, onEdit: null));

      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('hides delete button when onDelete is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testNote, onDelete: null));

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });
  });
}
