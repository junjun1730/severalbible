import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/subscription.dart';

/// Abstract repository interface for subscription operations
/// Defines the contract for data layer implementations
abstract class SubscriptionRepository {
  /// Get current user's subscription status
  /// [userId] - The authenticated user's ID
  /// Returns Either<Failure, Subscription?> - null if no subscription exists
  Future<Either<Failure, Subscription?>> getSubscriptionStatus({
    required String userId,
  });

  /// Get available subscription products
  /// [platform] - Optional platform filter (ios, android, web)
  /// Returns Either<Failure, List<SubscriptionProduct>>
  Future<Either<Failure, List<SubscriptionProduct>>> getAvailableProducts({
    SubscriptionPlatform? platform,
  });

  /// Activate a subscription after successful purchase verification
  /// [userId] - The authenticated user's ID
  /// [productId] - The subscription product ID
  /// [platform] - The platform where purchase was made
  /// [transactionId] - The store transaction ID
  /// [originalTransactionId] - Original transaction ID (for renewals)
  /// Returns Either<Failure, Subscription>
  Future<Either<Failure, Subscription>> activateSubscription({
    required String userId,
    required String productId,
    required SubscriptionPlatform platform,
    required String transactionId,
    String? originalTransactionId,
  });

  /// Cancel current subscription (remains active until expiration)
  /// [userId] - The authenticated user's ID
  /// [reason] - Optional cancellation reason
  /// Returns Either<Failure, void>
  Future<Either<Failure, void>> cancelSubscription({
    required String userId,
    String? reason,
  });

  /// Verify iOS receipt with Apple
  /// [receipt] - The receipt data from StoreKit
  /// [userId] - The authenticated user's ID
  /// Returns Either<Failure, Map<String, dynamic>> with verification result
  Future<Either<Failure, Map<String, dynamic>>> verifyIosReceipt({
    required String receipt,
    required String userId,
  });

  /// Verify Android purchase with Google Play
  /// [purchaseToken] - The purchase token from Google Play
  /// [productId] - The product ID
  /// [userId] - The authenticated user's ID
  /// Returns Either<Failure, Map<String, dynamic>> with verification result
  Future<Either<Failure, Map<String, dynamic>>> verifyAndroidPurchase({
    required String purchaseToken,
    required String productId,
    required String userId,
  });

  /// Check if user has active premium subscription
  /// [userId] - The authenticated user's ID
  /// Returns Either<Failure, bool>
  Future<Either<Failure, bool>> hasActivePremium({
    required String userId,
  });
}
