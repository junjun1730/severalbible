import '../../../../core/services/supabase_service.dart';
import 'scripture_datasource.dart';

/// Supabase implementation of ScriptureDataSource
/// Makes actual RPC calls to Supabase backend
class SupabaseScriptureDataSource implements ScriptureDataSource {
  final SupabaseService _supabaseService;

  SupabaseScriptureDataSource(this._supabaseService);

  @override
  Future<List<Map<String, dynamic>>> getRandomScripture(int count) async {
    final response = await _supabaseService.rpc<List<dynamic>>(
      'get_random_scripture',
      params: {'limit_count': count},
    );
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getDailyScriptures({
    required String userId,
    required int count,
  }) async {
    final response = await _supabaseService.rpc<List<dynamic>>(
      'get_daily_scriptures',
      params: {'p_user_id': userId, 'limit_count': count},
    );
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getPremiumScriptures({
    required String userId,
    required int count,
  }) async {
    final response = await _supabaseService.rpc<List<dynamic>>(
      'get_premium_scriptures',
      params: {'p_user_id': userId, 'limit_count': count},
    );
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> recordScriptureView({
    required String userId,
    required String scriptureId,
  }) async {
    await _supabaseService.rpc<void>(
      'record_scripture_view',
      params: {'p_user_id': userId, 'p_scripture_id': scriptureId},
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getScriptureHistory({
    required String userId,
    required DateTime date,
  }) async {
    final response = await _supabaseService.rpc<List<dynamic>>(
      'get_scripture_history',
      params: {
        'p_user_id': userId,
        'p_date': date.toIso8601String().split('T').first,
      },
    );
    return List<Map<String, dynamic>>.from(response);
  }
}
