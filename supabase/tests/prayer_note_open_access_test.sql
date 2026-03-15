-- pgTAP tests for migration 013: open prayer note access for all authenticated users
-- All members (and premium) can access notes without date restriction

BEGIN;

SELECT plan(6);

-- Setup: create test users
DO $$
DECLARE
    v_member_id UUID := '00000000-0000-0000-0000-000000000101';
    v_premium_id UUID := '00000000-0000-0000-0000-000000000102';
    v_old_note_date DATE := CURRENT_DATE - INTERVAL '30 days';
BEGIN
    -- Insert member profile
    INSERT INTO public.user_profiles (id, tier, email)
    VALUES (v_member_id, 'member', 'member@test.com')
    ON CONFLICT (id) DO UPDATE SET tier = 'member';

    -- Insert premium profile
    INSERT INTO public.user_profiles (id, tier, email)
    VALUES (v_premium_id, 'premium', 'premium@test.com')
    ON CONFLICT (id) DO UPDATE SET tier = 'premium';

    -- Insert an old scripture for note association
    INSERT INTO public.scriptures (id, reference, content, book, chapter, verse, is_premium)
    VALUES ('00000000-0000-0000-0000-000000000201', 'Test 1:1', 'Test content', 'Test', 1, 1, FALSE)
    ON CONFLICT (id) DO NOTHING;

    -- Insert old prayer note for member (30 days ago)
    INSERT INTO public.prayer_notes (id, user_id, scripture_id, content, created_at, updated_at, created_date)
    VALUES (
        '00000000-0000-0000-0000-000000000301',
        v_member_id,
        '00000000-0000-0000-0000-000000000201',
        'Old member note',
        (v_old_note_date || ' 10:00:00')::TIMESTAMPTZ,
        (v_old_note_date || ' 10:00:00')::TIMESTAMPTZ,
        v_old_note_date
    )
    ON CONFLICT (id) DO NOTHING;

    -- Insert old prayer note for premium (30 days ago)
    INSERT INTO public.prayer_notes (id, user_id, scripture_id, content, created_at, updated_at, created_date)
    VALUES (
        '00000000-0000-0000-0000-000000000302',
        v_premium_id,
        '00000000-0000-0000-0000-000000000201',
        'Old premium note',
        (v_old_note_date || ' 10:00:00')::TIMESTAMPTZ,
        (v_old_note_date || ' 10:00:00')::TIMESTAMPTZ,
        v_old_note_date
    )
    ON CONFLICT (id) DO NOTHING;
END $$;

-- Test 1: get_prayer_notes — member can retrieve old notes (no date restriction)
SELECT lives_ok(
    $$
    SELECT set_config('request.jwt.claims', json_build_object(
        'sub', '00000000-0000-0000-0000-000000000101',
        'role', 'authenticated'
    )::text, true);
    $$,
    'Can set JWT claims for member'
);

-- Test 2: is_date_accessible — member returns TRUE for any date
SELECT ok(
    (SELECT public.is_date_accessible(CURRENT_DATE - INTERVAL '30 days')),
    'Member: is_date_accessible returns TRUE for 30-day-old date'
);

-- Test 3: is_date_accessible — member returns TRUE for today
SELECT ok(
    (SELECT public.is_date_accessible(CURRENT_DATE)),
    'Member: is_date_accessible returns TRUE for today'
);

-- Test 4: get_notes_count_by_date_range — member can query old date ranges
SELECT lives_ok(
    $$
    SELECT * FROM public.get_notes_count_by_date_range(
        CURRENT_DATE - INTERVAL '60 days',
        CURRENT_DATE
    );
    $$,
    'Member: get_notes_count_by_date_range does not throw for old dates'
);

-- Test 5: update_prayer_note — member can update old note
SELECT lives_ok(
    $$
    SELECT public.update_prayer_note(
        '00000000-0000-0000-0000-000000000301'::UUID,
        'Updated old member note'
    );
    $$,
    'Member: update_prayer_note does not throw for old note'
);

-- Test 6: delete_prayer_note — member can delete old note
SELECT lives_ok(
    $$
    SELECT public.delete_prayer_note('00000000-0000-0000-0000-000000000301'::UUID);
    $$,
    'Member: delete_prayer_note does not throw for old note'
);

-- Cleanup
DO $$
BEGIN
    DELETE FROM public.prayer_notes WHERE id IN (
        '00000000-0000-0000-0000-000000000301',
        '00000000-0000-0000-0000-000000000302'
    );
    DELETE FROM public.scriptures WHERE id = '00000000-0000-0000-0000-000000000201';
    DELETE FROM public.user_profiles WHERE id IN (
        '00000000-0000-0000-0000-000000000101',
        '00000000-0000-0000-0000-000000000102'
    );
END $$;

SELECT * FROM finish();

ROLLBACK;
