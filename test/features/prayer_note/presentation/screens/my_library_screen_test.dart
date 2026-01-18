import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:severalbible/features/prayer_note/domain/entities/prayer_note.dart';
import 'package:severalbible/features/prayer_note/presentation/screens/my_library_screen.dart';
import 'package:severalbible/features/prayer_note/presentation/providers/prayer_note_providers.dart';
import 'package:severalbible/features/prayer_note/presentation/widgets/prayer_calendar.dart';
import 'package:severalbible/features/prayer_note/presentation/widgets/prayer_note_card.dart';
import 'package:severalbible/features/auth/domain/user_tier.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';

void main() {
  late List<PrayerNote> testNotes;

  setUp(() {
    testNotes = [
      PrayerNote(
        id: 'note-1',
        userId: 'user-1',
        content: 'My first meditation on today\'s scripture.',
        createdAt: DateTime(2026, 1, 18, 10, 0),
        updatedAt: DateTime(2026, 1, 18, 10, 0),
        scriptureReference: 'John 3:16',
      ),
      PrayerNote(
        id: 'note-2',
        userId: 'user-1',
        content: 'Another reflection on God\'s word.',
        createdAt: DateTime(2026, 1, 18, 14, 0),
        updatedAt: DateTime(2026, 1, 18, 14, 0),
      ),
    ];
  });

  Widget createLoadingWidget({
    UserTier tier = UserTier.member,
    DateTime? selectedDate,
  }) {
    final completer = Completer<List<PrayerNote>>();
    final date = selectedDate ?? DateTime(2026, 1, 18);
    return ProviderScope(
      overrides: [
        prayerNoteListProvider.overrideWith((ref) => completer.future),
        selectedDateProvider.overrideWith((ref) => date),
        currentUserTierProvider.overrideWith((ref) => Future.value(tier)),
        datesWithNotesProvider(date).overrideWith((ref) => Future.value({})),
      ],
      child: const MaterialApp(
        home: MyLibraryScreen(),
      ),
    );
  }

  Widget createDataWidget({
    required List<PrayerNote> notes,
    UserTier tier = UserTier.member,
    DateTime? selectedDate,
    Set<DateTime>? datesWithNotes,
  }) {
    final date = selectedDate ?? DateTime(2026, 1, 18);
    return ProviderScope(
      overrides: [
        prayerNoteListProvider.overrideWith((ref) => Future.value(notes)),
        selectedDateProvider.overrideWith((ref) => date),
        currentUserTierProvider.overrideWith((ref) => Future.value(tier)),
        datesWithNotesProvider(date).overrideWith(
            (ref) => Future.value(datesWithNotes ?? {})),
      ],
      child: const MaterialApp(
        home: MyLibraryScreen(),
      ),
    );
  }

  Widget createErrorWidget({
    required Object error,
    UserTier tier = UserTier.member,
    DateTime? selectedDate,
  }) {
    final date = selectedDate ?? DateTime(2026, 1, 18);
    return ProviderScope(
      overrides: [
        prayerNoteListProvider.overrideWith((ref) => Future.error(error)),
        selectedDateProvider.overrideWith((ref) => date),
        currentUserTierProvider.overrideWith((ref) => Future.value(tier)),
        datesWithNotesProvider(date).overrideWith((ref) => Future.value({})),
      ],
      child: const MaterialApp(
        home: MyLibraryScreen(),
      ),
    );
  }

  group('MyLibraryScreen', () {
    testWidgets('shows loading indicator on initial load',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoadingWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders calendar', (WidgetTester tester) async {
      await tester.pumpWidget(createDataWidget(notes: testNotes));
      await tester.pumpAndSettle();

      expect(find.byType(PrayerCalendar), findsOneWidget);
    });

    testWidgets('shows notes list for selected date',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDataWidget(notes: testNotes));
      await tester.pumpAndSettle();

      expect(find.byType(PrayerNoteCard), findsNWidgets(2));
    });

    testWidgets('shows empty state when no notes', (WidgetTester tester) async {
      await tester.pumpWidget(createDataWidget(notes: []));
      await tester.pumpAndSettle();

      expect(find.textContaining('No meditations'), findsOneWidget);
    });

    testWidgets('shows error state', (WidgetTester tester) async {
      await tester.pumpWidget(createErrorWidget(error: 'Failed to load'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('shows title', (WidgetTester tester) async {
      await tester.pumpWidget(createDataWidget(notes: testNotes));
      await tester.pumpAndSettle();

      expect(find.text('My Library'), findsOneWidget);
    });
  });
}
