import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:severalbible/core/services/supabase_service.dart';
import 'package:severalbible/features/auth/data/auth_repository.dart';

// Mocks
class MockSupabaseService extends Mock implements SupabaseService {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

class MockSession extends Mock implements Session {}

void main() {
  late MockSupabaseService mockSupabaseService;
  late MockGoTrueClient mockGoTrueClient;
  late AuthRepository authRepository;

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    mockGoTrueClient = MockGoTrueClient();
    when(() => mockSupabaseService.auth).thenReturn(mockGoTrueClient);
    authRepository = AuthRepository(mockSupabaseService);
  });

  group('AuthRepository', () {
    group('currentUser', () {
      test('returns User when logged in', () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('test-user-id');
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

        final result = authRepository.currentUser;

        expect(result, isNotNull);
        expect(result?.id, 'test-user-id');
      });

      test('returns null when not logged in', () {
        when(() => mockGoTrueClient.currentUser).thenReturn(null);

        final result = authRepository.currentUser;

        expect(result, isNull);
      });
    });

    group('isLoggedIn', () {
      test('returns true when user is logged in', () {
        final mockUser = MockUser();
        when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

        expect(authRepository.isLoggedIn, true);
      });

      test('returns false when user is not logged in', () {
        when(() => mockGoTrueClient.currentUser).thenReturn(null);

        expect(authRepository.isLoggedIn, false);
      });
    });

    group('signInWithEmail', () {
      test('returns User on successful sign in', () async {
        final mockUser = MockUser();
        final mockSession = MockSession();
        final mockAuthResponse = MockAuthResponse();

        when(() => mockUser.id).thenReturn('test-user-id');
        when(() => mockAuthResponse.user).thenReturn(mockUser);
        when(() => mockAuthResponse.session).thenReturn(mockSession);
        when(
          () => mockGoTrueClient.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => mockAuthResponse);

        final result = await authRepository.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not be a failure'),
          (user) => expect(user.id, 'test-user-id'),
        );
      });

      test('returns failure on AuthException', () async {
        when(
          () => mockGoTrueClient.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(AuthException('Invalid credentials'));

        final result = await authRepository.signInWithEmail(
          email: 'test@example.com',
          password: 'wrong-password',
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, contains('Invalid credentials')),
          (user) => fail('Should not return user'),
        );
      });
    });

    group('signUpWithEmail', () {
      test('returns User on successful sign up', () async {
        final mockUser = MockUser();
        final mockSession = MockSession();
        final mockAuthResponse = MockAuthResponse();

        when(() => mockUser.id).thenReturn('new-user-id');
        when(() => mockAuthResponse.user).thenReturn(mockUser);
        when(() => mockAuthResponse.session).thenReturn(mockSession);
        when(
          () => mockGoTrueClient.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => mockAuthResponse);

        final result = await authRepository.signUpWithEmail(
          email: 'newuser@example.com',
          password: 'password123',
        );

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not be a failure'),
          (user) => expect(user.id, 'new-user-id'),
        );
      });

      test('returns failure when user already exists', () async {
        when(
          () => mockGoTrueClient.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(AuthException('User already registered'));

        final result = await authRepository.signUpWithEmail(
          email: 'existing@example.com',
          password: 'password123',
        );

        expect(result.isLeft(), true);
      });
    });

    group('signOut', () {
      test('signs out successfully', () async {
        when(() => mockGoTrueClient.signOut()).thenAnswer((_) async => {});

        final result = await authRepository.signOut();

        expect(result.isRight(), true);
        verify(() => mockGoTrueClient.signOut()).called(1);
      });

      test('returns failure on sign out error', () async {
        when(
          () => mockGoTrueClient.signOut(),
        ).thenThrow(AuthException('Sign out failed'));

        final result = await authRepository.signOut();

        expect(result.isLeft(), true);
      });
    });

    group('authStateChanges', () {
      test('emits auth state changes', () async {
        final mockUser = MockUser();
        final mockSession = MockSession();
        when(() => mockUser.id).thenReturn('test-user-id');
        when(() => mockSession.user).thenReturn(mockUser);

        final authState = AuthState(AuthChangeEvent.signedIn, mockSession);

        when(
          () => mockGoTrueClient.onAuthStateChange,
        ).thenAnswer((_) => Stream.value(authState));

        final stream = authRepository.authStateChanges;

        await expectLater(
          stream,
          emits(
            predicate<AuthState>(
              (state) => state.event == AuthChangeEvent.signedIn,
            ),
          ),
        );
      });
    });
  });
}
