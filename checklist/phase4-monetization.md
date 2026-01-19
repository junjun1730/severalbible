# Phase 4: Monetization - TDD Checklist

**Goal**: Implement In-App Purchase (IAP) system to enable premium subscriptions and tier upgrades. Convert free users to paying customers through strategic upselling.

**Total Items**: 92
**Coverage Target**: Repository 95%+, Service 95%+, Provider 90%+, Widget 80%+
**Estimated Duration**: 8-10 days

---

## 4-1. Database & Subscription Schema

### User Subscriptions Table

#### Create User Subscriptions Table
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.1 | 🟢 GREEN | Create `user_subscriptions` table with schema | [x] |
| 1.1 | 🟢 GREEN | Add foreign key to `user_profiles` table | [x] |
| 1.1 | 🔵 REFACTOR | Verify data integrity and indexes | [x] |

**SQL Schema**:
```sql
CREATE TABLE user_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  product_id TEXT NOT NULL, -- 'monthly_premium' or 'annual_premium'
  platform TEXT NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  store_transaction_id TEXT, -- Receipt validation ID
  original_transaction_id TEXT, -- Original purchase ID (for renewals)
  subscription_status TEXT NOT NULL CHECK (
    subscription_status IN ('active', 'canceled', 'expired', 'pending', 'grace_period')
  ),
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ, -- NULL for lifetime, date for subscriptions
  auto_renew BOOLEAN DEFAULT true,
  cancellation_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX idx_user_subscriptions_status ON user_subscriptions(subscription_status);
CREATE INDEX idx_user_subscriptions_expires_at ON user_subscriptions(expires_at);
```

#### Create Subscription Products Table
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.2 | 🟢 GREEN | Create `subscription_products` table for product definitions | [x] |
| 1.2 | 🟢 GREEN | Insert product definitions (monthly, annual) | [x] |

**SQL Schema**:
```sql
CREATE TABLE subscription_products (
  id TEXT PRIMARY KEY, -- 'monthly_premium', 'annual_premium'
  name TEXT NOT NULL,
  description TEXT,
  duration_days INTEGER, -- 30, 365, NULL for lifetime
  price_krw INTEGER NOT NULL, -- 9900, 99000
  price_usd DECIMAL(10,2), -- For international pricing
  ios_product_id TEXT, -- App Store Connect product ID
  android_product_id TEXT, -- Google Play product ID
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert initial products
INSERT INTO subscription_products (id, name, description, duration_days, price_krw, price_usd, ios_product_id, android_product_id) VALUES
  ('monthly_premium', 'Monthly Premium', 'Access all premium features for 1 month', 30, 9900, 9.99, 'com.onemessage.monthly', 'monthly_premium_sub'),
  ('annual_premium', 'Annual Premium', 'Access all premium features for 1 year (2 months free)', 365, 99000, 99.00, 'com.onemessage.annual', 'annual_premium_sub');
```

### RLS Policies for Subscriptions

#### User Subscriptions RLS
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.3 | 🔴 RED | Write SQL test: User can view own subscription | [x] |
| 1.3 | 🔴 RED | Write SQL test: User cannot view other subscriptions | [x] |
| 1.3 | 🔴 RED | Write SQL test: User cannot directly insert subscription | [x] |
| 1.3 | 🔴 RED | Write SQL test: User cannot directly delete subscription | [x] |
| 1.3 | 🟢 GREEN | Implement RLS policies for user_subscriptions | [x] |

**RLS Policy Example**:
```sql
-- Enable RLS
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can only view their own subscription
CREATE POLICY "Users can view own subscription" ON user_subscriptions
  FOR SELECT USING (auth.uid() = user_id);

-- Only service role can insert/update/delete (via RPC or Edge Function)
CREATE POLICY "Service role can manage subscriptions" ON user_subscriptions
  FOR ALL USING (auth.jwt()->>'role' = 'service_role');
```

#### Subscription Products RLS
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.4 | 🔴 RED | Write SQL test: All users can view active products | [x] |
| 1.4 | 🟢 GREEN | Implement RLS policy for public product viewing | [x] |

**RLS Policy Example**:
```sql
ALTER TABLE subscription_products ENABLE ROW LEVEL SECURITY;

-- Anyone can view active products
CREATE POLICY "Anyone can view active products" ON subscription_products
  FOR SELECT USING (is_active = true);
```

### RPC Functions for Subscriptions

#### RPC: get_subscription_status
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.5 | 🔴 RED | Write SQL test: returns active subscription | [x] |
| 1.5 | 🔴 RED | Write SQL test: returns null for no subscription | [x] |
| 1.5 | 🔴 RED | Write SQL test: checks expiration date | [x] |
| 1.5 | 🔴 RED | Write SQL test: validates user authentication | [x] |
| 1.5 | 🟢 GREEN | Implement `get_subscription_status` RPC | [x] |

