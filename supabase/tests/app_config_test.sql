-- pgTAP tests for App Config System (Feature Flags)
-- Phase 6: Feature Flag System
-- Run with: supabase test db

BEGIN;

-- Plan the number of tests
SELECT plan(15);

-- ============================================
-- Setup: Ensure migrations have run
-- ============================================

-- ============================================
-- Test 1-6: Table Structure
-- ============================================

SELECT has_table('public', 'app_config', 'app_config table should exist');

SELECT has_column('public', 'app_config', 'key', 'app_config should have key column');
SELECT has_column('public', 'app_config', 'value', 'app_config should have value column');
SELECT has_column('public', 'app_config', 'description', 'app_config should have description column');
SELECT has_column('public', 'app_config', 'updated_at', 'app_config should have updated_at column');

SELECT col_type_is('public', 'app_config', 'key', 'text', 'key should be TEXT');
SELECT col_type_is('public', 'app_config', 'value', 'jsonb', 'value should be JSONB');

-- ============================================
-- Test 7-8: Primary Key and Constraints
-- ============================================

SELECT has_pk('public', 'app_config', 'app_config should have primary key');
SELECT col_is_pk('public', 'app_config', 'key', 'key should be primary key');

-- ============================================
-- Test 9: Default Value (is_free_mode = false)
-- ============================================

SELECT results_eq(
    $$SELECT key, value, description FROM public.app_config WHERE key = 'is_free_mode'$$,
    $$VALUES (
        'is_free_mode'::text,
        'false'::jsonb,
        'Global feature flag: true = all logged-in users get Premium features, false = respect original tier system'::text
    )$$,
    'is_free_mode should default to false (paid mode)'
);

-- ============================================
-- Test 10-11: RLS Policies
-- ============================================

SELECT has_policy('public', 'app_config', 'Anyone can read app_config', 'app_config should have read policy');

-- Test RLS: Anonymous users can read
SET ROLE anon;
SELECT isnt_empty(
    $$SELECT * FROM public.app_config WHERE key = 'is_free_mode'$$,
    'Anonymous users should be able to read app_config'
);
RESET ROLE;

-- ============================================
-- Test 12-15: get_user_tier with Free Mode
-- ============================================

-- Create test users if they don't exist
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at)
VALUES
    ('11111111-1111-1111-1111-111111111111', 'guest@test.com', 'password', NOW(), NOW(), NOW()),
    ('22222222-2222-2222-2222-222222222222', 'member@test.com', 'password', NOW(), NOW(), NOW()),
    ('33333333-3333-3333-3333-333333333333', 'premium@test.com', 'password', NOW(), NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Set user tiers
UPDATE public.user_profiles SET tier = 'guest' WHERE id = '11111111-1111-1111-1111-111111111111';
UPDATE public.user_profiles SET tier = 'member' WHERE id = '22222222-2222-2222-2222-222222222222';
UPDATE public.user_profiles SET tier = 'premium' WHERE id = '33333333-3333-3333-3333-333333333333';

-- Test 12-13: Paid mode (is_free_mode = false)
UPDATE public.app_config SET value = 'false'::jsonb WHERE key = 'is_free_mode';

SELECT is(
    public.get_user_tier('22222222-2222-2222-2222-222222222222'),
    'member',
    'Paid mode: member should stay member'
);

SELECT is(
    public.get_user_tier('11111111-1111-1111-1111-111111111111'),
    'guest',
    'Paid mode: guest should stay guest'
);

-- Test 14-15: Free mode (is_free_mode = true)
UPDATE public.app_config SET value = 'true'::jsonb WHERE key = 'is_free_mode';

SELECT is(
    public.get_user_tier('22222222-2222-2222-2222-222222222222'),
    'premium',
    'Free mode: member should become premium'
);

SELECT is(
    public.get_user_tier('11111111-1111-1111-1111-111111111111'),
    'guest',
    'Free mode: guest should stay guest'
);

-- Finish tests
SELECT * FROM finish();

ROLLBACK;
