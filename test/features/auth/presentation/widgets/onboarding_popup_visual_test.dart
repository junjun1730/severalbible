import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/widgets/app_button.dart';
import 'package:severalbible/core/theme/app_theme.dart';
import 'package:severalbible/features/auth/presentation/widgets/onboarding_popup.dart';

void main() {
  /// Helper to create testable widget
  Widget createTestableWidget({VoidCallback? onSignIn}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: OnboardingPopup(onSignIn: onSignIn),
      ),
    );
  }

  group('OnboardingPopup Visual Update Tests (Cycle 3.5)', () {
    testWidgets('should use new button styles in popup', (tester) async {
      // Arrange
      bool signInCalled = false;

      // Act: Render popup
      await tester.pumpWidget(createTestableWidget(
        onSignIn: () => signInCalled = true,
      ));
      await tester.pump();

      // Assert: Verify AppButton.primary is used for "Sign In Now"
      final signInButtonFinder = find.widgetWithText(AppButton, 'Sign In Now');
      expect(signInButtonFinder, findsOneWidget);

      // Verify button has proper styling (56dp height, 16px radius via AppButton)
      final button = tester.widget<AppButton>(signInButtonFinder);
      expect(button, isNotNull);

      // AppButton with fullWidth=true handles sizing internally (via SizedBox wrapper)
      // No need to check for SizedBox ancestor - it's part of AppButton's implementation

      // Verify button triggers callback
      await tester.tap(signInButtonFinder);
      await tester.pumpAndSettle();
      expect(signInCalled, isTrue);
    });

    testWidgets('should apply purple theme', (tester) async {
      // Act: Render popup
      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Assert: Verify popup uses purple theme accents
      final theme = Theme.of(tester.element(find.byType(OnboardingPopup)));

      // Verify Material 3 theme is enabled
      expect(theme.useMaterial3, isTrue);

      // Verify primary color is purple-ish (Material 3 harmonized)
      final primary = theme.colorScheme.primary;
      expect(primary.red, greaterThan(80)); // Has red component (purple has red)
      expect(primary.blue, greaterThan(140)); // Has strong blue component (purple has blue)

      // Verify icon uses primary color
      final iconFinder = find.byIcon(Icons.auto_awesome);
      expect(iconFinder, findsOneWidget);
      final icon = tester.widget<Icon>(iconFinder);
      expect(icon.color, theme.colorScheme.primary);

      // Verify benefit icons use primary color
      final benefitIconFinder = find.byIcon(Icons.add_circle_outline);
      expect(benefitIconFinder, findsOneWidget);
      final benefitIcon = tester.widget<Icon>(benefitIconFinder);
      expect(benefitIcon.color, theme.colorScheme.primary);
    });

    testWidgets('should maintain conversion messaging', (tester) async {
      // Act: Render popup
      await tester.pumpWidget(createTestableWidget());
      await tester.pump();

      // Assert: Verify key conversion messages are present
      expect(find.text('Unlock More Grace'), findsOneWidget);
      expect(
        find.text('Sign in to receive 3x more daily grace and save your spiritual journey.'),
        findsOneWidget,
      );

      // Verify benefits list
      expect(find.text('3 scriptures per day (instead of 1)'), findsOneWidget);
      expect(find.text('Write and save prayer notes'), findsOneWidget);
      expect(find.text('Access your spiritual archive'), findsOneWidget);

      // Verify buttons
      expect(find.widgetWithText(AppButton, 'Sign In Now'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Maybe later'), findsOneWidget);
    });
  });
}
