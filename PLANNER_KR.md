# 상세 개발 계획

## 1단계: 환경 및 인증
**목표**: 프로젝트 기반을 구축하고 Supabase Auth를 통합하여 사용자 등급 관리를 시작합니다.

### 1-1. 프로젝트 초기화
- [x] **[설정]** Flutter 프로젝트 생성 및 폴더 구조 설정 (클린 아키텍처: layer/domain, layer/data, layer/presentation)
- [x] **[설정]** 필수 패키지 추가 (`flutter_riverpod`, `supabase_flutter`, `go_router`, `freezed` 등) 및 `analysis_options.yaml` 구성
- [x] **[설정]** 기본 CI/CD 및 Github Actions 설정 (빌드 테스트)

### 1-2. Supabase 환경 구성
- [x] **[DB]** Supabase 프로젝트 생성
- [x] **[DB]** `user_profiles` 테이블 생성 (id, tier, created_at 등)
- [x] **[DB]** RLS 정책 설정: `user_profiles` (자신의 프로필 보기/편집)
- [x] **[DB]** 트리거 함수 설정: 회원가입 시 `user_profiles` 자동 생성 (등급: 'guest' 또는 'member')

### 1-3. 인증 기능 (TDD)
- [x] **[도메인]** `UserTier` Enum 및 `UserProfile` Entity 정의 (freezed)
- [x] **[코어]** 테스트 용이성을 위한 `SupabaseService` 추상화 생성
- [x] **[테스트]** `AuthRepository` 단위 테스트 작성 (11개 테스트: 로그인, 로그아웃, 회원가입, 현재 사용자, 인증 상태)
- [x] **[데이터]** 오류 처리를 위한 Either 타입으로 `AuthRepository` 구현
- [x] **[테스트]** `UserProfileRepository` 단위 테스트 작성 (13개 테스트: CRUD 작업, 등급 관리)
- [x] **[데이터]** `UserProfileDataSource` 추상화를 통해 `UserProfileRepository` 구현
- [x] **[상태]** Riverpod Provider 구현 (auth, userProfile, tier provider)

### 1-4. UI 구현
- [x] **[UI]** 스플래시 화면 구현 (자동 로그인 확인 및 라우팅)
- [x] **[UI]** 로그인/회원가입 화면 구현 (소셜 로그인 버튼 포함)
- [x] **[UI]** 온보딩 퍼널 구현 (게스트 → 멤버 전환 유도 팝업)

---

## 2단계: 성경 전달 시스템
**목표**: 등급 기반 로직에 따라 핵심 콘텐츠인 성경 구절 카드 제공.
**상세 TDD 체크리스트**: `checklist/phase2-scripture-delivery.md` 참조 (92개 항목, 84개 테스트, 8-10일)

### 2-1. 데이터베이스 및 RPC ✅
- [x] **[DB]** `scriptures` 테이블 생성 및 더미 데이터 삽입 (23개 항목: 일반 15개 + 프리미엄 8개)
- [x] **[DB]** RLS 정책이 있는 `user_scripture_history` 테이블 생성
- [x] **[DB]** RPC 함수 구현: `get_random_scripture` (게스트용)
- [x] **[DB]** RPC 함수 구현: `get_daily_scriptures` (멤버용 - 중복 없음)
- [x] **[DB]** RPC 함수 구현: `get_premium_scriptures` (프리미엄용)
- [x] **[DB]** RPC 함수 구현: `record_scripture_view` (기록 추적)
- [x] **[테스트]** 모든 RPC 함수에 대한 pgTAP 테스트 작성 (15개 테스트)

**생성된 마이그레이션 파일**:
- `002_create_scriptures.sql`
- `003_create_user_scripture_history.sql`
- `004_create_scripture_rpc_functions.sql`
- `005_insert_scripture_dummy_data.sql`

**생성된 테스트 파일**:
- `supabase/tests/scripture_rpc_test.sql` (15개 pgTAP 테스트)

