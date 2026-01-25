import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

/// Enum representing subscription status
enum SubscriptionStatus {
  active,
  canceled,
  expired,
  pending,
  @JsonValue('grace_period')
  gracePeriod,
}

/// Enum representing platform for subscription
enum SubscriptionPlatform {
  ios,
  android,
  web,
}

/// Subscription entity representing a user's subscription status
/// Immutable data class using freezed for functional programming
@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String userId,
    required String productId,
    required SubscriptionPlatform platform,
    String? storeTransactionId,
    String? originalTransactionId,
    required SubscriptionStatus status,
    required DateTime startedAt,
    DateTime? expiresAt,
    @Default(true) bool autoRenew,
    String? cancellationReason,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(_convertSubscriptionSnakeToCamel(json));
}

/// SubscriptionProduct entity representing available subscription products
/// Immutable data class using freezed for functional programming
@freezed
class SubscriptionProduct with _$SubscriptionProduct {
  const factory SubscriptionProduct({
    required String id,
    required String name,
    String? description,
    int? durationDays,
    required int priceKrw,
    double? priceUsd,
    String? iosProductId,
    String? androidProductId,
    @Default(true) bool isActive,
    required DateTime createdAt,
  }) = _SubscriptionProduct;

  factory SubscriptionProduct.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionProductFromJson(_convertProductSnakeToCamel(json));
}

/// PurchaseResult representing the result of an IAP purchase
@freezed
class PurchaseResult with _$PurchaseResult {
  const factory PurchaseResult({
    required String productId,
    required String transactionId,
    String? originalTransactionId,
    required SubscriptionPlatform platform,
    String? receipt, // iOS
    String? purchaseToken, // Android
    required DateTime purchaseDate,
    required IAPPurchaseStatus status,
  }) = _PurchaseResult;

  factory PurchaseResult.fromJson(Map<String, dynamic> json) =>
      _$PurchaseResultFromJson(json);
}

/// Enum representing IAP purchase status (to avoid conflict with in_app_purchase)
enum IAPPurchaseStatus {
  purchased,
  pending,
  restored,
  canceled,
  error,
}

/// Converts snake_case keys to camelCase for Subscription entity
Map<String, dynamic> _convertSubscriptionSnakeToCamel(Map<String, dynamic> json) {
  final now = DateTime.now().toIso8601String();
  return {
    'id': json['id'] ?? '',
    'userId': json['user_id'] ?? '',
    'productId': json['product_id'] ?? '',
    'platform': json['platform'] ?? 'ios',
    'storeTransactionId': json['store_transaction_id'],
    'originalTransactionId': json['original_transaction_id'],
    'status': _parseSubscriptionStatus(json['subscription_status'] as String?),
    'startedAt': json['started_at'] ?? now,
    'expiresAt': json['expires_at'],
    'autoRenew': json['auto_renew'] ?? true,
    'cancellationReason': json['cancellation_reason'],
    'createdAt': json['created_at'] ?? now,
    'updatedAt': json['updated_at'] ?? now,
  };
}

/// Converts snake_case keys to camelCase for SubscriptionProduct entity
Map<String, dynamic> _convertProductSnakeToCamel(Map<String, dynamic> json) {
  return {
    'id': json['id'] ?? '',
    'name': json['name'] ?? '',
    'description': json['description'],
    'durationDays': json['duration_days'],
    'priceKrw': json['price_krw'] ?? 0,
    'priceUsd': json['price_usd'] != null
        ? (json['price_usd'] is int
            ? (json['price_usd'] as int).toDouble()
            : json['price_usd'])
        : null,
    'iosProductId': json['ios_product_id'],
    'androidProductId': json['android_product_id'],
    'isActive': json['is_active'] ?? true,
    'createdAt': json['created_at'] ?? DateTime.now().toIso8601String(),
  };
}

/// Parse subscription status string to enum value
String _parseSubscriptionStatus(String? status) {
  if (status == 'grace_period') return 'gracePeriod';
  return status ?? 'pending';
}
