import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scripture.dart';

/// Abstract repository interface for scripture operations
/// Defines the contract for data layer implementations
abstract class ScriptureRepository {
  /// Get random scripture for guest users (duplicates allowed)
  /// [count] - Number of scriptures to retrieve
  /// Returns Either<Failure, List<Scripture>>
  Future<Either<Failure, List<Scripture>>> getRandomScripture(int count);

  /// Get daily scriptures for member users (no duplicates for today)
  /// [userId] - The authenticated user's ID
  /// [count] - Number of scriptures to retrieve (default 3)
  /// Returns Either<Failure, List<Scripture>>
  Future<Either<Failure, List<Scripture>>> getDailyScriptures({
    required String userId,
    required int count,
  });

  /// Get premium scriptures for premium users
  /// [userId] - The authenticated user's ID
  /// [count] - Number of premium scriptures to retrieve (default 3)
  /// Returns Either<Failure, List<Scripture>>
  Future<Either<Failure, List<Scripture>>> getPremiumScriptures({
    required String userId,
    required int count,
  });

  /// Record that a user viewed a scripture
  /// [userId] - The authenticated user's ID
  /// [scriptureId] - The scripture that was viewed
  /// Returns Either<Failure, void>
  Future<Either<Failure, void>> recordScriptureView({
    required String userId,
    required String scriptureId,
  });

  /// Get user's scripture viewing history for a specific date
  /// [userId] - The authenticated user's ID
  /// [date] - The date to retrieve history for
  /// Returns Either<Failure, List<Scripture>>
  Future<Either<Failure, List<Scripture>>> getScriptureHistory({
    required String userId,
    required DateTime date,
  });
}
