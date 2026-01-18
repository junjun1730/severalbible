import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/prayer_note.dart';

/// Abstract repository interface for prayer note operations
/// Defines the contract for data layer implementations
abstract class PrayerNoteRepository {
  /// Create a new prayer note
  /// [userId] - The authenticated user's ID
  /// [content] - The prayer note content
  /// [scriptureId] - Optional reference to a scripture
  /// Returns Either<Failure, PrayerNote>
  Future<Either<Failure, PrayerNote>> createPrayerNote({
    required String userId,
    required String content,
    String? scriptureId,
  });

  /// Get prayer notes for a date range (tier-based filtering)
  /// [userId] - The authenticated user's ID
  /// [startDate] - Optional start date filter
  /// [endDate] - Optional end date filter
  /// Returns Either<Failure, List<PrayerNote>>
  Future<Either<Failure, List<PrayerNote>>> getPrayerNotes({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get prayer notes for a specific date
  /// [userId] - The authenticated user's ID
  /// [date] - The specific date to fetch notes for
  /// Returns Either<Failure, List<PrayerNote>>
  Future<Either<Failure, List<PrayerNote>>> getPrayerNotesByDate({
    required String userId,
    required DateTime date,
  });

  /// Update an existing prayer note
  /// [noteId] - The ID of the note to update
  /// [content] - The new content
  /// Returns Either<Failure, PrayerNote>
  Future<Either<Failure, PrayerNote>> updatePrayerNote({
    required String noteId,
    required String content,
  });

  /// Delete a prayer note
  /// [noteId] - The ID of the note to delete
  /// Returns Either<Failure, void>
  Future<Either<Failure, void>> deletePrayerNote({
    required String noteId,
  });

  /// Check if a date is accessible based on user tier
  /// Member: last 3 days accessible
  /// Premium: all dates accessible
  /// [userId] - The authenticated user's ID
  /// [date] - The date to check accessibility for
  /// Returns Either<Failure, bool>
  Future<Either<Failure, bool>> isDateAccessible({
    required String userId,
    required DateTime date,
  });
}
