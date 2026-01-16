-- Migration: Create Scripture RPC Functions
-- Description: RPC functions for tier-based scripture delivery
-- Date: 2026-01-16
-- Phase: 2-1 (Scripture Delivery System)

-- ============================================
-- 1. get_random_scripture (For Guest)
-- ============================================
-- Returns random scripture(s) for guest users
-- - Excludes premium scriptures
-- - Allows duplicates (no history tracking)

CREATE OR REPLACE FUNCTION public.get_random_scripture(limit_count INTEGER DEFAULT 1)
RETURNS SETOF public.scriptures
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
    SELECT *
    FROM public.scriptures
    WHERE is_premium = FALSE
    ORDER BY RANDOM()
    LIMIT limit_count;
$$;

COMMENT ON FUNCTION public.get_random_scripture IS 'Get random scripture(s) for guest users. Excludes premium content.';

-- ============================================
-- 2. get_daily_scriptures (For Member - No Duplicate)
-- ============================================
-- Returns scriptures for member users
-- - Excludes premium scriptures
-- - Excludes scriptures already viewed today (no-duplicate logic)

CREATE OR REPLACE FUNCTION public.get_daily_scriptures(
    p_user_id UUID,
    limit_count INTEGER DEFAULT 3
)
RETURNS SETOF public.scriptures
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT s.*
    FROM public.scriptures s
    WHERE s.is_premium = FALSE
        AND s.id NOT IN (
            -- Exclude scriptures viewed today by this user
            SELECT h.scripture_id
            FROM public.user_scripture_history h
            WHERE h.user_id = p_user_id
                AND h.viewed_date = CURRENT_DATE
        )
    ORDER BY RANDOM()
    LIMIT limit_count;
END;
$$;

COMMENT ON FUNCTION public.get_daily_scriptures IS 'Get daily scriptures for member users. Excludes already viewed today and premium content.';

-- ============================================
-- 3. get_premium_scriptures (For Premium)
-- ============================================
-- Returns premium scriptures for premium users
-- - Only premium scriptures
-- - Excludes scriptures already viewed today

CREATE OR REPLACE FUNCTION public.get_premium_scriptures(
    p_user_id UUID,
    limit_count INTEGER DEFAULT 3
)
RETURNS SETOF public.scriptures
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT s.*
    FROM public.scriptures s
    WHERE s.is_premium = TRUE
        AND s.id NOT IN (
            -- Exclude scriptures viewed today by this user
            SELECT h.scripture_id
            FROM public.user_scripture_history h
            WHERE h.user_id = p_user_id
                AND h.viewed_date = CURRENT_DATE
        )
    ORDER BY RANDOM()
    LIMIT limit_count;
END;
$$;

COMMENT ON FUNCTION public.get_premium_scriptures IS 'Get premium scriptures for premium users. Excludes already viewed today.';

-- ============================================
-- 4. record_scripture_view
-- ============================================
-- Records that a user viewed a scripture
-- - Handles duplicate prevention (same user, same scripture, same day)
-- - Uses ON CONFLICT to silently ignore duplicates

CREATE OR REPLACE FUNCTION public.record_scripture_view(
    p_user_id UUID,
    p_scripture_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.user_scripture_history (user_id, scripture_id, viewed_at, viewed_date)
    VALUES (p_user_id, p_scripture_id, NOW(), CURRENT_DATE)
    ON CONFLICT (user_id, scripture_id, viewed_date) DO NOTHING;
END;
$$;

COMMENT ON FUNCTION public.record_scripture_view IS 'Record that a user viewed a scripture. Prevents duplicate entries for same day.';

-- ============================================
-- 5. get_scripture_history (Optional utility)
-- ============================================
-- Returns scriptures viewed by a user on a specific date

CREATE OR REPLACE FUNCTION public.get_scripture_history(
    p_user_id UUID,
    p_date DATE DEFAULT CURRENT_DATE
)
RETURNS SETOF public.scriptures
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT s.*
    FROM public.scriptures s
    INNER JOIN public.user_scripture_history h ON s.id = h.scripture_id
    WHERE h.user_id = p_user_id
        AND h.viewed_date = p_date
    ORDER BY h.viewed_at;
END;
$$;

COMMENT ON FUNCTION public.get_scripture_history IS 'Get scriptures viewed by a user on a specific date.';

-- ============================================
-- 6. Grant execute permissions
-- ============================================
-- Allow authenticated users to call these functions
GRANT EXECUTE ON FUNCTION public.get_random_scripture TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_daily_scriptures TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_premium_scriptures TO authenticated;
GRANT EXECUTE ON FUNCTION public.record_scripture_view TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_scripture_history TO authenticated;
