-- Migration: Create prayer_notes table
-- Description: Prayer notes for user meditations with tier-based access control
-- Date: 2026-01-18
-- Phase: 3-1 (Prayer Note System)

-- ============================================
-- 1. Create prayer_notes table
-- ============================================
CREATE TABLE IF NOT EXISTS public.prayer_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    scripture_id UUID REFERENCES public.scriptures(id) ON DELETE SET NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_date DATE DEFAULT CURRENT_DATE  -- For indexing and date-based queries
);

-- Add comments
COMMENT ON TABLE public.prayer_notes IS 'User prayer notes and meditations linked to scriptures';
COMMENT ON COLUMN public.prayer_notes.user_id IS 'Reference to the user who created the note';
COMMENT ON COLUMN public.prayer_notes.scripture_id IS 'Optional reference to the related scripture';
COMMENT ON COLUMN public.prayer_notes.content IS 'The prayer note content written by the user';
COMMENT ON COLUMN public.prayer_notes.created_date IS 'Date column for efficient date-based queries';

-- ============================================
-- 2. Enable Row Level Security (RLS)
-- ============================================
ALTER TABLE public.prayer_notes ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 3. Create RLS Policies
-- ============================================

-- Helper function: Get user tier
CREATE OR REPLACE FUNCTION public.get_user_tier(p_user_id UUID)
RETURNS TEXT AS $$
DECLARE
    v_tier TEXT;
BEGIN
    SELECT tier INTO v_tier
    FROM public.user_profiles
    WHERE id = p_user_id;

    RETURN COALESCE(v_tier, 'guest');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Policy: Users can insert their own notes (authenticated only)
CREATE POLICY "Authenticated users can create notes"
    ON public.prayer_notes
    FOR INSERT
    WITH CHECK (
        auth.uid() IS NOT NULL
        AND auth.uid() = user_id
    );

-- Policy: Users can view their own notes (tier-based)
-- Premium: All notes
-- Member: Last 3 days only
CREATE POLICY "Users can view own notes based on tier"
    ON public.prayer_notes
    FOR SELECT
    USING (
        auth.uid() = user_id
        AND (
            -- Premium users can view all
            public.get_user_tier(auth.uid()) = 'premium'
            OR
            -- Member users can view last 3 days
            (
                public.get_user_tier(auth.uid()) = 'member'
                AND created_at >= NOW() - INTERVAL '3 days'
            )
        )
    );

-- Policy: Users can update their own notes (tier-based)
CREATE POLICY "Users can update own notes based on tier"
    ON public.prayer_notes
    FOR UPDATE
    USING (
        auth.uid() = user_id
        AND (
            -- Premium users can update all
            public.get_user_tier(auth.uid()) = 'premium'
            OR
            -- Member users can update last 3 days
            (
                public.get_user_tier(auth.uid()) = 'member'
                AND created_at >= NOW() - INTERVAL '3 days'
            )
        )
    );

-- Policy: Users can delete their own notes (tier-based)
CREATE POLICY "Users can delete own notes based on tier"
    ON public.prayer_notes
    FOR DELETE
    USING (
        auth.uid() = user_id
        AND (
            -- Premium users can delete all
            public.get_user_tier(auth.uid()) = 'premium'
            OR
            -- Member users can delete last 3 days
            (
                public.get_user_tier(auth.uid()) = 'member'
                AND created_at >= NOW() - INTERVAL '3 days'
            )
        )
    );

-- ============================================
-- 4. Create updated_at trigger
-- ============================================
-- Reuse existing function if available, otherwise create
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Update updated_at on row update
DROP TRIGGER IF EXISTS update_prayer_notes_updated_at ON public.prayer_notes;
CREATE TRIGGER update_prayer_notes_updated_at
    BEFORE UPDATE ON public.prayer_notes
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 5. Create indexes for performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_prayer_notes_user_id
    ON public.prayer_notes(user_id);

CREATE INDEX IF NOT EXISTS idx_prayer_notes_scripture_id
    ON public.prayer_notes(scripture_id);

CREATE INDEX IF NOT EXISTS idx_prayer_notes_created_at
    ON public.prayer_notes(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_prayer_notes_created_date
    ON public.prayer_notes(created_date DESC);

CREATE INDEX IF NOT EXISTS idx_prayer_notes_user_date
    ON public.prayer_notes(user_id, created_date DESC);

-- Composite index for tier-based queries
CREATE INDEX IF NOT EXISTS idx_prayer_notes_user_created_at
    ON public.prayer_notes(user_id, created_at DESC);
