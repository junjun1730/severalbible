import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

/// Web Client ID for Google Sign-In (used for both iOS and Android)
const String _webClientId =
    '52159302124-kssm6g9u8bt13kgli6q1o6d79fu3ifho.apps.googleusercontent.com';

/// iOS Client ID for Google Sign-In
const String _iosClientId =
    '52159302124-qfuljstfo9fl1ds3dh4eff44inkg22rp.apps.googleusercontent.com';

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

  /// Sign in with Google using Native Google Sign-In
  /// Uses google_sign_in package for native UI and signInWithIdToken for Supabase
  Future<Either<String, User>> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        clientId: _iosClientId,
        serverClientId: _webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return const Left('Google sign in was cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        return const Left('Failed to get ID token from Google');
      }

      // Use signInWithIdToken without nonce for Google
      // Google Sign-In doesn't use nonce by default
      final response = await _supabaseService.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null) {
        return Right(response.user!);
      } else {
        return const Left('Google sign in failed: No user returned');
      }
    } on AuthException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  /// Sign in with Apple using native Sign in with Apple
  /// Uses sign_in_with_apple package for native UI
  Future<Either<String, User>> signInWithApple() async {
    try {
      // Generate a random nonce
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      // Request Apple credential with the hashed nonce
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        return const Left('Failed to get ID token from Apple');
      }

      // Sign in to Supabase with the raw nonce (not hashed)
      final response = await _supabaseService.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (response.user != null) {
        return Right(response.user!);
      } else {
        return const Left('Apple sign in failed: No user returned');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const Left('Apple sign in was cancelled');
      }
      return Left('Apple sign in failed: ${e.message}');
    } on AuthException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  /// Sign in anonymously (Guest login)
  /// Creates an anonymous user session
  Future<Either<String, Unit>> signInAnonymously() async {
    try {
      await _supabaseService.auth.signInAnonymously();
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left('Anonymous sign in failed: $e');
    }
  }

  /// Generate a random nonce string
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// SHA256 hash of a string
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
