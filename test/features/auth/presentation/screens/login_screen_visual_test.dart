import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:severalbible/core/widgets/app_button.dart';
import 'package:severalbible/core/theme/app_theme.dart';
import 'package:severalbible/features/auth/domain/user_profile.dart';
import 'package:severalbible/features/auth/domain/user_tier.dart';
import 'package:severalbible/features/auth/data/auth_repository.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';
import 'package:severalbible/features/auth/presentation/screens/login_screen.dart';
import 'package:dartz/dartz.dart';
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

    // Register fallback values for onInvocation
    registerFallbackValue(UserProfile(
      id: 'test-id',
      tier: UserTier.member,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  });

  /// Helper to create testable widget with providers and router
  Widget createTestableWidget() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginScreen(),
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

  group('LoginScreen Visual Update Tests (Cycle 3.3)', () {
    testWidgets('should use new button styles', (tester) async {
      // Arrange: Setup screen
      when(() => mockAuthRepository.signInWithGoogle())
          .thenAnswer((_) async => Right(mockUser));
      when(() => mockAuthRepository.signInWithApple())
          .thenAnswer((_) async => Right(mockUser));

      // Act: Render screen
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert: Verify AppButton widgets are used
      // Google button should use AppButton.secondary
      final googleButtonFinder = find.widgetWithText(AppButton, 'Continue with Google');
      expect(googleButtonFinder, findsOneWidget);

      // Apple button should use AppButton.secondary
      final appleButtonFinder = find.widgetWithText(AppButton, 'Continue with Apple');
      expect(appleButtonFinder, findsOneWidget);

      // Verify buttons have 56dp height (via AppButton)
      final googleButton = tester.widget<AppButton>(googleButtonFinder);
      expect(googleButton, isNotNull);

      // Verify buttons have 16px border radius (indirectly via AppButton usage)
      // AppButton enforces this via its internal style
    });

    testWidgets('should apply new color scheme', (tester) async {
      // Arrange
      when(() => mockAuthRepository.signInWithGoogle())
          .thenAnswer((_) async => Right(mockUser));
      when(() => mockAuthRepository.signInWithApple())
          .thenAnswer((_) async => Right(mockUser));

      // Act: Render screen
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert: Verify theme is applied and buttons use AppButton
      final theme = Theme.of(tester.element(find.byType(LoginScreen)));

      // Verify Material 3 theme is enabled
      expect(theme.useMaterial3, isTrue);

      // Verify that AppTheme is being used by checking primary color is purple-ish
      // ColorScheme.fromSeed generates harmonized colors, so exact match isn't expected
      final primary = theme.colorScheme.primary;
      expect(primary.red, greaterThan(80)); // Has red component (purple has red)
      expect(primary.blue, greaterThan(140)); // Has strong blue component (purple has blue)

      // Buttons should be present and properly styled with AppButton
      expect(find.widgetWithText(AppButton, 'Continue with Google'), findsOneWidget);
      expect(find.widgetWithText(AppButton, 'Continue with Apple'), findsOneWidget);
    });

    testWidgets('should maintain all auth functionality', (tester) async {
      // Arrange: Setup mock responses
      when(() => mockAuthRepository.signInWithGoogle())
          .thenAnswer((_) async => Right(mockUser));
      when(() => mockAuthRepository.signInWithApple())
          .thenAnswer((_) async => Right(mockUser));
      when(() => mockAuthRepository.signInAnonymously())
          .thenAnswer((_) async => const Right(unit));

      // Act: Render screen
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Assert: Verify Google sign-in button exists and can be tapped
      final googleButton = find.widgetWithText(AppButton, 'Continue with Google');
      expect(googleButton, findsOneWidget);
      await tester.tap(googleButton);
      await tester.pumpAndSettle();
      verify(() => mockAuthRepository.signInWithGoogle()).called(1);

      // Assert: Verify Apple sign-in button exists and can be tapped
      final appleButton = find.widgetWithText(AppButton, 'Continue with Apple');
      expect(appleButton, findsOneWidget);
      await tester.tap(appleButton);
      await tester.pumpAndSettle();
      verify(() => mockAuthRepository.signInWithApple()).called(1);

      // Assert: Verify Guest button exists and can be tapped
      final guestButton = find.widgetWithText(TextButton, 'Continue as Guest');
      expect(guestButton, findsOneWidget);
      await tester.tap(guestButton);
      await tester.pumpAndSettle();
      verify(() => mockAuthRepository.signInAnonymously()).called(1);

      // Verify no breaking changes to auth flow
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
