// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Subscription _$SubscriptionFromJson(Map<String, dynamic> json) {
  return _Subscription.fromJson(json);
}

/// @nodoc
mixin _$Subscription {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError;
  SubscriptionPlatform get platform => throw _privateConstructorUsedError;
  String? get storeTransactionId => throw _privateConstructorUsedError;
  String? get originalTransactionId => throw _privateConstructorUsedError;
  SubscriptionStatus get status => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  bool get autoRenew => throw _privateConstructorUsedError;
  String? get cancellationReason => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Subscription to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionCopyWith<Subscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionCopyWith<$Res> {
  factory $SubscriptionCopyWith(
    Subscription value,
    $Res Function(Subscription) then,
  ) = _$SubscriptionCopyWithImpl<$Res, Subscription>;
  @useResult
  $Res call({
    String id,
    String userId,
    String productId,
    SubscriptionPlatform platform,
    String? storeTransactionId,
    String? originalTransactionId,
    SubscriptionStatus status,
    DateTime startedAt,
    DateTime? expiresAt,
    bool autoRenew,
    String? cancellationReason,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$SubscriptionCopyWithImpl<$Res, $Val extends Subscription>
    implements $SubscriptionCopyWith<$Res> {
  _$SubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? productId = null,
    Object? platform = null,
    Object? storeTransactionId = freezed,
    Object? originalTransactionId = freezed,
    Object? status = null,
    Object? startedAt = null,
    Object? expiresAt = freezed,
    Object? autoRenew = null,
    Object? cancellationReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            platform: null == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                      as SubscriptionPlatform,
            storeTransactionId: freezed == storeTransactionId
                ? _value.storeTransactionId
                : storeTransactionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            originalTransactionId: freezed == originalTransactionId
                ? _value.originalTransactionId
                : originalTransactionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SubscriptionStatus,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            autoRenew: null == autoRenew
                ? _value.autoRenew
                : autoRenew // ignore: cast_nullable_to_non_nullable
                      as bool,
            cancellationReason: freezed == cancellationReason
                ? _value.cancellationReason
                : cancellationReason // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SubscriptionImplCopyWith<$Res>
    implements $SubscriptionCopyWith<$Res> {
  factory _$$SubscriptionImplCopyWith(
    _$SubscriptionImpl value,
    $Res Function(_$SubscriptionImpl) then,
  ) = __$$SubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String productId,
    SubscriptionPlatform platform,
    String? storeTransactionId,
    String? originalTransactionId,
    SubscriptionStatus status,
    DateTime startedAt,
    DateTime? expiresAt,
    bool autoRenew,
    String? cancellationReason,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$SubscriptionImplCopyWithImpl<$Res>
    extends _$SubscriptionCopyWithImpl<$Res, _$SubscriptionImpl>
    implements _$$SubscriptionImplCopyWith<$Res> {
  __$$SubscriptionImplCopyWithImpl(
    _$SubscriptionImpl _value,
    $Res Function(_$SubscriptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? productId = null,
    Object? platform = null,
    Object? storeTransactionId = freezed,
    Object? originalTransactionId = freezed,
    Object? status = null,
    Object? startedAt = null,
    Object? expiresAt = freezed,
    Object? autoRenew = null,
    Object? cancellationReason = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SubscriptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        platform: null == platform
            ? _value.platform
            : platform // ignore: cast_nullable_to_non_nullable
                  as SubscriptionPlatform,
        storeTransactionId: freezed == storeTransactionId
            ? _value.storeTransactionId
            : storeTransactionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        originalTransactionId: freezed == originalTransactionId
            ? _value.originalTransactionId
            : originalTransactionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SubscriptionStatus,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        autoRenew: null == autoRenew
            ? _value.autoRenew
            : autoRenew // ignore: cast_nullable_to_non_nullable
                  as bool,
        cancellationReason: freezed == cancellationReason
            ? _value.cancellationReason
            : cancellationReason // ignore: cast_nullable_to_non_nullable
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
class _$SubscriptionImpl implements _Subscription {
  const _$SubscriptionImpl({
    required this.id,
    required this.userId,
    required this.productId,
    required this.platform,
    this.storeTransactionId,
    this.originalTransactionId,
    required this.status,
    required this.startedAt,
    this.expiresAt,
    this.autoRenew = true,
    this.cancellationReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$SubscriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String productId;
  @override
  final SubscriptionPlatform platform;
  @override
  final String? storeTransactionId;
  @override
  final String? originalTransactionId;
  @override
  final SubscriptionStatus status;
  @override
  final DateTime startedAt;
  @override
  final DateTime? expiresAt;
  @override
  @JsonKey()
  final bool autoRenew;
  @override
  final String? cancellationReason;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Subscription(id: $id, userId: $userId, productId: $productId, platform: $platform, storeTransactionId: $storeTransactionId, originalTransactionId: $originalTransactionId, status: $status, startedAt: $startedAt, expiresAt: $expiresAt, autoRenew: $autoRenew, cancellationReason: $cancellationReason, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.storeTransactionId, storeTransactionId) ||
                other.storeTransactionId == storeTransactionId) &&
            (identical(other.originalTransactionId, originalTransactionId) ||
                other.originalTransactionId == originalTransactionId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.autoRenew, autoRenew) ||
                other.autoRenew == autoRenew) &&
            (identical(other.cancellationReason, cancellationReason) ||
                other.cancellationReason == cancellationReason) &&
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
    userId,
    productId,
    platform,
    storeTransactionId,
    originalTransactionId,
    status,
    startedAt,
    expiresAt,
    autoRenew,
    cancellationReason,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      __$$SubscriptionImplCopyWithImpl<_$SubscriptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionImplToJson(this);
  }
}

abstract class _Subscription implements Subscription {
  const factory _Subscription({
    required final String id,
    required final String userId,
    required final String productId,
    required final SubscriptionPlatform platform,
    final String? storeTransactionId,
    final String? originalTransactionId,
    required final SubscriptionStatus status,
    required final DateTime startedAt,
    final DateTime? expiresAt,
    final bool autoRenew,
    final String? cancellationReason,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$SubscriptionImpl;

  factory _Subscription.fromJson(Map<String, dynamic> json) =
      _$SubscriptionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get productId;
  @override
  SubscriptionPlatform get platform;
  @override
  String? get storeTransactionId;
  @override
  String? get originalTransactionId;
  @override
  SubscriptionStatus get status;
  @override
  DateTime get startedAt;
  @override
  DateTime? get expiresAt;
  @override
  bool get autoRenew;
  @override
  String? get cancellationReason;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Subscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionImplCopyWith<_$SubscriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubscriptionProduct _$SubscriptionProductFromJson(Map<String, dynamic> json) {
  return _SubscriptionProduct.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionProduct {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int? get durationDays => throw _privateConstructorUsedError;
  int get priceKrw => throw _privateConstructorUsedError;
  double? get priceUsd => throw _privateConstructorUsedError;
  String? get iosProductId => throw _privateConstructorUsedError;
  String? get androidProductId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionProduct to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionProductCopyWith<SubscriptionProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionProductCopyWith<$Res> {
  factory $SubscriptionProductCopyWith(
    SubscriptionProduct value,
    $Res Function(SubscriptionProduct) then,
  ) = _$SubscriptionProductCopyWithImpl<$Res, SubscriptionProduct>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    int? durationDays,
    int priceKrw,
    double? priceUsd,
    String? iosProductId,
    String? androidProductId,
    bool isActive,
    DateTime createdAt,
  });
}

/// @nodoc
class _$SubscriptionProductCopyWithImpl<$Res, $Val extends SubscriptionProduct>
    implements $SubscriptionProductCopyWith<$Res> {
  _$SubscriptionProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? durationDays = freezed,
    Object? priceKrw = null,
    Object? priceUsd = freezed,
    Object? iosProductId = freezed,
    Object? androidProductId = freezed,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            durationDays: freezed == durationDays
                ? _value.durationDays
                : durationDays // ignore: cast_nullable_to_non_nullable
                      as int?,
            priceKrw: null == priceKrw
                ? _value.priceKrw
                : priceKrw // ignore: cast_nullable_to_non_nullable
                      as int,
            priceUsd: freezed == priceUsd
                ? _value.priceUsd
                : priceUsd // ignore: cast_nullable_to_non_nullable
                      as double?,
            iosProductId: freezed == iosProductId
                ? _value.iosProductId
                : iosProductId // ignore: cast_nullable_to_non_nullable
                      as String?,
            androidProductId: freezed == androidProductId
                ? _value.androidProductId
                : androidProductId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubscriptionProductImplCopyWith<$Res>
    implements $SubscriptionProductCopyWith<$Res> {
  factory _$$SubscriptionProductImplCopyWith(
    _$SubscriptionProductImpl value,
    $Res Function(_$SubscriptionProductImpl) then,
  ) = __$$SubscriptionProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    int? durationDays,
    int priceKrw,
    double? priceUsd,
    String? iosProductId,
    String? androidProductId,
    bool isActive,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$SubscriptionProductImplCopyWithImpl<$Res>
    extends _$SubscriptionProductCopyWithImpl<$Res, _$SubscriptionProductImpl>
    implements _$$SubscriptionProductImplCopyWith<$Res> {
  __$$SubscriptionProductImplCopyWithImpl(
    _$SubscriptionProductImpl _value,
    $Res Function(_$SubscriptionProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? durationDays = freezed,
    Object? priceKrw = null,
    Object? priceUsd = freezed,
    Object? iosProductId = freezed,
    Object? androidProductId = freezed,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$SubscriptionProductImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        durationDays: freezed == durationDays
            ? _value.durationDays
            : durationDays // ignore: cast_nullable_to_non_nullable
                  as int?,
        priceKrw: null == priceKrw
            ? _value.priceKrw
            : priceKrw // ignore: cast_nullable_to_non_nullable
                  as int,
        priceUsd: freezed == priceUsd
            ? _value.priceUsd
            : priceUsd // ignore: cast_nullable_to_non_nullable
                  as double?,
        iosProductId: freezed == iosProductId
            ? _value.iosProductId
            : iosProductId // ignore: cast_nullable_to_non_nullable
                  as String?,
        androidProductId: freezed == androidProductId
            ? _value.androidProductId
            : androidProductId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionProductImpl implements _SubscriptionProduct {
  const _$SubscriptionProductImpl({
    required this.id,
    required this.name,
    this.description,
    this.durationDays,
    required this.priceKrw,
    this.priceUsd,
    this.iosProductId,
    this.androidProductId,
    this.isActive = true,
    required this.createdAt,
  });

  factory _$SubscriptionProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionProductImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final int? durationDays;
  @override
  final int priceKrw;
  @override
  final double? priceUsd;
  @override
  final String? iosProductId;
  @override
  final String? androidProductId;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SubscriptionProduct(id: $id, name: $name, description: $description, durationDays: $durationDays, priceKrw: $priceKrw, priceUsd: $priceUsd, iosProductId: $iosProductId, androidProductId: $androidProductId, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.durationDays, durationDays) ||
                other.durationDays == durationDays) &&
            (identical(other.priceKrw, priceKrw) ||
                other.priceKrw == priceKrw) &&
            (identical(other.priceUsd, priceUsd) ||
                other.priceUsd == priceUsd) &&
            (identical(other.iosProductId, iosProductId) ||
                other.iosProductId == iosProductId) &&
            (identical(other.androidProductId, androidProductId) ||
                other.androidProductId == androidProductId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    durationDays,
    priceKrw,
    priceUsd,
    iosProductId,
    androidProductId,
    isActive,
    createdAt,
  );

  /// Create a copy of SubscriptionProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionProductImplCopyWith<_$SubscriptionProductImpl> get copyWith =>
      __$$SubscriptionProductImplCopyWithImpl<_$SubscriptionProductImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionProductImplToJson(this);
  }
}

abstract class _SubscriptionProduct implements SubscriptionProduct {
  const factory _SubscriptionProduct({
    required final String id,
    required final String name,
    final String? description,
    final int? durationDays,
    required final int priceKrw,
    final double? priceUsd,
    final String? iosProductId,
    final String? androidProductId,
    final bool isActive,
    required final DateTime createdAt,
  }) = _$SubscriptionProductImpl;

  factory _SubscriptionProduct.fromJson(Map<String, dynamic> json) =
      _$SubscriptionProductImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  int? get durationDays;
  @override
  int get priceKrw;
  @override
  double? get priceUsd;
  @override
  String? get iosProductId;
  @override
  String? get androidProductId;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;

  /// Create a copy of SubscriptionProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionProductImplCopyWith<_$SubscriptionProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PurchaseResult _$PurchaseResultFromJson(Map<String, dynamic> json) {
  return _PurchaseResult.fromJson(json);
}

/// @nodoc
mixin _$PurchaseResult {
  String get productId => throw _privateConstructorUsedError;
  String get transactionId => throw _privateConstructorUsedError;
  String? get originalTransactionId => throw _privateConstructorUsedError;
  SubscriptionPlatform get platform => throw _privateConstructorUsedError;
  String? get receipt => throw _privateConstructorUsedError; // iOS
  String? get purchaseToken => throw _privateConstructorUsedError; // Android
  DateTime get purchaseDate => throw _privateConstructorUsedError;
  IAPPurchaseStatus get status => throw _privateConstructorUsedError;

  /// Serializes this PurchaseResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurchaseResultCopyWith<PurchaseResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseResultCopyWith<$Res> {
  factory $PurchaseResultCopyWith(
    PurchaseResult value,
    $Res Function(PurchaseResult) then,
  ) = _$PurchaseResultCopyWithImpl<$Res, PurchaseResult>;
  @useResult
  $Res call({
    String productId,
    String transactionId,
    String? originalTransactionId,
    SubscriptionPlatform platform,
    String? receipt,
    String? purchaseToken,
    DateTime purchaseDate,
    IAPPurchaseStatus status,
  });
}

/// @nodoc
class _$PurchaseResultCopyWithImpl<$Res, $Val extends PurchaseResult>
    implements $PurchaseResultCopyWith<$Res> {
  _$PurchaseResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? transactionId = null,
    Object? originalTransactionId = freezed,
    Object? platform = null,
    Object? receipt = freezed,
    Object? purchaseToken = freezed,
    Object? purchaseDate = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            productId: null == productId
                ? _value.productId
                : productId // ignore: cast_nullable_to_non_nullable
                      as String,
            transactionId: null == transactionId
                ? _value.transactionId
                : transactionId // ignore: cast_nullable_to_non_nullable
                      as String,
            originalTransactionId: freezed == originalTransactionId
                ? _value.originalTransactionId
                : originalTransactionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            platform: null == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                      as SubscriptionPlatform,
            receipt: freezed == receipt
                ? _value.receipt
                : receipt // ignore: cast_nullable_to_non_nullable
                      as String?,
            purchaseToken: freezed == purchaseToken
                ? _value.purchaseToken
                : purchaseToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            purchaseDate: null == purchaseDate
                ? _value.purchaseDate
                : purchaseDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as IAPPurchaseStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PurchaseResultImplCopyWith<$Res>
    implements $PurchaseResultCopyWith<$Res> {
  factory _$$PurchaseResultImplCopyWith(
    _$PurchaseResultImpl value,
    $Res Function(_$PurchaseResultImpl) then,
  ) = __$$PurchaseResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String productId,
    String transactionId,
    String? originalTransactionId,
    SubscriptionPlatform platform,
    String? receipt,
    String? purchaseToken,
    DateTime purchaseDate,
    IAPPurchaseStatus status,
  });
}

/// @nodoc
class __$$PurchaseResultImplCopyWithImpl<$Res>
    extends _$PurchaseResultCopyWithImpl<$Res, _$PurchaseResultImpl>
    implements _$$PurchaseResultImplCopyWith<$Res> {
  __$$PurchaseResultImplCopyWithImpl(
    _$PurchaseResultImpl _value,
    $Res Function(_$PurchaseResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? transactionId = null,
    Object? originalTransactionId = freezed,
    Object? platform = null,
    Object? receipt = freezed,
    Object? purchaseToken = freezed,
    Object? purchaseDate = null,
    Object? status = null,
  }) {
    return _then(
      _$PurchaseResultImpl(
        productId: null == productId
            ? _value.productId
            : productId // ignore: cast_nullable_to_non_nullable
                  as String,
        transactionId: null == transactionId
            ? _value.transactionId
            : transactionId // ignore: cast_nullable_to_non_nullable
                  as String,
        originalTransactionId: freezed == originalTransactionId
            ? _value.originalTransactionId
            : originalTransactionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        platform: null == platform
            ? _value.platform
            : platform // ignore: cast_nullable_to_non_nullable
                  as SubscriptionPlatform,
        receipt: freezed == receipt
            ? _value.receipt
            : receipt // ignore: cast_nullable_to_non_nullable
                  as String?,
        purchaseToken: freezed == purchaseToken
            ? _value.purchaseToken
            : purchaseToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        purchaseDate: null == purchaseDate
            ? _value.purchaseDate
            : purchaseDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as IAPPurchaseStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PurchaseResultImpl implements _PurchaseResult {
  const _$PurchaseResultImpl({
    required this.productId,
    required this.transactionId,
    this.originalTransactionId,
    required this.platform,
    this.receipt,
    this.purchaseToken,
    required this.purchaseDate,
    required this.status,
  });

  factory _$PurchaseResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseResultImplFromJson(json);

  @override
  final String productId;
  @override
  final String transactionId;
  @override
  final String? originalTransactionId;
  @override
  final SubscriptionPlatform platform;
  @override
  final String? receipt;
  // iOS
  @override
  final String? purchaseToken;
  // Android
  @override
  final DateTime purchaseDate;
  @override
  final IAPPurchaseStatus status;

  @override
  String toString() {
    return 'PurchaseResult(productId: $productId, transactionId: $transactionId, originalTransactionId: $originalTransactionId, platform: $platform, receipt: $receipt, purchaseToken: $purchaseToken, purchaseDate: $purchaseDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseResultImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.originalTransactionId, originalTransactionId) ||
                other.originalTransactionId == originalTransactionId) &&
            (identical(other.platform, platform) ||
                other.platform == platform) &&
            (identical(other.receipt, receipt) || other.receipt == receipt) &&
            (identical(other.purchaseToken, purchaseToken) ||
                other.purchaseToken == purchaseToken) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    productId,
    transactionId,
    originalTransactionId,
    platform,
    receipt,
    purchaseToken,
    purchaseDate,
    status,
  );

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseResultImplCopyWith<_$PurchaseResultImpl> get copyWith =>
      __$$PurchaseResultImplCopyWithImpl<_$PurchaseResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseResultImplToJson(this);
  }
}

abstract class _PurchaseResult implements PurchaseResult {
  const factory _PurchaseResult({
    required final String productId,
    required final String transactionId,
    final String? originalTransactionId,
    required final SubscriptionPlatform platform,
    final String? receipt,
    final String? purchaseToken,
    required final DateTime purchaseDate,
    required final IAPPurchaseStatus status,
  }) = _$PurchaseResultImpl;

  factory _PurchaseResult.fromJson(Map<String, dynamic> json) =
      _$PurchaseResultImpl.fromJson;

  @override
  String get productId;
  @override
  String get transactionId;
  @override
  String? get originalTransactionId;
  @override
  SubscriptionPlatform get platform;
  @override
  String? get receipt; // iOS
  @override
  String? get purchaseToken; // Android
  @override
  DateTime get purchaseDate;
  @override
  IAPPurchaseStatus get status;

  /// Create a copy of PurchaseResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurchaseResultImplCopyWith<_$PurchaseResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
