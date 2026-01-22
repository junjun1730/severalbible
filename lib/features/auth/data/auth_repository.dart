import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

/// Repository for authentication operations
/// Uses Either type for explicit error handling (functional programming)
class AuthRepository {
  final SupabaseService _supabaseService;

  AuthRepository(this._supabaseService);

  /// Get the currently authenticated user
  User? get currentUser => _supabaseService.auth.currentUser;

  /// Check if a user is currently logged in
  bool get isLoggedIn => currentUser != null;

  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges =>
      _supabaseService.auth.onAuthStateChange;

  /// Sign in with email and password
  /// Returns Either<String, User> - Left for error, Right for success
  Future<Either<String, User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return Right(response.user!);
      } else {
        return const Left('Sign in failed: No user returned');
      }
    } on AuthException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  /// Sign up with email and password
  /// Returns Either<String, User> - Left for error, Right for success
  Future<Either<String, User>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return Right(response.user!);
      } else {
        return const Left('Sign up failed: No user returned');
      }
    } on AuthException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  /// Sign out the current user
  /// Returns Either<String, Unit> - Left for error, Right for success
  Future<Either<String, Unit>> signOut() async {
    try {
      await _supabaseService.auth.signOut();
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  /// Sign in with Google OAuth
  Future<Either<String, Unit>> signInWithGoogle() async {
    try {
      await _supabaseService.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.example.severalbible://login-callback',
      );
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  /// Sign in with Apple OAuth
  Future<Either<String, Unit>> signInWithApple() async {
    try {
      await _supabaseService.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'com.example.severalbible://login-callback',
      );
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }
}
