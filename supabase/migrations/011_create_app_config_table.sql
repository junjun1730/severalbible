-- Migration: Create app_config table for feature flags
-- Description: Centralized configuration table for global app settings
-- Date: 2026-02-23

-- ============================================
-- 1. Create app_config table
-- ============================================
CREATE TABLE IF NOT EXISTS public.app_config (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add comments
COMMENT ON TABLE public.app_config IS 'Global app configuration and feature flags';
COMMENT ON COLUMN public.app_config.key IS 'Configuration key (e.g., is_free_mode)';
COMMENT ON COLUMN public.app_config.value IS 'JSONB value (boolean, string, object)';
COMMENT ON COLUMN public.app_config.description IS 'Human-readable description of the config';
COMMENT ON COLUMN public.app_config.updated_at IS 'Last update timestamp';

-- ============================================
-- 2. Enable Row Level Security (RLS)
-- ============================================
ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read (including anon/guest users)
CREATE POLICY "Anyone can read app_config"
    ON public.app_config FOR SELECT
    TO authenticated, anon
    USING (true);

-- Policy: Only service role can modify (admin only)
-- No policy needed - service_role bypasses RLS

-- ============================================
-- 3. Insert default value (paid mode)
-- ============================================
INSERT INTO public.app_config (key, value, description)
VALUES (
    'is_free_mode',
    'false'::jsonb,
    'Global feature flag: true = all logged-in users get Premium features, false = respect original tier system'
)
ON CONFLICT (key) DO NOTHING;

-- ============================================
-- 4. Create index and trigger
-- ============================================
CREATE INDEX IF NOT EXISTS idx_app_config_key ON public.app_config(key);

-- Create trigger for updated_at (reuse existing function)
DROP TRIGGER IF EXISTS update_app_config_updated_at ON public.app_config;
CREATE TRIGGER update_app_config_updated_at
    BEFORE UPDATE ON public.app_config
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();
