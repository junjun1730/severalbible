import '../../domain/entities/subscription.dart';

/// Abstract interface for subscription data operations
/// Implementation will use Supabase RPC and Edge Functions
abstract class SubscriptionDataSource {
  /// Get user's subscription status
  /// Returns null if no subscription exists
  Future<Map<String, dynamic>?> getSubscriptionStatus({
    required String userId,
  });

  /// Get available subscription products
  Future<List<Map<String, dynamic>>> getAvailableProducts({
    SubscriptionPlatform? platform,
  });

  /// Activate a subscription
  /// Calls Supabase RPC function
  Future<Map<String, dynamic>> activateSubscription({
    required String userId,
    required String productId,
    required SubscriptionPlatform platform,
    required String transactionId,
    String? originalTransactionId,
  });

  /// Cancel a subscription
  /// Calls Supabase RPC function
  Future<void> cancelSubscription({
    required String userId,
    String? reason,
  });

  /// Verify iOS receipt via Edge Function
  Future<Map<String, dynamic>> verifyIosReceipt({
    required String receipt,
    required String userId,
  });

  /// Verify Android purchase via Edge Function
  Future<Map<String, dynamic>> verifyAndroidPurchase({
    required String purchaseToken,
    required String productId,
    required String userId,
  });

  /// Check if user has active premium
  Future<bool> hasActivePremium({
    required String userId,
  });
}