### 2-2. 성경 기능 (TDD) ✅
- [x] **[도메인]** `Scripture` Entity 정의 (`freezed` 적용)
- [x] **[도메인]** `ScriptureRepository` 인터페이스 정의
- [x] **[테스트]** `ScriptureRepository` 단위 테스트 작성 (17개 테스트 통과)
- [x] **[데이터]** `SupabaseScriptureDataSource`를 사용하여 `SupabaseScriptureRepository` 구현
- [x] **[상태]** Provider 구현 (DailyScriptures, PremiumScriptures, ScriptureViewTracker)

**생성된 구현 파일**:
- `lib/core/errors/failures.dart` - 오류 처리를 위한 Failure 타입
- `lib/features/scripture/domain/entities/scripture.dart` - freezed가 적용된 Scripture 엔티티
- `lib/features/scripture/domain/repositories/scripture_repository.dart` - 리포지토리 인터페이스
- `lib/features/scripture/data/datasources/scripture_datasource.dart` - DataSource 인터페이스
- `lib/features/scripture/data/datasources/supabase_scripture_datasource.dart` - Supabase 구현
- `lib/features/scripture/data/repositories/supabase_scripture_repository.dart` - 리포지토리 구현
- `lib/features/scripture/presentation/providers/scripture_providers.dart` - Riverpod provider

### 2-3. UI 구현 ✅
- [x] **[UI]** `ScriptureCard` 위젯 구현 (디자인 시스템 적용: 글꼴, 배경 등) - 9개 테스트 통과
- [x] **[UI]** `DailyFeedScreen` 구현 (PageView/ListView 활용) - 6개 테스트 통과
- [x] **[로직]** 게스트 (1일 1회) 및 멤버 (1일 3회) 제한 로직과 UI 연결
- [x] **[UI]** 블로커 위젯 구현 (로그인/결제 유도, 제한 도달 시) - 9개 테스트 통과
- [x] **[UI]** PageIndicator 위젯 구현 - 4개 테스트 통과

---

## 3단계: 기도 노트 시스템
**목표**: 사용자가 묵상 기록을 작성하고 볼 수 있는 기능 구현. 등급 기반 보기 제한 적용.
**상세 TDD 체크리스트**: `checklist/phase3-prayer-note.md` 참조 (99개 항목, 85개 테스트, 6-8일)

### 3-1. 데이터베이스 및 RLS
- [x] **[DB]** `prayer_notes` 테이블 생성
- [x] **[DB]** RLS 정책 설정: 멤버 (최근 3일), 프리미엄 (전체), 게스트 (금지) 정책 확인
- [x] **[DB]** RPC 함수 구현 (7개 함수: CRUD + 유틸리티)
- [x] **[테스트]** RLS 및 RPC 함수에 대한 pgTAP 테스트 작성 (20개 테스트)
- [x] **[엣지]** 자동 삭제 엣지 함수 생성 (멤버용 7일 제한)

**생성된 마이그레이션 파일**:
- `006_create_prayer_notes.sql`
- `007_create_prayer_note_rpc_functions.sql`

**생성된 테스트 파일**:
- `supabase/tests/prayer_note_test.sql` (20개 pgTAP 테스트)

**생성된 엣지 함수**:
- `supabase/functions/cleanup-old-notes/index.ts`

### 3-2. 기도 노트 기능 (TDD) ✅
- [x] **[도메인]** `PrayerNote` Entity 정의 (freezed)
- [x] **[도메인]** `PrayerNoteRepository` 인터페이스 정의 (CRUD + isDateAccessible)
- [x] **[테스트]** `PrayerNoteRepository` 테스트 작성 (23개 테스트 통과)
- [x] **[데이터]** `SupabasePrayerNoteDataSource`를 사용하여 `SupabasePrayerNoteRepository` 구현
- [x] **[상태]** Provider 구현 (PrayerNoteList, FormController, DateAccessibility)

