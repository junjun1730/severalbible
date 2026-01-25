import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/subscription.dart';
import 'subscription_datasource.dart';

/// Supabase implementation of SubscriptionDataSource
/// Makes actual RPC calls and Edge Function invocations to Supabase backend
class SupabaseSubscriptionDataSource implements SubscriptionDataSource {
  final SupabaseService _supabaseService;

  SupabaseSubscriptionDataSource(this._supabaseService);

  @override
  Future<Map<String, dynamic>?> getSubscriptionStatus({
    required String userId,
  }) async {
    final response = await _supabaseService.rpc<List<dynamic>>(
      'get_subscription_status',
      params: {'p_user_id': userId},
    );

    if (response.isEmpty) return null;
    return response.first as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableProducts({
    SubscriptionPlatform? platform,
  }) async {
    final params = <String, dynamic>{};
    if (platform != null) {
      params['p_platform'] = platform.name;
    }

    final response = await _supabaseService.rpc<List<dynamic>>(
      'get_available_products',
      params: params.isEmpty ? null : params,
    );

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>> activateSubscription({
    required String userId,
    required String productId,
    required SubscriptionPlatform platform,
    required String transactionId,
    String? originalTransactionId,
  }) async {
    final response = await _supabaseService.rpc<Map<String, dynamic>>(
      'activate_subscription',
      params: {
        'p_user_id': userId,
        'p_product_id': productId,
        'p_platform': platform.name,
        'p_transaction_id': transactionId,
        'p_original_transaction_id': originalTransactionId,
      },
    );

    return response;
  }

  @override
  Future<void> cancelSubscription({
    required String userId,
    String? reason,
  }) async {
    await _supabaseService.rpc<void>(
      'cancel_subscription',
      params: {'p_user_id': userId, 'p_reason': reason},
    );
  }

  @override
  Future<Map<String, dynamic>> verifyIosReceipt({
    required String receipt,
    required String userId,
  }) async {
    final response = await _supabaseService.invokeEdgeFunction(
      'verify-ios-receipt',
      body: {'receipt': receipt, 'userId': userId},
    );

    return response;
  }

  @override
  Future<Map<String, dynamic>> verifyAndroidPurchase({
    required String purchaseToken,
    required String productId,
    required String userId,
  }) async {
    final response = await _supabaseService.invokeEdgeFunction(
      'verify-android-receipt',
      body: {
        'purchaseToken': purchaseToken,
        'productId': productId,
        'userId': userId,
      },
    );

    return response;
  }

  @override
  Future<bool> hasActivePremium({required String userId}) async {
    final response = await _supabaseService.rpc<bool>(
      'has_active_premium',
      params: {'p_user_id': userId},
    );

    return response;
  }
}
