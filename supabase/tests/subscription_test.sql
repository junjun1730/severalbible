-- pgTAP tests for Subscription System
-- Phase 4-1: Database & RLS
-- Run with: supabase test db

BEGIN;

-- Plan the number of tests
SELECT plan(25);

-- ============================================
-- Setup: Create test users and data
-- ============================================

-- Create test users in auth.users (will trigger profile creation)
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at)
VALUES
    ('44444444-4444-4444-4444-444444444444', 'member_sub@test.com', 'password', NOW(), NOW(), NOW()),
    ('55555555-5555-5555-5555-555555555555', 'premium_sub@test.com', 'password', NOW(), NOW(), NOW()),
    ('66666666-6666-6666-6666-666666666666', 'other_user@test.com', 'password', NOW(), NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Set user tiers
UPDATE public.user_profiles SET tier = 'member' WHERE id = '44444444-4444-4444-4444-444444444444';
UPDATE public.user_profiles SET tier = 'premium' WHERE id = '55555555-5555-5555-5555-555555555555';
UPDATE public.user_profiles SET tier = 'member' WHERE id = '66666666-6666-6666-6666-666666666666';

-- ============================================
-- Test 1-6: Table Structure - subscription_products
-- ============================================

SELECT has_table('public', 'subscription_products', 'subscription_products table should exist');

SELECT has_column('public', 'subscription_products', 'id', 'subscription_products should have id column');
SELECT has_column('public', 'subscription_products', 'name', 'subscription_products should have name column');
SELECT has_column('public', 'subscription_products', 'price_krw', 'subscription_products should have price_krw column');
SELECT has_column('public', 'subscription_products', 'duration_days', 'subscription_products should have duration_days column');
SELECT has_column('public', 'subscription_products', 'is_active', 'subscription_products should have is_active column');

-- ============================================
-- Test 7-13: Table Structure - user_subscriptions
-- ============================================

SELECT has_table('public', 'user_subscriptions', 'user_subscriptions table should exist');

SELECT has_column('public', 'user_subscriptions', 'id', 'user_subscriptions should have id column');
SELECT has_column('public', 'user_subscriptions', 'user_id', 'user_subscriptions should have user_id column');
SELECT has_column('public', 'user_subscriptions', 'product_id', 'user_subscriptions should have product_id column');
SELECT has_column('public', 'user_subscriptions', 'platform', 'user_subscriptions should have platform column');
SELECT has_column('public', 'user_subscriptions', 'subscription_status', 'user_subscriptions should have subscription_status column');
SELECT has_column('public', 'user_subscriptions', 'expires_at', 'user_subscriptions should have expires_at column');

-- ============================================
-- Test 14-15: RLS is enabled
-- ============================================

SELECT row_security_active('public.subscription_products');
SELECT row_security_active('public.user_subscriptions');

-- ============================================
-- Test 16-17: get_available_products RPC
-- ============================================

-- Should return active products for anonymous users
SELECT is(
    (SELECT COUNT(*)::INTEGER FROM public.get_available_products()),
    2,
    'get_available_products should return 2 active products'
);

-- Should return correct product IDs
SELECT is(
    (SELECT product_id FROM public.get_available_products() WHERE price_krw = 9900),
    'monthly_premium',
    'get_available_products should return monthly_premium product'
);

-- ============================================
-- Test 18-20: activate_subscription RPC
-- ============================================

-- Test activation with valid data
SELECT is(
    (
        SELECT (result->>'success')::BOOLEAN
        FROM (
            SELECT public.activate_subscription(
                '44444444-4444-4444-4444-444444444444',
                'monthly_premium',
                'ios',
                'test_transaction_001'
            ) AS result
        ) t
    ),
    true,
    'activate_subscription should succeed with valid data'
);

-- Verify subscription was created
SELECT is(
    (SELECT subscription_status FROM public.user_subscriptions WHERE user_id = '44444444-4444-4444-4444-444444444444'),
    'active',
    'Subscription status should be active after activation'
);

-- Verify user tier was updated to premium
SELECT is(
    (SELECT tier FROM public.user_profiles WHERE id = '44444444-4444-4444-4444-444444444444'),
    'premium',
    'User tier should be premium after subscription activation'
);

-- ============================================
-- Test 21: get_subscription_status RPC
-- ============================================

-- Set session as subscribed user
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" TO '{"sub": "44444444-4444-4444-4444-444444444444"}';

SELECT is(
    (SELECT status FROM public.get_subscription_status('44444444-4444-4444-4444-444444444444')),
    'active',
    'get_subscription_status should return active status'
);

-- ============================================
-- Test 22: has_active_premium RPC
-- ============================================

SELECT is(
    public.has_active_premium('44444444-4444-4444-4444-444444444444'),
    true,
    'has_active_premium should return true for subscribed user'
);

SELECT is(
    public.has_active_premium('66666666-6666-6666-6666-666666666666'),
    false,
    'has_active_premium should return false for non-subscribed user'
);

-- ============================================
-- Test 23-25: cancel_subscription RPC
-- ============================================

-- Set session as subscribed user
SET LOCAL "request.jwt.claims" TO '{"sub": "44444444-4444-4444-4444-444444444444"}';

SELECT is(
    (
        SELECT (result->>'success')::BOOLEAN
        FROM (
            SELECT public.cancel_subscription(
                '44444444-4444-4444-4444-444444444444',
                'Testing cancellation'
            ) AS result
        ) t
    ),
    true,
    'cancel_subscription should succeed'
);

-- Verify subscription status changed to canceled
SELECT is(
    (SELECT subscription_status FROM public.user_subscriptions WHERE user_id = '44444444-4444-4444-4444-444444444444'),
    'canceled',
    'Subscription status should be canceled after cancellation'
);

-- User should still have premium tier (until expiration)
SELECT is(
    (SELECT tier FROM public.user_profiles WHERE id = '44444444-4444-4444-4444-444444444444'),
    'premium',
    'User tier should remain premium until subscription expires'
);

-- ============================================
-- Cleanup
-- ============================================

-- Note: Test data will be rolled back automatically

SELECT * FROM finish();

ROLLBACK;
