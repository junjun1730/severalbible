import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/subscription/presentation/widgets/purchase_button.dart';

void main() {
  group('PurchaseButton', () {
    testWidgets('renders button with provided text', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PurchaseButton(
            text: 'Start Monthly Premium',
            onPressed: null,
          ),
        ),
      ));

      expect(find.text('Start Monthly Premium'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PurchaseButton(
            text: 'Start Monthly Premium',
            isLoading: true,
            onPressed: null,
          ),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Start Monthly Premium'), findsNothing);
    });

    testWidgets('disables button when isLoading is true', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PurchaseButton(
            text: 'Start Monthly Premium',
            isLoading: true,
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('calls onPressed callback when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PurchaseButton(
            text: 'Start Monthly Premium',
            isLoading: false,
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('button takes full width', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: PurchaseButton(
              text: 'Start Premium',
              onPressed: null,
            ),
          ),
        ),
      ));

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(double.infinity));
    });
  });
}
