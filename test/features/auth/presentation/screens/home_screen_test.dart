import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:severalbible/features/auth/presentation/screens/home_screen.dart';
import 'package:severalbible/features/auth/domain/user_tier.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

void main() {
  group('HomeScreen AppBar', () {
    Widget createHomeScreen() {
      return ProviderScope(
        overrides: [
          currentUserTierProvider.overrideWith((ref) => Future.value(UserTier.member)),
          isLoggedInProvider.overrideWith((ref) => true),
          // Override currentUserProvider to prevent onboarding popup timer
          currentUserProvider.overrideWith((ref) => null),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/settings',
                builder: (context, state) => const Scaffold(
                  body: Text('Settings'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('AppBar renders without title text', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();
      // Wait for onboarding timer to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Assert - AppBar should exist but without title text
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('One Message'), findsNothing);
    });

    testWidgets('Settings icon button is present', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();
      // Wait for onboarding timer to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Assert
      expect(find.byIcon(Icons.settings), findsOneWidget);

      final settingsButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.settings),
          matching: find.byType(IconButton),
        ),
      );
      expect(settingsButton.onPressed, isNotNull);
    });

    testWidgets('AppBar has correct background color', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createHomeScreen());
      await tester.pumpAndSettle();
      // Wait for onboarding timer to complete
      await tester.pump(const Duration(milliseconds: 600));

      // Assert
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final theme = Theme.of(tester.element(find.byType(AppBar)));
      expect(appBar.backgroundColor, theme.colorScheme.inversePrimary);
    });
  });
}
