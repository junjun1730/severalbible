### 기술 스택

**Frontend (Mobile)**:

```yaml
name: one_message
description: Daily spiritual content app

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0 # or flutter_bloc: ^8.1.0

  # Supabase
  supabase_flutter: ^2.0.0

  # UI
  table_calendar: ^3.0.9
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0

  # Navigation
  go_router: ^12.0.0

  # Payment
  in_app_purchase: ^3.1.0
  # or purchases_flutter: ^6.0.0  (RevenueCat)

  # Utilities
  intl: ^0.18.1
  shared_preferences: ^2.2.2
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  flutter_lints: ^3.0.0
  freezed: ^2.4.7
  json_serializable: ^6.7.1
```

**Backend (Supabase)**:

- **Database**: PostgreSQL 15+
- **Auth**: Supabase Auth (OAuth + Email)
- **Storage**: Supabase Storage (미디어 파일, 향후 확장용)
- **Edge Functions**: Deno (TypeScript)
- **Realtime**: Supabase Realtime Subscriptions

### 아키텍처 패턴

**Clean Architecture + Repository Pattern**

**상태 관리**:

- **Option 1**: Riverpod (권장)
  - 간결한 문법
  - 자동 dispose
  - 테스트 용이
- **Option 2**: BLoC
  - 명확한 Event-State 패턴
  - 복잡한 상태 관리에 유리

### Supabase 데이터베이스 스키마

```sql
-- Users (Supabase Auth 자동 생성, 확장용 테이블)
CREATE TABLE public.user_profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  tier TEXT NOT NULL DEFAULT 'guest' CHECK (tier IN ('guest', 'member', 'premium')),
  subscription_expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Scriptures (경전 콘텐츠)
CREATE TABLE public.scriptures (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  source TEXT NOT NULL,
  category TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Scripture History (읽은 기록)
CREATE TABLE public.user_scripture_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  scripture_id UUID REFERENCES public.scriptures NOT NULL,
  read_at TIMESTAMPTZ DEFAULT NOW(),
  tier_at_read_time TEXT NOT NULL,
  UNIQUE(user_id, scripture_id)
);

-- Prayer Notes (기도 노트)
CREATE TABLE public.prayer_notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  scripture_id UUID REFERENCES public.scriptures,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_user_scripture_history_user_id ON public.user_scripture_history(user_id);
CREATE INDEX idx_prayer_notes_user_id ON public.prayer_notes(user_id);
CREATE INDEX idx_prayer_notes_created_at ON public.prayer_notes(created_at);
```

### Row Level Security (RLS) 정책

```sql
-- user_profiles: 본인 것만 조회/수정
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON public.user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.user_profiles FOR UPDATE
  USING (auth.uid() = id);

-- scriptures: 모두 읽기 가능
ALTER TABLE public.scriptures ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read scriptures"
  ON public.scriptures FOR SELECT
  USING (true);

-- user_scripture_history: 본인 기록만 CRUD
ALTER TABLE public.user_scripture_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own history"
  ON public.user_scripture_history FOR ALL
  USING (auth.uid() = user_id);

-- prayer_notes: 본인 기록만 CRUD + Tier별 조회 제한
ALTER TABLE public.prayer_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own notes"
  ON public.prayer_notes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own notes"
  ON public.prayer_notes FOR SELECT
  USING (
    auth.uid() = user_id AND (
      -- Premium: 모든 기록 조회
      (SELECT tier FROM public.user_profiles WHERE id = auth.uid()) = 'premium'
      OR
      -- Member: 최근 3일만 조회
      (
        (SELECT tier FROM public.user_profiles WHERE id = auth.uid()) = 'member'
        AND created_at >= NOW() - INTERVAL '3 days'
      )
    )
  );

CREATE POLICY "Users can update own notes"
  ON public.prayer_notes FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own notes"
  ON public.prayer_notes FOR DELETE
  USING (auth.uid() = user_id);
```

### Supabase RPC 함수

```sql
-- 랜덤 경전 가져오기 (Guest용)
CREATE OR REPLACE FUNCTION get_random_scripture(limit_count INT)
RETURNS SETOF scriptures
LANGUAGE sql
AS $$
  SELECT * FROM scriptures
  WHERE is_premium = FALSE
  ORDER BY RANDOM()
  LIMIT limit_count;
$$;

-- 중복 방지 경전 가져오기 (Member용)
CREATE OR REPLACE FUNCTION get_daily_scriptures(
  p_user_id UUID,
  limit_count INT
)
RETURNS SETOF scriptures
LANGUAGE sql
AS $$
  SELECT s.* FROM scriptures s
  WHERE s.is_premium = FALSE
    AND s.id NOT IN (
      SELECT scripture_id
      FROM user_scripture_history
      WHERE user_id = p_user_id
    )
  ORDER BY RANDOM()
  LIMIT limit_count;
$$;

-- 프리미엄 경전 가져오기 (Premium용)
CREATE OR REPLACE FUNCTION get_premium_scriptures(
  p_user_id UUID,
  limit_count INT
)
RETURNS SETOF scriptures
LANGUAGE sql
AS $$
  SELECT s.* FROM scriptures s
  WHERE s.is_premium = TRUE
    AND s.id NOT IN (
      SELECT scripture_id
      FROM user_scripture_history
      WHERE user_id = p_user_id
    )
  ORDER BY RANDOM()
  LIMIT limit_count;
$$;
```

### Supabase Edge Function (자동 삭제)

```typescript
// supabase/functions/delete-old-prayer-notes/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
  );

  // Member 회원의 7일 이전 기록 삭제
  const { data, error } = await supabaseClient
    .from("prayer_notes")
    .delete()
    .lt(
      "created_at",
      new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString()
    )
    .in(
      "user_id",
      supabaseClient.from("user_profiles").select("id").eq("tier", "member")
    );

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  return new Response(JSON.stringify({ deleted: data }), {
    headers: { "Content-Type": "application/json" },
  });
});
```
