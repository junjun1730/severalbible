import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/prayer_note/presentation/widgets/prayer_note_input.dart';

void main() {
  late TextEditingController controller;

  setUp(() {
    controller = TextEditingController();
  });

  tearDown(() {
    controller.dispose();
  });

  Widget createWidgetUnderTest({
    bool isEnabled = true,
    bool isLoading = false,
    String? initialContent,
    VoidCallback? onSave,
    int maxLength = 500,
  }) {
    if (initialContent != null) {
      controller.text = initialContent;
    }
    return MaterialApp(
      home: Scaffold(
        body: PrayerNoteInput(
          controller: controller,
          isEnabled: isEnabled,
          isLoading: isLoading,
          onSave: onSave,
          maxLength: maxLength,
        ),
      ),
    );
  }

  group('PrayerNoteInput Widget', () {
    testWidgets('renders text field', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows character count', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(maxLength: 500));

      // Initially 0/500
      expect(find.text('0/500'), findsOneWidget);

      // Enter some text
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      expect(find.text('5/500'), findsOneWidget);
    });

    testWidgets('disables for guest tier (isEnabled=false)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(isEnabled: false));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });

    testWidgets('shows save button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('calls onSave callback when save button is pressed', (
      WidgetTester tester,
    ) async {
      bool saveCalled = false;
      await tester.pumpWidget(
        createWidgetUnderTest(onSave: () => saveCalled = true),
      );

      // Enter some text first
      await tester.enterText(find.byType(TextField), 'Test content');
      await tester.pump();

      // Tap save button
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();

      expect(saveCalled, true);
    });

    testWidgets('validates empty content - save button disabled when empty', (
      WidgetTester tester,
    ) async {
      bool saveCalled = false;
      await tester.pumpWidget(
        createWidgetUnderTest(onSave: () => saveCalled = true),
      );

      // Try to tap save without entering text
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();

      // Save should not be called for empty content
      expect(saveCalled, false);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest(isLoading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows hint text for meditation input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Write your meditation...'), findsOneWidget);
    });

    testWidgets('displays initial content when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(initialContent: 'Initial meditation text'),
      );

      expect(find.text('Initial meditation text'), findsOneWidget);
    });
  });
}
