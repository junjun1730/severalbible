-- Migration: Update member prayer note access to today only
-- Description: Change member tier prayer note access from last 3 days to today only
-- Date: 2026-02-13
-- Phase: Tier Redesign

-- ============================================
-- 1. RPC: get_prayer_notes (member: today only)
-- ============================================
CREATE OR REPLACE FUNCTION public.get_prayer_notes(
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    scripture_id UUID,
    content TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    created_date DATE,
    scripture_reference TEXT,
    scripture_content TEXT,
    scripture_book TEXT,
    scripture_chapter INTEGER,
    scripture_verse INTEGER
) AS $$
DECLARE
    v_user_id UUID;
    v_user_tier TEXT;
    v_min_date TIMESTAMPTZ;
BEGIN
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required';
    END IF;

    v_user_tier := public.get_user_tier(v_user_id);

    IF v_user_tier = 'guest' THEN
        RAISE EXCEPTION 'Guests cannot view prayer notes. Please sign up.';
    ELSIF v_user_tier = 'member' THEN
        -- Members can only see today's notes
        v_min_date := CURRENT_DATE::TIMESTAMPTZ;
    ELSE
        -- Premium can see all
        v_min_date := '-infinity'::TIMESTAMPTZ;
    END IF;

    RETURN QUERY
    SELECT
        pn.id,
        pn.user_id,
        pn.scripture_id,
        pn.content,
        pn.created_at,
        pn.updated_at,
        pn.created_date,
        s.reference AS scripture_reference,
        s.content AS scripture_content,
        s.book AS scripture_book,
        s.chapter AS scripture_chapter,
        s.verse AS scripture_verse
    FROM public.prayer_notes pn
    LEFT JOIN public.scriptures s ON pn.scripture_id = s.id
    WHERE pn.user_id = v_user_id
        AND pn.created_at >= v_min_date
        AND (p_start_date IS NULL OR pn.created_date >= p_start_date)
        AND (p_end_date IS NULL OR pn.created_date <= p_end_date)
    ORDER BY pn.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ============================================
-- 2. RPC: get_prayer_notes_by_date (member: today only)
-- ============================================
CREATE OR REPLACE FUNCTION public.get_prayer_notes_by_date(
    p_date DATE
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    scripture_id UUID,
    content TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    created_date DATE,
    scripture_reference TEXT,
    scripture_content TEXT,
    scripture_book TEXT,
    scripture_chapter INTEGER,
    scripture_verse INTEGER
) AS $$
DECLARE
    v_user_id UUID;
    v_user_tier TEXT;
    v_min_date DATE;
BEGIN
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required';
    END IF;

    v_user_tier := public.get_user_tier(v_user_id);

    IF v_user_tier = 'guest' THEN
        RAISE EXCEPTION 'Guests cannot view prayer notes. Please sign up.';
    ELSIF v_user_tier = 'member' THEN
        -- Members can only see today's notes
        v_min_date := CURRENT_DATE;
        IF p_date < v_min_date THEN
            RAISE EXCEPTION 'Members can only view today''s notes. Upgrade to Premium for full access.';
        END IF;
    END IF;
    -- Premium can access any date

    RETURN QUERY
    SELECT
        pn.id,
        pn.user_id,
        pn.scripture_id,
        pn.content,
        pn.created_at,
        pn.updated_at,
        pn.created_date,
        s.reference AS scripture_reference,
        s.content AS scripture_content,
        s.book AS scripture_book,
        s.chapter AS scripture_chapter,
        s.verse AS scripture_verse
    FROM public.prayer_notes pn
    LEFT JOIN public.scriptures s ON pn.scripture_id = s.id
    WHERE pn.user_id = v_user_id
        AND pn.created_date = p_date
    ORDER BY pn.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ============================================
-- 3. RPC: is_date_accessible (member: today only)
-- ============================================
CREATE OR REPLACE FUNCTION public.is_date_accessible(
    p_date DATE
)
RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
    v_user_tier TEXT;
    v_min_date DATE;
BEGIN
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        RETURN FALSE;
    END IF;

    v_user_tier := public.get_user_tier(v_user_id);

    IF v_user_tier = 'guest' THEN
        RETURN FALSE;
    ELSIF v_user_tier = 'premium' THEN
        RETURN TRUE;
    ELSE
        -- Member: today only
        v_min_date := CURRENT_DATE;
        RETURN p_date >= v_min_date;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ============================================