**생성된 구현 파일**:
- `lib/features/prayer_note/domain/entities/prayer_note.dart` - freezed가 적용된 PrayerNote 엔티티
- `lib/features/prayer_note/domain/repositories/prayer_note_repository.dart` - 리포지토리 인터페이스
- `lib/features/prayer_note/data/datasources/prayer_note_datasource.dart` - DataSource 인터페이스
- `lib/features/prayer_note/data/datasources/supabase_prayer_note_datasource.dart` - Supabase 구현
- `lib/features/prayer_note/data/repositories/supabase_prayer_note_repository.dart` - 리포지토리 구현
- `lib/features/prayer_note/presentation/providers/prayer_note_providers.dart` - Riverpod provider

**생성된 테스트 파일**:
- `test/features/prayer_note/data/repositories/prayer_note_repository_test.dart` (23개 테스트)

### 3-3. UI 구현 ✅
- [x] **[UI]** 성경 카드 하단에 '묵상 남기기' 입력 폼 위젯 구현 (PrayerNoteInput - 9개 테스트)
- [x] **[UI]** `MyLibraryScreen` 탭 구현 (6개 테스트 통과)
- [x] **[UI]** `TableCalendar` 통합 및 날짜별 묵상 표시 (PrayerCalendar - 5개 테스트)
- [x] **[UI]** 멤버 등급의 과거 기록에 잠금 아이콘을 표시하는 로직 구현 (DateAccessibilityIndicator - 6개 테스트)
- [x] **[UI]** `PrayerNoteCard` 위젯 구현 (10개 테스트)

**생성된 구현 파일**:
- `lib/features/prayer_note/presentation/widgets/prayer_note_input.dart` - 묵상 입력 위젯
- `lib/features/prayer_note/presentation/widgets/prayer_note_card.dart` - 노트 카드 표시 위젯
- `lib/features/prayer_note/presentation/widgets/prayer_calendar.dart` - `table_calendar`를 사용한 캘린더
- `lib/features/prayer_note/presentation/widgets/date_accessibility_indicator.dart` - 잠금/해제 표시기
- `lib/features/prayer_note/presentation/screens/my_library_screen.dart` - 내 라이브러리 화면

**생성된 테스트 파일**:
- `test/features/prayer_note/presentation/widgets/prayer_note_input_test.dart` (9개 테스트)
- `test/features/prayer_note/presentation/widgets/prayer_note_card_test.dart` (10개 테스트)
- `test/features/prayer_note/presentation/widgets/prayer_calendar_test.dart` (5개 테스트)
- `test/features/prayer_note/presentation/widgets/date_accessibility_indicator_test.dart` (6개 테스트)
- `test/features/prayer_note/presentation/screens/my_library_screen_test.dart` (6개 테스트)

---

## 4단계: 수익화
**목표**: 수익 모델을 적용하고 프리미엄 사용자 전환 유도.
**상세 TDD 체크리스트**: `checklist/phase4-monetization.md` 참조 (112개 항목, 143개 테스트, 8-10일)

### 4-1. 데이터베이스 및 구독 스키마 ✅
- [x] **[DB]** 가격 정보가 포함된 `subscription_products` 테이블 생성
- [x] **[DB]** 상태 추적 기능이 있는 `user_subscriptions` 테이블 생성
- [x] **[DB]** 구독 테이블에 대한 RLS 정책 구현
- [x] **[DB]** RPC 함수 구현 (get_subscription_status, activate_subscription, cancel_subscription, get_available_products, has_active_premium)
- [x] **[테스트]** RLS 및 RPC 함수에 대한 pgTAP 테스트 작성 (25개 테스트)
- [x] **[엣지]** 엣지 함수 생성 (verify-ios-receipt, verify-android-receipt, subscription-webhook, check-expired-subscriptions)

**생성된 마이그레이션 파일**:
- `008_create_user_subscriptions.sql`
- `009_create_subscription_rpc_functions.sql`

**생성된 테스트 파일**:
- `supabase/tests/subscription_test.sql` (25개 pgTAP 테스트)

