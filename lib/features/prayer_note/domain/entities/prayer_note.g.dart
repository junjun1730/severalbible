// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrayerNote _$PrayerNoteFromJson(Map<String, dynamic> json) => _PrayerNote(
  id: json['id'] as String,
  userId: json['userId'] as String,
  scriptureId: json['scriptureId'] as String?,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  scriptureReference: json['scriptureReference'] as String?,
  scriptureContent: json['scriptureContent'] as String?,
);

Map<String, dynamic> _$PrayerNoteToJson(_PrayerNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'scriptureId': instance.scriptureId,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'scriptureReference': instance.scriptureReference,
      'scriptureContent': instance.scriptureContent,
    };