-- 4. RPC: get_notes_count_by_date_range (member: today only)
-- ============================================
CREATE OR REPLACE FUNCTION public.get_notes_count_by_date_range(
    p_start_date DATE,
    p_end_date DATE
)
RETURNS TABLE (
    note_date DATE,
    note_count BIGINT,
    is_accessible BOOLEAN
) AS $$
DECLARE
    v_user_id UUID;
    v_user_tier TEXT;
    v_min_date DATE;
BEGIN
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required';
    END IF;

    v_user_tier := public.get_user_tier(v_user_id);

    IF v_user_tier = 'guest' THEN
        RAISE EXCEPTION 'Guests cannot view prayer notes';
    ELSIF v_user_tier = 'member' THEN
        -- Member: today only
        v_min_date := CURRENT_DATE;
    ELSE
        v_min_date := '-infinity'::DATE;
    END IF;

    RETURN QUERY
    SELECT
        pn.created_date AS note_date,
        COUNT(*)::BIGINT AS note_count,
        (pn.created_date >= v_min_date) AS is_accessible
    FROM public.prayer_notes pn
    WHERE pn.user_id = v_user_id
        AND pn.created_date >= p_start_date
        AND pn.created_date <= p_end_date
    GROUP BY pn.created_date
    ORDER BY pn.created_date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ============================================
-- 5. RPC: update_prayer_note (member: today only)
-- ============================================
CREATE OR REPLACE FUNCTION public.update_prayer_note(
    p_note_id UUID,
    p_content TEXT
)
RETURNS public.prayer_notes AS $$
DECLARE
    v_user_id UUID;
    v_user_tier TEXT;
    v_note public.prayer_notes;
    v_min_date TIMESTAMPTZ;
BEGIN
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required';
    END IF;

    IF p_content IS NULL OR TRIM(p_content) = '' THEN
        RAISE EXCEPTION 'Content cannot be empty';
    END IF;

    SELECT * INTO v_note
    FROM public.prayer_notes
    WHERE id = p_note_id;

    IF v_note IS NULL THEN
        RAISE EXCEPTION 'Prayer note not found';
    END IF;

    IF v_note.user_id != v_user_id THEN
        RAISE EXCEPTION 'You can only update your own notes';
    END IF;

    v_user_tier := public.get_user_tier(v_user_id);

    IF v_user_tier = 'guest' THEN
        RAISE EXCEPTION 'Guests cannot update prayer notes';
    ELSIF v_user_tier = 'member' THEN
        -- Members can only update today's notes
        v_min_date := CURRENT_DATE::TIMESTAMPTZ;
        IF v_note.created_at < v_min_date THEN
            RAISE EXCEPTION 'Members can only update today''s notes. Upgrade to Premium.';
        END IF;
    END IF;
    -- Premium can update any note

    UPDATE public.prayer_notes
    SET content = TRIM(p_content),
        updated_at = NOW()
    WHERE id = p_note_id
    RETURNING * INTO v_note;

    RETURN v_note;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 6. RPC: delete_prayer_note (member: today only)
-- ============================================
CREATE OR REPLACE FUNCTION public.delete_prayer_note(
    p_note_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_user_id UUID;
    v_user_tier TEXT;
    v_note public.prayer_notes;
    v_min_date TIMESTAMPTZ;
BEGIN
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required';
    END IF;

    SELECT * INTO v_note
    FROM public.prayer_notes
    WHERE id = p_note_id;

    IF v_note IS NULL THEN
        RAISE EXCEPTION 'Prayer note not found';
    END IF;

    IF v_note.user_id != v_user_id THEN
        RAISE EXCEPTION 'You can only delete your own notes';
    END IF;

    v_user_tier := public.get_user_tier(v_user_id);

    IF v_user_tier = 'guest' THEN
        RAISE EXCEPTION 'Guests cannot delete prayer notes';
    ELSIF v_user_tier = 'member' THEN
        -- Members can only delete today's notes
        v_min_date := CURRENT_DATE::TIMESTAMPTZ;
        IF v_note.created_at < v_min_date THEN
            RAISE EXCEPTION 'Members can only delete today''s notes. Upgrade to Premium.';
        END IF;
    END IF;
    -- Premium can delete any note

    DELETE FROM public.prayer_notes
    WHERE id = p_note_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
