import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:severalbible/core/errors/failures.dart';
import 'package:severalbible/features/auth/domain/user_tier.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';
import 'package:severalbible/features/subscription/domain/entities/subscription.dart';
import 'package:severalbible/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:severalbible/features/subscription/domain/services/iap_service.dart';
import 'package:severalbible/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock classes
class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

class MockIAPService extends Mock implements IAPService {}

class MockUser extends Mock implements User {
  @override
  final String id;

  MockUser(this.id);
}

void main() {
  late MockSubscriptionRepository mockRepository;
  late MockIAPService mockIAPService;

  final testDateTime = DateTime(2026, 1, 20, 12, 0, 0);
  final testExpirationDate = DateTime(2026, 2, 20, 12, 0, 0);
  final testUserId = 'user-123-abc';

  final testSubscription = Subscription(
    id: 'sub-123-xyz',
    userId: testUserId,
    productId: 'monthly_premium',
    platform: SubscriptionPlatform.ios,
    storeTransactionId: 'txn-456',
    originalTransactionId: 'txn-456',
    status: SubscriptionStatus.active,
    startedAt: testDateTime,
    expiresAt: testExpirationDate,
    autoRenew: true,
    createdAt: testDateTime,
    updatedAt: testDateTime,
  );

  final testProducts = [
    SubscriptionProduct(
      id: 'monthly_premium',
      name: 'Monthly Premium',
      description: 'Access all premium features for 1 month',
      durationDays: 30,
      priceKrw: 9900,
      priceUsd: 9.99,
      iosProductId: 'com.onemessage.monthly',
      androidProductId: 'monthly_premium_sub',
      isActive: true,
      createdAt: testDateTime,
    ),
    SubscriptionProduct(
      id: 'annual_premium',
      name: 'Annual Premium',
      description: 'Access all premium features for 1 year',
      durationDays: 365,
      priceKrw: 99000,
      priceUsd: 99.00,
      iosProductId: 'com.onemessage.annual',
      androidProductId: 'annual_premium_sub',
      isActive: true,
      createdAt: testDateTime,
    ),
  ];

  final testUser = MockUser(testUserId);

  setUpAll(() {
    registerFallbackValue(SubscriptionPlatform.ios);
  });

  setUp(() {
    mockRepository = MockSubscriptionRepository();
    mockIAPService = MockIAPService();
  });

  group('subscriptionStatusProvider', () {
    test(
      'should return subscription when user has active subscription',
      () async {
        // Arrange
        when(
          () => mockRepository.getSubscriptionStatus(userId: testUserId),
        ).thenAnswer((_) async => Right(testSubscription));

        final container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWith((ref) => testUser),
            subscriptionRepositoryProvider.overrideWith(
              (ref) => mockRepository,
            ),
          ],
        );
        addTearDown(container.dispose);

        // Act
        final result = await container.read(subscriptionStatusProvider.future);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, 'sub-123-xyz');
        expect(result.status, SubscriptionStatus.active);
      },
    );

    test('should return null when user has no subscription', () async {
      // Arrange
      when(
        () => mockRepository.getSubscriptionStatus(userId: testUserId),
      ).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          subscriptionRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final result = await container.read(subscriptionStatusProvider.future);

      // Assert
      expect(result, isNull);
    });

    test('should return null when user is not logged in', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => null),
          subscriptionRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final result = await container.read(subscriptionStatusProvider.future);

      // Assert
      expect(result, isNull);
    });

    test('should throw error when repository fails', () async {
      // Arrange
      when(
        () => mockRepository.getSubscriptionStatus(userId: testUserId),
      ).thenAnswer((_) async => const Left(ServerFailure('Database error')));

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          subscriptionRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Act & Assert
      expect(
        () => container.read(subscriptionStatusProvider.future),
        throwsException,
      );
    });
  });

  group('availableProductsProvider', () {
    test('should return list of products', () async {
      // Arrange
      when(
        () => mockRepository.getAvailableProducts(platform: null),
      ).thenAnswer((_) async => Right(testProducts));

      final container = ProviderContainer(
        overrides: [
          subscriptionRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final result = await container.read(availableProductsProvider.future);

      // Assert
      expect(result.length, 2);
      expect(result.first.id, 'monthly_premium');
      expect(result.last.id, 'annual_premium');
    });

    test('should throw error when repository fails', () async {
      // Arrange
      when(
        () => mockRepository.getAvailableProducts(platform: null),
      ).thenAnswer((_) async => const Left(ServerFailure('Failed to fetch')));

      final container = ProviderContainer(
        overrides: [
          subscriptionRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Act & Assert
      expect(
        () => container.read(availableProductsProvider.future),
        throwsException,
      );
    });
  });

  group('hasPremiumProvider', () {
    test('should return true for premium user', () async {
      // Arrange
      when(
        () => mockRepository.hasActivePremium(userId: testUserId),
      ).thenAnswer((_) async => const Right(true));

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          subscriptionRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final result = await container.read(hasPremiumProvider.future);

      // Assert
      expect(result, true);
    });

    test('should return false for non-premium user', () async {
      // Arrange
      when(
        () => mockRepository.hasActivePremium(userId: testUserId),
      ).thenAnswer((_) async => const Right(false));

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          subscriptionRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final result = await container.read(hasPremiumProvider.future);

      // Assert
      expect(result, false);
    });

    test('should return false when user is not logged in', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => null),
          subscriptionRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final result = await container.read(hasPremiumProvider.future);

      // Assert
      expect(result, false);
    });
  });

  group('shouldShowUpgradePromptProvider', () {
    test('should return true for member tier', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          currentUserTierProvider.overrideWith((ref) async => UserTier.member),
        ],
      );
      addTearDown(container.dispose);

      // Wait for provider to load
      await container.read(currentUserTierProvider.future);

      // Act
      final result = container.read(shouldShowUpgradePromptProvider);

      // Assert
      expect(result, true);
    });

    test('should return false for premium tier', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          currentUserTierProvider.overrideWith((ref) async => UserTier.premium),
        ],
      );
      addTearDown(container.dispose);

      // Wait for provider to load
      await container.read(currentUserTierProvider.future);

      // Act
      final result = container.read(shouldShowUpgradePromptProvider);

      // Assert
      expect(result, false);
    });

    test('should return false for guest tier', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          currentUserTierProvider.overrideWith((ref) async => UserTier.guest),
        ],
      );
      addTearDown(container.dispose);

      // Wait for provider to load
      await container.read(currentUserTierProvider.future);

      // Act
      final result = container.read(shouldShowUpgradePromptProvider);

      // Assert
      expect(result, false);
    });
  });

  group('subscriptionExpirationProvider', () {
    test('should return expiration message for active subscription', () async {
      // Arrange - subscription expires in 31 days
      final futureExpiration = DateTime.now().add(const Duration(days: 31));
      final expiringSubscription = testSubscription.copyWith(
        expiresAt: futureExpiration,
      );

      when(
        () => mockRepository.getSubscriptionStatus(userId: testUserId),
      ).thenAnswer((_) async => Right(expiringSubscription));

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          subscriptionRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Wait for subscription to load
      await container.read(subscriptionStatusProvider.future);

      // Act
      final result = container.read(subscriptionExpirationProvider);

      // Assert
      expect(result, contains('Renews on'));
    });

    test('should return null when no subscription', () async {
      // Arrange
      when(
        () => mockRepository.getSubscriptionStatus(userId: testUserId),
      ).thenAnswer((_) async => const Right(null));

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => testUser),
          subscriptionRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Wait for subscription to load
      await container.read(subscriptionStatusProvider.future);

      // Act
      final result = container.read(subscriptionExpirationProvider);

      // Assert
      expect(result, isNull);
    });
  });

  group('PurchaseController', () {
    test('should handle purchase error for not logged in user', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => null),
          subscriptionRepositoryProvider.overrideWith((ref) => mockRepository),
          iapServiceProvider.overrideWith((ref) => mockIAPService),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(purchaseControllerProvider.notifier);

      // Act
      await controller.purchaseProduct('monthly_premium');

      // Assert
      final state = container.read(purchaseControllerProvider);
      expect(state.hasError, true);
    });
  });

  group('RestorePurchaseController', () {
    test('should handle restore error for not logged in user', () async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => null),
          subscriptionRepositoryProvider.overrideWith((ref) => mockRepository),
          iapServiceProvider.overrideWith((ref) => mockIAPService),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        restorePurchaseControllerProvider.notifier,
      );

      // Act
      await controller.restorePurchases();

      // Assert
      final state = container.read(restorePurchaseControllerProvider);
      expect(state.hasError, true);
    });
  });
}
