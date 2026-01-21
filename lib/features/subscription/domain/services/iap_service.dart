import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/subscription.dart';

/// Abstract service interface for In-App Purchase operations
/// Platform-specific implementations for iOS and Android
abstract class IAPService {
  /// Initialize IAP service (platform-specific)
  /// Must be called before any purchase operations
  /// Returns Either<Failure, void>
  Future<Either<Failure, void>> initialize();

  /// Fetch available products from store
  /// [productIds] - List of product IDs to fetch
  /// Returns Either<Failure, List<SubscriptionProduct>>
  Future<Either<Failure, List<SubscriptionProduct>>> fetchProducts({
    required List<String> productIds,
  });

  /// Purchase a subscription product
  /// [productId] - The product ID to purchase
  /// Returns Either<Failure, PurchaseResult>
  Future<Either<Failure, PurchaseResult>> purchaseSubscription({
    required String productId,
  });

  /// Restore previous purchases
  /// Returns Either<Failure, List<PurchaseResult>>
  Future<Either<Failure, List<PurchaseResult>>> restorePurchases();

  /// Get pending purchases (incomplete transactions)
  /// Returns Either<Failure, List<PurchaseResult>>
  Future<Either<Failure, List<PurchaseResult>>> getPendingPurchases();

  /// Complete a purchase transaction
  /// [transactionId] - The transaction ID to complete
  /// Returns Either<Failure, void>
  Future<Either<Failure, void>> completePurchase({
    required String transactionId,
  });

  /// Dispose resources and listeners
  void dispose();
}
