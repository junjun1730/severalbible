# 상세 개발 계획 (Detailed Development Plan)

## Phase 1: 환경 설정 및 인증 (Environment & Auth)
**목표**: 프로젝트 기반을 다지고, Supabase 인증을 연동하여 사용자 등급(Tier) 관리를 시작합니다.

### 1-1. 프로젝트 초기화
- [ ] **[Setup]** Flutter 프로젝트 생성 및 폴더 구조 세팅 (Clean Architecture: layer/domain, layer/data, layer/presentation)
- [ ] **[Setup]** 필수 패키지 추가 (`flutter_riverpod`, `supabase_flutter`, `go_router`, `freezed` 등) 및 `analysis_options.yaml` 설정
- [ ] **[Setup]** CI/CD 및 Github Actions 기본 설정 (Build test)

### 1-2. Supabase 환경 구성
- [ ] **[DB]** Supabase 프로젝트 생성
- [ ] **[DB]** `user_profiles` 테이블 생성 (id, tier, created_at 등)
- [ ] **[DB]** RLS 정책 설정: `user_profiles` (본인 조회/수정 권한)
- [ ] **[DB]** Trigger 함수 설정: 회원가입 시 `user_profiles` 자동 생성 (Tier: 'guest' or 'member')

### 1-3. Auth Feature (TDD)
- [ ] **[Domain]** `User` Entity 및 `AuthRepository` Interface 정의
- [ ] **[Test]** `AuthRepository` Unit Test 작성 (MockSupabase 활용: 로그인, 로그아웃, 회원가입, User 상태 확인)
- [ ] **[Data]** `SupabaseAuthRepository` 구현
- [ ] **[State]** `AuthProvider` (Riverpod) 구현 및 Test (상태 변화 감지)

### 1-4. UI 구현
- [ ] **[UI]** Splash Screen 구현 (자동 로그인 체크 및 라우팅)
- [ ] **[UI]** Login/Sign-up Screen 구현 (Social Login 버튼 포함)
- [ ] **[UI]** Onboarding Funnel (Guest → Member 유도 팝업) 구현

---

## Phase 2: 말씀 카드 제공 시스템 (Scripture Delivery)
**목표**: 핵심 콘텐츠인 말씀 카드를 등급별 로직에 맞춰 제공합니다.

### 2-1. 데이터베이스 및 RPC
- [ ] **[DB]** `scriptures` 테이블 생성 및 더미 데이터(최소 20개) 입력
- [ ] **[DB]** `user_scripture_history` 테이블 생성
- [ ] **[DB]** RPC 함수 구현: `get_random_scripture` (Guest용)
- [ ] **[DB]** RPC 함수 구현: `get_daily_scriptures` (Member용 - 중복 제외)
- [ ] **[DB]** RPC 함수 구현: `get_premium_scriptures` (Premium용)

### 2-2. Scripture Feature (TDD)
- [ ] **[Domain]** `Scripture` Entity 정의 (`freezed` 적용)
- [ ] **[Domain]** `ScriptureRepository` Interface 정의
- [ ] **[Test]** `ScriptureRepository` Unit Test 작성 (각 RPC 호출 및 매핑 검증)
- [ ] **[Data]** `SupabaseScriptureRepository` 구현
- [ ] **[State]** `DailyScriptureProvider` 구현 (오늘의 말씀 캐싱 및 로딩 상태 관리)

### 2-3. UI 구현
- [ ] **[UI]** `ScriptureCard` Widget 구현 (디자인 시스템 적용: 폰트, 배경 등)
- [ ] **[UI]** `DailyFeedScreen` 구현 (PageView/ListView 활용)
- [ ] **[Logic]** Guest용 1일 1회 제한 및 Member용 1일 3회 제한 로직 UI 연동
- [ ] **[UI]** Blocker Widget 구현 (제한 도달 시 로그인/결제 유도)

---

## Phase 3: 기도 노트 시스템 (Prayer Notes)
**목표**: 사용자가 묵상을 기록하고 조회하는 기능을 구현합니다. 등급별 조회 제한을 적용합니다.

### 3-1. 데이터베이스 및 RLS
- [ ] **[DB]** `prayer_notes` 테이블 생성
- [ ] **[DB]** RLS 정책 설정: Member(최근 3일), Premium(전체), Guest(불가) 정책 적용 확인
- [ ] **[Edge]** 오래된 기록 자동 삭제 함수(Edge Function) 배포 (Member용 7일 제한)

### 3-2. Prayer Note Feature (TDD)
- [ ] **[Domain]** `PrayerNote` Entity 정의
- [ ] **[Domain]** `PrayerNoteRepository` Interface 정의 (CRUD)
- [ ] **[Test]** `PrayerNoteRepository` Test 작성 (작성, 조회, 수정, 삭제)
- [ ] **[Data]** `SupabasePrayerNoteRepository` 구현
- [ ] **[State]** `PrayerNoteListProvider` 및 `PrayerNoteFormController` 구현

### 3-3. UI 구현
- [ ] **[UI]** 말씀 카드 하단 '묵상 남기기' 입력 폼 Widget 구현
- [ ] **[UI]** `MyLibraryScreen` (내 서재) 탭 구현
- [ ] **[UI]** `TableCalendar` 연동 및 날짜별 묵상 표시
- [ ] **[Logic]** Member 등급에 대한 과거 기록 잠금(Lock) 표시 로직 구현

---

## Phase 4: 유료화 및 결제 (Monetization)
**목표**: 수익 모델을 붙이고 Premium 사용자 전환을 유도합니다.

### 4-1. 인앱 결제 설정
- [ ] **[Setup]** App Store Connect / Google Play Console 앱 등록 및 상품(구독) 생성
- [ ] **[Pkg]** `in_app_purchase` 패키지 설정

### 4-2. Payment Feature (TDD)
- [ ] **[Domain]** `SubscriptionRepository` Interface 정의
- [ ] **[Data]** IAP 결제 검증 및 처리 로직 구현
- [ ] **[DB]** 결제 성공 시 `user_profiles`의 `tier` 업데이트 로직 (또는 Webhook)

### 4-3. UI 구현
- [ ] **[UI]** `PremiumLandingScreen` (구독 안내 페이지) 구현
- [ ] **[UI]** "말씀 더 보기", "과거 기록 보기" 클릭 시 Upselling 팝업 연결
- [ ] **[UI]** 설정 페이지 내 '구독 관리' 메뉴 구현

---

## Phase 5: 최적화 및 론칭 (Optimization & Launch)
**목표**: 앱의 완성도를 높이고 스토어에 출시합니다.

### 5-1. 최적화
- [ ] **[Perf]** 이미지 캐싱(`cached_network_image`) 적용 확인
- [ ] **[Perf]** 리스트뷰 Lazy Loading 점검
- [ ] **[Local]** 오프라인 대응 (Hive 등을 이용해 최근 본 말씀 캐싱 - 선택 사항)

### 5-2. 배포 준비
- [ ] **[Asset]** 앱 아이콘(Launcher Icon) 및 스플래시 스크린 생성
- [ ] **[Store]** 스크린샷 캡처 및 스토어 설명 작성
- [ ] **[Policy]** 개인정보처리방침 및 이용약관 링크 연결
- [ ] **[Test]** TestFlight / Google Play Internal Test 배포 및 QA