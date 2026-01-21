### 기술 스택

**프론트엔드 (모바일)**:

```yaml
name: one_message
description: 매일 영적인 콘텐츠를 제공하는 앱

dependencies:
  flutter:
    sdk: flutter

  # 상태 관리
  flutter_riverpod: ^2.4.0 # 또는 flutter_bloc: ^8.1.0

  # Supabase
  supabase_flutter: ^2.0.0

  # UI
  table_calendar: ^3.0.9
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0

  # 네비게이션
  go_router: ^12.0.0

  # 결제
  in_app_purchase: ^3.1.0
  # 또는 purchases_flutter: ^6.0.0  (RevenueCat)

  # 유틸리티
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

**백엔드 (Supabase)**:

- **데이터베이스**: PostgreSQL 15+
- **인증**: Supabase Auth (OAuth + 이메일)
- **스토리지**: Supabase Storage (미디어 파일, 향후 확장용)
- **엣지 함수**: Deno (TypeScript)
- **실시간**: Supabase Realtime Subscriptions

### 아키텍처 패턴

**클린 아키텍처 + 리포지토리 패턴**

**상태 관리**:

- **옵션 1**: Riverpod (권장)
  - 간결한 구문
  - 자동 메모리 해제
  - 쉬운 테스트
- **옵션 2**: BLoC
  - 명확한 Event-State 패턴
  - 복잡한 상태 관리에 유리

### Supabase 데이터베이스 스키마

```sql
-- 사용자 (Supabase Auth에 의해 자동 생성, 확장을 위한 테이블)
CREATE TABLE public.user_profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  tier TEXT NOT NULL DEFAULT 'guest' CHECK (tier IN ('guest', 'member', 'premium')),
  subscription_expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 성경 구절 (성경 콘텐츠)
CREATE TABLE public.scriptures (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  source TEXT NOT NULL,
  category TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 사용자 성경 읽기 기록 (읽기 기록)
CREATE TABLE public.user_scripture_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  scripture_id UUID REFERENCES public.scriptures NOT NULL,
  read_at TIMESTAMPTZ DEFAULT NOW(),
  tier_at_read_time TEXT NOT NULL,
  UNIQUE(user_id, scripture_id)
);

-- 기도 노트 (기도/묵상 노트)
CREATE TABLE public.prayer_notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  scripture_id UUID REFERENCES public.scriptures,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스
CREATE INDEX idx_user_scripture_history_user_id ON public.user_scripture_history(user_id);
CREATE INDEX idx_prayer_notes_user_id ON public.prayer_notes(user_id);
CREATE INDEX idx_prayer_notes_created_at ON public.prayer_notes(created_at);
```

### 행 수준 보안 (RLS) 정책

```sql
-- user_profiles: 자신의 프로필만 보고 편집
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON public.user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.user_profiles FOR UPDATE
  USING (auth.uid() = id);

-- scriptures: 누구나 읽기 가능
ALTER TABLE public.scriptures ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read scriptures"
  ON public.scriptures FOR SELECT
  USING (true);

-- user_scripture_history: 자신의 기록만 CRUD
ALTER TABLE public.user_scripture_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own history"
  ON public.user_scripture_history FOR ALL
  USING (auth.uid() = user_id);

-- prayer_notes: 자신의 노트만 CRUD + 등급별 보기 제한
ALTER TABLE public.prayer_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own notes"
  ON public.prayer_notes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own notes"
  ON public.prayer_notes FOR SELECT
  USING (
    auth.uid() = user_id AND (
      -- Premium: 모든 기록 보기
      (SELECT tier FROM public.user_profiles WHERE id = auth.uid()) = 'premium'
      OR
      -- Member: 최근 3일 기록만 보기
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
-- 무작위 성경 구절 가져오기 (게스트용)
CREATE OR REPLACE FUNCTION get_random_scripture(limit_count INT)
RETURNS SETOF scriptures
LANGUAGE sql
AS $$
  SELECT * FROM scriptures
  WHERE is_premium = FALSE
  ORDER BY RANDOM()
  LIMIT limit_count;
$$;

-- 오늘의 성경 구절 가져오기 (멤버용 - 중복 없음)
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

-- 프리미엄 성경 구절 가져오기 (프리미엄용)
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

### Supabase 엣지 함수 (자동 삭제)

```typescript
// supabase/functions/delete-old-prayer-notes/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
  );

  // Member 등급 사용자의 7일 이상된 기록 삭제
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