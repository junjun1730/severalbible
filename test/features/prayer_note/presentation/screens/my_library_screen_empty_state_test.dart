import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:severalbible/core/widgets/empty_state.dart';
import 'package:severalbible/features/prayer_note/domain/entities/prayer_note.dart';
import 'package:severalbible/features/prayer_note/presentation/screens/my_library_screen.dart';
import 'package:severalbible/features/prayer_note/presentation/providers/prayer_note_providers.dart';
import 'package:severalbible/features/prayer_note/presentation/widgets/prayer_note_card.dart';
import 'package:severalbible/features/auth/domain/user_tier.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';

void main() {
  Widget createTestWidget({
    required List<PrayerNote> notes,
    UserTier tier = UserTier.member,
  }) {
    final date = DateTime(2026, 1, 18);
    return ProviderScope(
      overrides: [
        prayerNoteListProvider.overrideWith((ref) => Future.value(notes)),
        selectedDateProvider.overrideWith((ref) => date),
        currentUserTierProvider.overrideWith((ref) => Future.value(tier)),
        datesWithNotesProvider(date).overrideWith((ref) => Future.value({})),
      ],
      child: const MaterialApp(home: MyLibraryScreen()),
    );
  }

  group('MyLibraryScreen Empty State', () {
    testWidgets('should display EmptyState widget when no notes', (
      WidgetTester tester,
    ) async {
      // Arrange: Create widget with empty notes list
      await tester.pumpWidget(createTestWidget(notes: []));
      await tester.pumpAndSettle();

      // Assert: EmptyState widget should be present
      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('should display correct empty message with book icon', (
      WidgetTester tester,
    ) async {
      // Arrange: Create widget with empty notes list
      await tester.pumpWidget(createTestWidget(notes: []));
      await tester.pumpAndSettle();

      // Assert: Should have Korean title
      expect(
        find.text('아직 작성된 감상문이 없습니다'),
        findsOneWidget,
      );

      // Assert: Should have Korean subtitle
      expect(
        find.text('말씀을 읽고 첫 감상문을 작성해보세요'),
        findsOneWidget,
      );

      // Assert: Should have book icon
      final emptyState = tester.widget<EmptyState>(find.byType(EmptyState));
      expect(emptyState.icon, Icons.book);
    });

    testWidgets('should hide EmptyState when notes exist', (
      WidgetTester tester,
    ) async {
      // Arrange: Create widget with 1 note
      final testNote = PrayerNote(
        id: 'note-1',
        userId: 'user-1',
        content: 'Test meditation',
        createdAt: DateTime(2026, 1, 18, 10, 0),
        updatedAt: DateTime(2026, 1, 18, 10, 0),
        scriptureReference: 'John 3:16',
      );

      await tester.pumpWidget(createTestWidget(notes: [testNote]));
      await tester.pumpAndSettle();

      // Assert: EmptyState should NOT be present
      expect(find.byType(EmptyState), findsNothing);

      // Assert: ListView with PrayerNoteCard should be shown instead
      expect(find.byType(PrayerNoteCard), findsOneWidget);
    });
  });
}
