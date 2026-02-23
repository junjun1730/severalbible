// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Subscription {

 String get id; String get userId; String get productId; SubscriptionPlatform get platform; String? get storeTransactionId; String? get originalTransactionId; SubscriptionStatus get status; DateTime get startedAt; DateTime? get expiresAt; bool get autoRenew; String? get cancellationReason; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Subscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionCopyWith<Subscription> get copyWith => _$SubscriptionCopyWithImpl<Subscription>(this as Subscription, _$identity);

  /// Serializes this Subscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Subscription&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.storeTransactionId, storeTransactionId) || other.storeTransactionId == storeTransactionId)&&(identical(other.originalTransactionId, originalTransactionId) || other.originalTransactionId == originalTransactionId)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.autoRenew, autoRenew) || other.autoRenew == autoRenew)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,productId,platform,storeTransactionId,originalTransactionId,status,startedAt,expiresAt,autoRenew,cancellationReason,createdAt,updatedAt);

@override
String toString() {
  return 'Subscription(id: $id, userId: $userId, productId: $productId, platform: $platform, storeTransactionId: $storeTransactionId, originalTransactionId: $originalTransactionId, status: $status, startedAt: $startedAt, expiresAt: $expiresAt, autoRenew: $autoRenew, cancellationReason: $cancellationReason, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SubscriptionCopyWith<$Res>  {
  factory $SubscriptionCopyWith(Subscription value, $Res Function(Subscription) _then) = _$SubscriptionCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String productId, SubscriptionPlatform platform, String? storeTransactionId, String? originalTransactionId, SubscriptionStatus status, DateTime startedAt, DateTime? expiresAt, bool autoRenew, String? cancellationReason, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SubscriptionCopyWithImpl<$Res>
    implements $SubscriptionCopyWith<$Res> {
  _$SubscriptionCopyWithImpl(this._self, this._then);

  final Subscription _self;
  final $Res Function(Subscription) _then;

/// Create a copy of Subscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? productId = null,Object? platform = null,Object? storeTransactionId = freezed,Object? originalTransactionId = freezed,Object? status = null,Object? startedAt = null,Object? expiresAt = freezed,Object? autoRenew = null,Object? cancellationReason = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as SubscriptionPlatform,storeTransactionId: freezed == storeTransactionId ? _self.storeTransactionId : storeTransactionId // ignore: cast_nullable_to_non_nullable
as String?,originalTransactionId: freezed == originalTransactionId ? _self.originalTransactionId : originalTransactionId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubscriptionStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,autoRenew: null == autoRenew ? _self.autoRenew : autoRenew // ignore: cast_nullable_to_non_nullable
as bool,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Subscription].
extension SubscriptionPatterns on Subscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Subscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Subscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Subscription value)  $default,){
final _that = this;
switch (_that) {
case _Subscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Subscription value)?  $default,){
final _that = this;
switch (_that) {
case _Subscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String productId,  SubscriptionPlatform platform,  String? storeTransactionId,  String? originalTransactionId,  SubscriptionStatus status,  DateTime startedAt,  DateTime? expiresAt,  bool autoRenew,  String? cancellationReason,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Subscription() when $default != null:
return $default(_that.id,_that.userId,_that.productId,_that.platform,_that.storeTransactionId,_that.originalTransactionId,_that.status,_that.startedAt,_that.expiresAt,_that.autoRenew,_that.cancellationReason,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String productId,  SubscriptionPlatform platform,  String? storeTransactionId,  String? originalTransactionId,  SubscriptionStatus status,  DateTime startedAt,  DateTime? expiresAt,  bool autoRenew,  String? cancellationReason,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Subscription():
return $default(_that.id,_that.userId,_that.productId,_that.platform,_that.storeTransactionId,_that.originalTransactionId,_that.status,_that.startedAt,_that.expiresAt,_that.autoRenew,_that.cancellationReason,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String productId,  SubscriptionPlatform platform,  String? storeTransactionId,  String? originalTransactionId,  SubscriptionStatus status,  DateTime startedAt,  DateTime? expiresAt,  bool autoRenew,  String? cancellationReason,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Subscription() when $default != null:
return $default(_that.id,_that.userId,_that.productId,_that.platform,_that.storeTransactionId,_that.originalTransactionId,_that.status,_that.startedAt,_that.expiresAt,_that.autoRenew,_that.cancellationReason,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Subscription implements Subscription {
  const _Subscription({required this.id, required this.userId, required this.productId, required this.platform, this.storeTransactionId, this.originalTransactionId, required this.status, required this.startedAt, this.expiresAt, this.autoRenew = true, this.cancellationReason, required this.createdAt, required this.updatedAt});
  factory _Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String productId;
@override final  SubscriptionPlatform platform;
@override final  String? storeTransactionId;
@override final  String? originalTransactionId;
@override final  SubscriptionStatus status;
@override final  DateTime startedAt;
@override final  DateTime? expiresAt;
@override@JsonKey() final  bool autoRenew;
@override final  String? cancellationReason;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Subscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionCopyWith<_Subscription> get copyWith => __$SubscriptionCopyWithImpl<_Subscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Subscription&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.storeTransactionId, storeTransactionId) || other.storeTransactionId == storeTransactionId)&&(identical(other.originalTransactionId, originalTransactionId) || other.originalTransactionId == originalTransactionId)&&(identical(other.status, status) || other.status == status)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.autoRenew, autoRenew) || other.autoRenew == autoRenew)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,productId,platform,storeTransactionId,originalTransactionId,status,startedAt,expiresAt,autoRenew,cancellationReason,createdAt,updatedAt);

@override
String toString() {
  return 'Subscription(id: $id, userId: $userId, productId: $productId, platform: $platform, storeTransactionId: $storeTransactionId, originalTransactionId: $originalTransactionId, status: $status, startedAt: $startedAt, expiresAt: $expiresAt, autoRenew: $autoRenew, cancellationReason: $cancellationReason, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionCopyWith<$Res> implements $SubscriptionCopyWith<$Res> {
  factory _$SubscriptionCopyWith(_Subscription value, $Res Function(_Subscription) _then) = __$SubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String productId, SubscriptionPlatform platform, String? storeTransactionId, String? originalTransactionId, SubscriptionStatus status, DateTime startedAt, DateTime? expiresAt, bool autoRenew, String? cancellationReason, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SubscriptionCopyWithImpl<$Res>
    implements _$SubscriptionCopyWith<$Res> {
  __$SubscriptionCopyWithImpl(this._self, this._then);

  final _Subscription _self;
  final $Res Function(_Subscription) _then;

/// Create a copy of Subscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? productId = null,Object? platform = null,Object? storeTransactionId = freezed,Object? originalTransactionId = freezed,Object? status = null,Object? startedAt = null,Object? expiresAt = freezed,Object? autoRenew = null,Object? cancellationReason = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Subscription(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as SubscriptionPlatform,storeTransactionId: freezed == storeTransactionId ? _self.storeTransactionId : storeTransactionId // ignore: cast_nullable_to_non_nullable
as String?,originalTransactionId: freezed == originalTransactionId ? _self.originalTransactionId : originalTransactionId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SubscriptionStatus,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,autoRenew: null == autoRenew ? _self.autoRenew : autoRenew // ignore: cast_nullable_to_non_nullable
as bool,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$SubscriptionProduct {

 String get id; String get name; String? get description; int? get durationDays; int get priceKrw; double? get priceUsd; String? get iosProductId; String? get androidProductId; bool get isActive; DateTime get createdAt;
/// Create a copy of SubscriptionProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionProductCopyWith<SubscriptionProduct> get copyWith => _$SubscriptionProductCopyWithImpl<SubscriptionProduct>(this as SubscriptionProduct, _$identity);

  /// Serializes this SubscriptionProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.priceKrw, priceKrw) || other.priceKrw == priceKrw)&&(identical(other.priceUsd, priceUsd) || other.priceUsd == priceUsd)&&(identical(other.iosProductId, iosProductId) || other.iosProductId == iosProductId)&&(identical(other.androidProductId, androidProductId) || other.androidProductId == androidProductId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,durationDays,priceKrw,priceUsd,iosProductId,androidProductId,isActive,createdAt);

@override
String toString() {
  return 'SubscriptionProduct(id: $id, name: $name, description: $description, durationDays: $durationDays, priceKrw: $priceKrw, priceUsd: $priceUsd, iosProductId: $iosProductId, androidProductId: $androidProductId, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SubscriptionProductCopyWith<$Res>  {
  factory $SubscriptionProductCopyWith(SubscriptionProduct value, $Res Function(SubscriptionProduct) _then) = _$SubscriptionProductCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, int? durationDays, int priceKrw, double? priceUsd, String? iosProductId, String? androidProductId, bool isActive, DateTime createdAt
});




}
/// @nodoc
class _$SubscriptionProductCopyWithImpl<$Res>
    implements $SubscriptionProductCopyWith<$Res> {
  _$SubscriptionProductCopyWithImpl(this._self, this._then);

  final SubscriptionProduct _self;
  final $Res Function(SubscriptionProduct) _then;

/// Create a copy of SubscriptionProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? durationDays = freezed,Object? priceKrw = null,Object? priceUsd = freezed,Object? iosProductId = freezed,Object? androidProductId = freezed,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationDays: freezed == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int?,priceKrw: null == priceKrw ? _self.priceKrw : priceKrw // ignore: cast_nullable_to_non_nullable
as int,priceUsd: freezed == priceUsd ? _self.priceUsd : priceUsd // ignore: cast_nullable_to_non_nullable
as double?,iosProductId: freezed == iosProductId ? _self.iosProductId : iosProductId // ignore: cast_nullable_to_non_nullable
as String?,androidProductId: freezed == androidProductId ? _self.androidProductId : androidProductId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionProduct].
extension SubscriptionProductPatterns on SubscriptionProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionProduct value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionProduct value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  int? durationDays,  int priceKrw,  double? priceUsd,  String? iosProductId,  String? androidProductId,  bool isActive,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionProduct() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.durationDays,_that.priceKrw,_that.priceUsd,_that.iosProductId,_that.androidProductId,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  int? durationDays,  int priceKrw,  double? priceUsd,  String? iosProductId,  String? androidProductId,  bool isActive,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionProduct():
return $default(_that.id,_that.name,_that.description,_that.durationDays,_that.priceKrw,_that.priceUsd,_that.iosProductId,_that.androidProductId,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  int? durationDays,  int priceKrw,  double? priceUsd,  String? iosProductId,  String? androidProductId,  bool isActive,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionProduct() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.durationDays,_that.priceKrw,_that.priceUsd,_that.iosProductId,_that.androidProductId,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubscriptionProduct implements SubscriptionProduct {
  const _SubscriptionProduct({required this.id, required this.name, this.description, this.durationDays, required this.priceKrw, this.priceUsd, this.iosProductId, this.androidProductId, this.isActive = true, required this.createdAt});
  factory _SubscriptionProduct.fromJson(Map<String, dynamic> json) => _$SubscriptionProductFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  int? durationDays;
@override final  int priceKrw;
@override final  double? priceUsd;
@override final  String? iosProductId;
@override final  String? androidProductId;
@override@JsonKey() final  bool isActive;
@override final  DateTime createdAt;

/// Create a copy of SubscriptionProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionProductCopyWith<_SubscriptionProduct> get copyWith => __$SubscriptionProductCopyWithImpl<_SubscriptionProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubscriptionProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.priceKrw, priceKrw) || other.priceKrw == priceKrw)&&(identical(other.priceUsd, priceUsd) || other.priceUsd == priceUsd)&&(identical(other.iosProductId, iosProductId) || other.iosProductId == iosProductId)&&(identical(other.androidProductId, androidProductId) || other.androidProductId == androidProductId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,durationDays,priceKrw,priceUsd,iosProductId,androidProductId,isActive,createdAt);

@override
String toString() {
  return 'SubscriptionProduct(id: $id, name: $name, description: $description, durationDays: $durationDays, priceKrw: $priceKrw, priceUsd: $priceUsd, iosProductId: $iosProductId, androidProductId: $androidProductId, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionProductCopyWith<$Res> implements $SubscriptionProductCopyWith<$Res> {
  factory _$SubscriptionProductCopyWith(_SubscriptionProduct value, $Res Function(_SubscriptionProduct) _then) = __$SubscriptionProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, int? durationDays, int priceKrw, double? priceUsd, String? iosProductId, String? androidProductId, bool isActive, DateTime createdAt
});




}
/// @nodoc
class __$SubscriptionProductCopyWithImpl<$Res>
    implements _$SubscriptionProductCopyWith<$Res> {
  __$SubscriptionProductCopyWithImpl(this._self, this._then);

  final _SubscriptionProduct _self;
  final $Res Function(_SubscriptionProduct) _then;

/// Create a copy of SubscriptionProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? durationDays = freezed,Object? priceKrw = null,Object? priceUsd = freezed,Object? iosProductId = freezed,Object? androidProductId = freezed,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_SubscriptionProduct(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,durationDays: freezed == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int?,priceKrw: null == priceKrw ? _self.priceKrw : priceKrw // ignore: cast_nullable_to_non_nullable
as int,priceUsd: freezed == priceUsd ? _self.priceUsd : priceUsd // ignore: cast_nullable_to_non_nullable
as double?,iosProductId: freezed == iosProductId ? _self.iosProductId : iosProductId // ignore: cast_nullable_to_non_nullable
as String?,androidProductId: freezed == androidProductId ? _self.androidProductId : androidProductId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$PurchaseResult {

 String get productId; String get transactionId; String? get originalTransactionId; SubscriptionPlatform get platform; String? get receipt;// iOS
 String? get purchaseToken;// Android
 DateTime get purchaseDate; IAPPurchaseStatus get status;
/// Create a copy of PurchaseResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseResultCopyWith<PurchaseResult> get copyWith => _$PurchaseResultCopyWithImpl<PurchaseResult>(this as PurchaseResult, _$identity);

  /// Serializes this PurchaseResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseResult&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.originalTransactionId, originalTransactionId) || other.originalTransactionId == originalTransactionId)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.receipt, receipt) || other.receipt == receipt)&&(identical(other.purchaseToken, purchaseToken) || other.purchaseToken == purchaseToken)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,transactionId,originalTransactionId,platform,receipt,purchaseToken,purchaseDate,status);

@override
String toString() {
  return 'PurchaseResult(productId: $productId, transactionId: $transactionId, originalTransactionId: $originalTransactionId, platform: $platform, receipt: $receipt, purchaseToken: $purchaseToken, purchaseDate: $purchaseDate, status: $status)';
}


}

/// @nodoc
abstract mixin class $PurchaseResultCopyWith<$Res>  {
  factory $PurchaseResultCopyWith(PurchaseResult value, $Res Function(PurchaseResult) _then) = _$PurchaseResultCopyWithImpl;
@useResult
$Res call({
 String productId, String transactionId, String? originalTransactionId, SubscriptionPlatform platform, String? receipt, String? purchaseToken, DateTime purchaseDate, IAPPurchaseStatus status
});




}
/// @nodoc
class _$PurchaseResultCopyWithImpl<$Res>
    implements $PurchaseResultCopyWith<$Res> {
  _$PurchaseResultCopyWithImpl(this._self, this._then);

  final PurchaseResult _self;
  final $Res Function(PurchaseResult) _then;

/// Create a copy of PurchaseResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? transactionId = null,Object? originalTransactionId = freezed,Object? platform = null,Object? receipt = freezed,Object? purchaseToken = freezed,Object? purchaseDate = null,Object? status = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,originalTransactionId: freezed == originalTransactionId ? _self.originalTransactionId : originalTransactionId // ignore: cast_nullable_to_non_nullable
as String?,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as SubscriptionPlatform,receipt: freezed == receipt ? _self.receipt : receipt // ignore: cast_nullable_to_non_nullable
as String?,purchaseToken: freezed == purchaseToken ? _self.purchaseToken : purchaseToken // ignore: cast_nullable_to_non_nullable
as String?,purchaseDate: null == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IAPPurchaseStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseResult].
extension PurchaseResultPatterns on PurchaseResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseResult value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseResult value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productId,  String transactionId,  String? originalTransactionId,  SubscriptionPlatform platform,  String? receipt,  String? purchaseToken,  DateTime purchaseDate,  IAPPurchaseStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseResult() when $default != null:
return $default(_that.productId,_that.transactionId,_that.originalTransactionId,_that.platform,_that.receipt,_that.purchaseToken,_that.purchaseDate,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productId,  String transactionId,  String? originalTransactionId,  SubscriptionPlatform platform,  String? receipt,  String? purchaseToken,  DateTime purchaseDate,  IAPPurchaseStatus status)  $default,) {final _that = this;
switch (_that) {
case _PurchaseResult():
return $default(_that.productId,_that.transactionId,_that.originalTransactionId,_that.platform,_that.receipt,_that.purchaseToken,_that.purchaseDate,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productId,  String transactionId,  String? originalTransactionId,  SubscriptionPlatform platform,  String? receipt,  String? purchaseToken,  DateTime purchaseDate,  IAPPurchaseStatus status)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseResult() when $default != null:
return $default(_that.productId,_that.transactionId,_that.originalTransactionId,_that.platform,_that.receipt,_that.purchaseToken,_that.purchaseDate,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PurchaseResult implements PurchaseResult {
  const _PurchaseResult({required this.productId, required this.transactionId, this.originalTransactionId, required this.platform, this.receipt, this.purchaseToken, required this.purchaseDate, required this.status});
  factory _PurchaseResult.fromJson(Map<String, dynamic> json) => _$PurchaseResultFromJson(json);

@override final  String productId;
@override final  String transactionId;
@override final  String? originalTransactionId;
@override final  SubscriptionPlatform platform;
@override final  String? receipt;
// iOS
@override final  String? purchaseToken;
// Android
@override final  DateTime purchaseDate;
@override final  IAPPurchaseStatus status;

/// Create a copy of PurchaseResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseResultCopyWith<_PurchaseResult> get copyWith => __$PurchaseResultCopyWithImpl<_PurchaseResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseResult&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.originalTransactionId, originalTransactionId) || other.originalTransactionId == originalTransactionId)&&(identical(other.platform, platform) || other.platform == platform)&&(identical(other.receipt, receipt) || other.receipt == receipt)&&(identical(other.purchaseToken, purchaseToken) || other.purchaseToken == purchaseToken)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,productId,transactionId,originalTransactionId,platform,receipt,purchaseToken,purchaseDate,status);

@override
String toString() {
  return 'PurchaseResult(productId: $productId, transactionId: $transactionId, originalTransactionId: $originalTransactionId, platform: $platform, receipt: $receipt, purchaseToken: $purchaseToken, purchaseDate: $purchaseDate, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PurchaseResultCopyWith<$Res> implements $PurchaseResultCopyWith<$Res> {
  factory _$PurchaseResultCopyWith(_PurchaseResult value, $Res Function(_PurchaseResult) _then) = __$PurchaseResultCopyWithImpl;
@override @useResult
$Res call({
 String productId, String transactionId, String? originalTransactionId, SubscriptionPlatform platform, String? receipt, String? purchaseToken, DateTime purchaseDate, IAPPurchaseStatus status
});




}
/// @nodoc
class __$PurchaseResultCopyWithImpl<$Res>
    implements _$PurchaseResultCopyWith<$Res> {
  __$PurchaseResultCopyWithImpl(this._self, this._then);

  final _PurchaseResult _self;
  final $Res Function(_PurchaseResult) _then;

/// Create a copy of PurchaseResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? transactionId = null,Object? originalTransactionId = freezed,Object? platform = null,Object? receipt = freezed,Object? purchaseToken = freezed,Object? purchaseDate = null,Object? status = null,}) {
  return _then(_PurchaseResult(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,transactionId: null == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String,originalTransactionId: freezed == originalTransactionId ? _self.originalTransactionId : originalTransactionId // ignore: cast_nullable_to_non_nullable
as String?,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as SubscriptionPlatform,receipt: freezed == receipt ? _self.receipt : receipt // ignore: cast_nullable_to_non_nullable
as String?,purchaseToken: freezed == purchaseToken ? _self.purchaseToken : purchaseToken // ignore: cast_nullable_to_non_nullable
as String?,purchaseDate: null == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IAPPurchaseStatus,
  ));
}


}

// dart format on
