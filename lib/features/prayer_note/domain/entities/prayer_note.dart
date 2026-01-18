import 'package:freezed_annotation/freezed_annotation.dart';

part 'prayer_note.freezed.dart';
part 'prayer_note.g.dart';

/// PrayerNote entity representing a user's meditation record
/// Immutable data class using freezed for functional programming
@freezed
class PrayerNote with _$PrayerNote {
  const factory PrayerNote({
    required String id,
    required String userId,
    String? scriptureId,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
    // Joined scripture data (optional)
    String? scriptureReference,
    String? scriptureContent,
  }) = _PrayerNote;

  factory PrayerNote.fromJson(Map<String, dynamic> json) =>
      _$PrayerNoteFromJson(_convertSnakeToCamel(json));
}

/// Converts snake_case keys to camelCase for freezed compatibility
Map<String, dynamic> _convertSnakeToCamel(Map<String, dynamic> json) {
  return {
    'id': json['id'],
    'userId': json['user_id'],
    'scriptureId': json['scripture_id'],
    'content': json['content'],
    'createdAt': json['created_at'],
    'updatedAt': json['updated_at'],
    'scriptureReference': json['scripture_reference'],
    'scriptureContent': json['scripture_content'],
  };
}
