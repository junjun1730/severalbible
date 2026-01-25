import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:severalbible/features/auth/presentation/screens/login_screen.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';
import 'package:severalbible/features/auth/data/auth_repository.dart';
import 'package:severalbible/core/services/supabase_service.dart';

// Mocks
class MockAuthRepository extends Mock implements AuthRepository {}

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSupabaseService mockSupabaseService;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSupabaseService = MockSupabaseService();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        supabaseServiceProvider.overrideWithValue(mockSupabaseService),
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders app title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('One Message'), findsOneWidget);
    });

    testWidgets('renders welcome message', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.textContaining('Sign in'), findsOneWidget);
    });

    testWidgets('renders Google sign-in button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.textContaining('Google'), findsOneWidget);
    });

    testWidgets('renders Apple sign-in button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.textContaining('Apple'), findsOneWidget);
    });

    testWidgets('renders guest mode button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.textContaining('Guest'), findsOneWidget);
    });

    testWidgets('Google button triggers signInWithGoogle', (tester) async {
      when(
        () => mockAuthRepository.signInWithGoogle(),
      ).thenAnswer((_) async => const Right(unit));

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.textContaining('Google'));
      await tester.pump();

      verify(() => mockAuthRepository.signInWithGoogle()).called(1);
    });

    testWidgets('Apple button triggers signInWithApple', (tester) async {
      when(
        () => mockAuthRepository.signInWithApple(),
      ).thenAnswer((_) async => const Right(unit));

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.textContaining('Apple'));
      await tester.pump();

      verify(() => mockAuthRepository.signInWithApple()).called(1);
    });

    testWidgets('shows error snackbar on sign-in failure', (tester) async {
      when(
        () => mockAuthRepository.signInWithGoogle(),
      ).thenAnswer((_) async => const Left('Sign in failed'));

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.textContaining('Google'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
