/// Abstract interface for prayer note data operations
/// Implementations handle actual database communication
abstract class PrayerNoteDataSource {
  /// Create a new prayer note
  /// Returns the created note as JSON
  Future<Map<String, dynamic>> createPrayerNote({
    required String userId,
    required String content,
    String? scriptureId,
  });

  /// Get prayer notes for a date range
  /// Returns list of notes as JSON
  Future<List<Map<String, dynamic>>> getPrayerNotes({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get prayer notes for a specific date
  /// Returns list of notes as JSON
  Future<List<Map<String, dynamic>>> getPrayerNotesByDate({
    required String userId,
    required DateTime date,
  });

  /// Update an existing prayer note
  /// Returns the updated note as JSON
  Future<Map<String, dynamic>> updatePrayerNote({
    required String noteId,
    required String content,
  });

  /// Delete a prayer note
  Future<void> deletePrayerNote({
    required String noteId,
  });

  /// Check if a date is accessible based on user tier
  /// Returns true if accessible, false otherwise
  Future<bool> isDateAccessible({
    required String userId,
    required DateTime date,
  });
}
