import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/widgets/app_button.dart';
import 'package:severalbible/features/prayer_note/presentation/widgets/prayer_note_input.dart';
import 'package:severalbible/features/scripture/domain/entities/scripture.dart';

void main() {
  final testScripture = Scripture(
    id: 'test-1',
    book: 'John',
    chapter: 3,
    verse: 16,
    content: 'For God so loved the world that he gave his one and only Son.',
    reference: 'John 3:16',
    category: 'Grace',
    isPremium: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  Widget createTestWidget({
    required Scripture scripture,
    required TextEditingController controller,
    VoidCallback? onSave,
    VoidCallback? onCancel,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PrayerNoteInputModal(
          scripture: scripture,
          controller: controller,
          onSave: onSave,
          onCancel: onCancel,
        ),
      ),
    );
  }

  group('PrayerNoteInputModal', () {
    testWidgets('should display title header', (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      await tester.pumpWidget(
        createTestWidget(
          scripture: testScripture,
          controller: controller,
        ),
      );

      // Assert: Korean title "감상문 쓰기" should be present
      expect(find.text('감상문 쓰기'), findsOneWidget);

      // Assert: Close button should be present
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should display scripture content in purple container', (
      WidgetTester tester,
    ) async {
      // Arrange
      final controller = TextEditingController();
      await tester.pumpWidget(
        createTestWidget(
          scripture: testScripture,
          controller: controller,
        ),
      );

      // Assert: Scripture content should be displayed
      expect(find.text(testScripture.content), findsOneWidget);

      // Assert: Scripture reference should be displayed
      expect(find.text(testScripture.reference), findsOneWidget);

      // Assert: Container with purple/themed background should exist
      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers.any((c) => c.decoration != null), true);
    });

    testWidgets('should display multiline text field with placeholder', (
      WidgetTester tester,
    ) async {
      // Arrange
      final controller = TextEditingController();
      await tester.pumpWidget(
        createTestWidget(
          scripture: testScripture,
          controller: controller,
        ),
      );

      // Assert: TextField should be present
      expect(find.byType(TextField), findsOneWidget);

      // Assert: TextField should have placeholder
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, isNotNull);

      // Assert: TextField should be multiline
      expect(textField.maxLines, greaterThanOrEqualTo(5));
    });

    testWidgets('should display cancel and save buttons', (
      WidgetTester tester,
    ) async {
      // Arrange
      final controller = TextEditingController();
      await tester.pumpWidget(
        createTestWidget(
          scripture: testScripture,
          controller: controller,
        ),
      );

      // Assert: Two AppButton widgets should be present
      expect(find.byType(AppButton), findsNWidgets(2));

      // Assert: Cancel button with Korean text
      expect(find.text('취소'), findsOneWidget);

      // Assert: Save button with Korean text
      expect(find.text('저장하기'), findsOneWidget);
    });

    testWidgets('should call onSave and text should not be empty', (
      WidgetTester tester,
    ) async {
      // Arrange
      final controller = TextEditingController();
      bool saveCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          scripture: testScripture,
          controller: controller,
          onSave: () {
            saveCalled = true;
          },
        ),
      );

      // Act: Enter text
      await tester.enterText(find.byType(TextField), 'My meditation notes');
      await tester.pumpAndSettle();

      // Act: Tap save button
      await tester.tap(find.text('저장하기'));
      await tester.pumpAndSettle();

      // Assert: onSave should be called
      expect(saveCalled, true);
    });

    testWidgets('should call onCancel when cancel button tapped', (
      WidgetTester tester,
    ) async {
      // Arrange
      final controller = TextEditingController();
      bool cancelCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          scripture: testScripture,
          controller: controller,
          onCancel: () {
            cancelCalled = true;
          },
        ),
      );

      // Act: Tap cancel button
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      // Assert: onCancel should be called
      expect(cancelCalled, true);
    });

    testWidgets('should not call onSave when text is empty', (
      WidgetTester tester,
    ) async {
      // Arrange
      final controller = TextEditingController(); // Empty
      bool saveCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          scripture: testScripture,
          controller: controller,
          onSave: () {
            saveCalled = true;
          },
        ),
      );

      // Act: Tap save button without entering text
      await tester.tap(find.text('저장하기'));
      await tester.pumpAndSettle();

      // Assert: onSave should NOT be called
      expect(saveCalled, false);
    });
  });
}
