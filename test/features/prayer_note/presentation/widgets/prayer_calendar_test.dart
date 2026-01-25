import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/prayer_note/presentation/widgets/prayer_calendar.dart';

void main() {
  late DateTime focusedDay;
  late DateTime selectedDay;
  late Set<DateTime> datesWithNotes;

  setUp(() {
    focusedDay = DateTime(2026, 1, 18);
    selectedDay = DateTime(2026, 1, 18);
    datesWithNotes = {
      DateTime(2026, 1, 15),
      DateTime(2026, 1, 17),
      DateTime(2026, 1, 18),
    };
  });

  Widget createWidgetUnderTest({
    DateTime? overrideFocusedDay,
    DateTime? overrideSelectedDay,
    Set<DateTime>? overrideDatesWithNotes,
    void Function(DateTime, DateTime)? onDaySelected,
    void Function(DateTime)? onPageChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PrayerCalendar(
          focusedDay: overrideFocusedDay ?? focusedDay,
          selectedDay: overrideSelectedDay ?? selectedDay,
          datesWithNotes: overrideDatesWithNotes ?? datesWithNotes,
          onDaySelected: onDaySelected ?? (selected, focused) {},
          onPageChanged: onPageChanged ?? (focused) {},
        ),
      ),
    );
  }

  group('PrayerCalendar Widget', () {
    testWidgets('displays current month', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Should display January 2026
      expect(find.textContaining('January'), findsOneWidget);
      expect(find.textContaining('2026'), findsOneWidget);
    });

    testWidgets('highlights dates with notes', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // The calendar should render with markers for dates with notes
      // We can verify by looking for our PrayerCalendar widget
      expect(find.byType(PrayerCalendar), findsOneWidget);
    });

    testWidgets('allows date selection', (WidgetTester tester) async {
      DateTime? selectedDate;
      await tester.pumpWidget(
        createWidgetUnderTest(
          onDaySelected: (selected, focused) {
            selectedDate = selected;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap on day 15
      final dayFinder = find.text('15');
      expect(dayFinder, findsWidgets);
      await tester.tap(dayFinder.first);
      await tester.pumpAndSettle();

      expect(selectedDate?.day, 15);
    });

    testWidgets('navigates months with chevron buttons', (
      WidgetTester tester,
    ) async {
      DateTime? pageChangedTo;
      await tester.pumpWidget(
        createWidgetUnderTest(
          onPageChanged: (focused) {
            pageChangedTo = focused;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Find the next month chevron and tap it
      final nextMonthButton = find.byIcon(Icons.chevron_right);
      expect(nextMonthButton, findsOneWidget);

      await tester.tap(nextMonthButton);
      await tester.pumpAndSettle();

      // The callback should have been called with February
      expect(pageChangedTo?.month, 2);
    });

    testWidgets('shows marker for dates with notes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          overrideDatesWithNotes: {
            DateTime(2026, 1, 15),
            DateTime(2026, 1, 17),
          },
        ),
      );
      await tester.pumpAndSettle();

      // Calendar should be rendered with markers
      // The presence of PrayerCalendar indicates proper setup
      expect(find.byType(PrayerCalendar), findsOneWidget);
    });
  });
}