**생성된 엣지 함수**:
- `supabase/functions/verify-ios-receipt/index.ts`
- `supabase/functions/verify-android-receipt/index.ts`
- `supabase/functions/subscription-webhook/index.ts`
- `supabase/functions/check-expired-subscriptions/index.ts`

### 4-2. 구독 기능 (TDD) ✅
- [x] **[도메인]** `Subscription` 및 `SubscriptionProduct` Entity 정의 (freezed)
- [x] **[도메인]** `SubscriptionRepository` 인터페이스 정의
- [x] **[도메인]** `IAPService` 인터페이스 정의
- [x] **[테스트]** `SubscriptionRepository` 단위 테스트 작성 (32개 테스트 통과)
- [x] **[테스트]** `IAPService` 단위 테스트 작성 (7개 테스트 통과)
- [x] **[데이터]** `SupabaseSubscriptionDataSource`를 사용하여 `SupabaseSubscriptionRepository` 구현
- [x] **[데이터]** `in_app_purchase`를 사용하여 iOS/Android용 `IAPService` 구현
- [x] **[상태]** Provider 구현 (16개 테스트 통과: SubscriptionStatus, AvailableProducts, PurchaseController, RestorePurchaseController, HasPremium)

**생성된 구현 파일**:
- `lib/features/subscription/domain/entities/subscription.dart` - freezed가 적용된 Subscription, SubscriptionProduct, PurchaseResult 엔티티
- `lib/features/subscription/domain/repositories/subscription_repository.dart` - 리포지토리 인터페이스
- `lib/features/subscription/domain/services/iap_service.dart` - IAP 서비스 인터페이스
- `lib/features/subscription/data/datasources/subscription_datasource.dart` - DataSource 인터페이스
- `lib/features/subscription/data/datasources/supabase_subscription_datasource.dart` - Supabase 구현
- `lib/features/subscription/data/repositories/supabase_subscription_repository.dart` - 리포지토리 구현
- `lib/features/subscription/data/services/iap_service_impl.dart` - IAP 서비스 구현
- `lib/features/subscription/presentation/providers/subscription_providers.dart` - 모든 Riverpod provider

**생성된 테스트 파일**:
- `test/features/subscription/data/repositories/subscription_repository_test.dart` (32개 테스트)
- `test/features/subscription/data/services/iap_service_test.dart` (7개 테스트)
- `test/features/subscription/presentation/providers/subscription_providers_test.dart` (16개 테스트)

### 4-3. UI 구현
- [ ] **[UI]** `PremiumLandingScreen` 구현 (구독 안내 페이지)
- [ ] **[UI]** `SubscriptionProductCard` 위젯 구현
- [ ] **[UI]** `PurchaseButton` 위젯 구현
- [ ] **[UI]** `UpsellDialog` 위젯 구현
- [ ] **[UI]** `ManageSubscriptionScreen` 구현
- [ ] **[UI]** 성경 피드 및 기도 기록에 업셀링 통합
- [ ] **[테스트]** 구매 흐름에 대한 통합 테스트 작성 (iOS/Android)

---

## 5단계: 최적화 및 출시
**목표**: 앱 완성도 향상 및 스토어 출시.

### 5-1. 최적화
- [ ] **[성능]** 이미지 캐싱 (`cached_network_image`) 적용 확인
- [ ] **[성능]** ListView 지연 로딩 확인
- [ ] **[로컬]** 오프라인 지원 (Hive 등을 사용하여 최근 본 성경 구절 캐시 - 선택 사항)

### 5-2. 출시 준비
- [ ] **[자산]** 앱 아이콘 (런처 아이콘) 및 스플래시 화면 생성
- [ ] **[스토어]** 스크린샷 캡처 및 스토어 설명 작성
- [ ] **[정책]** 개인정보 처리방침 및 서비스 약관 링크
- [ ] **[테스트]** TestFlight / Google Play 내부 테스트 배포 및 QA
