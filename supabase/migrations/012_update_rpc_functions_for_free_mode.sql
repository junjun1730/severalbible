-- Migration: Update RPC functions to support free mode
-- Description: Enhances get_user_tier to respect is_free_mode flag
-- Date: 2026-02-23

-- ============================================
-- 1. Enhanced get_user_tier with free mode
-- ============================================
CREATE OR REPLACE FUNCTION public.get_user_tier(p_user_id UUID)
RETURNS TEXT AS $$
DECLARE
    v_tier TEXT;
    v_is_free_mode BOOLEAN;
BEGIN
    -- Get actual tier from user_profiles
    SELECT tier INTO v_tier
    FROM public.user_profiles
    WHERE id = p_user_id;

    v_tier := COALESCE(v_tier, 'guest');

    -- Check if free mode is enabled
    SELECT (value::text)::boolean INTO v_is_free_mode
    FROM public.app_config
    WHERE key = 'is_free_mode';

    v_is_free_mode := COALESCE(v_is_free_mode, false);

    -- Free mode logic: if ON and user is member, return premium
    IF v_is_free_mode AND v_tier = 'member' THEN
        RETURN 'premium';
    END IF;

    RETURN v_tier;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

COMMENT ON FUNCTION public.get_user_tier(UUID) IS
'Returns effective user tier with free mode support.
 In free mode: member → premium, others unchanged.
 In paid mode: returns actual tier.';
