// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Subscription _$SubscriptionFromJson(Map<String, dynamic> json) =>
    _Subscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      platform: $enumDecode(_$SubscriptionPlatformEnumMap, json['platform']),
      storeTransactionId: json['storeTransactionId'] as String?,
      originalTransactionId: json['originalTransactionId'] as String?,
      status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
      startedAt: DateTime.parse(json['startedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      autoRenew: json['autoRenew'] as bool? ?? true,
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SubscriptionToJson(_Subscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'productId': instance.productId,
      'platform': _$SubscriptionPlatformEnumMap[instance.platform]!,
      'storeTransactionId': instance.storeTransactionId,
      'originalTransactionId': instance.originalTransactionId,
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'startedAt': instance.startedAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'autoRenew': instance.autoRenew,
      'cancellationReason': instance.cancellationReason,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$SubscriptionPlatformEnumMap = {
  SubscriptionPlatform.ios: 'ios',
  SubscriptionPlatform.android: 'android',
  SubscriptionPlatform.web: 'web',
};

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.canceled: 'canceled',
  SubscriptionStatus.expired: 'expired',
  SubscriptionStatus.pending: 'pending',
  SubscriptionStatus.gracePeriod: 'grace_period',
};

_SubscriptionProduct _$SubscriptionProductFromJson(Map<String, dynamic> json) =>
    _SubscriptionProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      durationDays: (json['durationDays'] as num?)?.toInt(),
      priceKrw: (json['priceKrw'] as num).toInt(),
      priceUsd: (json['priceUsd'] as num?)?.toDouble(),
      iosProductId: json['iosProductId'] as String?,
      androidProductId: json['androidProductId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SubscriptionProductToJson(
  _SubscriptionProduct instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'durationDays': instance.durationDays,
  'priceKrw': instance.priceKrw,
  'priceUsd': instance.priceUsd,
  'iosProductId': instance.iosProductId,
  'androidProductId': instance.androidProductId,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
};

_PurchaseResult _$PurchaseResultFromJson(Map<String, dynamic> json) =>
    _PurchaseResult(
      productId: json['productId'] as String,
      transactionId: json['transactionId'] as String,
      originalTransactionId: json['originalTransactionId'] as String?,
      platform: $enumDecode(_$SubscriptionPlatformEnumMap, json['platform']),
      receipt: json['receipt'] as String?,
      purchaseToken: json['purchaseToken'] as String?,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      status: $enumDecode(_$IAPPurchaseStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$PurchaseResultToJson(_PurchaseResult instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'transactionId': instance.transactionId,
      'originalTransactionId': instance.originalTransactionId,
      'platform': _$SubscriptionPlatformEnumMap[instance.platform]!,
      'receipt': instance.receipt,
      'purchaseToken': instance.purchaseToken,
      'purchaseDate': instance.purchaseDate.toIso8601String(),
      'status': _$IAPPurchaseStatusEnumMap[instance.status]!,
    };

const _$IAPPurchaseStatusEnumMap = {
  IAPPurchaseStatus.purchased: 'purchased',
  IAPPurchaseStatus.pending: 'pending',
  IAPPurchaseStatus.restored: 'restored',
  IAPPurchaseStatus.canceled: 'canceled',
  IAPPurchaseStatus.error: 'error',
};
