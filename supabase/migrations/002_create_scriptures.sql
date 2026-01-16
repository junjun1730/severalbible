-- Migration: Create scriptures table
-- Description: Creates the scriptures table for storing daily scripture content
-- Date: 2026-01-16
-- Phase: 2-1 (Scripture Delivery System)

-- ============================================
-- 1. Create scriptures table
-- ============================================
CREATE TABLE IF NOT EXISTS public.scriptures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    book TEXT NOT NULL,
    chapter INTEGER NOT NULL CHECK (chapter > 0),
    verse INTEGER NOT NULL CHECK (verse > 0),
    content TEXT NOT NULL,
    reference TEXT NOT NULL,  -- e.g., "John 3:16"
    is_premium BOOLEAN DEFAULT FALSE,
    category TEXT,  -- e.g., "wisdom", "hope", "faith", "comfort", "strength"
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add comments
COMMENT ON TABLE public.scriptures IS 'Scripture content for daily delivery';
COMMENT ON COLUMN public.scriptures.book IS 'Book name of the Bible (e.g., John, Psalms)';
COMMENT ON COLUMN public.scriptures.chapter IS 'Chapter number';
COMMENT ON COLUMN public.scriptures.verse IS 'Verse number';
COMMENT ON COLUMN public.scriptures.content IS 'Full scripture text content';
COMMENT ON COLUMN public.scriptures.reference IS 'Formatted reference string (e.g., John 3:16)';
COMMENT ON COLUMN public.scriptures.is_premium IS 'Premium-only content flag';
COMMENT ON COLUMN public.scriptures.category IS 'Content category for filtering';

-- ============================================
-- 2. Enable Row Level Security (RLS)
-- ============================================
ALTER TABLE public.scriptures ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 3. Create RLS Policies
-- ============================================

-- Policy: Anyone can view non-premium scriptures (including guests)
CREATE POLICY "Anyone can view non-premium scriptures"
    ON public.scriptures
    FOR SELECT
    USING (is_premium = FALSE);

-- Policy: Authenticated users can view premium scriptures
-- Note: Premium tier check will be done at RPC level for better control
CREATE POLICY "Authenticated users can view premium scriptures"
    ON public.scriptures
    FOR SELECT
    USING (auth.uid() IS NOT NULL AND is_premium = TRUE);

-- ============================================
-- 4. Create indexes for performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_scriptures_is_premium ON public.scriptures(is_premium);
CREATE INDEX IF NOT EXISTS idx_scriptures_category ON public.scriptures(category);
CREATE INDEX IF NOT EXISTS idx_scriptures_book ON public.scriptures(book);

-- ============================================
-- 5. Create updated_at trigger
-- ============================================
DROP TRIGGER IF EXISTS update_scriptures_updated_at ON public.scriptures;
CREATE TRIGGER update_scriptures_updated_at
    BEFORE UPDATE ON public.scriptures
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();
