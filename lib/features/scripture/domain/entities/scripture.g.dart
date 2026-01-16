// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scripture.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScriptureImpl _$$ScriptureImplFromJson(Map<String, dynamic> json) =>
    _$ScriptureImpl(
      id: json['id'] as String,
      book: json['book'] as String,
      chapter: (json['chapter'] as num).toInt(),
      verse: (json['verse'] as num).toInt(),
      content: json['content'] as String,
      reference: json['reference'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ScriptureImplToJson(_$ScriptureImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'book': instance.book,
      'chapter': instance.chapter,
      'verse': instance.verse,
      'content': instance.content,
      'reference': instance.reference,
      'isPremium': instance.isPremium,
      'category': instance.category,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
