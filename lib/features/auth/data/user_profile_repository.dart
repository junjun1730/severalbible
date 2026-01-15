import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/user_profile.dart';
import '../domain/user_tier.dart';
import 'user_profile_data_source.dart';

/// Repository for user profile operations
/// Uses Either type for explicit error handling (functional programming)
class UserProfileRepository {
  final UserProfileDataSource _dataSource;

  UserProfileRepository(this._dataSource);

  /// Get user profile by user ID
  /// Returns Either<String, UserProfile> - Left for error, Right for success
  Future<Either<String, UserProfile>> getUserProfile(String userId) async {
    try {
      final response = await _dataSource.getProfile(userId);

      if (response == null) {
        return Left('User profile not found for id: $userId');
      }

      return Right(_mapToUserProfile(response));
    } on PostgrestException catch (e) {
      return Left('Database error: ${e.message}');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  /// Get user tier by user ID
  /// Returns guest tier if profile not found (for non-logged-in users)
  Future<Either<String, UserTier>> getUserTier(String userId) async {
    try {
      final response = await _dataSource.getProfile(userId);

      if (response == null) {
        return const Right(UserTier.guest);
      }

      final tier = UserTier.fromString(response['tier'] as String);
      return Right(tier);
    } on PostgrestException catch (e) {
      return Left('Database error: ${e.message}');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  /// Update user tier
  /// Returns Either<String, UserProfile> - Left for error, Right for success
  Future<Either<String, UserProfile>> updateUserTier({
    required String userId,
    required UserTier tier,
  }) async {
    try {
      final response = await _dataSource.updateTier(userId, tier.name);
      return Right(_mapToUserProfile(response));
    } on PostgrestException catch (e) {
      return Left('Database error: ${e.message}');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  /// Create user profile (usually called automatically by trigger)
  Future<Either<String, UserProfile>> createUserProfile({
    required String userId,
    UserTier tier = UserTier.member,
  }) async {
    try {
      final response = await _dataSource.createProfile(userId, tier.name);
      return Right(_mapToUserProfile(response));
    } on PostgrestException catch (e) {
      return Left('Database error: ${e.message}');
    } catch (e) {
      return Left('Unexpected error: $e');
    }
  }

  /// Map database response to UserProfile model
  UserProfile _mapToUserProfile(Map<String, dynamic> data) {
    return UserProfile(
      id: data['id'] as String,
      tier: UserTier.fromString(data['tier'] as String),
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }
}
