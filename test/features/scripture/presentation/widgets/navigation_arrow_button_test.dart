import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/scripture/presentation/widgets/navigation_arrow_button.dart';

void main() {
  group('NavigationArrowButton', () {
    testWidgets('renders left arrow icon correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationArrowButton(
              icon: Icons.arrow_back_ios,
              onPressed: () {},
              isEnabled: true,
              side: NavigationSide.left,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('renders right arrow icon correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationArrowButton(
              icon: Icons.arrow_forward_ios,
              onPressed: () {},
              isEnabled: true,
              side: NavigationSide.right,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped and enabled', (tester) async {
      // Arrange
      var wasCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationArrowButton(
              icon: Icons.arrow_forward_ios,
              onPressed: () {
                wasCalled = true;
              },
              isEnabled: true,
              side: NavigationSide.right,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Assert
      expect(wasCalled, true);
    });

    testWidgets('shows disabled state when isEnabled is false', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationArrowButton(
              icon: Icons.arrow_back_ios,
              onPressed: () {},
              isEnabled: false,
              side: NavigationSide.left,
            ),
          ),
        ),
      );

      // Assert
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNull);

      // Check opacity for disabled state
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.3);
    });

    testWidgets('has proper accessibility labels for left side', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationArrowButton(
              icon: Icons.arrow_back_ios,
              onPressed: () {},
              isEnabled: true,
              side: NavigationSide.left,
            ),
          ),
        ),
      );

      // Assert
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.tooltip, 'Previous');
    });

    testWidgets('has proper accessibility labels for right side', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationArrowButton(
              icon: Icons.arrow_forward_ios,
              onPressed: () {},
              isEnabled: true,
              side: NavigationSide.right,
            ),
          ),
        ),
      );

      // Assert
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.tooltip, 'Next');
    });

    testWidgets('respects theme colors', (tester) async {
      // Arrange
      const testColor = Colors.blue;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            iconTheme: const IconThemeData(color: testColor),
          ),
          home: Scaffold(
            body: NavigationArrowButton(
              icon: Icons.arrow_forward_ios,
              onPressed: () {},
              isEnabled: true,
              side: NavigationSide.right,
            ),
          ),
        ),
      );

      // Assert
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, Colors.white); // Should override theme with white for contrast
    });

    testWidgets('has correct size (48x48)', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationArrowButton(
              icon: Icons.arrow_forward_ios,
              onPressed: () {},
              isEnabled: true,
              side: NavigationSide.right,
            ),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(IconButton),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.minWidth, 48);
      expect(container.constraints?.minHeight, 48);
    });
  });
}
