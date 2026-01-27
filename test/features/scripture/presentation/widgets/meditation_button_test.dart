import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/scripture/presentation/widgets/meditation_button.dart';

void main() {
  group('MeditationButton Widget', () {
    testWidgets('renders with correct icon and text', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeditationButton(
              isEnabled: true,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.edit_note), findsOneWidget);
      expect(find.text('Leave Meditation'), findsOneWidget);
      expect(find.byType(MeditationButton), findsOneWidget);
    });

    testWidgets('enabled button styling', (tester) async {
      // Arrange
      bool callbackInvoked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeditationButton(
              isEnabled: true,
              onTap: () {
                callbackInvoked = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap the button text
      await tester.tap(find.text('Leave Meditation'));
      await tester.pump();

      // Assert - Button should be enabled and callback invoked
      expect(callbackInvoked, isTrue);
    });

    testWidgets('disabled button styling', (tester) async {
      // Arrange
      bool callbackInvoked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeditationButton(
              isEnabled: false,
              onTap: () {
                callbackInvoked = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Try to tap the button
      await tester.tap(find.text('Leave Meditation'));
      await tester.pump();

      // Assert - Callback should NOT be invoked when disabled
      expect(callbackInvoked, isFalse);
    });

    testWidgets('calls onTap when pressed', (tester) async {
      // Arrange
      bool wasTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeditationButton(
              isEnabled: true,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Leave Meditation'));
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('full width constraint', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: MeditationButton(
                isEnabled: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Check the MeditationButton widget size
      final meditationButtonSize = tester.getSize(find.byType(MeditationButton));
      expect(meditationButtonSize.width, equals(300));
      expect(meditationButtonSize.height, greaterThanOrEqualTo(56));
    });

    testWidgets('accessibility semantics', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeditationButton(
              isEnabled: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Leave Meditation'), findsOneWidget);
      final text = tester.widget<Text>(find.text('Leave Meditation'));
      expect(text.data, contains('Leave Meditation'));
    });
  });
}
