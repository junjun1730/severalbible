// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PrayerNoteImpl _$$PrayerNoteImplFromJson(Map<String, dynamic> json) =>
    _$PrayerNoteImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      scriptureId: json['scriptureId'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      scriptureReference: json['scriptureReference'] as String?,
      scriptureContent: json['scriptureContent'] as String?,
    );

Map<String, dynamic> _$$PrayerNoteImplToJson(_$PrayerNoteImpl instance) =>
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
