import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/subscription/presentation/widgets/upsell_dialog.dart';

void main() {
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

  testWidgets('shows upgrade and cancel buttons', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: UpsellDialog(trigger: UpsellTrigger.archiveLocked),
      ),
    ));

    expect(find.text('Upgrade Now'), findsOneWidget);
    expect(find.text('Maybe Later'), findsOneWidget);
  });
}
