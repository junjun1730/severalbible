-- Migration: Create user_profiles table
-- Description: Creates the user_profiles table with tier management for One Message app
-- Date: 2026-01-14

-- ============================================
-- 1. Create user_profiles table
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    tier TEXT NOT NULL DEFAULT 'member' CHECK (tier IN ('guest', 'member', 'premium')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add comment to table
COMMENT ON TABLE public.user_profiles IS 'User profile information including subscription tier';
COMMENT ON COLUMN public.user_profiles.tier IS 'User subscription tier: guest, member, or premium';

-- ============================================
-- 2. Enable Row Level Security (RLS)
-- ============================================
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 3. Create RLS Policies
-- ============================================

-- Policy: Users can view their own profile
CREATE POLICY "Users can view own profile"
    ON public.user_profiles
    FOR SELECT
    USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON public.user_profiles
    FOR UPDATE
    USING (auth.uid() = id);

-- Policy: Users can insert their own profile (for edge cases)
CREATE POLICY "Users can insert own profile"
    ON public.user_profiles
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ============================================
-- 4. Create trigger for auto-creating profile
-- ============================================

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, tier)
    VALUES (NEW.id, 'member')
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger: Auto-create profile when user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 5. Create updated_at trigger
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Update updated_at on row update
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON public.user_profiles;
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 6. Create indexes for performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_user_profiles_tier ON public.user_profiles(tier);
