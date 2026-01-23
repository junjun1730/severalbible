import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/subscription/presentation/widgets/upsell_dialog.dart';

void main() {
  group('UpsellDialog', () {
    testWidgets('renders correct content for archive locked trigger', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: UpsellDialog(trigger: UpsellTrigger.archiveLocked),
        ),
      ));

      expect(find.text('Unlock Your History'), findsOneWidget);
      expect(find.textContaining('access your entire prayer note archive'), findsOneWidget);
      expect(find.byIcon(Icons.history_edu), findsOneWidget);
    });

    testWidgets('renders correct content for content exhausted trigger', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: UpsellDialog(trigger: UpsellTrigger.contentExhausted),
        ),
      ));

      expect(find.text('Thirsting for More?'), findsOneWidget);
      expect(find.textContaining('unlimited access to daily scriptures'), findsOneWidget);
      expect(find.byIcon(Icons.water_drop), findsOneWidget);
    });

    testWidgets('renders correct content for premium scripture trigger', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: UpsellDialog(trigger: UpsellTrigger.premiumScripture),
        ),
      ));

      expect(find.text('Exclusive Teachings'), findsOneWidget);
      expect(find.textContaining('Premium members'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('shows upgrade and cancel buttons', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: UpsellDialog(trigger: UpsellTrigger.archiveLocked),
        ),
      ));

      expect(find.text('Upgrade Now'), findsOneWidget);
      expect(find.text('Maybe Later'), findsOneWidget);
    });

    testWidgets('dismisses dialog when "Maybe Later" is tapped', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const UpsellDialog(trigger: UpsellTrigger.archiveLocked),
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      ));

      // Open the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Unlock Your History'), findsOneWidget);

      // Tap "Maybe Later"
      await tester.tap(find.text('Maybe Later'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.text('Unlock Your History'), findsNothing);
    });

    testWidgets('displays different icons for each trigger type', (tester) async {
      // Test archive locked icon
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: UpsellDialog(trigger: UpsellTrigger.archiveLocked),
        ),
      ));
      expect(find.byIcon(Icons.history_edu), findsOneWidget);

      // Test content exhausted icon
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: UpsellDialog(trigger: UpsellTrigger.contentExhausted),
        ),
      ));
      expect(find.byIcon(Icons.water_drop), findsOneWidget);

      // Test premium scripture icon
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: UpsellDialog(trigger: UpsellTrigger.premiumScripture),
        ),
      ));
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}
