import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_datasource.dart';

/// Supabase implementation of SubscriptionRepository
/// Handles subscription data operations through Supabase RPC and Edge Functions
class SupabaseSubscriptionRepository implements SubscriptionRepository {
  final SubscriptionDataSource _dataSource;

  SupabaseSubscriptionRepository(this._dataSource);

  @override
  Future<Either<Failure, Subscription?>> getSubscriptionStatus({
    required String userId,
  }) async {
    try {
      final json = await _dataSource.getSubscriptionStatus(userId: userId);
      if (json == null) return const Right(null);

      final subscription = Subscription.fromJson(json);
      return Right(subscription);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionProduct>>> getAvailableProducts({
    SubscriptionPlatform? platform,
  }) async {
    try {
      final jsonList = await _dataSource.getAvailableProducts(
        platform: platform,
      );
      final products = jsonList.map(SubscriptionProduct.fromJson).toList();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Subscription>> activateSubscription({
    required String userId,
    required String productId,
    required SubscriptionPlatform platform,
    required String transactionId,
    String? originalTransactionId,
  }) async {
    try {
      // Call activation RPC
      await _dataSource.activateSubscription(
        userId: userId,
        productId: productId,
        platform: platform,
        transactionId: transactionId,
        originalTransactionId: originalTransactionId,
      );

      // Fetch the newly activated subscription
      final subscriptionJson = await _dataSource.getSubscriptionStatus(
        userId: userId,
      );

      if (subscriptionJson == null) {
        return const Left(ServerFailure('Subscription activation failed'));
      }

      final subscription = Subscription.fromJson(subscriptionJson);
      return Right(subscription);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelSubscription({
    required String userId,
    String? reason,
  }) async {
    try {
      await _dataSource.cancelSubscription(userId: userId, reason: reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyIosReceipt({
    required String receipt,
    required String userId,
  }) async {
    try {
      final result = await _dataSource.verifyIosReceipt(
        receipt: receipt,
        userId: userId,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyAndroidPurchase({
    required String purchaseToken,
    required String productId,
    required String userId,
  }) async {
    try {
      final result = await _dataSource.verifyAndroidPurchase(
        purchaseToken: purchaseToken,
        productId: productId,
        userId: userId,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasActivePremium({
    required String userId,
  }) async {
    try {
      final hasPremium = await _dataSource.hasActivePremium(userId: userId);
      return Right(hasPremium);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
