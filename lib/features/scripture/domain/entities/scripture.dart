import 'package:freezed_annotation/freezed_annotation.dart';

part 'scripture.freezed.dart';
part 'scripture.g.dart';

/// Scripture entity representing a Bible verse or spiritual content
/// Immutable data class using freezed for functional programming
@freezed
class Scripture with _$Scripture {
  const factory Scripture({
    required String id,
    required String book,
    required int chapter,
    required int verse,
    required String content,
    required String reference,
    @Default(false) bool isPremium,
    String? category,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Scripture;

  factory Scripture.fromJson(Map<String, dynamic> json) =>
      _$ScriptureFromJson(_convertSnakeToCamel(json));
}

/// Converts snake_case keys to camelCase for freezed compatibility
Map<String, dynamic> _convertSnakeToCamel(Map<String, dynamic> json) {
  return {
    'id': json['id'],
    'book': json['book'],
    'chapter': json['chapter'],
    'verse': json['verse'],
    'content': json['content'],
    'reference': json['reference'],
    'isPremium': json['is_premium'] ?? false,
    'category': json['category'],
    'createdAt': json['created_at'],
    'updatedAt': json['updated_at'],
  };
}
