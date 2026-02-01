import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:severalbible/core/theme/app_theme.dart';
import 'package:severalbible/features/auth/presentation/screens/splash_screen.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';
import 'package:severalbible/features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;
import 'package:go_router/go_router.dart';

/// Mock for AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

/// Mock for Supabase User
class MockUser extends Mock implements User {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late User mockUser;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUser = MockUser();

    // Setup default mock behavior
    when(() => mockAuthRepository.isLoggedIn).thenReturn(false);
    when(() => mockAuthRepository.currentUser).thenReturn(null);
  });

  /// Helper to create testable widget with providers and router
  Widget createTestableWidget({bool isLoggedIn = false}) {
    when(() => mockAuthRepository.isLoggedIn).thenReturn(isLoggedIn);
    when(() => mockAuthRepository.currentUser).thenReturn(isLoggedIn ? mockUser : null);
    when(() => mockUser.isAnonymous).thenReturn(false);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(autoNavigate: false),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login')),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }

  group('SplashScreen Visual Update Tests (Cycle 3.4)', () {
    testWidgets('should display app icon with purple theme', (tester) async {
      // Act: Render screen
      await tester.pumpWidget(createTestableWidget());
      await tester.pump(); // Single pump, don't wait for CircularProgressIndicator to settle

      // Assert: Verify app icon is displayed
      final iconFinder = find.byIcon(Icons.menu_book_rounded);
      expect(iconFinder, findsOneWidget);

      // Verify icon uses primary color (purple from theme)
      final icon = tester.widget<Icon>(iconFinder);
      final theme = Theme.of(tester.element(find.byType(SplashScreen)));
      expect(icon.color, theme.colorScheme.primary);

      // Verify primary color is purple-ish (Material 3 harmonized)
      final primary = theme.colorScheme.primary;
      expect(primary.red, greaterThan(80)); // Has red component (purple has red)
      expect(primary.blue, greaterThan(140)); // Has strong blue component (purple has blue)
    });

    testWidgets('should use clean background with gradient', (tester) async {
      // Act: Render screen
      await tester.pumpWidget(createTestableWidget());
      await tester.pump(); // Single pump, don't wait for CircularProgressIndicator to settle

      // Assert: Verify gradient background is present
      final containerFinder = find.descendant(
        of: find.byType(Scaffold),
        matching: find.byType(Container),
      ).first;
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      expect(container.decoration, isA<BoxDecoration>());

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());

      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors.length, 2);

      // Verify gradient uses theme colors
      final theme = Theme.of(tester.element(find.byType(SplashScreen)));
      expect(gradient.colors[0], theme.colorScheme.primary);
      expect(gradient.colors[1], theme.colorScheme.primaryContainer);
    });

    testWidgets('should maintain auto-login functionality', (tester) async {
      // Arrange: Track navigation
      bool authCheckCalled = false;
      bool? lastAuthState;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => SplashScreen(
              autoNavigate: true,
              onAuthChecked: (isLoggedIn) {
                authCheckCalled = true;
                lastAuthState = isLoggedIn;
              },
            ),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(body: Text('Login')),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
        ],
      );

      when(() => mockAuthRepository.isLoggedIn).thenReturn(false);
      when(() => mockAuthRepository.currentUser).thenReturn(null);

      // Act: Render screen
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );

      // Wait for navigation delay
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      // Assert: Verify auth check was called
      expect(authCheckCalled, isTrue);
      expect(lastAuthState, isFalse);

      // Verify navigation to login screen occurred
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
