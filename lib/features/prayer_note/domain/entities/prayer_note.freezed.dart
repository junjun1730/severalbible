// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prayer_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrayerNote {

 String get id; String get userId; String? get scriptureId; String get content; DateTime get createdAt; DateTime get updatedAt;// Joined scripture data (optional)
 String? get scriptureReference; String? get scriptureContent;
/// Create a copy of PrayerNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrayerNoteCopyWith<PrayerNote> get copyWith => _$PrayerNoteCopyWithImpl<PrayerNote>(this as PrayerNote, _$identity);

  /// Serializes this PrayerNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrayerNote&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.scriptureId, scriptureId) || other.scriptureId == scriptureId)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.scriptureReference, scriptureReference) || other.scriptureReference == scriptureReference)&&(identical(other.scriptureContent, scriptureContent) || other.scriptureContent == scriptureContent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,scriptureId,content,createdAt,updatedAt,scriptureReference,scriptureContent);

@override
String toString() {
  return 'PrayerNote(id: $id, userId: $userId, scriptureId: $scriptureId, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, scriptureReference: $scriptureReference, scriptureContent: $scriptureContent)';
}


}

/// @nodoc
abstract mixin class $PrayerNoteCopyWith<$Res>  {
  factory $PrayerNoteCopyWith(PrayerNote value, $Res Function(PrayerNote) _then) = _$PrayerNoteCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? scriptureId, String content, DateTime createdAt, DateTime updatedAt, String? scriptureReference, String? scriptureContent
});




}
/// @nodoc
class _$PrayerNoteCopyWithImpl<$Res>
    implements $PrayerNoteCopyWith<$Res> {
  _$PrayerNoteCopyWithImpl(this._self, this._then);

  final PrayerNote _self;
  final $Res Function(PrayerNote) _then;

/// Create a copy of PrayerNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? scriptureId = freezed,Object? content = null,Object? createdAt = null,Object? updatedAt = null,Object? scriptureReference = freezed,Object? scriptureContent = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,scriptureId: freezed == scriptureId ? _self.scriptureId : scriptureId // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,scriptureReference: freezed == scriptureReference ? _self.scriptureReference : scriptureReference // ignore: cast_nullable_to_non_nullable
as String?,scriptureContent: freezed == scriptureContent ? _self.scriptureContent : scriptureContent // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PrayerNote].
extension PrayerNotePatterns on PrayerNote {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrayerNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrayerNote() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrayerNote value)  $default,){
final _that = this;
switch (_that) {
case _PrayerNote():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrayerNote value)?  $default,){
final _that = this;
switch (_that) {
case _PrayerNote() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? scriptureId,  String content,  DateTime createdAt,  DateTime updatedAt,  String? scriptureReference,  String? scriptureContent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrayerNote() when $default != null:
return $default(_that.id,_that.userId,_that.scriptureId,_that.content,_that.createdAt,_that.updatedAt,_that.scriptureReference,_that.scriptureContent);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? scriptureId,  String content,  DateTime createdAt,  DateTime updatedAt,  String? scriptureReference,  String? scriptureContent)  $default,) {final _that = this;
switch (_that) {
case _PrayerNote():
return $default(_that.id,_that.userId,_that.scriptureId,_that.content,_that.createdAt,_that.updatedAt,_that.scriptureReference,_that.scriptureContent);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? scriptureId,  String content,  DateTime createdAt,  DateTime updatedAt,  String? scriptureReference,  String? scriptureContent)?  $default,) {final _that = this;
switch (_that) {
case _PrayerNote() when $default != null:
return $default(_that.id,_that.userId,_that.scriptureId,_that.content,_that.createdAt,_that.updatedAt,_that.scriptureReference,_that.scriptureContent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrayerNote implements PrayerNote {
  const _PrayerNote({required this.id, required this.userId, this.scriptureId, required this.content, required this.createdAt, required this.updatedAt, this.scriptureReference, this.scriptureContent});
  factory _PrayerNote.fromJson(Map<String, dynamic> json) => _$PrayerNoteFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String? scriptureId;
@override final  String content;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
// Joined scripture data (optional)
@override final  String? scriptureReference;
@override final  String? scriptureContent;

/// Create a copy of PrayerNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrayerNoteCopyWith<_PrayerNote> get copyWith => __$PrayerNoteCopyWithImpl<_PrayerNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrayerNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrayerNote&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.scriptureId, scriptureId) || other.scriptureId == scriptureId)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.scriptureReference, scriptureReference) || other.scriptureReference == scriptureReference)&&(identical(other.scriptureContent, scriptureContent) || other.scriptureContent == scriptureContent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,scriptureId,content,createdAt,updatedAt,scriptureReference,scriptureContent);

@override
String toString() {
  return 'PrayerNote(id: $id, userId: $userId, scriptureId: $scriptureId, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, scriptureReference: $scriptureReference, scriptureContent: $scriptureContent)';
}


}

/// @nodoc
abstract mixin class _$PrayerNoteCopyWith<$Res> implements $PrayerNoteCopyWith<$Res> {
  factory _$PrayerNoteCopyWith(_PrayerNote value, $Res Function(_PrayerNote) _then) = __$PrayerNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? scriptureId, String content, DateTime createdAt, DateTime updatedAt, String? scriptureReference, String? scriptureContent
});




}
/// @nodoc
class __$PrayerNoteCopyWithImpl<$Res>
    implements _$PrayerNoteCopyWith<$Res> {
  __$PrayerNoteCopyWithImpl(this._self, this._then);

  final _PrayerNote _self;
  final $Res Function(_PrayerNote) _then;

/// Create a copy of PrayerNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? scriptureId = freezed,Object? content = null,Object? createdAt = null,Object? updatedAt = null,Object? scriptureReference = freezed,Object? scriptureContent = freezed,}) {
  return _then(_PrayerNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,scriptureId: freezed == scriptureId ? _self.scriptureId : scriptureId // ignore: cast_nullable_to_non_nullable
as String?,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,scriptureReference: freezed == scriptureReference ? _self.scriptureReference : scriptureReference // ignore: cast_nullable_to_non_nullable
as String?,scriptureContent: freezed == scriptureContent ? _self.scriptureContent : scriptureContent // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
