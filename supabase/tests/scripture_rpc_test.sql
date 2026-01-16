-- pgTAP Tests for Scripture RPC Functions
-- Phase 2-1: Scripture Delivery System
-- Run with: SELECT * FROM runtests();

BEGIN;

-- Load pgTAP extension
SELECT plan(15);  -- Total number of tests

-- ============================================
-- Setup: Create test user and test data
-- ============================================

-- Create a test user ID (simulated)
DO $$
DECLARE
    test_user_id UUID := '11111111-1111-1111-1111-111111111111';
    test_scripture_id UUID;
    premium_scripture_id UUID;
BEGIN
    -- Store test user ID for later use
    PERFORM set_config('test.user_id', test_user_id::TEXT, TRUE);

    -- Get a non-premium scripture ID for testing
    SELECT id INTO test_scripture_id
    FROM public.scriptures
    WHERE is_premium = FALSE
    LIMIT 1;
    PERFORM set_config('test.scripture_id', test_scripture_id::TEXT, TRUE);

    -- Get a premium scripture ID for testing
    SELECT id INTO premium_scripture_id
    FROM public.scriptures
    WHERE is_premium = TRUE
    LIMIT 1;
    PERFORM set_config('test.premium_scripture_id', premium_scripture_id::TEXT, TRUE);
END $$;

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
        current_setting('test.user_id')::UUID,
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
            current_setting('test.user_id')::UUID,
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
        '22222222-2222-2222-2222-222222222222'::UUID,  -- New user with no history
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
            current_setting('test.user_id')::UUID,
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
        current_setting('test.user_id')::UUID,
        3
    )) <= 3,
    'get_premium_scriptures should return up to 3 scriptures'
);

-- ============================================
-- Test 10: record_scripture_view - Successfully records view
-- ============================================
DO $$
BEGIN
    -- Record a view
    PERFORM public.record_scripture_view(
        current_setting('test.user_id')::UUID,
        current_setting('test.scripture_id')::UUID
    );
END $$;

SELECT ok(
    EXISTS (
        SELECT 1
        FROM public.user_scripture_history
        WHERE user_id = current_setting('test.user_id')::UUID
            AND scripture_id = current_setting('test.scripture_id')::UUID
            AND viewed_date = CURRENT_DATE
    ),
    'record_scripture_view should insert history record'
);

-- ============================================
-- Test 11: record_scripture_view - Handles duplicate gracefully
-- ============================================
DO $$
BEGIN
    -- Try to record the same view again (should not error)
    PERFORM public.record_scripture_view(
        current_setting('test.user_id')::UUID,
        current_setting('test.scripture_id')::UUID
    );
END $$;

SELECT is(
    (
        SELECT COUNT(*)
        FROM public.user_scripture_history
        WHERE user_id = current_setting('test.user_id')::UUID
            AND scripture_id = current_setting('test.scripture_id')::UUID
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
            current_setting('test.user_id')::UUID,
            100
        )
        WHERE id = current_setting('test.scripture_id')::UUID
    ),
    'get_daily_scriptures should exclude scripture viewed today'
);

-- ============================================
-- Test 13: get_scripture_history - Returns viewed scriptures
-- ============================================
SELECT ok(
    (SELECT COUNT(*) FROM public.get_scripture_history(
        current_setting('test.user_id')::UUID,
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
            current_setting('test.user_id')::UUID,
            CURRENT_DATE
        )
        WHERE id = current_setting('test.scripture_id')::UUID
    ),
    'get_scripture_history should include the recorded scripture'
);

-- ============================================
-- Test 15: get_scripture_history - Empty for date with no history
-- ============================================
SELECT is(
    (SELECT COUNT(*) FROM public.get_scripture_history(
        current_setting('test.user_id')::UUID,
        '2000-01-01'::DATE  -- Date with no history
    )),
    0::BIGINT,
    'get_scripture_history should return empty for date with no views'
);

-- ============================================
-- Cleanup: Remove test data
-- ============================================
DELETE FROM public.user_scripture_history
WHERE user_id = current_setting('test.user_id')::UUID;

-- Finish tests
SELECT * FROM finish();

ROLLBACK;  -- Rollback to keep database clean
