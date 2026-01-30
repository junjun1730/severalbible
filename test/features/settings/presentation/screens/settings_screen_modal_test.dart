import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/settings/presentation/screens/settings_screen.dart';
import 'package:severalbible/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';
import 'package:severalbible/features/auth/domain/user_tier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  Widget createTestWidget({
    UserTier tier = UserTier.member,
  }) {
    final mockUser = User(
      id: 'test_user_123',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) => mockUser),
        currentUserTierProvider.overrideWith((ref) => Future.value(tier)),
        hasPremiumProvider.overrideWith((ref) => Future.value(false)),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    );
  }

  group('SettingsScreen Modal Presentation', () {
    testWidgets('should display as bottom sheet without AppBar', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert: No AppBar should be present in the widget tree
      expect(find.byType(AppBar), findsNothing);

      // Assert: Content should still be present
      expect(find.text('Subscription'), findsOneWidget);
    });

    testWidgets('should display title in modal header', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert: Korean title "설정" should be present
      expect(find.text('설정'), findsOneWidget);

      // Assert: Title should use headlineMedium style
      final titleText = tester.widget<Text>(find.text('설정'));
      expect(titleText.style, isNotNull);
    });

    testWidgets('should display close button', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert: Close button (X icon) should be present
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Assert: Close button should be tappable
      final closeButton = find.ancestor(
        of: find.byIcon(Icons.close),
        matching: find.byType(IconButton),
      );
      expect(closeButton, findsOneWidget);
    });

    testWidgets('should maintain all existing settings sections', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert: Subscription section present
      expect(find.text('Subscription'), findsOneWidget);

      // Assert: Account section present
      expect(find.text('Account'), findsOneWidget);

      // Assert: Legal section present
      expect(find.text('Legal'), findsOneWidget);

      // Assert: All ListTiles present
      expect(find.text('Upgrade to Premium'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
    });
  });
}
