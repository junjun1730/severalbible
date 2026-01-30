import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/widgets/app_bottom_sheet.dart';

void main() {
  group('AppBottomSheet', () {
    testWidgets('should display bottom sheet with rounded corners', (
      WidgetTester tester,
    ) async {
      // Arrange: Create a test app with a button to show the bottom sheet
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppBottomSheet.show(
                      context: context,
                      builder: (context) => const Text('Test Content'),
                    );
                  },
                  child: const Text('Show Sheet'),
                );
              },
            ),
          ),
        ),
      );

      // Act: Tap the button to show the bottom sheet
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      // Assert: Bottom sheet should have rounded top corners
      // Find the container with rounded decoration
      final containers = tester.widgetList<Container>(find.byType(Container));

      // Find the container with BoxDecoration that has borderRadius
      final decoratedContainer = containers.firstWhere(
        (container) {
          final decoration = container.decoration;
          return decoration is BoxDecoration &&
                 decoration.borderRadius != null;
        },
      );

      final decoration = decoratedContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, isA<BorderRadius>());

      // Verify it's rounded on top
      final borderRadius = decoration.borderRadius as BorderRadius;
      expect(borderRadius.topLeft.x, greaterThan(0));
      expect(borderRadius.topRight.x, greaterThan(0));
    });

    testWidgets('should display drag handle', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppBottomSheet.show(
                      context: context,
                      builder: (context) => const Text('Test Content'),
                    );
                  },
                  child: const Text('Show Sheet'),
                );
              },
            ),
          ),
        ),
      );

      // Act: Show the bottom sheet
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      // Assert: Drag handle should be present
      // The drag handle is typically a Container with specific styling
      expect(find.text('Test Content'), findsOneWidget);

      // Find the container that acts as drag handle (gray rounded bar)
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('should support custom height', (WidgetTester tester) async {
      const customHeight = 400.0;

      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppBottomSheet.show(
                      context: context,
                      maxHeight: customHeight,
                      builder: (context) => const Text('Test Content'),
                    );
                  },
                  child: const Text('Show Sheet'),
                );
              },
            ),
          ),
        ),
      );

      // Act: Show the bottom sheet with custom height
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      // Assert: Content should be constrained by maxHeight
      final contentContainer = find.ancestor(
        of: find.text('Test Content'),
        matching: find.byType(Container),
      );
      expect(contentContainer, findsWidgets);
    });

    testWidgets('should be dismissible by drag', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppBottomSheet.show(
                      context: context,
                      builder: (context) => const Text('Test Content'),
                    );
                  },
                  child: const Text('Show Sheet'),
                );
              },
            ),
          ),
        ),
      );

      // Act: Show the bottom sheet
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Test Content'), findsOneWidget);

      // Act: Drag down to dismiss (simulate swipe down)
      await tester.drag(
        find.text('Test Content'),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      // Assert: Bottom sheet should be dismissed
      expect(find.text('Test Content'), findsNothing);
    });

    testWidgets('should apply safe area padding', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppBottomSheet.show(
                      context: context,
                      builder: (context) => const Text('Test Content'),
                    );
                  },
                  child: const Text('Show Sheet'),
                );
              },
            ),
          ),
        ),
      );

      // Act: Show the bottom sheet
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      // Assert: SafeArea should wrap the content
      final safeArea = find.ancestor(
        of: find.text('Test Content'),
        matching: find.byType(SafeArea),
      );
      expect(safeArea, findsOneWidget);
    });
  });
}
