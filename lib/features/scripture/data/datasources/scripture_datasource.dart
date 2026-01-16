/// Abstract interface for scripture data source operations
/// This abstraction allows for mocking in tests
abstract class ScriptureDataSource {
  /// Get random scriptures (for guest users)
  /// [count] - Number of scriptures to retrieve
  Future<List<Map<String, dynamic>>> getRandomScripture(int count);

  /// Get daily scriptures with no-duplicate logic (for member users)
  /// [userId] - The authenticated user's ID
  /// [count] - Number of scriptures to retrieve
  Future<List<Map<String, dynamic>>> getDailyScriptures({
    required String userId,
    required int count,
  });

  /// Get premium scriptures (for premium users)
  /// [userId] - The authenticated user's ID
  /// [count] - Number of scriptures to retrieve
  Future<List<Map<String, dynamic>>> getPremiumScriptures({
    required String userId,
    required int count,
  });

  /// Record that a user viewed a scripture
  /// [userId] - The authenticated user's ID
  /// [scriptureId] - The scripture ID that was viewed
  Future<void> recordScriptureView({
    required String userId,
    required String scriptureId,
  });

  /// Get user's scripture history for a specific date
  /// [userId] - The authenticated user's ID
  /// [date] - The date to retrieve history for
  Future<List<Map<String, dynamic>>> getScriptureHistory({
    required String userId,
    required DateTime date,
  });
}
