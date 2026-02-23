// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scripture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Scripture {

 String get id; String get book; int get chapter; int get verse; String get content; String get reference; bool get isPremium; String? get category; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Scripture
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptureCopyWith<Scripture> get copyWith => _$ScriptureCopyWithImpl<Scripture>(this as Scripture, _$identity);

  /// Serializes this Scripture to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Scripture&&(identical(other.id, id) || other.id == id)&&(identical(other.book, book) || other.book == book)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verse, verse) || other.verse == verse)&&(identical(other.content, content) || other.content == content)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.category, category) || other.category == category)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,book,chapter,verse,content,reference,isPremium,category,createdAt,updatedAt);

@override
String toString() {
  return 'Scripture(id: $id, book: $book, chapter: $chapter, verse: $verse, content: $content, reference: $reference, isPremium: $isPremium, category: $category, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ScriptureCopyWith<$Res>  {
  factory $ScriptureCopyWith(Scripture value, $Res Function(Scripture) _then) = _$ScriptureCopyWithImpl;
@useResult
$Res call({
 String id, String book, int chapter, int verse, String content, String reference, bool isPremium, String? category, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ScriptureCopyWithImpl<$Res>
    implements $ScriptureCopyWith<$Res> {
  _$ScriptureCopyWithImpl(this._self, this._then);

  final Scripture _self;
  final $Res Function(Scripture) _then;

/// Create a copy of Scripture
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? book = null,Object? chapter = null,Object? verse = null,Object? content = null,Object? reference = null,Object? isPremium = null,Object? category = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,book: null == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as String,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verse: null == verse ? _self.verse : verse // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Scripture].
extension ScripturePatterns on Scripture {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Scripture value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Scripture() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Scripture value)  $default,){
final _that = this;
switch (_that) {
case _Scripture():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Scripture value)?  $default,){
final _that = this;
switch (_that) {
case _Scripture() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String book,  int chapter,  int verse,  String content,  String reference,  bool isPremium,  String? category,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Scripture() when $default != null:
return $default(_that.id,_that.book,_that.chapter,_that.verse,_that.content,_that.reference,_that.isPremium,_that.category,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String book,  int chapter,  int verse,  String content,  String reference,  bool isPremium,  String? category,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Scripture():
return $default(_that.id,_that.book,_that.chapter,_that.verse,_that.content,_that.reference,_that.isPremium,_that.category,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String book,  int chapter,  int verse,  String content,  String reference,  bool isPremium,  String? category,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Scripture() when $default != null:
return $default(_that.id,_that.book,_that.chapter,_that.verse,_that.content,_that.reference,_that.isPremium,_that.category,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Scripture implements Scripture {
  const _Scripture({required this.id, required this.book, required this.chapter, required this.verse, required this.content, required this.reference, this.isPremium = false, this.category, required this.createdAt, required this.updatedAt});
  factory _Scripture.fromJson(Map<String, dynamic> json) => _$ScriptureFromJson(json);

@override final  String id;
@override final  String book;
@override final  int chapter;
@override final  int verse;
@override final  String content;
@override final  String reference;
@override@JsonKey() final  bool isPremium;
@override final  String? category;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Scripture
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScriptureCopyWith<_Scripture> get copyWith => __$ScriptureCopyWithImpl<_Scripture>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScriptureToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Scripture&&(identical(other.id, id) || other.id == id)&&(identical(other.book, book) || other.book == book)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verse, verse) || other.verse == verse)&&(identical(other.content, content) || other.content == content)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.category, category) || other.category == category)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,book,chapter,verse,content,reference,isPremium,category,createdAt,updatedAt);

@override
String toString() {
  return 'Scripture(id: $id, book: $book, chapter: $chapter, verse: $verse, content: $content, reference: $reference, isPremium: $isPremium, category: $category, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ScriptureCopyWith<$Res> implements $ScriptureCopyWith<$Res> {
  factory _$ScriptureCopyWith(_Scripture value, $Res Function(_Scripture) _then) = __$ScriptureCopyWithImpl;
@override @useResult
$Res call({
 String id, String book, int chapter, int verse, String content, String reference, bool isPremium, String? category, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ScriptureCopyWithImpl<$Res>
    implements _$ScriptureCopyWith<$Res> {
  __$ScriptureCopyWithImpl(this._self, this._then);

  final _Scripture _self;
  final $Res Function(_Scripture) _then;

/// Create a copy of Scripture
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? book = null,Object? chapter = null,Object? verse = null,Object? content = null,Object? reference = null,Object? isPremium = null,Object? category = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Scripture(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,book: null == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as String,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verse: null == verse ? _self.verse : verse // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
