-- Phase 4-1: Create Subscription RPC Functions
-- Migration: 009_create_subscription_rpc_functions.sql

-- ============================================
-- 1. get_subscription_status
-- Returns current user's subscription status
-- ============================================
CREATE OR REPLACE FUNCTION get_subscription_status(p_user_id UUID DEFAULT NULL)
RETURNS TABLE (
  subscription_id UUID,
  product_id TEXT,
  product_name TEXT,
  status TEXT,
  platform TEXT,
  started_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  auto_renew BOOLEAN,
  is_active BOOLEAN
) AS $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Use provided user_id or current authenticated user
  v_user_id := COALESCE(p_user_id, auth.uid());

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  RETURN QUERY
  SELECT
    s.id AS subscription_id,
    s.product_id,
    p.name AS product_name,
    s.subscription_status AS status,
    s.platform,
    s.started_at,
    s.expires_at,
    s.auto_renew,
    CASE
      WHEN s.subscription_status = 'active'
           AND (s.expires_at IS NULL OR s.expires_at > NOW())
      THEN true
      WHEN s.subscription_status = 'grace_period'
           AND s.expires_at > NOW() - INTERVAL '3 days'
      THEN true
      ELSE false
    END AS is_active
  FROM user_subscriptions s
  JOIN subscription_products p ON s.product_id = p.id
  WHERE s.user_id = v_user_id
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 2. get_available_products
-- Returns all active subscription products
-- ============================================
CREATE OR REPLACE FUNCTION get_available_products(p_platform TEXT DEFAULT NULL)
RETURNS TABLE (
  product_id TEXT,
  name TEXT,
  description TEXT,
  duration_days INTEGER,
  price_krw INTEGER,
  price_usd DECIMAL(10,2),
  ios_product_id TEXT,
  android_product_id TEXT,
  store_product_id TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    sp.id AS product_id,
    sp.name,
    sp.description,
    sp.duration_days,
    sp.price_krw,
    sp.price_usd,
    sp.ios_product_id,
    sp.android_product_id,
    CASE
      WHEN p_platform = 'ios' THEN sp.ios_product_id
      WHEN p_platform = 'android' THEN sp.android_product_id
      ELSE NULL
    END AS store_product_id
  FROM subscription_products sp
  WHERE sp.is_active = true
  ORDER BY sp.price_krw ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 3. activate_subscription
-- Activates or renews a subscription after successful purchase
-- Should be called from Edge Function after receipt verification
-- ============================================
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
  v_current_expires_at TIMESTAMPTZ;
  v_is_renewal BOOLEAN := false;
BEGIN
  -- Validate product exists and is active
  SELECT * INTO v_product
  FROM subscription_products
  WHERE id = p_product_id AND is_active = true;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invalid product_id: %', p_product_id;
  END IF;

  -- Validate platform
  IF p_platform NOT IN ('ios', 'android', 'web') THEN
    RAISE EXCEPTION 'Invalid platform: %', p_platform;
  END IF;

  -- Check if user already has a subscription
  SELECT expires_at INTO v_current_expires_at
  FROM user_subscriptions
  WHERE user_id = p_user_id;

  -- Calculate expiration date
  IF v_product.duration_days IS NOT NULL THEN
    -- If renewal and current subscription hasn't expired yet, extend from current expiry
    IF v_current_expires_at IS NOT NULL AND v_current_expires_at > NOW() THEN
      v_expires_at := v_current_expires_at + (v_product.duration_days || ' days')::INTERVAL;
      v_is_renewal := true;
    ELSE
      v_expires_at := NOW() + (v_product.duration_days || ' days')::INTERVAL;
    END IF;
  ELSE
    v_expires_at := NULL; -- Lifetime subscription
  END IF;

  -- Insert or update subscription (using UPSERT)
  INSERT INTO user_subscriptions (
    user_id,
    product_id,
    platform,
    store_transaction_id,
    original_transaction_id,
    subscription_status,
    started_at,
    expires_at,
    auto_renew
  ) VALUES (
    p_user_id,
    p_product_id,
    p_platform,
    p_transaction_id,
    COALESCE(p_original_transaction_id, p_transaction_id),
    'active',
    CASE WHEN v_is_renewal THEN (SELECT started_at FROM user_subscriptions WHERE user_id = p_user_id) ELSE NOW() END,
    v_expires_at,
    true
  )
  ON CONFLICT (user_id) DO UPDATE SET
    product_id = EXCLUDED.product_id,
    platform = EXCLUDED.platform,
    store_transaction_id = EXCLUDED.store_transaction_id,
    original_transaction_id = COALESCE(user_subscriptions.original_transaction_id, EXCLUDED.original_transaction_id),
    subscription_status = 'active',
    expires_at = v_expires_at,
    auto_renew = true,
    cancellation_reason = NULL,
    updated_at = NOW()
  RETURNING id INTO v_subscription_id;

  -- Update user tier to premium
  UPDATE user_profiles
  SET tier = 'premium', updated_at = NOW()
  WHERE id = p_user_id;

  RETURN json_build_object(
    'success', true,
    'subscription_id', v_subscription_id,
    'product_id', p_product_id,
    'expires_at', v_expires_at,
    'is_renewal', v_is_renewal
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 4. cancel_subscription
-- Cancels subscription but keeps access until expiration
-- ============================================
CREATE OR REPLACE FUNCTION cancel_subscription(
  p_user_id UUID DEFAULT NULL,
  p_reason TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  v_user_id UUID;
  v_subscription user_subscriptions%ROWTYPE;
BEGIN
  -- Use provided user_id or current authenticated user
  v_user_id := COALESCE(p_user_id, auth.uid());

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;

  -- Get current subscription
  SELECT * INTO v_subscription
  FROM user_subscriptions
  WHERE user_id = v_user_id;

  IF NOT FOUND THEN
    RETURN json_build_object(
      'success', false,
      'error', 'No subscription found'
    );
  END IF;

  -- Already canceled
  IF v_subscription.subscription_status = 'canceled' THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Subscription already canceled'
    );
  END IF;

  -- Update subscription status to canceled
  UPDATE user_subscriptions
  SET
    subscription_status = 'canceled',
    auto_renew = false,
    cancellation_reason = p_reason,
    updated_at = NOW()
  WHERE user_id = v_user_id;

  -- Note: User keeps premium access until expires_at
  -- The check_expired_subscriptions Edge Function will downgrade later

  RETURN json_build_object(
    'success', true,
    'message', 'Subscription canceled. Premium access continues until ' || v_subscription.expires_at,
    'expires_at', v_subscription.expires_at
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 5. check_subscription_expiry
-- Called by Edge Function to check and update expired subscriptions
-- Should only be called with service role
-- ============================================
CREATE OR REPLACE FUNCTION check_subscription_expiry()
RETURNS JSON AS $$
DECLARE
  v_expired_count INTEGER;
  v_grace_count INTEGER;
BEGIN
  -- Find and mark expired subscriptions
  WITH expired AS (
    UPDATE user_subscriptions
    SET
      subscription_status = 'expired',
      auto_renew = false,
      updated_at = NOW()
    WHERE
      subscription_status IN ('active', 'grace_period')
      AND expires_at IS NOT NULL
      AND expires_at <= NOW()
    RETURNING user_id
  ),
  -- Downgrade user tier
  downgraded AS (
    UPDATE user_profiles
    SET tier = 'member', updated_at = NOW()
    WHERE id IN (SELECT user_id FROM expired)
    RETURNING id
  )
  SELECT COUNT(*) INTO v_expired_count FROM downgraded;

  -- Move to grace period (for subscriptions expiring within 3 days that failed renewal)
  -- This is optional - for handling payment failures
  WITH grace AS (
    UPDATE user_subscriptions
    SET
      subscription_status = 'grace_period',
      updated_at = NOW()
    WHERE
      subscription_status = 'active'
      AND auto_renew = true
      AND expires_at IS NOT NULL
      AND expires_at <= NOW() + INTERVAL '3 days'
      AND expires_at > NOW()
    RETURNING id
  )
  SELECT COUNT(*) INTO v_grace_count FROM grace;

  RETURN json_build_object(
    'success', true,
    'expired_count', v_expired_count,
    'grace_period_count', v_grace_count,
    'checked_at', NOW()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 6. has_active_premium
-- Quick check if user has active premium subscription
-- ============================================
CREATE OR REPLACE FUNCTION has_active_premium(p_user_id UUID DEFAULT NULL)
RETURNS BOOLEAN AS $$
DECLARE
  v_user_id UUID;
  v_is_active BOOLEAN;
BEGIN
  v_user_id := COALESCE(p_user_id, auth.uid());

  IF v_user_id IS NULL THEN
    RETURN false;
  END IF;

  SELECT
    CASE
      WHEN subscription_status = 'active'
           AND (expires_at IS NULL OR expires_at > NOW())
      THEN true
      WHEN subscription_status = 'grace_period'
           AND expires_at > NOW() - INTERVAL '3 days'
      THEN true
      ELSE false
    END INTO v_is_active
  FROM user_subscriptions
  WHERE user_id = v_user_id;

  RETURN COALESCE(v_is_active, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- Grant execute permissions
-- ============================================
GRANT EXECUTE ON FUNCTION get_subscription_status TO authenticated;
GRANT EXECUTE ON FUNCTION get_available_products TO anon, authenticated;
GRANT EXECUTE ON FUNCTION cancel_subscription TO authenticated;
GRANT EXECUTE ON FUNCTION has_active_premium TO authenticated;
-- Note: activate_subscription and check_subscription_expiry should only be called
-- from Edge Functions with service role key
