import '../../../../core/services/supabase_service.dart';
import 'prayer_note_datasource.dart';

/// Supabase implementation of PrayerNoteDataSource
/// Makes actual RPC calls to Supabase backend
class SupabasePrayerNoteDataSource implements PrayerNoteDataSource {
  final SupabaseService _supabaseService;

  SupabasePrayerNoteDataSource(this._supabaseService);

  @override
  Future<Map<String, dynamic>> createPrayerNote({
    required String userId,
    required String content,
    String? scriptureId,
  }) async {
    final response = await _supabaseService.rpc<Map<String, dynamic>>(
      'create_prayer_note',
      params: {
        'p_user_id': userId,
        'p_content': content,
        'p_scripture_id': scriptureId,
      },
    );
    return response;
  }

  @override
  Future<List<Map<String, dynamic>>> getPrayerNotes({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _supabaseService.rpc<List<dynamic>>(
      'get_prayer_notes',
      params: {
        'p_user_id': userId,
        'p_start_date': startDate?.toIso8601String().split('T').first,
        'p_end_date': endDate?.toIso8601String().split('T').first,
      },
    );
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getPrayerNotesByDate({
    required String userId,
    required DateTime date,
  }) async {
    final response = await _supabaseService.rpc<List<dynamic>>(
      'get_prayer_notes_by_date',
      params: {
        'p_user_id': userId,
        'p_date': date.toIso8601String().split('T').first,
      },
    );
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>> updatePrayerNote({
    required String noteId,
    required String content,
  }) async {
    final response = await _supabaseService.rpc<Map<String, dynamic>>(
      'update_prayer_note',
      params: {
        'p_note_id': noteId,
        'p_content': content,
      },
    );
    return response;
  }

  @override
  Future<void> deletePrayerNote({
    required String noteId,
  }) async {
    await _supabaseService.rpc<void>(
      'delete_prayer_note',
      params: {
        'p_note_id': noteId,
      },
    );
  }

  @override
  Future<bool> isDateAccessible({
    required String userId,
    required DateTime date,
  }) async {
    final response = await _supabaseService.rpc<bool>(
      'is_date_accessible',
      params: {
        'p_user_id': userId,
        'p_date': date.toIso8601String().split('T').first,
      },
    );
    return response;
  }
}
