-- Phase 4-1: Create Subscription Tables and RLS Policies
-- Migration: 008_create_user_subscriptions.sql

-- ============================================
-- 1. Subscription Products Table
-- ============================================
CREATE TABLE IF NOT EXISTS subscription_products (
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
  ('annual_premium', 'Annual Premium', 'Access all premium features for 1 year (2 months free)', 365, 99000, 99.00, 'com.onemessage.annual', 'annual_premium_sub')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 2. User Subscriptions Table
-- ============================================
CREATE TABLE IF NOT EXISTS user_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  product_id TEXT NOT NULL REFERENCES subscription_products(id),
  platform TEXT NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  store_transaction_id TEXT, -- Receipt validation ID
  original_transaction_id TEXT, -- Original purchase ID (for renewals)
  subscription_status TEXT NOT NULL DEFAULT 'pending' CHECK (
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
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_status ON user_subscriptions(subscription_status);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_expires_at ON user_subscriptions(expires_at);

-- ============================================
-- 3. RLS Policies for subscription_products
-- ============================================
ALTER TABLE subscription_products ENABLE ROW LEVEL SECURITY;

-- Anyone can view active products (needed for app to show pricing)
DROP POLICY IF EXISTS "Anyone can view active products" ON subscription_products;
CREATE POLICY "Anyone can view active products" ON subscription_products
  FOR SELECT USING (is_active = true);

-- Only service role can manage products (insert/update/delete)
DROP POLICY IF EXISTS "Service role can manage products" ON subscription_products;
CREATE POLICY "Service role can manage products" ON subscription_products
  FOR ALL USING (
    (SELECT current_setting('request.jwt.claims', true)::json->>'role') = 'service_role'
  );

-- ============================================
-- 4. RLS Policies for user_subscriptions
-- ============================================
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can only view their own subscription
DROP POLICY IF EXISTS "Users can view own subscription" ON user_subscriptions;
CREATE POLICY "Users can view own subscription" ON user_subscriptions
  FOR SELECT USING (auth.uid() = user_id);

-- Service role can manage all subscriptions (for Edge Functions and webhooks)
DROP POLICY IF EXISTS "Service role can manage subscriptions" ON user_subscriptions;
CREATE POLICY "Service role can manage subscriptions" ON user_subscriptions
  FOR ALL USING (
    (SELECT current_setting('request.jwt.claims', true)::json->>'role') = 'service_role'
  );

-- ============================================
-- 5. Trigger for updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_user_subscriptions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_user_subscriptions_updated_at ON user_subscriptions;
CREATE TRIGGER trigger_update_user_subscriptions_updated_at
  BEFORE UPDATE ON user_subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_user_subscriptions_updated_at();

-- ============================================
-- 6. Grant permissions
-- ============================================
GRANT SELECT ON subscription_products TO anon, authenticated;
GRANT SELECT ON user_subscriptions TO authenticated;
