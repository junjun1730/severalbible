// DEAD CODE: in_app_purchase removed as part of ad-based revenue model pivot (2026-03-15)
// This file is a stub kept for reference. IAP functionality has been replaced by AdMob.
// The subscription directory is retained for data model compatibility only.
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/services/iap_service.dart';

/// Stub implementation of IAPService — IAP has been replaced by AdMob ads.
/// This class is kept for compilation purposes only and is not used in production.
class IAPServiceImpl implements IAPService {
  @override
  Future<Either<Failure, void>> initialize() async =>
      const Left(ServerFailure('IAP not available: revenue model switched to ads'));

  @override
  Future<Either<Failure, List<SubscriptionProduct>>> fetchProducts({
    required List<String> productIds,
  }) async =>
      const Left(ServerFailure('IAP not available: revenue model switched to ads'));

  @override
  Future<Either<Failure, PurchaseResult>> purchaseSubscription({
    required String productId,
  }) async =>
      const Left(ServerFailure('IAP not available: revenue model switched to ads'));

  @override
  Future<Either<Failure, List<PurchaseResult>>> restorePurchases() async =>
      const Left(ServerFailure('IAP not available: revenue model switched to ads'));

  @override
  Future<Either<Failure, List<PurchaseResult>>> getPendingPurchases() async =>
      const Left(ServerFailure('IAP not available: revenue model switched to ads'));

  @override
  Future<Either<Failure, void>> completePurchase({
    required String transactionId,
  }) async =>
      const Left(ServerFailure('IAP not available: revenue model switched to ads'));

  @override
  void dispose() {}
}
