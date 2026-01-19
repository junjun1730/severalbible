-- pgTAP Tests for Scripture RPC Functions
-- Phase 2-1: Scripture Delivery System
-- Run with: supabase test db

BEGIN;

-- Load pgTAP extension
SELECT plan(15);  -- Total number of tests

-- ============================================
-- Setup: Create test user and ensure test data exists
-- ============================================

-- Ensure test user exists in auth.users
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at)
VALUES ('11111111-1111-1111-1111-111111111111', 'test@test.com', 'password', NOW(), NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Ensure user_profile exists
INSERT INTO public.user_profiles (id, tier)
VALUES ('11111111-1111-1111-1111-111111111111', 'member')
ON CONFLICT (id) DO UPDATE SET tier = 'member';

-- Clean up any existing test history
DELETE FROM public.user_scripture_history
WHERE user_id = '11111111-1111-1111-1111-111111111111';

-- ============================================
-- Test 1: get_random_scripture - Basic functionality
-- ============================================
SELECT is(
    (SELECT COUNT(*) FROM public.get_random_scripture(1)),
    1::BIGINT,
    'get_random_scripture(1) should return exactly 1 row'
);

-- ============================================
-- Test 2: get_random_scripture - Returns requested count
-- ============================================
SELECT is(
    (SELECT COUNT(*) FROM public.get_random_scripture(3)),
    3::BIGINT,
    'get_random_scripture(3) should return exactly 3 rows'
);

-- ============================================
-- Test 3: get_random_scripture - Excludes premium scriptures
-- ============================================
SELECT ok(
    NOT EXISTS (
        SELECT 1
        FROM public.get_random_scripture(100)
        WHERE is_premium = TRUE
    ),
    'get_random_scripture should exclude all premium scriptures'
);

-- ============================================
-- Test 4: get_random_scripture - Returns valid scripture data
-- ============================================
SELECT ok(
    (
        SELECT book IS NOT NULL
            AND content IS NOT NULL
            AND reference IS NOT NULL
        FROM public.get_random_scripture(1)
        LIMIT 1
    ),
    'get_random_scripture should return scripture with valid data'
);

-- ============================================
-- Test 5: get_daily_scriptures - Returns up to requested count
-- ============================================
SELECT ok(
    (SELECT COUNT(*) FROM public.get_daily_scriptures(
        '11111111-1111-1111-1111-111111111111'::UUID,
        3
    )) <= 3,
    'get_daily_scriptures should return up to 3 scriptures'
);

-- ============================================
-- Test 6: get_daily_scriptures - Excludes premium scriptures
-- ============================================
SELECT ok(
    NOT EXISTS (
        SELECT 1
        FROM public.get_daily_scriptures(
            '11111111-1111-1111-1111-111111111111'::UUID,
            100
        )
        WHERE is_premium = TRUE
    ),
    'get_daily_scriptures should exclude premium scriptures'
);

-- ============================================
-- Test 7: get_daily_scriptures - Works with new user (no history)
-- ============================================
SELECT ok(
    (SELECT COUNT(*) FROM public.get_daily_scriptures(
        '22222222-2222-2222-2222-222222222222'::UUID,  -- Random user with no history
        3
    )) > 0,
    'get_daily_scriptures should work for user with no history'
);

-- ============================================
-- Test 8: get_premium_scriptures - Returns only premium
-- ============================================
SELECT ok(
    NOT EXISTS (
        SELECT 1
        FROM public.get_premium_scriptures(
            '11111111-1111-1111-1111-111111111111'::UUID,
            100
        )
        WHERE is_premium = FALSE
    ),
    'get_premium_scriptures should return only premium scriptures'
);

-- ============================================
-- Test 9: get_premium_scriptures - Returns up to requested count
-- ============================================
SELECT ok(
    (SELECT COUNT(*) FROM public.get_premium_scriptures(
        '11111111-1111-1111-1111-111111111111'::UUID,
        3
    )) <= 3,
    'get_premium_scriptures should return up to 3 scriptures'
);

-- ============================================
-- Test 10: record_scripture_view - Successfully records view
-- ============================================
-- First, get a valid scripture ID and record a view
SELECT public.record_scripture_view(
    '11111111-1111-1111-1111-111111111111'::UUID,
    (SELECT id FROM public.scriptures WHERE is_premium = FALSE LIMIT 1)
);

SELECT ok(
    EXISTS (
        SELECT 1
        FROM public.user_scripture_history
        WHERE user_id = '11111111-1111-1111-1111-111111111111'::UUID
            AND viewed_date = CURRENT_DATE
    ),
    'record_scripture_view should insert history record'
);

-- ============================================
-- Test 11: record_scripture_view - Handles duplicate gracefully
-- ============================================
-- Record the same view again
SELECT public.record_scripture_view(
    '11111111-1111-1111-1111-111111111111'::UUID,
    (SELECT scripture_id FROM public.user_scripture_history
     WHERE user_id = '11111111-1111-1111-1111-111111111111'::UUID LIMIT 1)
);

SELECT is(
    (
        SELECT COUNT(DISTINCT scripture_id)
        FROM public.user_scripture_history
        WHERE user_id = '11111111-1111-1111-1111-111111111111'::UUID
            AND viewed_date = CURRENT_DATE
    ),
    1::BIGINT,
    'record_scripture_view should not create duplicate for same day'
);

-- ============================================
-- Test 12: get_daily_scriptures - Excludes viewed scriptures
-- ============================================
SELECT ok(
    NOT EXISTS (
        SELECT 1
        FROM public.get_daily_scriptures(
            '11111111-1111-1111-1111-111111111111'::UUID,
            100
        ) ds
        WHERE ds.id IN (
            SELECT scripture_id
            FROM public.user_scripture_history
            WHERE user_id = '11111111-1111-1111-1111-111111111111'::UUID
        )
    ),
    'get_daily_scriptures should exclude scripture viewed today'
);

-- ============================================
-- Test 13: get_scripture_history - Returns viewed scriptures
-- ============================================
SELECT ok(
    (SELECT COUNT(*) FROM public.get_scripture_history(
        '11111111-1111-1111-1111-111111111111'::UUID,
        CURRENT_DATE
    )) > 0,
    'get_scripture_history should return viewed scriptures for today'
);

-- ============================================
-- Test 14: get_scripture_history - Returns correct scripture
-- ============================================
SELECT ok(
    EXISTS (
        SELECT 1
        FROM public.get_scripture_history(
            '11111111-1111-1111-1111-111111111111'::UUID,
            CURRENT_DATE
        ) gs
        WHERE gs.id IN (
            SELECT scripture_id
            FROM public.user_scripture_history
            WHERE user_id = '11111111-1111-1111-1111-111111111111'::UUID
        )
    ),
    'get_scripture_history should include the recorded scripture'
);

-- ============================================
-- Test 15: get_scripture_history - Empty for date with no history
-- ============================================
SELECT is(
    (SELECT COUNT(*) FROM public.get_scripture_history(
        '11111111-1111-1111-1111-111111111111'::UUID,
        '2000-01-01'::DATE  -- Date with no history
    )),
    0::BIGINT,
    'get_scripture_history should return empty for date with no views'
);

-- Finish tests
SELECT * FROM finish();

ROLLBACK;  -- Rollback to keep database clean
