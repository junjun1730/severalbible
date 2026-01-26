-- ============================================
-- Test Account Creation Script
-- Creates premium test accounts for development
-- ============================================

-- Helper function to create test accounts with premium subscriptions
CREATE OR REPLACE FUNCTION create_test_premium_account(
  p_email TEXT,
  p_password TEXT,
  p_user_id UUID
)
RETURNS JSON AS $$
DECLARE
  v_encrypted_password TEXT;
BEGIN
  -- Hash the password using Supabase's crypt function
  v_encrypted_password := crypt(p_password, gen_salt('bf'));

  -- Insert into auth.users (or update if exists)
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    aud,
    role,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  ) VALUES (
    p_user_id,
    '00000000-0000-0000-0000-000000000000'::uuid,
    p_email,
    v_encrypted_password,
    NOW(), -- Email auto-confirmed
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{}'::jsonb,
    'authenticated',
    'authenticated',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    encrypted_password = EXCLUDED.encrypted_password,
    email_confirmed_at = NOW(),
    updated_at = NOW();

  -- Ensure user profile exists
  INSERT INTO user_profiles (id, tier, created_at, updated_at)
  VALUES (p_user_id, 'member', NOW(), NOW())
  ON CONFLICT (id) DO UPDATE SET
    tier = 'member',
    updated_at = NOW();

  -- Activate premium subscription using existing RPC
  PERFORM activate_subscription(
    p_user_id := p_user_id,
    p_product_id := 'monthly_premium',
    p_platform := 'web',
    p_transaction_id := 'test-' || p_user_id::text || '-' || extract(epoch from now())::text,
    p_original_transaction_id := 'test-' || p_user_id::text
  );

  RETURN json_build_object(
    'success', true,
    'email', p_email,
    'user_id', p_user_id,
    'tier', 'premium',
    'message', 'Test account created and premium activated'
  );

EXCEPTION
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM,
      'email', p_email
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- Create 3 Pre-configured Test Accounts
-- ============================================

DO $$
BEGIN
  -- Account 1: General premium testing
  RAISE NOTICE 'Creating account 1: premium.test@onemessage.app';
  PERFORM create_test_premium_account(
    'premium.test@onemessage.app',
    'Premium123!',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid
  );

  -- Account 2: Prayer note feature testing
  RAISE NOTICE 'Creating account 2: prayer.test@onemessage.app';
  PERFORM create_test_premium_account(
    'prayer.test@onemessage.app',
    'Prayer123!',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::uuid
  );

  -- Account 3: Scripture delivery testing
  RAISE NOTICE 'Creating account 3: scripture.test@onemessage.app';
  PERFORM create_test_premium_account(
    'scripture.test@onemessage.app',
    'Scripture123!',
    'cccccccc-cccc-cccc-cccc-cccccccccccc'::uuid
  );

  RAISE NOTICE '✅ All test accounts created successfully!';
END $$;

-- ============================================
-- Verification Query
-- ============================================
SELECT
  u.email,
  u.id as user_id,
  p.tier,
  s.subscription_status,
  s.product_id,
  s.expires_at,
  u.email_confirmed_at,
  u.created_at
FROM auth.users u
JOIN user_profiles p ON u.id = p.id
LEFT JOIN user_subscriptions s ON u.id = s.user_id
WHERE u.email LIKE '%test@onemessage.app'
ORDER BY u.email;

-- ============================================
-- Cleanup (Uncomment to delete test accounts)
-- ============================================
-- DELETE FROM auth.users WHERE email LIKE '%test@onemessage.app';
-- Note: Cascade deletes will remove user_profiles and user_subscriptions automatically
