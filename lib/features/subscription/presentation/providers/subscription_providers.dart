import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../auth/domain/user_tier.dart';
import '../../data/datasources/subscription_datasource.dart';
import '../../data/datasources/supabase_subscription_datasource.dart';
import '../../data/repositories/supabase_subscription_repository.dart';
import '../../data/services/iap_service_impl.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/services/iap_service.dart';

/// Provider for SubscriptionDataSource
final subscriptionDataSourceProvider = Provider<SubscriptionDataSource>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return SupabaseSubscriptionDataSource(supabaseService);
});

/// Provider for SubscriptionRepository
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final dataSource = ref.watch(subscriptionDataSourceProvider);
  return SupabaseSubscriptionRepository(dataSource);
});

/// Provider for IAPService
final iapServiceProvider = Provider<IAPService>((ref) {
  final service = IAPServiceImpl();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for current user's subscription status
/// Returns null if no subscription exists
final subscriptionStatusProvider = FutureProvider<Subscription?>((ref) async {
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    return null;
  }

  final repository = ref.watch(subscriptionRepositoryProvider);
  final result = await repository.getSubscriptionStatus(userId: currentUser.id);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (subscription) => subscription,
  );
});

/// Provider for available subscription products
final availableProductsProvider =
    FutureProvider<List<SubscriptionProduct>>((ref) async {
  final repository = ref.watch(subscriptionRepositoryProvider);
  final result = await repository.getAvailableProducts();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

/// Provider for checking if user has active premium subscription
final hasPremiumProvider = FutureProvider<bool>((ref) async {
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    return false;
  }

  final repository = ref.watch(subscriptionRepositoryProvider);
  final result = await repository.hasActivePremium(userId: currentUser.id);

  return result.fold(
    (failure) => false,
    (hasPremium) => hasPremium,
  );
});

/// State for purchase process
enum PurchaseState {
  idle,
  loading,
  success,
  error,
  canceled,
}

/// Controller for managing subscription purchases
class PurchaseController extends StateNotifier<AsyncValue<PurchaseState>> {
  final SubscriptionRepository _subscriptionRepository;
  final IAPService _iapService;
  final String? _userId;
  final Ref _ref;

  PurchaseController(
    this._subscriptionRepository,
    this._iapService,
    this._userId,
    this._ref,
  ) : super(const AsyncValue.data(PurchaseState.idle));

  /// Initialize IAP service
  Future<void> initialize() async {
    final result = await _iapService.initialize();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) {},
    );
  }

  /// Purchase a subscription product
  Future<void> purchaseProduct(String productId) async {
    if (_userId == null) {
      state = AsyncValue.error('User must be logged in', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      // 1. Initiate purchase through store
      final purchaseResult = await _iapService.purchaseSubscription(
        productId: productId,
      );

      await purchaseResult.fold(
        (failure) async {
          if (failure.message.contains('canceled')) {
            state = const AsyncValue.data(PurchaseState.canceled);
          } else {
            state = AsyncValue.error(failure.message, StackTrace.current);
          }
        },
        (result) async {
          // 2. Verify receipt/purchase with server
          if (result.platform == SubscriptionPlatform.ios &&
              result.receipt != null) {
            await _verifyAndActivateIos(result);
          } else if (result.platform == SubscriptionPlatform.android &&
              result.purchaseToken != null) {
            await _verifyAndActivateAndroid(result);
          }
        },
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _verifyAndActivateIos(PurchaseResult result) async {
    // Verify receipt with Apple
    final verifyResult = await _subscriptionRepository.verifyIosReceipt(
      receipt: result.receipt!,
      userId: _userId!,
    );

    await verifyResult.fold(
      (failure) async {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (data) async {
        // Activate subscription
        await _activateSubscription(
          productId: result.productId,
          platform: SubscriptionPlatform.ios,
          transactionId: result.transactionId,
          originalTransactionId: result.originalTransactionId,
        );
      },
    );
  }

  Future<void> _verifyAndActivateAndroid(PurchaseResult result) async {
    // Verify purchase with Google
    final verifyResult = await _subscriptionRepository.verifyAndroidPurchase(
      purchaseToken: result.purchaseToken!,
      productId: result.productId,
      userId: _userId!,
    );

    await verifyResult.fold(
      (failure) async {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (data) async {
        // Activate subscription
        await _activateSubscription(
          productId: result.productId,
          platform: SubscriptionPlatform.android,
          transactionId: result.transactionId,
          originalTransactionId: result.originalTransactionId,
        );
      },
    );
  }

  Future<void> _activateSubscription({
    required String productId,
    required SubscriptionPlatform platform,
    required String transactionId,
    String? originalTransactionId,
  }) async {
    final activateResult = await _subscriptionRepository.activateSubscription(
      userId: _userId!,
      productId: productId,
      platform: platform,
      transactionId: transactionId,
      originalTransactionId: originalTransactionId,
    );

    await activateResult.fold(
      (failure) async {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (subscription) async {
        // Refresh subscription status
        _ref.invalidate(subscriptionStatusProvider);
        _ref.invalidate(hasPremiumProvider);
        _ref.invalidate(currentUserTierProvider);

        state = const AsyncValue.data(PurchaseState.success);
      },
    );
  }

  /// Reset state to idle
  void reset() {
    state = const AsyncValue.data(PurchaseState.idle);
  }
}

/// Provider for purchase controller
final purchaseControllerProvider =
    StateNotifierProvider<PurchaseController, AsyncValue<PurchaseState>>((ref) {
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
  final iapService = ref.watch(iapServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  return PurchaseController(
    subscriptionRepository,
    iapService,
    currentUser?.id,
    ref,
  );
});

/// Controller for restoring purchases
class RestorePurchaseController extends StateNotifier<AsyncValue<void>> {
  final SubscriptionRepository _subscriptionRepository;
  final IAPService _iapService;
  final String? _userId;
  final Ref _ref;

  RestorePurchaseController(
    this._subscriptionRepository,
    this._iapService,
    this._userId,
    this._ref,
  ) : super(const AsyncValue.data(null));

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    if (_userId == null) {
      state = AsyncValue.error('User must be logged in', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final result = await _iapService.restorePurchases();

      await result.fold(
        (failure) async {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (purchases) async {
          if (purchases.isEmpty) {
            state = AsyncValue.error(
              'No purchases found to restore',
              StackTrace.current,
            );
            return;
          }

          // Activate the most recent purchase
          final latest = purchases.first;
          if (latest.platform == SubscriptionPlatform.ios &&
              latest.receipt != null) {
            final verifyResult = await _subscriptionRepository.verifyIosReceipt(
              receipt: latest.receipt!,
              userId: _userId!,
            );

            await verifyResult.fold(
              (failure) async {
                state = AsyncValue.error(failure.message, StackTrace.current);
              },
              (data) async {
                await _activateRestoredSubscription(latest);
              },
            );
          } else if (latest.platform == SubscriptionPlatform.android &&
              latest.purchaseToken != null) {
            final verifyResult =
                await _subscriptionRepository.verifyAndroidPurchase(
              purchaseToken: latest.purchaseToken!,
              productId: latest.productId,
              userId: _userId!,
            );

            await verifyResult.fold(
              (failure) async {
                state = AsyncValue.error(failure.message, StackTrace.current);
              },
              (data) async {
                await _activateRestoredSubscription(latest);
              },
            );
          }
        },
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _activateRestoredSubscription(PurchaseResult purchase) async {
    final activateResult = await _subscriptionRepository.activateSubscription(
      userId: _userId!,
      productId: purchase.productId,
      platform: purchase.platform,
      transactionId: purchase.transactionId,
      originalTransactionId: purchase.originalTransactionId,
    );

    await activateResult.fold(
      (failure) async {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (subscription) async {
        // Refresh subscription status
        _ref.invalidate(subscriptionStatusProvider);
        _ref.invalidate(hasPremiumProvider);
        _ref.invalidate(currentUserTierProvider);

        state = const AsyncValue.data(null);
      },
    );
  }
}

/// Provider for restore purchase controller
final restorePurchaseControllerProvider =
    StateNotifierProvider<RestorePurchaseController, AsyncValue<void>>((ref) {
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
  final iapService = ref.watch(iapServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  return RestorePurchaseController(
    subscriptionRepository,
    iapService,
    currentUser?.id,
    ref,
  );
});

/// Provider for checking if upgrade prompt should be shown
/// Shows when Member user has exhausted daily scriptures
final shouldShowUpgradePromptProvider = Provider<bool>((ref) {
  final tierAsync = ref.watch(currentUserTierProvider);

  final tier = tierAsync.when(
    data: (t) => t,
    loading: () => UserTier.guest,
    error: (_, __) => UserTier.guest,
  );

  // Only show for members, not for premium or guest
  return tier == UserTier.member;
});

/// Provider for subscription expiration info
final subscriptionExpirationProvider = Provider<String?>((ref) {
  final subscriptionAsync = ref.watch(subscriptionStatusProvider);

  return subscriptionAsync.when(
    data: (subscription) {
      if (subscription == null || subscription.expiresAt == null) {
        return null;
      }

      final daysRemaining =
          subscription.expiresAt!.difference(DateTime.now()).inDays;

      if (daysRemaining <= 0) {
        return 'Expired';
      } else if (daysRemaining == 1) {
        return 'Expires tomorrow';
      } else if (daysRemaining <= 7) {
        return 'Expires in $daysRemaining days';
      } else {
        return 'Renews on ${_formatDate(subscription.expiresAt!)}';
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
