import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;

import '../../../../core/errors/failures.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/services/iap_service.dart';

/// Implementation of IAPService using in_app_purchase package
/// Handles iOS StoreKit and Android Google Play Billing
class IAPServiceImpl implements IAPService {
  final iap.InAppPurchase _iapInstance;
  StreamSubscription<List<iap.PurchaseDetails>>? _subscription;
  Completer<Either<Failure, PurchaseResult>>? _purchaseCompleter;
  Completer<Either<Failure, List<PurchaseResult>>>? _restoreCompleter;

  /// Creates IAPService with optional InAppPurchase instance for testing
  IAPServiceImpl([iap.InAppPurchase? iapInstance])
    : _iapInstance = iapInstance ?? iap.InAppPurchase.instance;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      final available = await _iapInstance.isAvailable();
      if (!available) {
        return const Left(ServerFailure('In-app purchases not available'));
      }

      // Listen to purchase updates
      _subscription = _iapInstance.purchaseStream.listen(
        _handlePurchaseUpdate,
        onDone: _handleStreamDone,
        onError: _handleStreamError,
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionProduct>>> fetchProducts({
    required List<String> productIds,
  }) async {
    try {
      final response = await _iapInstance.queryProductDetails(
        productIds.toSet(),
      );

      if (response.error != null) {
        return Left(ServerFailure(response.error!.message));
      }

      if (response.productDetails.isEmpty) {
        return const Left(ServerFailure('No products found'));
      }

      final products = response.productDetails.map((details) {
        return SubscriptionProduct(
          id: details.id,
          name: details.title,
          description: details.description,
          durationDays: _getDurationDays(details.id),
          priceKrw: details.rawPrice.toInt(),
          priceUsd: _convertToUsd(details.rawPrice, details.currencyCode),
          iosProductId: Platform.isIOS ? details.id : null,
          androidProductId: Platform.isAndroid ? details.id : null,
          isActive: true,
          createdAt: DateTime.now(),
        );
      }).toList();

      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PurchaseResult>> purchaseSubscription({
    required String productId,
  }) async {
    try {
      // Query product details first
      final response = await _iapInstance.queryProductDetails({productId});

      if (response.productDetails.isEmpty) {
        return Left(ServerFailure('Product not found: $productId'));
      }

      final productDetails = response.productDetails.first;

      // Set up completer for async result
      _purchaseCompleter = Completer<Either<Failure, PurchaseResult>>();

      // Initiate purchase
      final purchaseParam = iap.PurchaseParam(productDetails: productDetails);
      final success = await _iapInstance.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!success) {
        _purchaseCompleter = null;
        return const Left(ServerFailure('Purchase initiation failed'));
      }

      // Wait for purchase result from stream
      return _purchaseCompleter!.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          _purchaseCompleter = null;
          return const Left(ServerFailure('Purchase timeout'));
        },
      );
    } catch (e) {
      _purchaseCompleter = null;
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PurchaseResult>>> restorePurchases() async {
    try {
      _restoreCompleter = Completer<Either<Failure, List<PurchaseResult>>>();

      await _iapInstance.restorePurchases();

      // Wait for restore results from stream
      return _restoreCompleter!.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          _restoreCompleter = null;
          return const Right([]);
        },
      );
    } catch (e) {
      _restoreCompleter = null;
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PurchaseResult>>> getPendingPurchases() async {
    // Pending purchases are handled through the purchase stream
    // This is a no-op for the current implementation
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> completePurchase({
    required String transactionId,
  }) async {
    // Completion is handled internally through _handlePurchaseUpdate
    // This method is exposed for manual completion if needed
    return const Right(null);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Handle incoming purchase updates from the stream
  void _handlePurchaseUpdate(List<iap.PurchaseDetails> purchaseDetailsList) {
    final restoredPurchases = <PurchaseResult>[];

    for (final purchase in purchaseDetailsList) {
      switch (purchase.status) {
        case iap.PurchaseStatus.pending:
          // Purchase is pending - no action needed
          break;

        case iap.PurchaseStatus.purchased:
        case iap.PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchase, restoredPurchases);
          break;

        case iap.PurchaseStatus.error:
          _handlePurchaseError(purchase);
          break;

        case iap.PurchaseStatus.canceled:
          _handlePurchaseCanceled(purchase);
          break;
      }

      // Complete the purchase if pending
      if (purchase.pendingCompletePurchase) {
        _iapInstance.completePurchase(purchase);
      }
    }

    // Complete restore if there are restored purchases
    if (restoredPurchases.isNotEmpty && _restoreCompleter != null) {
      _restoreCompleter!.complete(Right(restoredPurchases));
      _restoreCompleter = null;
    }
  }

  void _handleSuccessfulPurchase(
    iap.PurchaseDetails purchase,
    List<PurchaseResult> restoredPurchases,
  ) {
    final result = PurchaseResult(
      productId: purchase.productID,
      transactionId: purchase.purchaseID ?? '',
      originalTransactionId: _getOriginalTransactionId(purchase),
      platform: Platform.isIOS
          ? SubscriptionPlatform.ios
          : SubscriptionPlatform.android,
      receipt: Platform.isIOS
          ? purchase.verificationData.serverVerificationData
          : null,
      purchaseToken: Platform.isAndroid
          ? purchase.verificationData.serverVerificationData
          : null,
      purchaseDate:
          DateTime.tryParse(purchase.transactionDate ?? '') ?? DateTime.now(),
      status: purchase.status == iap.PurchaseStatus.restored
          ? IAPPurchaseStatus.restored
          : IAPPurchaseStatus.purchased,
    );

    if (purchase.status == iap.PurchaseStatus.restored) {
      restoredPurchases.add(result);
    } else if (_purchaseCompleter != null) {
      _purchaseCompleter!.complete(Right(result));
      _purchaseCompleter = null;
    }
  }

  void _handlePurchaseError(iap.PurchaseDetails purchase) {
    if (_purchaseCompleter != null) {
      _purchaseCompleter!.complete(
        Left(ServerFailure(purchase.error?.message ?? 'Purchase failed')),
      );
      _purchaseCompleter = null;
    }
  }

  void _handlePurchaseCanceled(iap.PurchaseDetails purchase) {
    if (_purchaseCompleter != null) {
      _purchaseCompleter!.complete(
        const Left(ServerFailure('Purchase canceled by user')),
      );
      _purchaseCompleter = null;
    }
  }

  void _handleStreamDone() {
    // Stream closed - clean up
    _subscription = null;
  }

  void _handleStreamError(Object error) {
    if (_purchaseCompleter != null) {
      _purchaseCompleter!.complete(Left(ServerFailure(error.toString())));
      _purchaseCompleter = null;
    }
  }

  /// Get duration days based on product ID
  int _getDurationDays(String productId) {
    if (productId.contains('annual')) return 365;
    if (productId.contains('monthly')) return 30;
    return 30; // Default to monthly
  }

  /// Convert raw price to USD (approximate)
  double? _convertToUsd(double rawPrice, String currencyCode) {
    if (currencyCode == 'USD') return rawPrice;
    if (currencyCode == 'KRW') return rawPrice / 1400; // Approximate rate
    return null;
  }

  /// Get original transaction ID for renewals (iOS specific)
  String? _getOriginalTransactionId(iap.PurchaseDetails purchase) {
    // For iOS, the original transaction ID is available in the receipt
    // For simplicity, we use the purchase ID here
    return purchase.purchaseID;
  }
}
