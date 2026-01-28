import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:severalbible/core/router/app_router.dart';
import 'package:severalbible/core/theme/app_theme.dart';
import 'package:severalbible/main.dart';

// Mock router for testing
final _testRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Test Home')),
      ),
    ),
  ],
);

void main() {
  group('OneMessageApp', () {
    testWidgets('should_apply_custom_theme_to_material_app', (tester) async {
      // Arrange & Act - provide a test router
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appRouterProvider.overrideWithValue(_testRouter),
          ],
          child: const OneMessageApp(),
        ),
      );

      // Find the MaterialApp
      final materialAppFinder = find.byType(MaterialApp);
      expect(materialAppFinder, findsOneWidget);

      // Get the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(materialAppFinder);

      // Assert - theme should use AppTheme.lightTheme
      expect(materialApp.theme, isNotNull);
      expect(materialApp.theme, equals(AppTheme.lightTheme));

      // Verify the theme has our custom purple color scheme
      expect(
        materialApp.theme!.colorScheme.primary.value,
        isNot(equals(Colors.indigo.value)),
      );

      // Verify Material 3 is enabled
      expect(materialApp.theme!.useMaterial3, isTrue);
    });

    testWidgets('should_maintain_existing_router_config', (tester) async {
      // Arrange - provide a test router
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appRouterProvider.overrideWithValue(_testRouter),
          ],
          child: const OneMessageApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Find the MaterialApp
      final materialAppFinder = find.byType(MaterialApp);
      expect(materialAppFinder, findsOneWidget);

      // Get the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(materialAppFinder);

      // Assert - verify app configuration is preserved
      expect(materialApp.title, equals('One Message'));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);

      // Verify the router is working by checking that content renders
      // The test router shows "Test Home" text when routing works
      await tester.pump();
      expect(find.text('Test Home'), findsOneWidget);
    });

    testWidgets('should_preserve_provider_scope', (tester) async {
      // Arrange & Act - provide a test router
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appRouterProvider.overrideWithValue(_testRouter),
          ],
          child: const OneMessageApp(),
        ),
      );

      // Assert - ProviderScope should exist in the widget tree
      final providerScopeFinder = find.byType(ProviderScope);
      expect(providerScopeFinder, findsOneWidget);

      // Verify OneMessageApp is a ConsumerWidget (can access Riverpod)
      final oneMessageAppFinder = find.byType(OneMessageApp);
      expect(oneMessageAppFinder, findsOneWidget);

      // Verify the app can access providers (router provider specifically)
      final materialAppFinder = find.byType(MaterialApp);
      expect(materialAppFinder, findsOneWidget);

      final materialApp = tester.widget<MaterialApp>(materialAppFinder);
      expect(materialApp.routerConfig, isNotNull);
    });
  });
}
