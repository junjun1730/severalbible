import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:severalbible/features/prayer_note/presentation/utils/my_library_navigation.dart';
import 'package:severalbible/features/auth/domain/user_tier.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';
import 'package:severalbible/features/subscription/presentation/widgets/upsell_dialog.dart';
import 'package:severalbible/core/router/app_router.dart';

void main() {
  group('navigateToMyLibrary', () {
    testWidgets('Premium user navigates to MyLibraryScreen', (tester) async {
      // Arrange
      bool navigated = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserTierProvider.overrideWith((ref) => Future.value(UserTier.premium)),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => Consumer(
                    builder: (context, ref, child) => Scaffold(
                      body: ElevatedButton(
                        onPressed: () async {
                          await navigateToMyLibrary(context, ref);
                        },
                        child: const Text('Navigate'),
                      ),
                    ),
                  ),
                ),
                GoRoute(
                  path: AppRoutes.myLibrary,
                  builder: (context, state) {
                    navigated = true;
                    return const Scaffold(body: Text('MyLibrary'));
                  },
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Assert
      expect(navigated, true);
      expect(find.text('MyLibrary'), findsOneWidget);
    });

    testWidgets('Member user sees UpsellDialog', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserTierProvider.overrideWith((ref) => Future.value(UserTier.member)),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    await navigateToMyLibrary(context, ref);
                  },
                  child: const Text('Navigate'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(UpsellDialog), findsOneWidget);
    });

    testWidgets('Guest user sees UpsellDialog', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserTierProvider.overrideWith((ref) => Future.value(UserTier.guest)),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    await navigateToMyLibrary(context, ref);
                  },
                  child: const Text('Navigate'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(UpsellDialog), findsOneWidget);
    });
  });
}
