// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scripture.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Scripture _$ScriptureFromJson(Map<String, dynamic> json) {
  return _Scripture.fromJson(json);
}

/// @nodoc
mixin _$Scripture {
  String get id => throw _privateConstructorUsedError;
  String get book => throw _privateConstructorUsedError;
  int get chapter => throw _privateConstructorUsedError;
  int get verse => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get reference => throw _privateConstructorUsedError;
  bool get isPremium => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Scripture to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Scripture
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScriptureCopyWith<Scripture> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScriptureCopyWith<$Res> {
  factory $ScriptureCopyWith(Scripture value, $Res Function(Scripture) then) =
      _$ScriptureCopyWithImpl<$Res, Scripture>;
  @useResult
  $Res call({
    String id,
    String book,
    int chapter,
    int verse,
    String content,
    String reference,
    bool isPremium,
    String? category,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$ScriptureCopyWithImpl<$Res, $Val extends Scripture>
    implements $ScriptureCopyWith<$Res> {
  _$ScriptureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Scripture
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? book = null,
    Object? chapter = null,
    Object? verse = null,
    Object? content = null,
    Object? reference = null,
    Object? isPremium = null,
    Object? category = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            book: null == book
                ? _value.book
                : book // ignore: cast_nullable_to_non_nullable
                      as String,
            chapter: null == chapter
                ? _value.chapter
                : chapter // ignore: cast_nullable_to_non_nullable
                      as int,
            verse: null == verse
                ? _value.verse
                : verse // ignore: cast_nullable_to_non_nullable
                      as int,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            reference: null == reference
                ? _value.reference
                : reference // ignore: cast_nullable_to_non_nullable
                      as String,
            isPremium: null == isPremium
                ? _value.isPremium
                : isPremium // ignore: cast_nullable_to_non_nullable
                      as bool,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScriptureImplCopyWith<$Res>
    implements $ScriptureCopyWith<$Res> {
  factory _$$ScriptureImplCopyWith(
    _$ScriptureImpl value,
    $Res Function(_$ScriptureImpl) then,
  ) = __$$ScriptureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String book,
    int chapter,
    int verse,
    String content,
    String reference,
    bool isPremium,
    String? category,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$ScriptureImplCopyWithImpl<$Res>
    extends _$ScriptureCopyWithImpl<$Res, _$ScriptureImpl>
    implements _$$ScriptureImplCopyWith<$Res> {
  __$$ScriptureImplCopyWithImpl(
    _$ScriptureImpl _value,
    $Res Function(_$ScriptureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Scripture
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? book = null,
    Object? chapter = null,
    Object? verse = null,
    Object? content = null,
    Object? reference = null,
    Object? isPremium = null,
    Object? category = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ScriptureImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        book: null == book
            ? _value.book
            : book // ignore: cast_nullable_to_non_nullable
                  as String,
        chapter: null == chapter
            ? _value.chapter
            : chapter // ignore: cast_nullable_to_non_nullable
                  as int,
        verse: null == verse
            ? _value.verse
            : verse // ignore: cast_nullable_to_non_nullable
                  as int,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        reference: null == reference
            ? _value.reference
            : reference // ignore: cast_nullable_to_non_nullable
                  as String,
        isPremium: null == isPremium
            ? _value.isPremium
            : isPremium // ignore: cast_nullable_to_non_nullable
                  as bool,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScriptureImpl implements _Scripture {
  const _$ScriptureImpl({
    required this.id,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.content,
    required this.reference,
    this.isPremium = false,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$ScriptureImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScriptureImplFromJson(json);

  @override
  final String id;
  @override
  final String book;
  @override
  final int chapter;
  @override
  final int verse;
  @override
  final String content;
  @override
  final String reference;
  @override
  @JsonKey()
  final bool isPremium;
  @override
  final String? category;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Scripture(id: $id, book: $book, chapter: $chapter, verse: $verse, content: $content, reference: $reference, isPremium: $isPremium, category: $category, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScriptureImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.book, book) || other.book == book) &&
            (identical(other.chapter, chapter) || other.chapter == chapter) &&
            (identical(other.verse, verse) || other.verse == verse) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.reference, reference) ||
                other.reference == reference) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    book,
    chapter,
    verse,
    content,
    reference,
    isPremium,
    category,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Scripture
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScriptureImplCopyWith<_$ScriptureImpl> get copyWith =>
      __$$ScriptureImplCopyWithImpl<_$ScriptureImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScriptureImplToJson(this);
  }
}

abstract class _Scripture implements Scripture {
  const factory _Scripture({
    required final String id,
    required final String book,
    required final int chapter,
    required final int verse,
    required final String content,
    required final String reference,
    final bool isPremium,
    final String? category,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ScriptureImpl;

  factory _Scripture.fromJson(Map<String, dynamic> json) =
      _$ScriptureImpl.fromJson;

  @override
  String get id;
  @override
  String get book;
  @override
  int get chapter;
  @override
  int get verse;
  @override
  String get content;
  @override
  String get reference;
  @override
  bool get isPremium;
  @override
  String? get category;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Scripture
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScriptureImplCopyWith<_$ScriptureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
