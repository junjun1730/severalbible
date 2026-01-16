-- Migration: Create user_scripture_history table
-- Description: Tracks which scriptures users have viewed for no-duplicate logic
-- Date: 2026-01-16
-- Phase: 2-1 (Scripture Delivery System)

-- ============================================
-- 1. Create user_scripture_history table
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_scripture_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    scripture_id UUID NOT NULL REFERENCES public.scriptures(id) ON DELETE CASCADE,
    viewed_at TIMESTAMPTZ DEFAULT NOW(),
    viewed_date DATE DEFAULT CURRENT_DATE  -- Separate date column for indexing
);

-- Add unique constraint to prevent duplicate entries for same day
-- Using dedicated date column avoids IMMUTABLE function requirement
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_user_scripture_date
    ON public.user_scripture_history(user_id, scripture_id, viewed_date);

-- Add comments
COMMENT ON TABLE public.user_scripture_history IS 'Tracks user scripture viewing history for no-duplicate logic';
COMMENT ON COLUMN public.user_scripture_history.user_id IS 'Reference to the user who viewed the scripture';
COMMENT ON COLUMN public.user_scripture_history.scripture_id IS 'Reference to the viewed scripture';
COMMENT ON COLUMN public.user_scripture_history.viewed_at IS 'Timestamp when the scripture was viewed';

-- ============================================
-- 2. Enable Row Level Security (RLS)
-- ============================================
ALTER TABLE public.user_scripture_history ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 3. Create RLS Policies
-- ============================================

-- Policy: Users can view their own history
CREATE POLICY "Users can view own scripture history"
    ON public.user_scripture_history
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can insert their own history
CREATE POLICY "Users can insert own scripture history"
    ON public.user_scripture_history
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own history (optional cleanup)
CREATE POLICY "Users can delete own scripture history"
    ON public.user_scripture_history
    FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- 4. Create indexes for performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_user_scripture_history_user_id
    ON public.user_scripture_history(user_id);

CREATE INDEX IF NOT EXISTS idx_user_scripture_history_scripture_id
    ON public.user_scripture_history(scripture_id);

CREATE INDEX IF NOT EXISTS idx_user_scripture_history_viewed_at
    ON public.user_scripture_history(viewed_at);

CREATE INDEX IF NOT EXISTS idx_user_scripture_history_user_date
    ON public.user_scripture_history(user_id, viewed_date);
