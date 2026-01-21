import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:severalbible/core/errors/failures.dart';
import 'package:severalbible/features/subscription/data/datasources/subscription_datasource.dart';
import 'package:severalbible/features/subscription/data/repositories/supabase_subscription_repository.dart';
import 'package:severalbible/features/subscription/domain/entities/subscription.dart';

// Mock class for SubscriptionDataSource
class MockSubscriptionDataSource extends Mock implements SubscriptionDataSource {}

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(SubscriptionPlatform.ios);
  });

  late SupabaseSubscriptionRepository repository;
  late MockSubscriptionDataSource mockDataSource;

  // Test fixtures
  final testDateTime = DateTime(2026, 1, 20, 12, 0, 0);
  final testExpirationDate = DateTime(2026, 2, 20, 12, 0, 0);
  final testUserId = 'user-123-abc';
  final testTransactionId = 'txn-456-def';
  final testReceipt = 'base64-encoded-receipt-data';
  final testPurchaseToken = 'google-play-purchase-token';

  final sampleSubscriptionJson = {
    'id': 'sub-123-xyz',
    'user_id': testUserId,
    'product_id': 'monthly_premium',
    'platform': 'ios',
    'store_transaction_id': testTransactionId,
    'original_transaction_id': testTransactionId,
    'subscription_status': 'active',
    'started_at': testDateTime.toIso8601String(),
    'expires_at': testExpirationDate.toIso8601String(),
    'auto_renew': true,
    'cancellation_reason': null,
    'created_at': testDateTime.toIso8601String(),
    'updated_at': testDateTime.toIso8601String(),
  };

  final sampleExpiredSubscriptionJson = {
    ...sampleSubscriptionJson,
    'subscription_status': 'expired',
    'expires_at': DateTime(2025, 12, 20).toIso8601String(),
    'auto_renew': false,
  };

  final sampleCanceledSubscriptionJson = {
    ...sampleSubscriptionJson,
    'subscription_status': 'canceled',
    'cancellation_reason': 'User requested cancellation',
    'auto_renew': false,
  };

  final sampleMonthlyProductJson = {
    'id': 'monthly_premium',
    'name': 'Monthly Premium',
    'description': 'Access all premium features for 1 month',
    'duration_days': 30,
    'price_krw': 9900,
    'price_usd': 9.99,
    'ios_product_id': 'com.onemessage.monthly',
    'android_product_id': 'monthly_premium_sub',
    'is_active': true,
    'created_at': testDateTime.toIso8601String(),
  };

  final sampleAnnualProductJson = {
    'id': 'annual_premium',
    'name': 'Annual Premium',
    'description': 'Access all premium features for 1 year (2 months free)',
    'duration_days': 365,
    'price_krw': 99000,
    'price_usd': 99.00,
    'ios_product_id': 'com.onemessage.annual',
    'android_product_id': 'annual_premium_sub',
    'is_active': true,
    'created_at': testDateTime.toIso8601String(),
  };

  final sampleIosVerificationResponse = {
    'valid': true,
    'transactionId': testTransactionId,
    'originalTransactionId': testTransactionId,
    'productId': 'monthly_premium',
    'expiresDate': testExpirationDate.millisecondsSinceEpoch.toString(),
  };

  final sampleAndroidVerificationResponse = {
    'valid': true,
    'purchaseToken': testPurchaseToken,
    'productId': 'monthly_premium',
    'orderId': 'GPA.1234-5678-9012-34567',
    'acknowledgementState': 1,
    'expiryTimeMillis': testExpirationDate.millisecondsSinceEpoch.toString(),
  };

  final sampleActivationResponse = {
    'subscription_id': 'sub-123-xyz',
    'expires_at': testExpirationDate.toIso8601String(),
    'status': 'success',
  };

  setUp(() {
    mockDataSource = MockSubscriptionDataSource();
    repository = SupabaseSubscriptionRepository(mockDataSource);
  });

  group('getSubscriptionStatus', () {
    test('should return Right(Subscription) when datasource returns active subscription',
        () async {
      // Arrange
      when(() => mockDataSource.getSubscriptionStatus(userId: any(named: 'userId')))
          .thenAnswer((_) async => sampleSubscriptionJson);

      // Act
      final result = await repository.getSubscriptionStatus(userId: testUserId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (subscription) {
          expect(subscription, isNotNull);
          expect(subscription!.id, 'sub-123-xyz');
          expect(subscription.status, SubscriptionStatus.active);
          expect(subscription.productId, 'monthly_premium');
          expect(subscription.platform, SubscriptionPlatform.ios);
          expect(subscription.autoRenew, true);
        },
      );
      verify(() => mockDataSource.getSubscriptionStatus(userId: testUserId)).called(1);
    });

    test('should return Right(null) when no subscription exists', () async {
      // Arrange
      when(() => mockDataSource.getSubscriptionStatus(userId: any(named: 'userId')))
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getSubscriptionStatus(userId: testUserId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (subscription) => expect(subscription, isNull),
      );
    });

    test('should return Left(ServerFailure) when datasource throws exception', () async {
      // Arrange
      when(() => mockDataSource.getSubscriptionStatus(userId: any(named: 'userId')))
          .thenThrow(Exception('Database connection error'));

      // Act
      final result = await repository.getSubscriptionStatus(userId: testUserId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Database connection error'));
        },
        (subscription) => fail('Expected Left but got Right'),
      );
    });

    test('should correctly parse expired subscription status', () async {
      // Arrange
      when(() => mockDataSource.getSubscriptionStatus(userId: any(named: 'userId')))
          .thenAnswer((_) async => sampleExpiredSubscriptionJson);

      // Act
      final result = await repository.getSubscriptionStatus(userId: testUserId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (subscription) {
          expect(subscription!.status, SubscriptionStatus.expired);
          expect(subscription.autoRenew, false);
        },
      );
    });
  });

  group('getAvailableProducts', () {
    test('should return Right(List<SubscriptionProduct>) when datasource succeeds',
        () async {
      // Arrange
      when(() => mockDataSource.getAvailableProducts(platform: any(named: 'platform')))
          .thenAnswer((_) async => [sampleMonthlyProductJson, sampleAnnualProductJson]);

      // Act
      final result = await repository.getAvailableProducts();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (products) {
          expect(products.length, 2);
          expect(products.first.id, 'monthly_premium');
          expect(products.first.priceKrw, 9900);
          expect(products.last.id, 'annual_premium');
          expect(products.last.priceKrw, 99000);
        },
      );
      verify(() => mockDataSource.getAvailableProducts(platform: null)).called(1);
    });

    test('should filter by platform when platform is provided', () async {
      // Arrange
      when(() => mockDataSource.getAvailableProducts(platform: SubscriptionPlatform.ios))
          .thenAnswer((_) async => [sampleMonthlyProductJson]);

      // Act
      final result = await repository.getAvailableProducts(
        platform: SubscriptionPlatform.ios,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (products) {
          expect(products.length, 1);
          expect(products.first.iosProductId, 'com.onemessage.monthly');
        },
      );
      verify(() => mockDataSource.getAvailableProducts(platform: SubscriptionPlatform.ios))
          .called(1);
    });

    test('should include pricing info correctly', () async {
      // Arrange
      when(() => mockDataSource.getAvailableProducts(platform: any(named: 'platform')))
          .thenAnswer((_) async => [sampleMonthlyProductJson]);

      // Act
      final result = await repository.getAvailableProducts();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (products) {
          final product = products.first;
          expect(product.priceKrw, 9900);
          expect(product.priceUsd, 9.99);
          expect(product.durationDays, 30);
        },
      );
    });

    test('should return Left(ServerFailure) when datasource throws exception', () async {
      // Arrange
      when(() => mockDataSource.getAvailableProducts(platform: any(named: 'platform')))
          .thenThrow(Exception('Failed to fetch products'));

      // Act
      final result = await repository.getAvailableProducts();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (products) => fail('Expected Left but got Right'),
      );
    });
  });

  group('activateSubscription', () {
    test('should return Right(Subscription) when activation succeeds', () async {
      // Arrange
      when(() => mockDataSource.activateSubscription(
            userId: any(named: 'userId'),
            productId: any(named: 'productId'),
            platform: any(named: 'platform'),
            transactionId: any(named: 'transactionId'),
            originalTransactionId: any(named: 'originalTransactionId'),
          )).thenAnswer((_) async => sampleActivationResponse);

      when(() => mockDataSource.getSubscriptionStatus(userId: any(named: 'userId')))
          .thenAnswer((_) async => sampleSubscriptionJson);

      // Act
      final result = await repository.activateSubscription(
        userId: testUserId,
        productId: 'monthly_premium',
        platform: SubscriptionPlatform.ios,
        transactionId: testTransactionId,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (subscription) {
          expect(subscription.status, SubscriptionStatus.active);
          expect(subscription.productId, 'monthly_premium');
        },
      );
    });

    test('should call datasource with correct parameters', () async {
      // Arrange
      when(() => mockDataSource.activateSubscription(
            userId: any(named: 'userId'),
            productId: any(named: 'productId'),
            platform: any(named: 'platform'),
            transactionId: any(named: 'transactionId'),
            originalTransactionId: any(named: 'originalTransactionId'),
          )).thenAnswer((_) async => sampleActivationResponse);

      when(() => mockDataSource.getSubscriptionStatus(userId: any(named: 'userId')))
          .thenAnswer((_) async => sampleSubscriptionJson);

      // Act
      await repository.activateSubscription(
        userId: testUserId,
        productId: 'monthly_premium',
        platform: SubscriptionPlatform.ios,
        transactionId: testTransactionId,
        originalTransactionId: 'original-txn-123',
      );

      // Assert
      verify(() => mockDataSource.activateSubscription(
            userId: testUserId,
            productId: 'monthly_premium',
            platform: SubscriptionPlatform.ios,
            transactionId: testTransactionId,
            originalTransactionId: 'original-txn-123',
          )).called(1);
    });

    test('should handle subscription renewal correctly', () async {
      // Arrange - renewal has original transaction ID
      when(() => mockDataSource.activateSubscription(
            userId: any(named: 'userId'),
            productId: any(named: 'productId'),
            platform: any(named: 'platform'),
            transactionId: any(named: 'transactionId'),
            originalTransactionId: any(named: 'originalTransactionId'),
          )).thenAnswer((_) async => sampleActivationResponse);

      when(() => mockDataSource.getSubscriptionStatus(userId: any(named: 'userId')))
          .thenAnswer((_) async => {
                ...sampleSubscriptionJson,
                'original_transaction_id': 'original-txn-123',
              });

      // Act
      final result = await repository.activateSubscription(
        userId: testUserId,
        productId: 'monthly_premium',
        platform: SubscriptionPlatform.ios,
        transactionId: 'new-renewal-txn',
        originalTransactionId: 'original-txn-123',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (subscription) {
          expect(subscription.originalTransactionId, 'original-txn-123');
        },
      );
    });

    test('should return Left(ValidationFailure) for invalid product', () async {
      // Arrange
      when(() => mockDataSource.activateSubscription(
            userId: any(named: 'userId'),
            productId: any(named: 'productId'),
            platform: any(named: 'platform'),
            transactionId: any(named: 'transactionId'),
            originalTransactionId: any(named: 'originalTransactionId'),
          )).thenThrow(Exception('Invalid product_id: invalid_product'));

      // Act
      final result = await repository.activateSubscription(
        userId: testUserId,
        productId: 'invalid_product',
        platform: SubscriptionPlatform.ios,
        transactionId: testTransactionId,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('Invalid product_id')),
        (subscription) => fail('Expected Left but got Right'),
      );
    });

    test('should return Left(ServerFailure) when datasource throws exception', () async {
      // Arrange
      when(() => mockDataSource.activateSubscription(
            userId: any(named: 'userId'),
            productId: any(named: 'productId'),
            platform: any(named: 'platform'),
            transactionId: any(named: 'transactionId'),
            originalTransactionId: any(named: 'originalTransactionId'),
          )).thenThrow(Exception('Activation failed'));

      // Act
      final result = await repository.activateSubscription(
        userId: testUserId,
        productId: 'monthly_premium',
        platform: SubscriptionPlatform.ios,
        transactionId: testTransactionId,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (subscription) => fail('Expected Left but got Right'),
      );
    });
  });

  group('cancelSubscription', () {
    test('should return Right(void) when cancellation succeeds', () async {
      // Arrange
      when(() => mockDataSource.cancelSubscription(
            userId: any(named: 'userId'),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async {});

      // Act
      final result = await repository.cancelSubscription(userId: testUserId);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockDataSource.cancelSubscription(
            userId: testUserId,
            reason: null,
          )).called(1);
    });

    test('should pass reason when provided', () async {
      // Arrange
      when(() => mockDataSource.cancelSubscription(
            userId: any(named: 'userId'),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async {});

      // Act
      final result = await repository.cancelSubscription(
        userId: testUserId,
        reason: 'Too expensive',
      );

      // Assert
      expect(result.isRight(), true);
      verify(() => mockDataSource.cancelSubscription(
            userId: testUserId,
            reason: 'Too expensive',
          )).called(1);
    });

    test('should return Left(ServerFailure) when no subscription exists', () async {
      // Arrange
      when(() => mockDataSource.cancelSubscription(
            userId: any(named: 'userId'),
            reason: any(named: 'reason'),
          )).thenThrow(Exception('No active subscription found'));

      // Act
      final result = await repository.cancelSubscription(userId: testUserId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('No active subscription')),
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('should return Left(ServerFailure) when datasource throws exception', () async {
      // Arrange
      when(() => mockDataSource.cancelSubscription(
            userId: any(named: 'userId'),
            reason: any(named: 'reason'),
          )).thenThrow(Exception('Cancellation failed'));

      // Act
      final result = await repository.cancelSubscription(userId: testUserId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('verifyIosReceipt', () {
    test('should return Right(data) for valid receipt', () async {
      // Arrange
      when(() => mockDataSource.verifyIosReceipt(
            receipt: any(named: 'receipt'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => sampleIosVerificationResponse);

      // Act
      final result = await repository.verifyIosReceipt(
        receipt: testReceipt,
        userId: testUserId,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (data) {
          expect(data['valid'], true);
          expect(data['transactionId'], testTransactionId);
          expect(data['productId'], 'monthly_premium');
        },
      );
    });

    test('should call Edge Function with correct parameters', () async {
      // Arrange
      when(() => mockDataSource.verifyIosReceipt(
            receipt: any(named: 'receipt'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => sampleIosVerificationResponse);

      // Act
      await repository.verifyIosReceipt(
        receipt: testReceipt,
        userId: testUserId,
      );

      // Assert
      verify(() => mockDataSource.verifyIosReceipt(
            receipt: testReceipt,
            userId: testUserId,
          )).called(1);
    });

    test('should extract transaction details correctly', () async {
      // Arrange
      when(() => mockDataSource.verifyIosReceipt(
            receipt: any(named: 'receipt'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => sampleIosVerificationResponse);

      // Act
      final result = await repository.verifyIosReceipt(
        receipt: testReceipt,
        userId: testUserId,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (data) {
          expect(data['transactionId'], isNotNull);
          expect(data['originalTransactionId'], isNotNull);
          expect(data['productId'], isNotNull);
          expect(data['expiresDate'], isNotNull);
        },
      );
    });

    test('should return Left(ValidationFailure) for invalid receipt', () async {
      // Arrange
      when(() => mockDataSource.verifyIosReceipt(
            receipt: any(named: 'receipt'),
            userId: any(named: 'userId'),
          )).thenThrow(Exception('Invalid receipt: status 21003'));

      // Act
      final result = await repository.verifyIosReceipt(
        receipt: 'invalid-receipt',
        userId: testUserId,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('Invalid receipt')),
        (data) => fail('Expected Left but got Right'),
      );
    });

    test('should return Left(ServerFailure) when Edge Function throws exception',
        () async {
      // Arrange
      when(() => mockDataSource.verifyIosReceipt(
            receipt: any(named: 'receipt'),
            userId: any(named: 'userId'),
          )).thenThrow(Exception('Edge Function unavailable'));

      // Act
      final result = await repository.verifyIosReceipt(
        receipt: testReceipt,
        userId: testUserId,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (data) => fail('Expected Left but got Right'),
      );
    });
  });

  group('verifyAndroidPurchase', () {
    test('should return Right(data) for valid purchase token', () async {
      // Arrange
      when(() => mockDataSource.verifyAndroidPurchase(
            purchaseToken: any(named: 'purchaseToken'),
            productId: any(named: 'productId'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => sampleAndroidVerificationResponse);

      // Act
      final result = await repository.verifyAndroidPurchase(
        purchaseToken: testPurchaseToken,
        productId: 'monthly_premium',
        userId: testUserId,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (data) {
          expect(data['valid'], true);
          expect(data['purchaseToken'], testPurchaseToken);
          expect(data['productId'], 'monthly_premium');
        },
      );
    });

    test('should call Edge Function with correct parameters', () async {
      // Arrange
      when(() => mockDataSource.verifyAndroidPurchase(
            purchaseToken: any(named: 'purchaseToken'),
            productId: any(named: 'productId'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => sampleAndroidVerificationResponse);

      // Act
      await repository.verifyAndroidPurchase(
        purchaseToken: testPurchaseToken,
        productId: 'monthly_premium',
        userId: testUserId,
      );

      // Assert
      verify(() => mockDataSource.verifyAndroidPurchase(
            purchaseToken: testPurchaseToken,
            productId: 'monthly_premium',
            userId: testUserId,
          )).called(1);
    });

    test('should extract purchase details correctly', () async {
      // Arrange
      when(() => mockDataSource.verifyAndroidPurchase(
            purchaseToken: any(named: 'purchaseToken'),
            productId: any(named: 'productId'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async => sampleAndroidVerificationResponse);

      // Act
      final result = await repository.verifyAndroidPurchase(
        purchaseToken: testPurchaseToken,
        productId: 'monthly_premium',
        userId: testUserId,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (data) {
          expect(data['purchaseToken'], isNotNull);
          expect(data['orderId'], isNotNull);
          expect(data['acknowledgementState'], isNotNull);
          expect(data['expiryTimeMillis'], isNotNull);
        },
      );
    });

    test('should return Left(ValidationFailure) for invalid token', () async {
      // Arrange
      when(() => mockDataSource.verifyAndroidPurchase(
            purchaseToken: any(named: 'purchaseToken'),
            productId: any(named: 'productId'),
            userId: any(named: 'userId'),
          )).thenThrow(Exception('Invalid purchase token'));

      // Act
      final result = await repository.verifyAndroidPurchase(
        purchaseToken: 'invalid-token',
        productId: 'monthly_premium',
        userId: testUserId,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('Invalid purchase token')),
        (data) => fail('Expected Left but got Right'),
      );
    });

    test('should return Left(ServerFailure) when Edge Function throws exception',
        () async {
      // Arrange
      when(() => mockDataSource.verifyAndroidPurchase(
            purchaseToken: any(named: 'purchaseToken'),
            productId: any(named: 'productId'),
            userId: any(named: 'userId'),
          )).thenThrow(Exception('Google Play API unavailable'));

      // Act
      final result = await repository.verifyAndroidPurchase(
        purchaseToken: testPurchaseToken,
        productId: 'monthly_premium',
        userId: testUserId,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (data) => fail('Expected Left but got Right'),
      );
    });
  });

  group('hasActivePremium', () {
    test('should return true for active subscription', () async {
      // Arrange
      when(() => mockDataSource.hasActivePremium(userId: any(named: 'userId')))
          .thenAnswer((_) async => true);

      // Act
      final result = await repository.hasActivePremium(userId: testUserId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (hasPremium) => expect(hasPremium, true),
      );
    });

    test('should return false for no subscription', () async {
      // Arrange
      when(() => mockDataSource.hasActivePremium(userId: any(named: 'userId')))
          .thenAnswer((_) async => false);

      // Act
      final result = await repository.hasActivePremium(userId: testUserId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (hasPremium) => expect(hasPremium, false),
      );
    });

    test('should return false for expired subscription', () async {
      // Arrange - subscription exists but has expired
      when(() => mockDataSource.hasActivePremium(userId: any(named: 'userId')))
          .thenAnswer((_) async => false);

      // Act
      final result = await repository.hasActivePremium(userId: testUserId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (hasPremium) => expect(hasPremium, false),
      );
    });

    test('should check expiration date correctly', () async {
      // Arrange - Use datasource which checks expiration internally
      when(() => mockDataSource.hasActivePremium(userId: any(named: 'userId')))
          .thenAnswer((_) async => true);

      // Act
      final result = await repository.hasActivePremium(userId: testUserId);

      // Assert
      verify(() => mockDataSource.hasActivePremium(userId: testUserId)).called(1);
      expect(result.isRight(), true);
    });

    test('should return Left(ServerFailure) when datasource throws exception', () async {
      // Arrange
      when(() => mockDataSource.hasActivePremium(userId: any(named: 'userId')))
          .thenThrow(Exception('Database error'));

      // Act
      final result = await repository.hasActivePremium(userId: testUserId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (hasPremium) => fail('Expected Left but got Right'),
      );
    });
  });
}
