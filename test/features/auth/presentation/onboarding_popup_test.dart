import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/auth/presentation/widgets/onboarding_popup.dart';

void main() {
  group('OnboardingPopup', () {
    testWidgets('displays conversion message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showOnboardingPopup(context),
                child: const Text('Show Popup'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Popup'));
      await tester.pumpAndSettle();

      expect(find.textContaining('grace'), findsWidgets);
    });

    testWidgets('displays sign in CTA button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showOnboardingPopup(context),
                child: const Text('Show Popup'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Popup'));
      await tester.pumpAndSettle();

      expect(find.text('Sign In Now'), findsOneWidget);
    });

    testWidgets('displays maybe later button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showOnboardingPopup(context),
                child: const Text('Show Popup'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Popup'));
      await tester.pumpAndSettle();

      expect(find.text('Maybe later'), findsOneWidget);
    });

    testWidgets('closes on maybe later tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showOnboardingPopup(context),
                child: const Text('Show Popup'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Popup'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Maybe later'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Sign In Now'), findsNothing);
    });

    testWidgets('calls onSignIn callback when sign in tapped', (tester) async {
      bool signInCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showOnboardingPopup(
                  context,
                  onSignIn: () => signInCalled = true,
                ),
                child: const Text('Show Popup'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Popup'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign In Now'));
      await tester.pumpAndSettle();

      expect(signInCalled, true);
    });

    testWidgets('displays benefit items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showOnboardingPopup(context),
                child: const Text('Show Popup'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Popup'));
      await tester.pumpAndSettle();

      expect(find.textContaining('scriptures'), findsOneWidget);
      expect(find.textContaining('prayer'), findsOneWidget);
      expect(find.textContaining('archive'), findsOneWidget);
    });
  });
}
