import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract data source for user profile database operations
/// This abstraction allows easy mocking in tests
abstract class UserProfileDataSource {
  Future<Map<String, dynamic>?> getProfile(String userId);
  Future<Map<String, dynamic>> updateTier(String userId, String tier);
  Future<Map<String, dynamic>> createProfile(String userId, String tier);
}

/// Production implementation using Supabase
class SupabaseUserProfileDataSource implements UserProfileDataSource {
  final SupabaseClient _client;
  static const String _tableName = 'user_profiles';

  SupabaseUserProfileDataSource(this._client);

  @override
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    return await _client
        .from(_tableName)
        .select()
        .eq('id', userId)
        .maybeSingle();
  }

  @override
  Future<Map<String, dynamic>> updateTier(String userId, String tier) async {
    return await _client
        .from(_tableName)
        .update({'tier': tier})
        .eq('id', userId)
        .select()
        .single();
  }

  @override
  Future<Map<String, dynamic>> createProfile(String userId, String tier) async {
    return await _client
        .from(_tableName)
        .insert({'id': userId, 'tier': tier})
        .select()
        .single();
  }
}
