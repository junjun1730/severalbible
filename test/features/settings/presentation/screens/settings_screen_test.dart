import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:severalbible/features/settings/presentation/screens/settings_screen.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';
import 'package:severalbible/core/router/app_router.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Mock URL Launcher Platform for testing
class MockUrlLauncher extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  String? lastLaunchedUrl;
  bool shouldThrow = false;

  @override
  Future<bool> canLaunch(String url) async => !shouldThrow;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    if (shouldThrow) {
      throw Exception('Failed to launch URL');
    }
    lastLaunchedUrl = url;
    return true;
  }

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    if (shouldThrow) {
      throw Exception('Failed to launch URL');
    }
    lastLaunchedUrl = url;
    return true;
  }
}

void main() {
  Widget createSubject({GoRouter? router}) {
    final testRouter =
        router ??
        GoRouter(
          initialLocation: AppRoutes.settings,
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const Scaffold(
                body: SettingsScreen(),
              ),
            ),
            GoRoute(
              path: AppRoutes.login,
              builder: (context, state) => const Scaffold(body: Text('Login')),
            ),
          ],
        );

    // Create a mock Supabase user for testing
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
      ],
      child: MaterialApp.router(routerConfig: testRouter),
    );
  }

  group('SettingsScreen', () {
    testWidgets('renders settings title', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Korean title in modal header
      expect(find.text('설정'), findsOneWidget);
    });

    testWidgets('does NOT show subscription section', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Upgrade to Premium'), findsNothing);
      expect(find.text('Manage Subscription'), findsNothing);
      expect(find.text('Subscription'), findsNothing);
    });

    testWidgets('shows logout option for logged-in user', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Sign Out'), findsOneWidget);
    });

    group('Legal Section', () {
      late MockUrlLauncher mockUrlLauncher;

      setUp(() {
        mockUrlLauncher = MockUrlLauncher();
        UrlLauncherPlatform.instance = mockUrlLauncher;
      });

      testWidgets('renders Legal section header', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createSubject());
        await tester.pumpAndSettle();

        expect(find.text('Legal'), findsOneWidget);
      });

      testWidgets('shows Privacy Policy tile', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createSubject());
        await tester.pumpAndSettle();

        expect(find.text('Privacy Policy'), findsOneWidget);
        expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
      });

      testWidgets('shows Terms of Service tile', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createSubject());
        await tester.pumpAndSettle();

        expect(find.text('Terms of Service'), findsOneWidget);
        expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      });

      testWidgets('tapping Privacy Policy launches URL', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Privacy Policy'));
        await tester.pumpAndSettle();

        expect(mockUrlLauncher.lastLaunchedUrl, isNotNull);
        expect(mockUrlLauncher.lastLaunchedUrl, contains('privacy'));
      });

      testWidgets('tapping Terms of Service launches URL', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createSubject());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Terms of Service'));
        await tester.pumpAndSettle();

        expect(mockUrlLauncher.lastLaunchedUrl, isNotNull);
        expect(mockUrlLauncher.lastLaunchedUrl, contains('terms'));
      });

      testWidgets('handles URL launch failure gracefully', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);

        mockUrlLauncher.shouldThrow = true;

        await tester.pumpWidget(createSubject());
        await tester.pumpAndSettle();

        // Should not crash when URL launch fails
        await tester.tap(find.text('Privacy Policy'));
        await tester.pumpAndSettle();

        // Should show an error snackbar
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text('Could not open Privacy Policy'),
          findsOneWidget,
        );
      });
    });
  });
}
