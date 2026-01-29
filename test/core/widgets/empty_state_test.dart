import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('should display icon in circular container',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.book,
              title: 'No Items',
              subtitle: 'Get started by adding an item',
            ),
          ),
        ),
      );

      // Assert
      // Icon should be present
      expect(find.byIcon(Icons.book), findsOneWidget);

      // Icon should be in a Container with rounded corners
      final icon = tester.widget<Icon>(find.byIcon(Icons.book));
      expect(icon, isNotNull);

      // Find the container wrapping the icon
      final containerFinder = find.ancestor(
        of: find.byIcon(Icons.book),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsAtLeastNWidgets(1));

      // Verify the container has decoration (for background color and rounded corners)
      final container = tester.widget<Container>(containerFinder.first);
      expect(container.decoration, isNotNull);
      expect(container.decoration, isA<BoxDecoration>());

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
      expect(decoration.color, isNotNull);
    });

    testWidgets('should display title and subtitle',
        (WidgetTester tester) async {
      // Arrange
      const titleText = 'No Items Found';
      const subtitleText = 'Start by adding your first item';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: titleText,
              subtitle: subtitleText,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(titleText), findsOneWidget);
      expect(find.text(subtitleText), findsOneWidget);

      // Verify title uses headlineSmall style
      final titleWidget = tester.widget<Text>(find.text(titleText));
      expect(titleWidget.style?.fontSize, greaterThan(16));

      // Verify subtitle uses bodyMedium style
      final subtitleWidget = tester.widget<Text>(find.text(subtitleText));
      expect(subtitleWidget.style, isNotNull);
    });

    testWidgets('should center all content vertically and horizontally',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.folder,
              title: 'Empty Folder',
              subtitle: 'No files here',
            ),
          ),
        ),
      );

      // Assert
      // Find the Column widget
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);

      final column = tester.widget<Column>(columnFinder);
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.center));
    });

    testWidgets('should support optional action button',
        (WidgetTester tester) async {
      var buttonTapped = false;

      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.add_circle_outline,
              title: 'No Items',
              subtitle: 'Add your first item',
              actionButton: ElevatedButton(
                onPressed: () {
                  buttonTapped = true;
                },
                child: const Text('Add Item'),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Tap the button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(buttonTapped, isTrue);
    });

    testWidgets('should work without action button',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.info,
              title: 'No Data',
              subtitle: 'Nothing to show',
              // No action button provided
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('No Data'), findsOneWidget);
      expect(find.text('Nothing to show'), findsOneWidget);
      // Should not crash without action button
    });

    testWidgets('should apply proper spacing between elements',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.cloud_off,
              title: 'Offline',
              subtitle: 'Check your connection',
            ),
          ),
        ),
      );

      // Assert
      // Find SizedBox widgets (used for spacing)
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsWidgets);

      // Verify there's spacing between elements
      // Should have at least 2 SizedBoxes for spacing (icon-title, title-subtitle)
      expect(sizedBoxes.evaluate().length, greaterThanOrEqualTo(2));

      // Check that spacing is reasonable (e.g., 16-24px)
      for (final element in sizedBoxes.evaluate()) {
        final sizedBox = element.widget as SizedBox;
        if (sizedBox.height != null) {
          expect(sizedBox.height! >= 8.0, isTrue,
              reason: 'Spacing should be at least 8px');
        }
      }
    });

    testWidgets('should use subtle gray text color for subtitle',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.search,
              title: 'No Results',
              subtitle: 'Try a different search term',
            ),
          ),
        ),
      );

      // Assert
      final subtitleWidget =
          tester.widget<Text>(find.text('Try a different search term'));

      // Subtitle should have reduced opacity or gray color
      expect(subtitleWidget.style, isNotNull);
      final color = subtitleWidget.style?.color;

      // Should have either:
      // 1. Reduced opacity (alpha < 255)
      // 2. Gray-ish color (not pure black or pure white)
      if (color != null) {
        final hasReducedOpacity = color.alpha < 255;
        final isGrayish = color.red == color.green && color.green == color.blue;
        expect(hasReducedOpacity || isGrayish, isTrue,
            reason:
                'Subtitle should have subtle color (reduced opacity or gray)');
      }
    });
  });
}