**RPC Function**:
```sql
CREATE OR REPLACE FUNCTION get_subscription_status(p_user_id UUID DEFAULT auth.uid())
RETURNS TABLE (
  subscription_id UUID,
  product_id TEXT,
  status TEXT,
  expires_at TIMESTAMPTZ,
  is_active BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    s.id,
    s.product_id,
    s.subscription_status,
    s.expires_at,
    CASE
      WHEN s.subscription_status = 'active' AND (s.expires_at IS NULL OR s.expires_at > NOW()) THEN true
      ELSE false
    END as is_active
  FROM user_subscriptions s
  WHERE s.user_id = p_user_id
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### RPC: activate_subscription
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.6 | 🔴 RED | Write SQL test: activates new subscription | [x] |
| 1.6 | 🔴 RED | Write SQL test: updates user_profiles tier to premium | [x] |
| 1.6 | 🔴 RED | Write SQL test: handles subscription renewal | [x] |
| 1.6 | 🔴 RED | Write SQL test: validates product_id exists | [x] |
| 1.6 | 🔴 RED | Write SQL test: returns error for invalid transaction | [x] |
| 1.6 | 🟢 GREEN | Implement `activate_subscription` RPC | [x] |

**RPC Function**:
```sql
CREATE OR REPLACE FUNCTION activate_subscription(
  p_user_id UUID,
  p_product_id TEXT,
  p_platform TEXT,
  p_transaction_id TEXT,
  p_original_transaction_id TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  v_product subscription_products%ROWTYPE;
  v_expires_at TIMESTAMPTZ;
  v_subscription_id UUID;
BEGIN
  -- Validate product exists
  SELECT * INTO v_product FROM subscription_products WHERE id = p_product_id AND is_active = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invalid product_id: %', p_product_id;
  END IF;

  -- Calculate expiration date
  IF v_product.duration_days IS NOT NULL THEN
    v_expires_at := NOW() + (v_product.duration_days || ' days')::INTERVAL;
  ELSE
    v_expires_at := NULL; -- Lifetime subscription
  END IF;

  -- Insert or update subscription
  INSERT INTO user_subscriptions (
    user_id, product_id, platform, store_transaction_id,
    original_transaction_id, subscription_status, started_at, expires_at
  ) VALUES (
    p_user_id, p_product_id, p_platform, p_transaction_id,
    COALESCE(p_original_transaction_id, p_transaction_id), 'active', NOW(), v_expires_at
  )
  ON CONFLICT (user_id) DO UPDATE SET
    product_id = EXCLUDED.product_id,
    store_transaction_id = EXCLUDED.store_transaction_id,
    subscription_status = 'active',
    expires_at = EXCLUDED.expires_at,
    auto_renew = true,
    updated_at = NOW()
  RETURNING id INTO v_subscription_id;

  -- Update user tier to premium
  UPDATE user_profiles SET tier = 'premium', updated_at = NOW() WHERE id = p_user_id;

  RETURN json_build_object(
    'subscription_id', v_subscription_id,
    'expires_at', v_expires_at,
    'status', 'success'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### RPC: cancel_subscription
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.7 | 🔴 RED | Write SQL test: cancels active subscription | [x] |
| 1.7 | 🔴 RED | Write SQL test: keeps access until expiration | [x] |
| 1.7 | 🔴 RED | Write SQL test: records cancellation reason | [x] |
| 1.7 | 🔴 RED | Write SQL test: sets auto_renew to false | [x] |
| 1.7 | 🟢 GREEN | Implement `cancel_subscription` RPC | [x] |

#### RPC: get_available_products
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.8 | 🔴 RED | Write SQL test: returns all active products | [x] |
| 1.8 | 🔴 RED | Write SQL test: includes pricing information | [x] |
| 1.8 | 🔴 RED | Write SQL test: filters by platform (optional) | [x] |
| 1.8 | 🟢 GREEN | Implement `get_available_products` RPC | [x] |

### Edge Function: Receipt Verification

#### Edge Function: verify-ios-receipt
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.9 | 🔴 RED | Write test: verifies valid iOS receipt with Apple | [x] |
| 1.9 | 🔴 RED | Write test: handles sandbox vs production environment | [x] |
| 1.9 | 🔴 RED | Write test: returns error for invalid receipt | [x] |
| 1.9 | 🔴 RED | Write test: extracts transaction details | [x] |
| 1.9 | 🟢 GREEN | Implement `verify-ios-receipt` Edge Function | [x] |

**Edge Function Example**:
```typescript
// supabase/functions/verify-ios-receipt/index.ts
import { createClient } from '@supabase/supabase-js';

const APPLE_VERIFY_URL_PRODUCTION = 'https://buy.itunes.apple.com/verifyReceipt';
const APPLE_VERIFY_URL_SANDBOX = 'https://sandbox.itunes.apple.com/verifyReceipt';

Deno.serve(async (req) => {
  const { receipt, userId } = await req.json();

  // Try production first, then sandbox
  let response = await fetch(APPLE_VERIFY_URL_PRODUCTION, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      'receipt-data': receipt,
      'password': Deno.env.get('APPLE_SHARED_SECRET')
    })
  });

  let result = await response.json();

  // If status 21007, it's a sandbox receipt
  if (result.status === 21007) {
    response = await fetch(APPLE_VERIFY_URL_SANDBOX, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        'receipt-data': receipt,
        'password': Deno.env.get('APPLE_SHARED_SECRET')
      })
    });
    result = await response.json();
  }

  if (result.status !== 0) {
    return new Response(JSON.stringify({ error: 'Invalid receipt', status: result.status }), {
      status: 400
    });
  }

  // Extract latest receipt info
  const latestReceiptInfo = result.latest_receipt_info?.[0] || result.receipt.in_app?.[0];

  return new Response(JSON.stringify({
    valid: true,
    transactionId: latestReceiptInfo.transaction_id,
    originalTransactionId: latestReceiptInfo.original_transaction_id,
    productId: latestReceiptInfo.product_id,
    expiresDate: latestReceiptInfo.expires_date_ms
  }));
});
```

#### Edge Function: verify-android-receipt
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.10 | 🔴 RED | Write test: verifies valid Android purchase with Google Play | [x] |
| 1.10 | 🔴 RED | Write test: handles subscription acknowledgment | [x] |
| 1.10 | 🔴 RED | Write test: returns error for invalid token | [x] |
| 1.10 | 🟢 GREEN | Implement `verify-android-receipt` Edge Function | [x] |

#### Edge Function: subscription-webhook
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.11 | 🔴 RED | Write test: handles subscription renewal notification | [x] |
| 1.11 | 🔴 RED | Write test: handles subscription cancellation | [x] |
| 1.11 | 🔴 RED | Write test: handles subscription expiration | [x] |
| 1.11 | 🔴 RED | Write test: validates webhook signature | [x] |
| 1.11 | 🟢 GREEN | Implement `subscription-webhook` Edge Function | [x] |

### Edge Function: Check Expired Subscriptions

#### Edge Function: check-expired-subscriptions
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.12 | 🔴 RED | Write test: detects expired subscriptions | [x] |
| 1.12 | 🔴 RED | Write test: downgrades user tier to member | [x] |
| 1.12 | 🔴 RED | Write test: preserves grace period | [x] |
| 1.12 | 🔴 RED | Write test: runs on schedule (cron) | [x] |
| 1.12 | 🟢 GREEN | Implement `check-expired-subscriptions` Edge Function | [x] |
| 1.12 | 🟢 GREEN | Configure cron schedule (daily at 2 AM) | [x] |

**Edge Function Example**:
```typescript
// supabase/functions/check-expired-subscriptions/index.ts
import { createClient } from '@supabase/supabase-js';

Deno.serve(async () => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  // Find expired subscriptions
  const { data: expiredSubs, error } = await supabase
    .from('user_subscriptions')
    .select('user_id, id')
    .eq('subscription_status', 'active')
    .lt('expires_at', new Date().toISOString())
    .is('expires_at', 'not.null');

  if (error) throw error;

  // Update subscription status and user tier
  for (const sub of expiredSubs || []) {
    await supabase
      .from('user_subscriptions')
      .update({ subscription_status: 'expired', updated_at: new Date().toISOString() })
      .eq('id', sub.id);

    await supabase
      .from('user_profiles')
      .update({ tier: 'member', updated_at: new Date().toISOString() })
      .eq('id', sub.user_id);
  }

  return new Response(JSON.stringify({ processed: expiredSubs?.length || 0 }));
});
```

---

## 4-2. Subscription Feature (TDD)

### Domain Layer

#### Subscription Entity
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.1 | 🟢 GREEN | Create `Subscription` entity with freezed | [ ] |
| 2.1 | 🟢 GREEN | Create `SubscriptionProduct` entity with freezed | [ ] |
| 2.1 | 🔵 REFACTOR | Verify immutability and copyWith | [ ] |

**Entity Definition** (`lib/features/subscription/domain/entities/subscription.dart`):
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

enum SubscriptionStatus {
  active,
  canceled,
  expired,
  pending,
  @JsonValue('grace_period')
  gracePeriod,
}

enum Platform {
  ios,
  android,
  web,
}

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String userId,
    required String productId,
    required Platform platform,
    String? storeTransactionId,
    String? originalTransactionId,
    required SubscriptionStatus status,
    required DateTime startedAt,
    DateTime? expiresAt,
    @Default(true) bool autoRenew,
    String? cancellationReason,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
}

@freezed
class SubscriptionProduct with _$SubscriptionProduct {
  const factory SubscriptionProduct({
    required String id,
    required String name,
    String? description,
    int? durationDays,
    required int priceKrw,
    double? priceUsd,
    String? iosProductId,
    String? androidProductId,
    @Default(true) bool isActive,
  }) = _SubscriptionProduct;

  factory SubscriptionProduct.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionProductFromJson(json);
}
```

#### SubscriptionRepository Interface
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.2 | 🟢 GREEN | Create `SubscriptionRepository` interface | [ ] |

**Repository Interface** (`lib/features/subscription/domain/repositories/subscription_repository.dart`):
```dart
import 'package:dartz/dartz.dart';
import '../entities/subscription.dart';
import '../../../../core/errors/failures.dart';

abstract class SubscriptionRepository {
  /// Get current user's subscription status
  Future<Either<Failure, Subscription?>> getSubscriptionStatus({
    required String userId,
  });

  /// Get available subscription products
  Future<Either<Failure, List<SubscriptionProduct>>> getAvailableProducts({
    Platform? platform,
  });

  /// Activate a subscription (after successful purchase)
  Future<Either<Failure, Subscription>> activateSubscription({
    required String userId,
    required String productId,
    required Platform platform,
    required String transactionId,
    String? originalTransactionId,
  });

  /// Cancel current subscription (remains active until expiration)
  Future<Either<Failure, void>> cancelSubscription({
    required String userId,
    String? reason,
  });

  /// Verify iOS receipt with Apple
  Future<Either<Failure, Map<String, dynamic>>> verifyIosReceipt({
    required String receipt,
    required String userId,
  });

  /// Verify Android purchase with Google Play
  Future<Either<Failure, Map<String, dynamic>>> verifyAndroidPurchase({
    required String purchaseToken,
    required String productId,
    required String userId,
  });

  /// Check if user has active premium subscription
  Future<Either<Failure, bool>> hasActivePremium({
    required String userId,
  });
}
```

### Data Layer - SubscriptionRepository Tests

#### Test Setup & Mocks
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.3 | 🔴 RED | Setup test file and mocks | [ ] |
| 2.3 | 🔴 RED | Create `MockSubscriptionDataSource` | [ ] |
| 2.3 | 🔴 RED | Create test fixtures for subscriptions | [ ] |

**Test File**: `test/features/subscription/data/repositories/subscription_repository_test.dart`

#### getSubscriptionStatus Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.4 | 🔴 RED | Test `getSubscriptionStatus` returns Right(subscription) for active | [ ] |
| 2.4 | 🔴 RED | Test `getSubscriptionStatus` returns Right(null) for no subscription | [ ] |
| 2.4 | 🔴 RED | Test `getSubscriptionStatus` returns Left(failure) on error | [ ] |
| 2.4 | 🔴 RED | Test `getSubscriptionStatus` checks expiration correctly | [ ] |
| 2.4 | 🟢 GREEN | Implement `getSubscriptionStatus` | [ ] |

#### getAvailableProducts Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.5 | 🔴 RED | Test `getAvailableProducts` returns Right(products) on success | [ ] |
| 2.5 | 🔴 RED | Test `getAvailableProducts` filters by platform | [ ] |
| 2.5 | 🔴 RED | Test `getAvailableProducts` includes pricing info | [ ] |
| 2.5 | 🔴 RED | Test `getAvailableProducts` returns Left(failure) on error | [ ] |
| 2.5 | 🟢 GREEN | Implement `getAvailableProducts` | [ ] |

#### activateSubscription Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.6 | 🔴 RED | Test `activateSubscription` returns Right(subscription) on success | [ ] |
| 2.6 | 🔴 RED | Test `activateSubscription` calls RPC with correct params | [ ] |
| 2.6 | 🔴 RED | Test `activateSubscription` handles renewal correctly | [ ] |
| 2.6 | 🔴 RED | Test `activateSubscription` returns Left(failure) for invalid product | [ ] |
| 2.6 | 🔴 RED | Test `activateSubscription` returns Left(failure) on error | [ ] |
| 2.6 | 🟢 GREEN | Implement `activateSubscription` | [ ] |

#### cancelSubscription Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.7 | 🔴 RED | Test `cancelSubscription` returns Right(void) on success | [ ] |
| 2.7 | 🔴 RED | Test `cancelSubscription` calls RPC with reason | [ ] |
| 2.7 | 🔴 RED | Test `cancelSubscription` returns Left(failure) on no subscription | [ ] |
| 2.7 | 🔴 RED | Test `cancelSubscription` returns Left(failure) on error | [ ] |
| 2.7 | 🟢 GREEN | Implement `cancelSubscription` | [ ] |

#### verifyIosReceipt Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.8 | 🔴 RED | Test `verifyIosReceipt` returns Right(data) for valid receipt | [ ] |
| 2.8 | 🔴 RED | Test `verifyIosReceipt` calls Edge Function | [ ] |
| 2.8 | 🔴 RED | Test `verifyIosReceipt` extracts transaction details | [ ] |
| 2.8 | 🔴 RED | Test `verifyIosReceipt` returns Left(failure) for invalid receipt | [ ] |
| 2.8 | 🔴 RED | Test `verifyIosReceipt` returns Left(failure) on error | [ ] |
| 2.8 | 🟢 GREEN | Implement `verifyIosReceipt` | [ ] |

#### verifyAndroidPurchase Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.9 | 🔴 RED | Test `verifyAndroidPurchase` returns Right(data) for valid purchase | [ ] |
| 2.9 | 🔴 RED | Test `verifyAndroidPurchase` calls Edge Function | [ ] |
| 2.9 | 🔴 RED | Test `verifyAndroidPurchase` extracts purchase details | [ ] |
| 2.9 | 🔴 RED | Test `verifyAndroidPurchase` returns Left(failure) for invalid token | [ ] |
| 2.9 | 🔴 RED | Test `verifyAndroidPurchase` returns Left(failure) on error | [ ] |
| 2.9 | 🟢 GREEN | Implement `verifyAndroidPurchase` | [ ] |

#### hasActivePremium Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.10 | 🔴 RED | Test `hasActivePremium` returns true for active subscription | [ ] |
| 2.10 | 🔴 RED | Test `hasActivePremium` returns false for no subscription | [ ] |
| 2.10 | 🔴 RED | Test `hasActivePremium` returns false for expired subscription | [ ] |
| 2.10 | 🔴 RED | Test `hasActivePremium` checks expiration date | [ ] |
| 2.10 | 🔴 RED | Test `hasActivePremium` returns Left(failure) on error | [ ] |
| 2.10 | 🟢 GREEN | Implement `hasActivePremium` | [ ] |

### Data Layer - Implementation

#### SubscriptionDataSource
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.11 | 🟢 GREEN | Create `SubscriptionDataSource` interface | [ ] |
| 2.11 | 🟢 GREEN | Implement `SupabaseSubscriptionDataSource` | [ ] |
| 2.11 | 🔵 REFACTOR | Extract JSON mapping logic | [ ] |

**DataSource File**: `lib/features/subscription/data/datasources/subscription_datasource.dart`

#### SubscriptionRepository Implementation
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.12 | 🟢 GREEN | Implement `SupabaseSubscriptionRepository` | [ ] |
| 2.12 | 🔵 REFACTOR | Add comprehensive error handling | [ ] |
| 2.12 | 🔵 REFACTOR | Verify all tests pass (30+ tests passing) | [ ] |

**Repository File**: `lib/features/subscription/data/repositories/supabase_subscription_repository.dart`

### IAP Service Layer

#### IAPService Interface
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.13 | 🟢 GREEN | Create `IAPService` interface | [ ] |

**Service Interface** (`lib/features/subscription/domain/services/iap_service.dart`):
```dart
import 'package:dartz/dartz.dart';
import '../entities/subscription.dart';
import '../../../../core/errors/failures.dart';

abstract class IAPService {
  /// Initialize IAP service (platform-specific)
  Future<Either<Failure, void>> initialize();

  /// Fetch available products from store
  Future<Either<Failure, List<SubscriptionProduct>>> fetchProducts({
    required List<String> productIds,
  });

  /// Purchase a subscription product
  Future<Either<Failure, PurchaseResult>> purchaseSubscription({
    required String productId,
  });

  /// Restore previous purchases
  Future<Either<Failure, List<PurchaseResult>>> restorePurchases();

  /// Get pending purchases (incomplete transactions)
  Future<Either<Failure, List<PurchaseResult>>> getPendingPurchases();
}

@freezed
class PurchaseResult with _$PurchaseResult {
  const factory PurchaseResult({
    required String productId,
    required String transactionId,
    String? originalTransactionId,
    required Platform platform,
    String? receipt, // iOS
    String? purchaseToken, // Android
    required DateTime purchaseDate,
    required PurchaseStatus status,
  }) = _PurchaseResult;
}

enum PurchaseStatus {
  purchased,
  pending,
  restored,
  canceled,
  error,
}
```

#### IAPService Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.14 | 🔴 RED | Test `initialize` succeeds on iOS | [ ] |
| 2.14 | 🔴 RED | Test `initialize` succeeds on Android | [ ] |
| 2.14 | 🔴 RED | Test `fetchProducts` returns available products | [ ] |
| 2.14 | 🔴 RED | Test `purchaseSubscription` completes purchase flow | [ ] |
| 2.14 | 🔴 RED | Test `purchaseSubscription` handles user cancellation | [ ] |
| 2.14 | 🔴 RED | Test `restorePurchases` returns previous purchases | [ ] |
| 2.14 | 🔴 RED | Test `getPendingPurchases` returns incomplete transactions | [ ] |
| 2.14 | 🟢 GREEN | Implement `IAPService` for iOS using `in_app_purchase` | [ ] |
| 2.14 | 🟢 GREEN | Implement `IAPService` for Android using `in_app_purchase` | [ ] |

**Service File**: `lib/features/subscription/data/services/iap_service_impl.dart`

### State Layer - Providers

#### SubscriptionStatusProvider
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 3.1 | 🔴 RED | Test provider loads subscription status | [ ] |
| 3.1 | 🔴 RED | Test provider handles loading state | [ ] |
| 3.1 | 🔴 RED | Test provider handles error state | [ ] |
| 3.1 | 🔴 RED | Test provider refreshes on activation | [ ] |
| 3.1 | 🟢 GREEN | Implement `SubscriptionStatusProvider` | [ ] |

#### AvailableProductsProvider
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 3.2 | 🔴 RED | Test provider loads available products | [ ] |
| 3.2 | 🔴 RED | Test provider filters by current platform | [ ] |
| 3.2 | 🔴 RED | Test provider handles error state | [ ] |
| 3.2 | 🟢 GREEN | Implement `AvailableProductsProvider` | [ ] |

#### PurchaseController
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 3.3 | 🔴 RED | Test controller initiates purchase | [ ] |
| 3.3 | 🔴 RED | Test controller verifies receipt (iOS) | [ ] |
| 3.3 | 🔴 RED | Test controller verifies purchase (Android) | [ ] |
| 3.3 | 🔴 RED | Test controller activates subscription | [ ] |
| 3.3 | 🔴 RED | Test controller handles purchase errors | [ ] |
| 3.3 | 🔴 RED | Test controller handles user cancellation | [ ] |
| 3.3 | 🟢 GREEN | Implement `PurchaseController` | [ ] |

#### RestorePurchaseController
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 3.4 | 🔴 RED | Test controller restores previous purchases | [ ] |
| 3.4 | 🔴 RED | Test controller activates restored subscription | [ ] |
| 3.4 | 🔴 RED | Test controller handles no purchases found | [ ] |
| 3.4 | 🟢 GREEN | Implement `RestorePurchaseController` | [ ] |

#### HasPremiumProvider
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 3.5 | 🔴 RED | Test provider returns true for premium users | [ ] |
| 3.5 | 🔴 RED | Test provider returns false for free users | [ ] |
| 3.5 | 🔴 RED | Test provider checks subscription expiration | [ ] |
| 3.5 | 🟢 GREEN | Implement `HasPremiumProvider` | [ ] |

#### Provider Setup
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 3.6 | 🟢 GREEN | Create `subscriptionRepositoryProvider` | [ ] |
| 3.6 | 🟢 GREEN | Create `subscriptionDataSourceProvider` | [ ] |
| 3.6 | 🟢 GREEN | Create `iapServiceProvider` | [ ] |
| 3.6 | 🟢 GREEN | Create `subscriptionStatusProvider` | [ ] |
| 3.6 | 🟢 GREEN | Create `availableProductsProvider` | [ ] |
| 3.6 | 🟢 GREEN | Create `purchaseControllerProvider` | [ ] |
| 3.6 | 🟢 GREEN | Create `hasPremiumProvider` | [ ] |

---

## 4-3. UI Implementation

### PremiumLandingScreen

#### PremiumLandingScreen Widget Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.1 | 🔴 RED | Widget test: renders premium benefits list | [ ] |
| 4.1 | 🔴 RED | Widget test: renders product cards (monthly/annual) | [ ] |
| 4.1 | 🔴 RED | Widget test: shows pricing with discount badge | [ ] |
| 4.1 | 🔴 RED | Widget test: shows loading during purchase | [ ] |
| 4.1 | 🔴 RED | Widget test: calls purchase callback on button tap | [ ] |
| 4.1 | 🔴 RED | Widget test: shows error message on failure | [ ] |
| 4.1 | 🔴 RED | Widget test: shows restore purchases button | [ ] |
| 4.1 | 🟢 GREEN | Implement `PremiumLandingScreen` | [ ] |

**Screen File**: `lib/features/subscription/presentation/screens/premium_landing_screen.dart`

**Screen Layout**:
```dart
// Premium Landing Screen UI Components:
// 1. Hero Section: "Unlock Unlimited Grace"
// 2. Benefits List:
//    - Access all premium scriptures (3+3 daily)
//    - Unlimited prayer note archive
//    - No ads, priority support
// 3. Product Cards:
//    - Monthly: ₩9,900/month
//    - Annual: ₩99,000/year (with "2 months free" badge)
// 4. CTA Buttons: "Start Monthly" / "Start Annual"
// 5. Legal: Terms, Privacy Policy, Auto-renewal info
// 6. Restore Purchases link
```

### SubscriptionProductCard Widget

#### SubscriptionProductCard Widget Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.2 | 🔴 RED | Widget test: renders product name and price | [ ] |
| 4.2 | 🔴 RED | Widget test: shows discount badge for annual | [ ] |
| 4.2 | 🔴 RED | Widget test: highlights selected product | [ ] |
| 4.2 | 🔴 RED | Widget test: shows trial period info (if applicable) | [ ] |
| 4.2 | 🔴 RED | Widget test: calls onTap callback | [ ] |
| 4.2 | 🟢 GREEN | Implement `SubscriptionProductCard` widget | [ ] |

**Widget File**: `lib/features/subscription/presentation/widgets/subscription_product_card.dart`

### PurchaseButton Widget

#### PurchaseButton Widget Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.3 | 🔴 RED | Widget test: renders button with product info | [ ] |
| 4.3 | 🔴 RED | Widget test: shows loading indicator during purchase | [ ] |
| 4.3 | 🔴 RED | Widget test: disables button when loading | [ ] |
| 4.3 | 🔴 RED | Widget test: calls onPressed callback | [ ] |
| 4.3 | 🟢 GREEN | Implement `PurchaseButton` widget | [ ] |

**Widget File**: `lib/features/subscription/presentation/widgets/purchase_button.dart`

### UpsellDialog Widget

#### UpsellDialog Widget Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.4 | 🔴 RED | Widget test: renders dialog with upsell message | [ ] |
| 4.4 | 🔴 RED | Widget test: shows different messages for different triggers | [ ] |
| 4.4 | 🔴 RED | Widget test: navigates to premium landing on "Upgrade" | [ ] |
| 4.4 | 🔴 RED | Widget test: dismisses on "Maybe Later" | [ ] |
| 4.4 | 🟢 GREEN | Implement `UpsellDialog` widget | [ ] |

**Widget File**: `lib/features/subscription/presentation/widgets/upsell_dialog.dart`

**Upsell Triggers**:
```dart
enum UpsellTrigger {
  archiveLocked,    // "Revisit past prayers"
  contentExhausted, // "Get more wisdom today"
  premiumScripture, // "Access exclusive teachings"
}
```

### ManageSubscriptionScreen

#### ManageSubscriptionScreen Widget Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.5 | 🔴 RED | Widget test: shows current subscription status | [ ] |
| 4.5 | 🔴 RED | Widget test: shows expiration date | [ ] |
| 4.5 | 🔴 RED | Widget test: shows cancel subscription button | [ ] |
| 4.5 | 🔴 RED | Widget test: shows restore purchases button | [ ] |
| 4.5 | 🔴 RED | Widget test: shows auto-renew status | [ ] |
| 4.5 | 🔴 RED | Widget test: handles cancel confirmation | [ ] |
| 4.5 | 🟢 GREEN | Implement `ManageSubscriptionScreen` | [ ] |

**Screen File**: `lib/features/subscription/presentation/screens/manage_subscription_screen.dart`

### Integration with Existing Features

#### Scripture Feed Upselling
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.6 | 🔴 RED | Integration test: shows upsell after 3 scriptures (member) | [ ] |
| 4.6 | 🔴 RED | Integration test: shows "See 3 More" for premium | [ ] |
| 4.6 | 🔴 RED | Integration test: upsell dialog navigates to premium screen | [ ] |
| 4.6 | 🟢 GREEN | Integrate upsell into `DailyFeedScreen` | [ ] |

#### Prayer Note Archive Upselling
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.7 | 🔴 RED | Integration test: shows lock icon for old notes (member) | [ ] |
| 4.7 | 🔴 RED | Integration test: tapping locked note shows upsell | [ ] |
| 4.7 | 🔴 RED | Integration test: premium sees all notes unlocked | [ ] |
| 4.7 | 🟢 GREEN | Integrate upsell into `MyLibraryScreen` | [ ] |

#### Settings Integration
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.8 | 🔴 RED | Integration test: shows "Manage Subscription" for premium | [ ] |
| 4.8 | 🔴 RED | Integration test: shows "Upgrade to Premium" for free | [ ] |
| 4.8 | 🟢 GREEN | Add subscription management to Settings | [ ] |

### Purchase Flow Integration Tests

#### iOS Purchase Flow
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.9 | 🔴 RED | Integration test: user taps upgrade button | [ ] |
| 4.9 | 🔴 RED | Integration test: StoreKit purchase dialog appears | [ ] |
| 4.9 | 🔴 RED | Integration test: receipt verified with Apple | [ ] |
| 4.9 | 🔴 RED | Integration test: subscription activated in Supabase | [ ] |
| 4.9 | 🔴 RED | Integration test: user tier updated to premium | [ ] |
| 4.9 | 🔴 RED | Integration test: UI refreshes to show premium status | [ ] |
| 4.9 | 🟢 GREEN | Implement iOS purchase flow | [ ] |

#### Android Purchase Flow
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.10 | 🔴 RED | Integration test: user taps upgrade button | [ ] |
| 4.10 | 🔴 RED | Integration test: Google Play billing flow appears | [ ] |
| 4.10 | 🔴 RED | Integration test: purchase verified with Google | [ ] |
| 4.10 | 🔴 RED | Integration test: subscription activated in Supabase | [ ] |
| 4.10 | 🔴 RED | Integration test: user tier updated to premium | [ ] |
| 4.10 | 🔴 RED | Integration test: UI refreshes to show premium status | [ ] |
| 4.10 | 🟢 GREEN | Implement Android purchase flow | [ ] |

#### Restore Purchase Flow
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.11 | 🔴 RED | Integration test: user taps "Restore Purchases" | [ ] |
| 4.11 | 🔴 RED | Integration test: previous purchases retrieved from store | [ ] |
| 4.11 | 🔴 RED | Integration test: subscription re-activated | [ ] |
| 4.11 | 🔴 RED | Integration test: shows success message | [ ] |
| 4.11 | 🔴 RED | Integration test: shows error if no purchases found | [ ] |
| 4.11 | 🟢 GREEN | Implement restore purchase flow | [ ] |

---

## Test File Locations

| Test Type | File Path | Tests |
|-----------|-----------|-------|
| RLS/RPC Tests (SQL) | `supabase/tests/subscription_test.sql` | 25 |
| Edge Function Tests (iOS) | `supabase/functions/verify-ios-receipt/test.ts` | 4 |
| Edge Function Tests (Android) | `supabase/functions/verify-android-receipt/test.ts` | 4 |
| Edge Function Tests (Webhook) | `supabase/functions/subscription-webhook/test.ts` | 4 |
| Edge Function Tests (Expiry) | `supabase/functions/check-expired-subscriptions/test.ts` | 4 |
| SubscriptionRepository | `test/features/subscription/data/repositories/subscription_repository_test.dart` | 30 |
| IAPService | `test/features/subscription/data/services/iap_service_test.dart` | 7 |
| SubscriptionStatusProvider | `test/features/subscription/presentation/providers/subscription_status_provider_test.dart` | 4 |
| AvailableProductsProvider | `test/features/subscription/presentation/providers/available_products_provider_test.dart` | 3 |
| PurchaseController | `test/features/subscription/presentation/providers/purchase_controller_test.dart` | 6 |
| RestorePurchaseController | `test/features/subscription/presentation/providers/restore_purchase_controller_test.dart` | 3 |
| PremiumLandingScreen | `test/features/subscription/presentation/screens/premium_landing_screen_test.dart` | 7 |
| ManageSubscriptionScreen | `test/features/subscription/presentation/screens/manage_subscription_screen_test.dart` | 6 |
| SubscriptionProductCard | `test/features/subscription/presentation/widgets/subscription_product_card_test.dart` | 5 |
| PurchaseButton | `test/features/subscription/presentation/widgets/purchase_button_test.dart` | 4 |
| UpsellDialog | `test/features/subscription/presentation/widgets/upsell_dialog_test.dart` | 4 |
| Scripture Feed Integration | `integration_test/scripture_upsell_flow_test.dart` | 3 |
| Archive Upsell Integration | `integration_test/archive_upsell_flow_test.dart` | 3 |
| iOS Purchase Flow | `integration_test/ios_purchase_flow_test.dart` | 6 |
| Android Purchase Flow | `integration_test/android_purchase_flow_test.dart` | 6 |
| Restore Purchase Flow | `integration_test/restore_purchase_flow_test.dart` | 5 |

**Total Test Cases**: 143 tests

---

## Implementation File Locations

| Component | File Path |
|-----------|-----------|
| Subscription Entity | `lib/features/subscription/domain/entities/subscription.dart` |
| SubscriptionProduct Entity | `lib/features/subscription/domain/entities/subscription_product.dart` |
| SubscriptionRepository Interface | `lib/features/subscription/domain/repositories/subscription_repository.dart` |
| IAPService Interface | `lib/features/subscription/domain/services/iap_service.dart` |
| SubscriptionDataSource | `lib/features/subscription/data/datasources/subscription_datasource.dart` |
| SupabaseSubscriptionDataSource | `lib/features/subscription/data/datasources/supabase_subscription_datasource.dart` |
| SupabaseSubscriptionRepository | `lib/features/subscription/data/repositories/supabase_subscription_repository.dart` |
| IAPServiceImpl | `lib/features/subscription/data/services/iap_service_impl.dart` |
| SubscriptionStatusProvider | `lib/features/subscription/presentation/providers/subscription_status_provider.dart` |
| AvailableProductsProvider | `lib/features/subscription/presentation/providers/available_products_provider.dart` |
| PurchaseController | `lib/features/subscription/presentation/providers/purchase_controller.dart` |
| RestorePurchaseController | `lib/features/subscription/presentation/providers/restore_purchase_controller.dart` |
| HasPremiumProvider | `lib/features/subscription/presentation/providers/has_premium_provider.dart` |
| Subscription Providers | `lib/features/subscription/presentation/providers/subscription_providers.dart` |
| PremiumLandingScreen | `lib/features/subscription/presentation/screens/premium_landing_screen.dart` |
| ManageSubscriptionScreen | `lib/features/subscription/presentation/screens/manage_subscription_screen.dart` |
| SubscriptionProductCard | `lib/features/subscription/presentation/widgets/subscription_product_card.dart` |
| PurchaseButton | `lib/features/subscription/presentation/widgets/purchase_button.dart` |
| UpsellDialog | `lib/features/subscription/presentation/widgets/upsell_dialog.dart` |

---

## Dependency Graph

```
Phase 4-1 (Database & Subscription Schema)
    ├─ user_subscriptions table
    ├─ subscription_products table
    ├─ RLS policies
    ├─ RPC functions (4 functions)
    └─ Edge Functions (4 functions)
        ↓
Phase 4-2 (Subscription Feature - TDD)
    ├─ Domain Layer (Entities, Interfaces)
    ├─ Data Layer Tests (SubscriptionRepository, IAPService)
    ├─ Data Layer Implementation
    └─ State Layer (Providers, Controllers)
        ↓
Phase 4-3 (UI Implementation)
    ├─ PremiumLandingScreen
    ├─ ManageSubscriptionScreen
    ├─ Subscription Widgets
    ├─ UpsellDialog Integration
    ├─ Scripture Feed Integration
    ├─ Prayer Archive Integration
    └─ Purchase Flow Integration Tests
```

---

## Daily Progress Milestones

### Day 1-2: Database & Subscription Setup
- Create user_subscriptions and subscription_products tables
- Implement RLS policies
- Implement 4 RPC functions (get_status, activate, cancel, get_products)
- Write SQL tests (25 tests with pgTAP)
- Setup Edge Functions (4 functions: iOS verify, Android verify, webhook, expiry check)

### Day 3-4: Domain & Data Layer (TDD)
- Define Subscription and SubscriptionProduct entities
- Create repository and service interfaces
- Write 37+ tests (SubscriptionRepository + IAPService)
- Implement SupabaseSubscriptionDataSource
- Implement SupabaseSubscriptionRepository
- Verify all tests pass

### Day 5-6: IAP Service & Store Integration
- Configure `in_app_purchase` package
- Implement IAPService for iOS
- Implement IAPService for Android
- Setup App Store Connect products
- Setup Google Play Console products
- Test sandbox purchases

### Day 7: State Layer & Providers
- Implement SubscriptionStatusProvider
- Implement AvailableProductsProvider
- Implement PurchaseController
- Implement RestorePurchaseController
- Implement HasPremiumProvider
- Write provider tests (16+ tests)

### Day 8-9: UI Implementation
- Implement PremiumLandingScreen (7 tests)
- Implement ManageSubscriptionScreen (6 tests)
- Implement SubscriptionProductCard widget (5 tests)
- Implement PurchaseButton widget (4 tests)
- Implement UpsellDialog widget (4 tests)
- Connect UI with providers

### Day 10: Integration & End-to-End Testing
- Integrate upselling into Scripture Feed (3 tests)
- Integrate upselling into Prayer Archive (3 tests)
- Write iOS purchase flow integration test (6 tests)
- Write Android purchase flow integration test (6 tests)
- Write restore purchase flow test (5 tests)
- Test receipt verification with Apple/Google sandbox
- Bug fixes and refinement
- Update documentation

---

## App Store & Google Play Setup Checklist

### iOS - App Store Connect
| Task | Status |
|------|--------|
| Create App ID with in-app purchase capability | [ ] |
| Create subscription group in App Store Connect | [ ] |
| Create "Monthly Premium" subscription product | [ ] |
| Create "Annual Premium" subscription product | [ ] |
| Configure pricing (₩9,900 monthly, ₩99,000 annual) | [ ] |
| Add localized descriptions and screenshots | [ ] |
| Configure auto-renewal settings | [ ] |
| Setup sandbox tester accounts | [ ] |
| Generate and configure shared secret for receipt verification | [ ] |
| Test purchases in sandbox environment | [ ] |

### Android - Google Play Console
| Task | Status |
|------|--------|
| Create app in Google Play Console | [ ] |
| Enable Google Play Billing | [ ] |
| Create "Monthly Premium" subscription product | [ ] |
| Create "Annual Premium" subscription product | [ ] |
| Configure pricing (₩9,900 monthly, ₩99,000 annual) | [ ] |
| Add localized descriptions | [ ] |
| Configure subscription benefits and renewal | [ ] |
| Setup Google Play Billing Library | [ ] |
| Setup license testers for testing | [ ] |
| Configure server notifications (webhook) | [ ] |
| Test purchases with test accounts | [ ] |

---

## Edge Function Configuration

### Environment Variables Required

```bash
# Supabase Edge Functions
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Apple App Store
APPLE_SHARED_SECRET=your-shared-secret-from-app-store-connect

# Google Play (Optional, for server-side verification)
GOOGLE_SERVICE_ACCOUNT_KEY=your-service-account-json
```

### Cron Job Configuration

```sql
-- Schedule subscription expiry check (daily at 2 AM UTC)
SELECT cron.schedule(
  'check-expired-subscriptions',
  '0 2 * * *',
  $$
  SELECT net.http_post(
    url:='https://your-project.supabase.co/functions/v1/check-expired-subscriptions',
    headers:='{"Content-Type": "application/json", "Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb
  ) as request_id;
  $$
);
```

---

## RLS Policy Summary

### User Subscriptions Table - Security First
```sql
-- Enable RLS
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can only view their own subscription
CREATE POLICY "Users can view own subscription" ON user_subscriptions
  FOR SELECT USING (auth.uid() = user_id);

-- Only service role can insert/update/delete
CREATE POLICY "Service role can manage subscriptions" ON user_subscriptions
  FOR ALL USING (auth.jwt()->>'role' = 'service_role');
```

### Subscription Products Table - Public Read
```sql
ALTER TABLE subscription_products ENABLE ROW LEVEL SECURITY;

-- Anyone can view active products
CREATE POLICY "Anyone can view active products" ON subscription_products
  FOR SELECT USING (is_active = true);
```

---

## Test Coverage Goals

| Layer | Target Coverage | Priority |
|-------|----------------|----------|
| SubscriptionRepository | 95%+ | Highest |
| Subscription Domain | 95%+ | Highest |
| IAPService | 95%+ | Highest |
| SubscriptionProviders | 90%+ | High |
| PremiumLandingScreen | 80%+ | Medium |
| ManageSubscriptionScreen | 80%+ | Medium |
| Subscription Widgets | 80%+ | Medium |
| RPC Functions (SQL) | 90%+ | High |
| Edge Functions | 90%+ | High |
| Integration Tests | Full Flow | Highest |

---

## Progress Summary

| Section | Total | Completed | Progress |
|---------|-------|-----------|----------|
| 4-1. Database & Subscription Schema | 30 | 30 | 100% |
| 4-2. Subscription Feature (TDD) | 40 | 0 | 0% |
| 4-3. UI Implementation | 42 | 0 | 0% |
| **Total** | **112** | **30** | **27%** |

---

## Important Notes

### Testing Strategy
1. **Unit Tests**: Use mocks for all store interactions (StoreKit, Google Play Billing)
2. **Sandbox Testing**: Test real purchases in App Store Connect and Google Play sandbox environments
3. **Receipt Validation**: Always verify receipts server-side (Edge Functions) for security
4. **Webhook Testing**: Use tools like ngrok to test webhook notifications locally

### Security Considerations
1. Never trust client-side purchase verification alone
2. Always validate receipts/purchase tokens server-side
3. Use service role key only in Edge Functions, never in client code
4. Implement proper error handling for failed verifications
5. Log all purchase attempts for audit trail

### User Experience
1. Clear communication about subscription benefits
2. Transparent pricing with no hidden fees
3. Easy cancellation process
4. Preserve access until subscription expires (no immediate cutoff)
5. Multiple upgrade prompts without being aggressive

### Edge Cases to Test
1. Network failures during purchase
2. App killed during purchase flow
3. Duplicate purchase attempts
4. Subscription expiration edge (exactly at midnight)
5. Multiple devices with same account
6. Family sharing (if enabled)
7. Regional pricing differences
8. Promotional offers and trials (future)

---

**Last Updated**: 2026-01-19
**Phase Status**: In Progress (Phase 4-1 Complete)
**Next Step**: Implement Subscription Feature with TDD (Section 4-2)
