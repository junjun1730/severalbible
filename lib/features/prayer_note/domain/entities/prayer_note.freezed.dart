// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prayer_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PrayerNote _$PrayerNoteFromJson(Map<String, dynamic> json) {
  return _PrayerNote.fromJson(json);
}

/// @nodoc
mixin _$PrayerNote {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get scriptureId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // Joined scripture data (optional)
  String? get scriptureReference => throw _privateConstructorUsedError;
  String? get scriptureContent => throw _privateConstructorUsedError;

  /// Serializes this PrayerNote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PrayerNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrayerNoteCopyWith<PrayerNote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrayerNoteCopyWith<$Res> {
  factory $PrayerNoteCopyWith(
    PrayerNote value,
    $Res Function(PrayerNote) then,
  ) = _$PrayerNoteCopyWithImpl<$Res, PrayerNote>;
  @useResult
  $Res call({
    String id,
    String userId,
    String? scriptureId,
    String content,
    DateTime createdAt,
    DateTime updatedAt,
    String? scriptureReference,
    String? scriptureContent,
  });
}

/// @nodoc
class _$PrayerNoteCopyWithImpl<$Res, $Val extends PrayerNote>
    implements $PrayerNoteCopyWith<$Res> {
  _$PrayerNoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrayerNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? scriptureId = freezed,
    Object? content = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? scriptureReference = freezed,
    Object? scriptureContent = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            scriptureId: freezed == scriptureId
                ? _value.scriptureId
                : scriptureId // ignore: cast_nullable_to_non_nullable
                      as String?,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            scriptureReference: freezed == scriptureReference
                ? _value.scriptureReference
                : scriptureReference // ignore: cast_nullable_to_non_nullable
                      as String?,
            scriptureContent: freezed == scriptureContent
                ? _value.scriptureContent
                : scriptureContent // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PrayerNoteImplCopyWith<$Res>
    implements $PrayerNoteCopyWith<$Res> {
  factory _$$PrayerNoteImplCopyWith(
    _$PrayerNoteImpl value,
    $Res Function(_$PrayerNoteImpl) then,
  ) = __$$PrayerNoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String? scriptureId,
    String content,
    DateTime createdAt,
    DateTime updatedAt,
    String? scriptureReference,
    String? scriptureContent,
  });
}

/// @nodoc
class __$$PrayerNoteImplCopyWithImpl<$Res>
    extends _$PrayerNoteCopyWithImpl<$Res, _$PrayerNoteImpl>
    implements _$$PrayerNoteImplCopyWith<$Res> {
  __$$PrayerNoteImplCopyWithImpl(
    _$PrayerNoteImpl _value,
    $Res Function(_$PrayerNoteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PrayerNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? scriptureId = freezed,
    Object? content = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? scriptureReference = freezed,
    Object? scriptureContent = freezed,
  }) {
    return _then(
      _$PrayerNoteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        scriptureId: freezed == scriptureId
            ? _value.scriptureId
            : scriptureId // ignore: cast_nullable_to_non_nullable
                  as String?,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        scriptureReference: freezed == scriptureReference
            ? _value.scriptureReference
            : scriptureReference // ignore: cast_nullable_to_non_nullable
                  as String?,
        scriptureContent: freezed == scriptureContent
            ? _value.scriptureContent
            : scriptureContent // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PrayerNoteImpl implements _PrayerNote {
  const _$PrayerNoteImpl({
    required this.id,
    required this.userId,
    this.scriptureId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.scriptureReference,
    this.scriptureContent,
  });

  factory _$PrayerNoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrayerNoteImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? scriptureId;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  // Joined scripture data (optional)
  @override
  final String? scriptureReference;
  @override
  final String? scriptureContent;

  @override
  String toString() {
    return 'PrayerNote(id: $id, userId: $userId, scriptureId: $scriptureId, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, scriptureReference: $scriptureReference, scriptureContent: $scriptureContent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrayerNoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.scriptureId, scriptureId) ||
                other.scriptureId == scriptureId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.scriptureReference, scriptureReference) ||
                other.scriptureReference == scriptureReference) &&
            (identical(other.scriptureContent, scriptureContent) ||
                other.scriptureContent == scriptureContent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    scriptureId,
    content,
    createdAt,
    updatedAt,
    scriptureReference,
    scriptureContent,
  );

  /// Create a copy of PrayerNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrayerNoteImplCopyWith<_$PrayerNoteImpl> get copyWith =>
      __$$PrayerNoteImplCopyWithImpl<_$PrayerNoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrayerNoteImplToJson(this);
  }
}

abstract class _PrayerNote implements PrayerNote {
  const factory _PrayerNote({
    required final String id,
    required final String userId,
    final String? scriptureId,
    required final String content,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? scriptureReference,
    final String? scriptureContent,
  }) = _$PrayerNoteImpl;

  factory _PrayerNote.fromJson(Map<String, dynamic> json) =
      _$PrayerNoteImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String? get scriptureId;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt; // Joined scripture data (optional)
  @override
  String? get scriptureReference;
  @override
  String? get scriptureContent;

  /// Create a copy of PrayerNote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrayerNoteImplCopyWith<_$PrayerNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
