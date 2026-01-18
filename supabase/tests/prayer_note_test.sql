-- pgTAP tests for Prayer Note System
-- Phase 3-1: Database & RLS
-- Run with: supabase test db

BEGIN;

-- Plan the number of tests
SELECT plan(19);

-- ============================================
-- Setup: Create test users and data
-- ============================================

-- Create test users in auth.users (will trigger profile creation)
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

-- Get a scripture ID for testing
DO $$
DECLARE
    v_scripture_id UUID;
BEGIN
    SELECT id INTO v_scripture_id FROM public.scriptures LIMIT 1;
    IF v_scripture_id IS NULL THEN
        -- Insert a test scripture if none exists
        INSERT INTO public.scriptures (id, book, chapter, verse, content, reference, is_premium)
        VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'John', 3, 16, 'For God so loved...', 'John 3:16', false);
    END IF;
END $$;

-- ============================================
-- Test 1-3: Table Structure
-- ============================================

SELECT has_table('public', 'prayer_notes', 'prayer_notes table should exist');

SELECT has_column('public', 'prayer_notes', 'id', 'prayer_notes should have id column');
SELECT has_column('public', 'prayer_notes', 'user_id', 'prayer_notes should have user_id column');
SELECT has_column('public', 'prayer_notes', 'scripture_id', 'prayer_notes should have scripture_id column');
SELECT has_column('public', 'prayer_notes', 'content', 'prayer_notes should have content column');
SELECT has_column('public', 'prayer_notes', 'created_at', 'prayer_notes should have created_at column');

-- ============================================
-- Test 4-6: RLS is enabled
-- ============================================

SELECT row_security_active('public.prayer_notes');

-- ============================================
-- Test 7-8: get_user_tier function
-- ============================================

SELECT is(
    public.get_user_tier('22222222-2222-2222-2222-222222222222'),
    'member',
    'get_user_tier should return member for member user'
);

SELECT is(
    public.get_user_tier('33333333-3333-3333-3333-333333333333'),
    'premium',
    'get_user_tier should return premium for premium user'
);

-- ============================================
-- Test 9-11: create_prayer_note RPC
-- ============================================

-- Set session as member user
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" TO '{"sub": "22222222-2222-2222-2222-222222222222"}';

SELECT lives_ok(
    $$ SELECT public.create_prayer_note('Test prayer note content') $$,
    'Member should be able to create prayer note'
);

SELECT lives_ok(
    $$ SELECT public.create_prayer_note('Note with scripture', (SELECT id FROM public.scriptures LIMIT 1)) $$,
    'Member should be able to create prayer note with scripture reference'
);

-- Test empty content validation
SELECT throws_ok(
    $$ SELECT public.create_prayer_note('') $$,
    'Content cannot be empty',
    'Should reject empty content'
);

-- ============================================
-- Test 12-13: get_prayer_notes RPC
-- ============================================

SELECT lives_ok(
    $$ SELECT * FROM public.get_prayer_notes() $$,
    'Member should be able to get prayer notes'
);

SELECT lives_ok(
    $$ SELECT * FROM public.get_prayer_notes(CURRENT_DATE - 2, CURRENT_DATE) $$,
    'Member should be able to get prayer notes with date range'
);

-- ============================================
-- Test 14-15: is_date_accessible RPC
-- ============================================

SELECT is(
    public.is_date_accessible(CURRENT_DATE),
    TRUE,
    'Today should be accessible for member'
);

SELECT is(
    public.is_date_accessible(CURRENT_DATE - 10),
    FALSE,
    '10 days ago should NOT be accessible for member'
);

-- ============================================
-- Test 16-17: Premium user access
-- ============================================

-- Switch to premium user
SET LOCAL "request.jwt.claims" TO '{"sub": "33333333-3333-3333-3333-333333333333"}';

SELECT is(
    public.is_date_accessible(CURRENT_DATE - 30),
    TRUE,
    '30 days ago should be accessible for premium'
);

SELECT lives_ok(
    $$ SELECT public.create_prayer_note('Premium user note') $$,
    'Premium should be able to create prayer note'
);

-- ============================================
-- Test 18-20: Guest restrictions
-- ============================================

-- Switch to guest user
SET LOCAL "request.jwt.claims" TO '{"sub": "11111111-1111-1111-1111-111111111111"}';

SELECT is(
    public.is_date_accessible(CURRENT_DATE),
    FALSE,
    'Guest should not have date access'
);

SELECT throws_ok(
    $$ SELECT public.create_prayer_note('Guest note') $$,
    'Guests cannot create prayer notes. Please sign up.',
    'Guest should not be able to create notes'
);

-- ============================================
-- Cleanup
-- ============================================

-- Reset role
RESET ROLE;

-- Finish tests
SELECT * FROM finish();

ROLLBACK;
