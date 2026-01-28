# One Message - 기술 명세서

**프로젝트 이름**: One Message (severalbible)
**버전**: 1.0.0
**최종 업데이트**: 2026-01-21
**개발 상태**: 4단계 (수익화 - 70% 완료)

---

## 목차

1. [프로젝트 개요](#프로젝트-개요)
2. [기술 스택](#기술-스택)
3. [아키텍처 및 디자인 패턴](#아키텍처-및-디자인-패턴)
4. [사용자 등급 및 기능 매트릭스](#사용자-등급-및-기능-매트릭스)
5. [개발 진행 상황](#개발-진행-상황)
6. [데이터베이스 스키마](#데이터베이스-스키마)
7. [도메인 엔티티](#도메인-엔티티)
8. [리포지토리 인터페이스](#리포지토리-인터페이스)
9. [구현된 기능](#구현된-기능)
10. [상태 관리](#상태-관리)
11. [테스트 커버리지](#테스트-커버리지)
12. [파일 구조](#파일-구조)
13. [API 문서](#api-문서)

---

## 프로젝트 개요

### 미션 선언문

One Message는 사용자가 다음을 할 수 있도록 돕는 영적 성장 애플리케이션입니다:
- **읽기**: 매일의 성경 구절과 영적 콘텐츠
- **쓰기**: 개인적인 묵상과 기도 노트
- **보관하기**: 시간이 지남에 따라 영적 자산 라이브러리 구축

### 핵심 가치

1. **단순성**: 깨끗하고 집중된 영적 콘텐츠 제공
2. **지속 가능성**: 프리미엄 구독을 통한 프리미엄(Freemium) 비즈니스 모델
3. **품질**: 신뢰성을 보장하는 TDD 기반 개발

### 대상 플랫폼

- **iOS**: iPhone/iPad (iOS 13+)
- **Android**: 스마트폰/태블릿 (Android 6.0+)
- **주요 시장**: 대한민국 (한국어)

---

## 기술 스택

### 프론트엔드

| 기술 | 버전 | 목적 |
|------------|---------|---------|
| Flutter | 3.10.4+ | 크로스플랫폼 UI 프레임워크 |
| Dart | 3.10.4+ | 프로그래밍 언어 |
| Riverpod | 2.4.0 | 상태 관리 |
| GoRouter | 13.0.0 | 네비게이션 및 라우팅 |
| Freezed | 2.4.0 | 불변 데이터 클래스 |
| Dartz | 0.10.1 | 함수형 프로그래밍 (Either 타입) |

### 백엔드 (Supabase)

| 기술 | 목적 |
|------------|---------|
| Supabase Auth | 사용자 인증 (이메일, 구글, 애플) |
| PostgreSQL | 기본 데이터베이스 |
| Row Level Security | 권한 부여 및 데이터 격리 |
| RPC Functions | 서버사이드 비즈니스 로직 |
| Edge Functions | 서버리스 TypeScript/Deno 함수 |
| Realtime | 실시간 데이터 구독 |

### 테스트 및 품질

| 기술 | 목적 |
|------------|---------|
| flutter_test | 유닛 및 위젯 테스트 |
| integration_test | E2E 테스트 |
| mockito/mocktail | 모의(Mocking) 프레임워크 |
| pgTAP | PostgreSQL 함수 테스트 |
| GitHub Actions | CI/CD 파이프라인 |

### 추가 라이브러리

```yaml
dependencies:
  table_calendar: ^3.1.0      # 기도 노트를 위한 캘린더 UI
  in_app_purchase: ^3.2.0     # iOS/Android IAP
  intl: ^0.19.0               # 국제화
  flutter_dotenv: ^5.1.0      # 환경 설정
```

---

## 아키텍처 및 디자인 패턴

### 클린 아키텍처 레이어

```
┌─────────────────────────────────────────┐
│          프레젠테이션 레이어            │
│  (스크린, 위젯, 프로바이더)             │
│  - UI 컴포넌트                          │
│  - 상태 관리 (Riverpod)                 │
│  - 사용자 상호작용                      │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           도메인 레이어                 │
│  (엔티티, 리포지토리 인터페이스)        │
│  - 비즈니스 로직                        │
│  - 순수 Dart (의존성 없음)              │
│  - 불변 엔티티 (Freezed)                │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│            데이터 레이어                  │
│  (리포지토리, 데이터소스, 서비스)       │
│  - Supabase 통합                        │
│  - 오류 처리 (Either<L, R>)             │
│  - 데이터 변환                          │
└─────────────────────────────────────────┘
```

### 주요 디자인 패턴

#### 1. 리포지토리 패턴
- 비즈니스 로직에서 데이터 소스를 추상화
- 도메인 레이어의 인터페이스, 데이터 레이어의 구현
- 모의(mock) 객체를 사용한 손쉬운 테스트 가능

#### 2. 함수형 프로그래밍 원칙

**불변성**:
```dart
@freezed
class Scripture with _$Scripture {
  const factory Scripture({
    required String id,
    required String content,
    // ... 불변 필드들
  }) = _Scripture;
}
```

**오류 처리를 위한 Either 타입**:
```dart
Future<Either<Failure, List<Scripture>>> getDailyScriptures({
  required String userId,
  required int count,
});
// 왼쪽 = 오류, 오른쪽 = 성공
```

**순수 함수**:
- 동일한 입력 → 동일한 출력
- 부수 효과(Side effects) 없음
- 테스트 가능하고 예측 가능함

#### 3. 프로바이더 패턴 (Riverpod)
- 의존성 주입
- 상태 관리
- 자동 폐기
- 프로바이더 조합

#### 4. 의존성 주입
```dart
// 프로바이더가 자동으로 의존성을 주입함
final scriptureRepositoryProvider = Provider<ScriptureRepository>((ref) {
  final dataSource = ref.watch(scriptureDataSourceProvider);
  return SupabaseScriptureRepository(dataSource);
});
```

---

## 사용자 등급 및 기능 매트릭스

### 등급 비교

| 기능 | 게스트 (비로그인) | 회원 (무료) | 프리미엄 (유료) |
|---------|-------------------|---------------|----------------|
| **성경 구절 접근** | ||||
| 매일의 성경 구절 | 1개 (랜덤, 중복 가능) | 3개 (중복 없음) | 일반 3개 + 프리미엄 3개 |
| 프리미엄 콘텐츠 | ❌ | ❌ | ✅ |
| **기도 노트** | ||||
| 노트 작성 | ❌ | ✅ | ✅ |
| 기록 보기 | ❌ | 최근 3일 | 무제한 |
| 보관 기간 | ❌ | 7일 | 영구 |
| **수익화** | ||||
| 상향 판매 유도 | 로그인 차단 | 보관 및 콘텐츠 제한 | 없음 |
| 가격 | 무료 | 무료 | 월 9,900원 또는 연 99,000원 |

### 등급 구현

**데이터베이스**:
```sql
-- user_profiles.tier enum
CHECK (tier IN ('guest', 'member', 'premium'))
```

**Flutter**:
```dart
enum UserTier {
  guest,    // 비인증 또는 체험판
  member,   // 무료 등록 사용자
  premium,  // 유료 구독자
}
```

---

## 개발 진행 상황

### 단계 요약

| 단계 | 설명 | 상태 | 테스트 | 진행률 |
|-------|-------------|--------|-------|----------|
| 1단계 | 환경 및 인증 | ✅ 완료 | 24개 | 100% |
| 2단계 | 성경 구절 전달 | ✅ 완료 | 60개 | 100% |
| 3단계 | 기도 노트 시스템 | ✅ 완료 | 59개 | 100% |
| 4단계 | 수익화 | 🔄 진행 중 | 55/145개 | 70% |
| 5단계 | 최적화 및 출시 | ⏳ 대기 중 | 0개 | 0% |

### 4단계 세부 내역 (현재)

| 하위 단계 | 설명 | 상태 | 테스트 |
|-----------|-------------|--------|-------|
| 4-1 | 데이터베이스 및 구독 스키마 | ✅ 완료 | pgTAP 25개 + Edge Function 4개 |
| 4-2 | 구독 기능 (TDD) | ✅ 완료 | Dart 테스트 55개 |
| 4-3 | UI 구현 | ⏳ 대기 중 | 0/26개 |

**총 완료율**: 5단계 중 4단계, 전체 약 74%

---

## 데이터베이스 스키마

### 테이블 개요

#### 1. user_profiles
**목적**: 사용자 등급 및 프로필 정보 저장

| 컬럼 | 타입 | 설명 |
|--------|------|-------------|
| id | UUID | 기본 키, auth.users(id) 참조 |
| tier | TEXT | 사용자 등급: 'guest', 'member', 'premium' |
| created_at | TIMESTAMPTZ | 계정 생성 타임스탬프 |
| updated_at | TIMESTAMPTZ | 마지막 업데이트 타임스탬프 |

**RLS 정책**:
- 사용자는 자신의 프로필을 보거나 업데이트할 수 있음
- 서비스 역할은 전체 접근 권한을 가짐

---

#### 2. scriptures
**목적**: 매일의 성경 구절 콘텐츠 저장

| 컬럼 | 타입 | 설명 |
|--------|------|-------------|
| id | UUID | 기본 키 |
| book | TEXT | 성경 책 이름 (예: "요한복음") |
| chapter | INTEGER | 장 번호 |
| verse | INTEGER | 절 번호 |
| content | TEXT | 성경 구절 텍스트 |
| reference | TEXT | 형식화된 참조 (예: "요 3:16") |
| is_premium | BOOLEAN | 프리미엄 전용 콘텐츠 플래그 |
| category | TEXT | 카테고리 (지혜, 소망, 믿음 등) |
| created_at | TIMESTAMPTZ | 생성 타임스탬프 |
| updated_at | TIMESTAMPTZ | 업데이트 타임스탬프 |

**RLS 정책**:
- 모든 인증된 사용자는 일반 성경 구절을 볼 수 있음
- 프리미엄 사용자만 `is_premium = true`인 성경 구절을 볼 수 있음

**더미 데이터**: 23개 성경 구절 (일반 15개 + 프리미엄 8개)

---

#### 3. user_scripture_history
**목적**: 사용자가 본 성경 구절 추적

| 컬럼 | 타입 | 설명 |
|--------|------|-------------|
| id | UUID | 기본 키 |
| user_id | UUID | auth.users(id) 참조 |
| scripture_id | UUID | scriptures(id) 참조 |
| viewed_at | TIMESTAMPTZ | 조회 타임스탬프 |

**RLS 정책**:
- 사용자는 자신의 기록만 보거나 삽입할 수 있음
- 중복 방지 로직에 사용됨

---

#### 4. prayer_notes
**목적**: 사용자 묵상 및 기도 기록 저장

| 컬럼 | 타입 | 설명 |
|--------|------|-------------|
| id | UUID | 기본 키 |
| user_id | UUID | auth.users(id) 참조 |
| scripture_id | UUID | 선택적 성경 구절 참조 |
| content | TEXT | 노트 내용 |
| created_at | TIMESTAMPTZ | 생성 타임스탬프 |
| updated_at | TIMESTAMPTZ | 업데이트 타임스탬프 |

**RLS 정책**:
- 회원: 최근 3일간의 노트만 볼 수 있음
- 프리미엄: 모든 노트를 볼 수 있음
- 게스트: 접근 불가

**보관**:
- 7일 이상 된 회원 노트는 자동 삭제됨
- 프리미엄 노트는 영구 보관됨

---

#### 5. user_subscriptions
**목적**: 프리미엄 구독 상태 추적

| 컬럼 | 타입 | 설명 |
|--------|------|-------------|
| id | UUID | 기본 키 |
| user_id | UUID | auth.users(id) 참조, UNIQUE |
| product_id | TEXT | 'monthly_premium' 또는 'annual_premium' |
| platform | TEXT | 'ios', 'android' 또는 'web' |
| store_transaction_id | TEXT | 영수증 검증 ID |
| original_transaction_id | TEXT | 최초 구매 ID (갱신용) |
| subscription_status | TEXT | 'active', 'canceled', 'expired', 'pending', 'grace_period' |
| started_at | TIMESTAMPTZ | 구독 시작일 |
| expires_at | TIMESTAMPTZ | 만료일 (평생 구독의 경우 NULL) |
| auto_renew | BOOLEAN | 자동 갱신 활성화 여부 |
| cancellation_reason | TEXT | 취소 사유 |
| created_at | TIMESTAMPTZ | 생성 타임스탬프 |
| updated_at | TIMESTAMPTZ | 업데이트 타임스탬프 |

**RLS 정책**:
- 사용자는 자신의 구독만 볼 수 있음
- 서비스 역할만 삽입/업데이트/삭제 가능

---

#### 6. subscription_products
**목적**: 사용 가능한 구독 상품 정의

| 컬럼 | 타입 | 설명 |
|--------|------|-------------|
| id | TEXT | 기본 키 ('monthly_premium', 'annual_premium') |
| name | TEXT | 상품 이름 |
| description | TEXT | 상품 설명 |
| duration_days | INTEGER | 30 (월간), 365 (연간), NULL (평생) |
| price_krw | INTEGER | 원화 가격 |
| price_usd | DECIMAL | 달러 가격 |
| ios_product_id | TEXT | App Store Connect 상품 ID |
| android_product_id | TEXT | Google Play 상품 ID |
| is_active | BOOLEAN | 상품 가용성 |
| created_at | TIMESTAMPTZ | 생성 타임스탬프 |

**RLS 정책**:
- 모든 사용자는 활성 상품을 볼 수 있음

**상품**:
1. `monthly_premium`: 월 9,900원
2. `annual_premium`: 연 99,000원 (2개월 무료)

---

### RPC 함수

#### 성경 구절 함수 (4개 함수)

1. **get_random_scripture**(count INTEGER)
   - 게스트 사용자를 위해 랜덤 성경 구절 반환
   - 중복 허용

2. **get_daily_scriptures**(user_id UUID, count INTEGER)
   - 회원을 위해 중복되지 않는 성경 구절 반환
   - 오늘 이미 본 성경 구절 제외

3. **get_premium_scriptures**(user_id UUID, count INTEGER)
   - 프리미엄 사용자를 위해 프리미엄 성경 구절 반환
   - 중복 방지 로직 적용

4. **record_scripture_view**(user_id UUID, scripture_id UUID)
   - 조회 기록 기록
   - 중복 방지에 사용

#### 기도 노트 함수 (7개 함수)

1. **create_prayer_note**(user_id UUID, content TEXT, scripture_id UUID)
2. **get_prayer_notes**(user_id UUID, start_date DATE, end_date DATE)
3. **get_prayer_notes_by_date**(user_id UUID, date DATE)
4. **update_prayer_note**(note_id UUID, content TEXT)
5. **delete_prayer_note**(note_id UUID)
6. **is_date_accessible**(user_id UUID, date DATE)
7. **get_notes_with_scripture**(user_id UUID, start_date DATE, end_date DATE)

#### 구독 함수 (5개 함수)

1. **get_subscription_status**(user_id UUID)
   - 현재 구독 상태와 활성 여부 반환

2. **activate_subscription**(user_id, product_id, platform, transaction_id, original_transaction_id)
   - 구매 검증 후 구독 활성화
   - 사용자 등급을 프리미엄으로 업데이트

3. **cancel_subscription**(user_id UUID, reason TEXT)
   - 구독 취소 (만료일까지 접근 유지)

4. **get_available_products**(platform TEXT)
   - 활성 구독 상품 반환

5. **has_active_premium**(user_id UUID)
   - 프리미엄 접근 권한 여부 Boolean 확인

---

### Edge 함수 (5개 함수)

#### 1. verify-ios-receipt
**목적**: Apple과 iOS 구매 영수증 검증

**엔드포인트**: `POST /functions/v1/verify-ios-receipt`

**요청**:
```json
{
  "receipt": "base64_encoded_receipt",
  "userId": "user_uuid"
}
```

**응답**:
```json
{
  "valid": true,
  "transactionId": "1000000123456789",
  "originalTransactionId": "1000000123456789",
  "productId": "com.onemessage.monthly",
  "expiresDate": "1704067200000"
}
```

---

#### 2. verify-android-receipt
**목적**: Google Play와 Android 구매 검증

**엔드포인트**: `POST /functions/v1/verify-android-receipt`

**요청**:
```json
{
  "purchaseToken": "google_purchase_token",
  "productId": "monthly_premium_sub",
  "userId": "user_uuid"
}
```

---

#### 3. subscription-webhook
**목적**: Apple/Google의 구독 갱신/취소 웹훅 처리

**엔드포인트**: `POST /functions/v1/subscription-webhook`

**처리 내용**:
- 구독 갱신
- 구독 취소
- 구독 만료
- 유예 기간 알림

---

#### 4. check-expired-subscriptions
**목적**: 만료된 구독을 확인하고 등급을 내리는 크론 잡

**스케줄**: 매일 UTC 2시

**동작**:
- `expires_at < NOW()`이고 상태가 'active'인 구독 찾기
- 상태를 'expired'로 업데이트
- 사용자 등급을 'premium'에서 'member'로 내리기

---

#### 5. cleanup-old-notes
**목적**: 회원 등급의 7일 이상 된 기도 노트 삭제

**스케줄**: 매일 UTC 3시

**로직**:
```sql
DELETE FROM prayer_notes
WHERE user_id IN (SELECT id FROM user_profiles WHERE tier = 'member')
  AND created_at < NOW() - INTERVAL '7 days';
```

---

## 도메인 엔티티

### 1. UserProfile

**파일**: `lib/features/auth/domain/user_profile.dart`

```dart
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required UserTier tier,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfile;
}

enum UserTier {
  guest,
  member,
  premium,
}
```

---

### 2. Scripture

**파일**: `lib/features/scripture/domain/entities/scripture.dart`

```dart
@freezed
class Scripture with _$Scripture {
  const factory Scripture({
    required String id,
    required String book,
    required int chapter,
    required int verse,
    required String content,
    required String reference,
    @Default(false) bool isPremium,
    String? category,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Scripture;
}
```

**속성**:
- `id`: 고유 식별자 (UUID)
- `book`: 성경 책 이름 (예: "창세기", "요한복음")
- `chapter`: 장 번호 (양의 정수)
- `verse`: 절 번호 (양의 정수)
- `content`: 전체 성경 구절 텍스트
- `reference`: 형식화된 문자열 (예: "요 3:16")
- `isPremium`: 프리미엄 전용 콘텐츠 플래그
- `category`: 선택적 분류 (지혜, 소망, 믿음 등)

---

### 3. PrayerNote

**파일**: `lib/features/prayer_note/domain/entities/prayer_note.dart`

```dart
@freezed
class PrayerNote with _$PrayerNote {
  const factory PrayerNote({
    required String id,
    required String userId,
    String? scriptureId,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
    // 조인된 성경 구절 데이터 (선택적)
    String? scriptureReference,
    String? scriptureContent,
  }) = _PrayerNote;
}
```

**속성**:
- `id`: 고유 식별자
- `userId`: 기도 노트 소유자
- `scriptureId`: 성경 구절에 대한 선택적 참조
- `content`: 사용자의 묵상/기도 텍스트
- `createdAt`: 생성 타임스탬프
- `scriptureReference`: scriptures 테이블에서 조인된 필드
- `scriptureContent`: scriptures 테이블에서 조인된 필드

---

### 4. Subscription

**파일**: `lib/features/subscription/domain/entities/subscription.dart`

```dart
@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String userId,
    required String productId,
    required SubscriptionPlatform platform,
    String? storeTransactionId,
    String? originalTransactionId,
    required SubscriptionStatus status,
    required DateTime startedAt,
    DateTime? expiresAt,
    @Default(true) bool autoRenew,
    String? cancellationReason,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Subscription;
}

enum SubscriptionStatus {
  active,
  canceled,
  expired,
  pending,
  gracePeriod,
}

enum SubscriptionPlatform {
  ios,
  android,
  web,
}
```

---

### 5. SubscriptionProduct

```dart
@freezed
class SubscriptionProduct with _$SubscriptionProduct {
  const factory SubscriptionProduct({
    required String id,
    required String name,
    String? description,
    int? durationDays,
    required int priceKrw,
    double? priceUsd,
    String? iosProductId,
    String? androidProductId,
    @Default(true) bool isActive,
    required DateTime createdAt,
  }) = _SubscriptionProduct;
}
```

---

### 6. PurchaseResult

```dart
@freezed
class PurchaseResult with _$PurchaseResult {
  const factory PurchaseResult({
    required String productId,
    required String transactionId,
    String? originalTransactionId,
    required SubscriptionPlatform platform,
    String? receipt, // iOS
    String? purchaseToken, // Android
    required DateTime purchaseDate,
    required IAPPurchaseStatus status,
  }) = _PurchaseResult;
}

enum IAPPurchaseStatus {
  purchased,
  pending,
  restored,
  canceled,
  error,
}
```

---

## 리포지토리 인터페이스

### 1. AuthRepository

**파일**: `lib/features/auth/data/auth_repository.dart`

**메서드**:
```dart
class AuthRepository {
  User? get currentUser;
  bool get isLoggedIn;
  Stream<AuthState> get authStateChanges;

  Future<Either<String, User>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<String, User>> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<Either<String, Unit>> signOut();
  Future<Either<String, Unit>> signInWithGoogle();
  Future<Either<String, Unit>> signInWithApple();
}
```

---

### 2. UserProfileRepository

**파일**: `lib/features/auth/data/user_profile_repository.dart`

**메서드**:
```dart
class UserProfileRepository {
  Future<Either<String, UserProfile>> getUserProfile(String userId);

  Future<Either<String, UserTier>> getUserTier(String userId);

  Future<Either<String, UserProfile>> updateUserTier({
    required String userId,
    required UserTier tier,
  });

  Future<Either<String, UserProfile>> createUserProfile({
    required String userId,
    UserTier tier = UserTier.member,
  });
}
```

---

### 3. ScriptureRepository

**파일**: `lib/features/scripture/domain/repositories/scripture_repository.dart`

**메서드**:
```dart
abstract class ScriptureRepository {
  /// 게스트 사용자를 위한 랜덤 성경 구절 가져오기 (중복 허용)
  Future<Either<Failure, List<Scripture>>> getRandomScripture(int count);

  /// 회원 사용자를 위한 매일의 성경 구절 가져오기 (중복 없음)
  Future<Either<Failure, List<Scripture>>> getDailyScriptures({
    required String userId,
    required int count,
  });

  /// 프리미엄 사용자를 위한 프리미엄 성경 구절 가져오기
  Future<Either<Failure, List<Scripture>>> getPremiumScriptures({
    required String userId,
    required int count,
  });

  /// 사용자가 성경 구절을 봤음을 기록
  Future<Either<Failure, void>> recordScriptureView({
    required String userId,
    required String scriptureId,
  });

  /// 특정 날짜에 대한 사용자의 성경 구절 조회 기록 가져오기
  Future<Either<Failure, List<Scripture>>> getScriptureHistory({
    required String userId,
    required DateTime date,
  });
}
```

**구현**: `SupabaseScriptureRepository`
**테스트**: 17개 테스트 통과

---

### 4. PrayerNoteRepository

**파일**: `lib/features/prayer_note/domain/repositories/prayer_note_repository.dart`

**메서드**:
```dart
abstract class PrayerNoteRepository {
  /// 새 기도 노트 생성
  Future<Either<Failure, PrayerNote>> createPrayerNote({
    required String userId,
    required String content,
    String? scriptureId,
  });

  /// 날짜 범위에 대한 기도 노트 가져오기 (등급 기반 필터링)
  Future<Either<Failure, List<PrayerNote>>> getPrayerNotes({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 특정 날짜에 대한 기도 노트 가져오기
  Future<Either<Failure, List<PrayerNote>>> getPrayerNotesByDate({
    required String userId,
    required DateTime date,
  });

  /// 기존 기도 노트 업데이트
  Future<Either<Failure, PrayerNote>> updatePrayerNote({
    required String noteId,
    required String content,
  });

  /// 기도 노트 삭제
  Future<Either<Failure, void>> deletePrayerNote({
    required String noteId,
  });

  /// 사용자 등급에 따라 날짜 접근 가능 여부 확인
  /// 회원: 최근 3일 접근 가능
  /// 프리미엄: 모든 날짜 접근 가능
  Future<Either<Failure, bool>> isDateAccessible({
    required String userId,
    required DateTime date,
  });
}
```

**구현**: `SupabasePrayerNoteRepository`
**테스트**: 23개 테스트 통과

---

### 5. SubscriptionRepository

**파일**: `lib/features/subscription/domain/repositories/subscription_repository.dart`

**메서드**:
```dart
abstract class SubscriptionRepository {
  /// 현재 사용자의 구독 상태 가져오기
  Future<Either<Failure, Subscription?>> getSubscriptionStatus({
    required String userId,
  });

  /// 사용 가능한 구독 상품 가져오기
  Future<Either<Failure, List<SubscriptionProduct>>> getAvailableProducts({
    SubscriptionPlatform? platform,
  });

  /// 성공적인 구매 검증 후 구독 활성화
  Future<Either<Failure, Subscription>> activateSubscription({
    required String userId,
    required String productId,
    required SubscriptionPlatform platform,
    required String transactionId,
    String? originalTransactionId,
  });

  /// 현재 구독 취소 (만료일까지 활성 상태 유지)
  Future<Either<Failure, void>> cancelSubscription({
    required String userId,
    String? reason,
  });

  /// Apple과 iOS 영수증 검증
  Future<Either<Failure, Map<String, dynamic>>> verifyIosReceipt({
    required String receipt,
    required String userId,
  });

  /// Google Play와 Android 구매 검증
  Future<Either<Failure, Map<String, dynamic>>> verifyAndroidPurchase({
    required String purchaseToken,
    required String productId,
    required String userId,
  });

  /// 사용자가 활성 프리미엄 구독을 가지고 있는지 확인
  Future<Either<Failure, bool>> hasActivePremium({
    required String userId,
  });
}
```

**구현**: `SupabaseSubscriptionRepository`
**테스트**: 32개 테스트 통과

---

### 6. IAPService

**파일**: `lib/features/subscription/domain/services/iap_service.dart`

**메서드**:
```dart
abstract class IAPService {
  /// IAP 서비스 초기화 (플랫폼별)
  Future<Either<Failure, void>> initialize();

  /// 스토어에서 사용 가능한 상품 가져오기
  Future<Either<Failure, List<SubscriptionProduct>>> fetchProducts({
    required List<String> productIds,
  });

  /// 구독 상품 구매
  Future<Either<Failure, PurchaseResult>> purchaseSubscription({
    required String productId,
  });

  /// 이전 구매 복원
  Future<Either<Failure, List<PurchaseResult>>> restorePurchases();

  /// 보류 중인 구매 가져오기 (미완료 거래)
  Future<Either<Failure, List<PurchaseResult>>> getPendingPurchases();

  /// 구매 거래 완료
  Future<Either<Failure, void>> completePurchase({
    required String transactionId,
  });

  /// 리소스 및 리스너 해제
  void dispose();
}
```

**구현**: `IAPServiceImpl` (`in_app_purchase` 패키지 사용, iOS/Android)
**테스트**: 7개 테스트 통과

---

## 구현된 기능

### 1단계: 환경 및 인증 ✅

#### 기능
1. **인증 시스템**
   - 이메일/비밀번호 로그인 및 회원가입
   - Google OAuth 통합
   - Apple 로그인 통합
   - Supabase Auth를 사용한 세션 관리

2. **사용자 프로필 관리**
   - 회원가입 시 자동 프로필 생성
   - 등급 관리 (게스트/회원/프리미엄)
   - 프로필 조회 및 업데이트

3. **온보딩 플로우**
   - 자동 로그인 확인 기능이 있는 스플래시 화면
   - 로그인/회원가입 화면
   - 게스트 사용자를 위한 온보딩 팝업

#### 구현된 파일
- `lib/features/auth/data/auth_repository.dart`
- `lib/features/auth/data/user_profile_repository.dart`
- `lib/features/auth/domain/user_profile.dart`
- `lib/features/auth/presentation/screens/splash_screen.dart`
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/auth/presentation/widgets/onboarding_popup.dart`

#### 테스트
- **AuthRepository**: 11개 테스트
- **UserProfileRepository**: 13개 테스트
- **총계**: 24개 테스트 통과

---

### 2단계: 성경 구절 전달 시스템 ✅

#### 기능
1. **등급 기반 성경 구절 전달**
   - **게스트**: 하루 1개 랜덤 성경 구절 (중복 허용)
   - **회원**: 하루 3개 성경 구절 (중복 없음)
   - **프리미엄**: 일반 3개 + 프리미엄 3개 성경 구절/일

2. **성경 구절 카드 UI**
   - 성경 구절 내용이 담긴 아름다운 카드 디자인
   - 참조 표시
   - 카테고리 배지
   - 반응형 레이아웃

3. **일일 피드 화면**
   - 수직 스크롤링 PageView
   - 페이지 표시기
   - 한도 도달 시 콘텐츠 차단기

4. **중복 방지 로직**
   - 조회 기록 추적
   - 그날 이미 본 성경 구절 제외
   - JOIN 최적화를 사용한 RPC 함수

#### 구현된 파일
- `lib/features/scripture/domain/entities/scripture.dart`
- `lib/features/scripture/domain/repositories/scripture_repository.dart`
- `lib/features/scripture/data/repositories/supabase_scripture_repository.dart`
- `lib/features/scripture/presentation/screens/daily_feed_screen.dart`
- `lib/features/scripture/presentation/widgets/scripture_card.dart`
- `lib/features/scripture/presentation/widgets/content_blocker.dart`
- `lib/features/scripture/presentation/widgets/page_indicator.dart`

#### 데이터베이스
- **마이그레이션 002**: `scriptures` 테이블 (23개 레코드: 일반 15개 + 프리미엄 8개)
- **마이그레이션 003**: `user_scripture_history` 테이블
- **마이그레이션 004**: 4개 RPC 함수
- **pgTAP 테스트**: 15개 SQL 테스트

#### 테스트
- **ScriptureRepository**: 17개 테스트
- **ScriptureCard 위젯**: 9개 테스트
- **DailyFeedScreen 위젯**: 6개 테스트
- **ContentBlocker 위젯**: 9개 테스트
- **PageIndicator 위젯**: 4개 테스트
- **pgTAP (SQL)**: 15개 테스트
- **총계**: 60개 테스트

---

### 3단계: 기도 노트 시스템 ✅

#### 기능
1. **기도 노트 생성**
   - 여러 줄 텍스트 입력
   - 선택적 성경 구절 참조
   - Supabase에 실시간 저장

2. **캘린더 뷰 (내 서재)**
   - `table_calendar` 통합
   - 날짜 기반 노트 표시
   - 등급별 잠금/해제 표시기

3. **등급 기반 접근 제어**
   - **게스트**: 노트 작성 또는 보기 불가
   - **회원**: 작성 가능, 최근 3일만 보기 가능
   - **프리미엄**: 모든 노트에 무제한 접근

4. **자동 정리**
   - Edge Function이 7일 이상 된 회원 노트를 삭제
   - 프리미엄 노트는 영구 보관

#### 구현된 파일
- `lib/features/prayer_note/domain/entities/prayer_note.dart`
- `lib/features/prayer_note/domain/repositories/prayer_note_repository.dart`
- `lib/features/prayer_note/data/repositories/supabase_prayer_note_repository.dart`
- `lib/features/prayer_note/presentation/screens/my_library_screen.dart`
- `lib/features/prayer_note/presentation/widgets/prayer_note_input.dart`
- `lib/features/prayer_note/presentation/widgets/prayer_note_card.dart`
- `lib/features/prayer_note/presentation/widgets/prayer_calendar.dart`
- `lib/features/prayer_note/presentation/widgets/date_accessibility_indicator.dart`

#### 데이터베이스
- **마이그레이션 006**: RLS 정책이 적용된 `prayer_notes` 테이블
- **마이그레이션 007**: 7개 RPC 함수 (CRUD + 유틸리티)
- **Edge Function**: `cleanup-old-notes` (매일 예약 실행)
- **pgTAP 테스트**: 20개 SQL 테스트

#### 테스트
- **PrayerNoteRepository**: 23개 테스트
- **MyLibraryScreen 위젯**: 6개 테스트
- **PrayerNoteInput 위젯**: 9개 테스트
- **PrayerNoteCard 위젯**: 10개 테스트
- **PrayerCalendar 위젯**: 5개 테스트
- **DateAccessibilityIndicator 위젯**: 6개 테스트
- **총계**: 59개 테스트

---

### 4단계: 수익화 (70% 완료) 🔄

#### 구현된 기능 (4-1 & 4-2)

**4-1. 데이터베이스 및 구독 스키마** ✅
1. **구독 테이블**
   - 포괄적인 상태 추적 기능이 있는 `user_subscriptions` 테이블
   - 가격 정보가 포함된 `subscription_products` 테이블
   - 보안을 위한 RLS 정책

2. **RPC 함수** (5개 함수)
   - `get_subscription_status`
   - `activate_subscription`
   - `cancel_subscription`
   - `get_available_products`
   - `has_active_premium`

3. **Edge 함수** (4개 함수)
   - `verify-ios-receipt`: Apple 영수증 검증
   - `verify-android-receipt`: Google Play 구매 검증
   - `subscription-webhook`: 스토어 알림 처리
   - `check-expired-subscriptions`: 만료 확인을 위한 크론 잡

**4-2. 구독 기능 (TDD)** ✅
1. **도메인 레이어**
   - Subscription, SubscriptionProduct, PurchaseResult 엔티티
   - SubscriptionRepository 인터페이스 (7개 메서드)
   - IAPService 인터페이스 (7개 메서드)

2. **데이터 레이어**
   - SupabaseSubscriptionRepository 구현
   - iOS/Android용 IAPServiceImpl (`in_app_purchase` 패키지 사용)

3. **상태 레이어 (Riverpod 프로바이더)**
   - `subscriptionStatusProvider`: 현재 구독 로드
   - `availableProductsProvider`: 스토어에서 상품 가져오기
   - `purchaseControllerProvider`: 구매 플로우 처리
   - `restorePurchaseControllerProvider`: 이전 구매 복원
   - `hasPremiumProvider`: 프리미엄 접근 권한 Boolean 확인

#### 구현된 파일
- `lib/features/subscription/domain/entities/subscription.dart`
- `lib/features/subscription/domain/repositories/subscription_repository.dart`
- `lib/features/subscription/domain/services/iap_service.dart`
- `lib/features/subscription/data/repositories/supabase_subscription_repository.dart`
- `lib/features/subscription/data/services/iap_service_impl.dart`
- `lib/features/subscription/presentation/providers/subscription_providers.dart`

#### 데이터베이스
- **마이그레이션 008**: `user_subscriptions` 및 `subscription_products` 테이블
- **마이그레이션 009**: 5개 RPC 함수
- **Edge 함수**: 4개 TypeScript/Deno 함수
- **pgTAP 테스트**: 25개 SQL 테스트

#### 테스트
- **SubscriptionRepository**: 32개 테스트
- **IAPService**: 7개 테스트
- **SubscriptionProviders**: 16개 테스트
- **pgTAP (SQL)**: 25개 테스트
- **총계**: 55개 테스트 (UI 테스트 대기 중)

#### 대기 중인 기능 (4-3)
- PremiumLandingScreen UI
- ManageSubscriptionScreen UI
- SubscriptionProductCard 위젯
- PurchaseButton 위젯
- UpsellDialog 위젯
- Scripture Feed 및 Prayer Archive와 통합
- iOS/Android 구매 플로우 통합 테스트

**예상**: 26개 추가 위젯/통합 테스트

---

## 상태 관리

### Riverpod 프로바이더

#### 인증 프로바이더

**파일**: `lib/features/auth/providers/auth_providers.dart`

```dart
// 핵심 프로바이더
final authRepositoryProvider = Provider<AuthRepository>((ref) {...});
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {...});

// 상태 프로바이더
final currentUserProvider = StreamProvider<User?>((ref) {...});
final authStateProvider = StreamProvider<AuthState>((ref) {...});

// 사용자 프로필 프로바이더
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {...});
final currentUserTierProvider = FutureProvider<UserTier>((ref) async {...});
```

**사용법**:
```dart
// 위젯에서
final userTier = ref.watch(currentUserTierProvider);
userTier.when(
  data: (tier) => Text('등급: $tier'),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('오류: $err'),
);
```

---

#### 성경 구절 프로바이더

**파일**: `lib/features/scripture/presentation/providers/scripture_providers.dart`

```dart
// 리포지토리 프로바이더
final scriptureRepositoryProvider = Provider<ScriptureRepository>((ref) {...});

// 매일의 성경 구절 (등급 기반)
final dailyScripturesProvider = FutureProvider<List<Scripture>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  final tier = await ref.watch(currentUserTierProvider.future);
  final repository = ref.watch(scriptureRepositoryProvider);

  if (tier == UserTier.guest) {
    return repository.getRandomScripture(1);
  } else {
    return repository.getDailyScriptures(userId: user!.id, count: 3);
  }
});

// 프리미엄 성경 구절 (프리미엄 사용자 전용)
final premiumScripturesProvider = FutureProvider<List<Scripture>>((ref) async {...});

// 성경 구절 조회 추적기
final scriptureViewTrackerProvider = Provider((ref) {
  return ScriptureViewTracker(ref.watch(scriptureRepositoryProvider));
});
```

---

#### 기도 노트 프로바이더

**파일**: `lib/features/prayer_note/presentation/providers/prayer_note_providers.dart`

```dart
// 리포지토리 프로바이더
final prayerNoteRepositoryProvider = Provider<PrayerNoteRepository>((ref) {...});

// 기도 노트 목록 (자동 새로고침)
final prayerNotesProvider = StreamProvider.family<List<PrayerNote>, DateTime>(
  (ref, date) {
    final userId = ref.watch(currentUserProvider).value!.id;
    return ref.watch(prayerNoteRepositoryProvider)
      .getPrayerNotesByDate(userId: userId, date: date);
  }
);

// 날짜 접근성 검사기
final dateAccessibilityProvider = FutureProvider.family<bool, DateTime>(
  (ref, date) async {
    final userId = ref.watch(currentUserProvider).value!.id;
    final result = await ref.watch(prayerNoteRepositoryProvider)
      .isDateAccessible(userId: userId, date: date);
    return result.fold((l) => false, (r) => r);
  }
);

// 노트 생성 컨트롤러
final createPrayerNoteProvider = StateNotifierProvider<CreatePrayerNoteNotifier, AsyncValue<PrayerNote?>>(
  (ref) => CreatePrayerNoteNotifier(ref.watch(prayerNoteRepositoryProvider))
);
```

---

#### 구독 프로바이더

**파일**: `lib/features/subscription/presentation/providers/subscription_providers.dart`

```dart
// 리포지토리 및 서비스 프로바이더
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {...});
final iapServiceProvider = Provider<IAPService>((ref) {...});

// 구독 상태
final subscriptionStatusProvider = FutureProvider<Subscription?>((ref) async {
  final userId = ref.watch(currentUserProvider).value?.id;
  if (userId == null) return null;

  final result = await ref.watch(subscriptionRepositoryProvider)
    .getSubscriptionStatus(userId: userId);
  return result.fold((l) => null, (r) => r);
});

// 사용 가능한 상품
final availableProductsProvider = FutureProvider<List<SubscriptionProduct>>((ref) async {
  final result = await ref.watch(subscriptionRepositoryProvider)
    .getAvailableProducts();
  return result.fold((l) => [], (r) => r);
});

// 프리미엄 여부 (boolean)
final hasPremiumProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(currentUserProvider).value?.id;
  if (userId == null) return false;

  final result = await ref.watch(subscriptionRepositoryProvider)
    .hasActivePremium(userId: userId);
  return result.fold((l) => false, (r) => r);
});

// 구매 컨트롤러
final purchaseControllerProvider = StateNotifierProvider<PurchaseController, AsyncValue<PurchaseResult?>>(
  (ref) => PurchaseController(
    ref.watch(iapServiceProvider),
    ref.watch(subscriptionRepositoryProvider),
  )
);

// 구매 복원 컨트롤러
final restorePurchaseControllerProvider = StateNotifierProvider<RestorePurchaseController, AsyncValue<List<PurchaseResult>>>(
  (ref) => RestorePurchaseController(
    ref.watch(iapServiceProvider),
    ref.watch(subscriptionRepositoryProvider),
  )
);
```

---

## 테스트 커버리지

### 테스트 통계

| 카테고리 | 테스트 파일 | 테스트 케이스 | 상태 |
|----------|------------|------------|--------|
| **인증** | 5 | 24 | ✅ 통과 |
| **성경 구절** | 5 + 1 SQL | 60 (Dart 45 + pgTAP 15) | ✅ 통과 |
| **기도 노트** | 6 + 1 SQL | 59 (Dart 39 + pgTAP 20) | ✅ 통과 |
| **구독** | 3 + 1 SQL | 55 (Dart 55 + pgTAP 25) | ✅ 통과 |
| **총계** | 20 | 198 | ✅ 통과 |

### 레이어별 커버리지

| 레이어 | 목표 | 현재 |
|-------|--------|---------|
| 리포지토리 | 95%+ | ~95% |
| 서비스 | 95%+ | ~95% |
| 프로바이더 | 90%+ | ~90% |
| 위젯 | 80%+ | ~85% |
| 스크린 | 70%+ | ~70% |

### 테스트 파일

#### 1단계: 인증
```
test/features/auth/
├── auth_repository_test.dart (11개 테스트)
├── user_profile_repository_test.dart (13개 테스트)
└── presentation/
    ├── splash_screen_test.dart
    ├── login_screen_test.dart
    └── onboarding_popup_test.dart
```

#### 2단계: 성경 구절
```
test/features/scripture/
├── data/
│   └── repositories/
│       └── scripture_repository_test.dart (17개 테스트)
└── presentation/
    ├── screens/
    │   └── daily_feed_screen_test.dart (6개 테스트)
    └── widgets/
        ├── scripture_card_test.dart (9개 테스트)
        ├── content_blocker_test.dart (9개 테스트)
        └── page_indicator_test.dart (4개 테스트)

supabase/tests/
└── scripture_rpc_test.sql (15개 pgTAP 테스트)
```

#### 3단계: 기도 노트
```
test/features/prayer_note/
├── data/
│   └── repositories/
│       └── prayer_note_repository_test.dart (23개 테스트)
└── presentation/
    ├── screens/
    │   └── my_library_screen_test.dart (6개 테스트)
    └── widgets/
        ├── prayer_note_input_test.dart (9개 테스트)
        ├── prayer_note_card_test.dart (10개 테스트)
        ├── prayer_calendar_test.dart (5개 테스트)
        └── date_accessibility_indicator_test.dart (6개 테스트)

supabase/tests/
└── prayer_note_test.sql (20개 pgTAP 테스트)
```

#### 4단계: 구독
```
test/features/subscription/
├── data/
│   ├── repositories/
│   │   └── subscription_repository_test.dart (32개 테스트)
│   └── services/
│       └── iap_service_test.dart (7개 테스트)
└── presentation/
    └── providers/
        └── subscription_providers_test.dart (16개 테스트)

supabase/tests/
└── subscription_test.sql (25개 pgTAP 테스트)
```

### 테스트 명령어

```bash
# 모든 Dart 테스트 실행
flutter test

# 커버리지와 함께 테스트 실행
flutter test --coverage

# 특정 기능 테스트 실행
flutter test test/features/auth/
flutter test test/features/scripture/
flutter test test/features/prayer_note/
flutter test test/features/subscription/

# pgTAP 테스트 실행 (Supabase)
cd supabase
supabase test db
```

---

## 파일 구조

```
severalbible/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   │   └── failures.dart
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   ├── services/
│   │   │   └── supabase_service.dart
│   │   └── utils/
│   │
│   └── features/
│       ├── auth/
│       │   ├── domain/
│       │   │   ├── user_profile.dart
│       │   │   └── user_tier.dart
│       │   ├── data/
│       │   │   ├── auth_repository.dart
│       │   │   ├── user_profile_repository.dart
│       │   │   └── user_profile_data_source.dart
│       │   ├── providers/
│       │   │   └── auth_providers.dart
│       │   └── presentation/
│       │       ├── screens/
│       │       │   ├── splash_screen.dart
│       │       │   ├── login_screen.dart
│       │       │   └── home_screen.dart
│       │       └── widgets/
│       │           └── onboarding_popup.dart
│       │
│       ├── scripture/
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── scripture.dart
│       │   │   └── repositories/
│       │   │       └── scripture_repository.dart
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── scripture_datasource.dart
│       │   │   │   └── supabase_scripture_datasource.dart
│       │   │   └── repositories/
│       │   │       └── supabase_scripture_repository.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── scripture_providers.dart
│       │       ├── screens/
│       │       │   └── daily_feed_screen.dart
│       │       └── widgets/
│       │           ├── scripture_card.dart
│       │           ├── content_blocker.dart
│       │           └── page_indicator.dart
│       │
│       ├── prayer_note/
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── prayer_note.dart
│       │   │   └── repositories/
│       │   │       └── prayer_note_repository.dart
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── prayer_note_datasource.dart
│       │   │   │   └── supabase_prayer_note_datasource.dart
│       │   │   └── repositories/
│       │   │       └── supabase_prayer_note_repository.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── prayer_note_providers.dart
│       │       ├── screens/
│       │       │   └── my_library_screen.dart
│       │       └── widgets/
│       │           ├── prayer_note_input.dart
│       │           ├── prayer_note_card.dart
│       │           ├── prayer_calendar.dart
│       │           └── date_accessibility_indicator.dart
│       │
│       └── subscription/
│           ├── domain/
│           │   ├── entities/
│           │   │   └── subscription.dart
│           │   ├── repositories/
│           │   │   └── subscription_repository.dart
│           │   └── services/
│           │       └── iap_service.dart
│           ├── data/
│           │   ├── datasources/
│           │   │   ├── subscription_datasource.dart
│           │   │   └── supabase_subscription_datasource.dart
│           │   ├── repositories/
│           │   │   └── supabase_subscription_repository.dart
│           │   └── services/
│           │       └── iap_service_impl.dart
│           └── presentation/
│               └── providers/
│                   └── subscription_providers.dart
│
├── test/
│   ├── features/
│   │   ├── auth/
│   │   ├── scripture/
│   │   ├── prayer_note/
│   │   └── subscription/
│   └── widget_test.dart
│
├── supabase/
│   ├── migrations/
│   │   ├── 001_create_user_profiles.sql
│   │   ├── 002_create_scriptures.sql
│   │   ├── 003_create_user_scripture_history.sql
│   │   ├── 004_create_scripture_rpc_functions.sql
│   │   ├── 005_insert_scripture_dummy_data.sql
│   │   ├── 006_create_prayer_notes.sql
│   │   ├── 007_create_prayer_note_rpc_functions.sql
│   │   ├── 008_create_user_subscriptions.sql
│   │   └── 009_create_subscription_rpc_functions.sql
│   ├── functions/
│   │   ├── verify-ios-receipt/
│   │   ├── verify-android-receipt/
│   │   ├── subscription-webhook/
│   │   ├── check-expired-subscriptions/
│   │   └── cleanup-old-notes/
│   └── tests/
│       ├── scripture_rpc_test.sql
│       ├── prayer_note_test.sql
│       └── subscription_test.sql
│
├── pubspec.yaml
├── CLAUDE.md
├── PLANNER.md
├── SPEC.md (이 파일)
└── README.md
```

**총 Dart 파일 수**: 51
**총 테스트 파일 수**: 20
**총 마이그레이션 수**: 9
**총 Edge 함수 수**: 5

---

## API 문서

### Supabase RPC 함수

#### 성경 구절 API

##### 1. get_random_scripture

**목적**: 게스트 사용자를 위해 랜덤 성경 구절 가져오기 (중복 허용)

**서명**:
```sql
get_random_scripture(p_count INTEGER DEFAULT 1)
RETURNS TABLE (
  id UUID,
  book TEXT,
  chapter INTEGER,
  verse INTEGER,
  content TEXT,
  reference TEXT,
  is_premium BOOLEAN,
  category TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
```

**사용법**:
```dart
final result = await supabase
  .rpc('get_random_scripture', params: {'p_count': 1});
```

---

##### 2. get_daily_scriptures

**목적**: 회원 사용자를 위해 중복되지 않는 성경 구절 가져오기

**서명**:
```sql
get_daily_scriptures(
  p_user_id UUID,
  p_count INTEGER DEFAULT 3
)
RETURNS TABLE (...)
```

**로직**:
- 오늘 이미 본 성경 구절 제외
- 프리미엄 성경 구절 제외
- 남은 풀에서 랜덤 선택

**사용법**:
```dart
final result = await supabase.rpc('get_daily_scriptures', params: {
  'p_user_id': userId,
  'p_count': 3,
});
```

---

##### 3. get_premium_scriptures

**목적**: 프리미엄 사용자를 위해 프리미엄 성경 구절 가져오기

**서명**:
```sql
get_premium_scriptures(
  p_user_id UUID,
  p_count INTEGER DEFAULT 3
)
RETURNS TABLE (...)
```

**로직**:
- `is_premium = true`인 성경 구절만 반환
- 오늘 이미 본 프리미엄 성경 구절 제외
- 프리미엄 등급 필요 (앱 로직에서 강제)

---

##### 4. record_scripture_view

**목적**: 사용자가 성경 구절을 봤음을 기록

**서명**:
```sql
record_scripture_view(
  p_user_id UUID,
  p_scripture_id UUID
)
RETURNS VOID
```

**사용법**:
```dart
await supabase.rpc('record_scripture_view', params: {
  'p_user_id': userId,
  'p_scripture_id': scriptureId,
});
```

---

#### 기도 노트 API

##### 1. create_prayer_note

**서명**:
```sql
create_prayer_note(
  p_user_id UUID,
  p_content TEXT,
  p_scripture_id UUID DEFAULT NULL
)
RETURNS UUID
```

**반환**: 새로 생성된 기도 노트의 ID

---

##### 2. get_prayer_notes_by_date

**서명**:
```sql
get_prayer_notes_by_date(
  p_user_id UUID,
  p_date DATE
)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  scripture_id UUID,
  content TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  scripture_reference TEXT,
  scripture_content TEXT
)
```

**참고**:
- `scripture_id`가 있는 경우 scriptures 테이블과 조인
- RLS가 자동으로 등급 기반 필터링 적용

---

##### 3. is_date_accessible

**서명**:
```sql
is_date_accessible(
  p_user_id UUID,
  p_date DATE
)
RETURNS BOOLEAN
```

**로직**:
```sql
-- 회원 등급: 날짜가 최근 3일 이내인 경우 접근 가능
-- 프리미엄 등급: 항상 접근 가능
-- 게스트 등급: 접근 불가
```

---

#### 구독 API

##### 1. get_subscription_status

**서명**:
```sql
get_subscription_status(p_user_id UUID DEFAULT auth.uid())
RETURNS TABLE (
  subscription_id UUID,
  product_id TEXT,
  status TEXT,
  expires_at TIMESTAMPTZ,
  is_active BOOLEAN
)
```

**반환**: 계산된 `is_active` 필드가 포함된 현재 구독

---

##### 2. activate_subscription

**서명**:
```sql
activate_subscription(
  p_user_id UUID,
  p_product_id TEXT,
  p_platform TEXT,
  p_transaction_id TEXT,
  p_original_transaction_id TEXT DEFAULT NULL
)
RETURNS JSON
```

**부수 효과**:
- `user_subscriptions` 테이블 삽입 또는 업데이트
- `user_profiles.tier`를 'premium'으로 업데이트
- 상품 기간에 따라 `expires_at` 계산

**반환**:
```json
{
  "subscription_id": "uuid",
  "expires_at": "2025-02-15T12:00:00Z",
  "status": "success"
}
```

---

##### 3. has_active_premium

**서명**:
```sql
has_active_premium(p_user_id UUID)
RETURNS BOOLEAN
```

**로직**:
```sql
SELECT EXISTS (
  SELECT 1 FROM user_subscriptions
  WHERE user_id = p_user_id
    AND subscription_status = 'active'
    AND (expires_at IS NULL OR expires_at > NOW())
)
```

---

### Flutter 리포지토리 메서드

모든 리포지토리 메서드는 명시적인 오류 처리를 위해 `Either<Failure, T>` 타입을 반환합니다:

**예시**:
```dart
final result = await scriptureRepository.getDailyScriptures(
  userId: userId,
  count: 3,
);

result.fold(
  (failure) => print('오류: ${failure.message}'),
  (scriptures) => print('성공: ${scriptures.length}개 성경 구절'),
);
```

**실패 타입**:
```dart
abstract class Failure {
  final String message;
}

class DatabaseFailure extends Failure {...}
class NetworkFailure extends Failure {...}
class CacheFailure extends Failure {...}
class ServerFailure extends Failure {...}
```

---

## 향후 로드맵

### 5단계: 최적화 및 출시 (대기 중)

**목표**:
1. 성능 최적화
2. 오프라인 지원 (선택 사항)
3. 앱 스토어 준비
4. QA 및 버그 수정

**작업**:
- `cached_network_image`를 사용한 이미지 캐싱
- ListView 지연 로딩 최적화
- Hive를 사용한 오프라인 성경 구절 캐싱 (선택 사항)
- 앱 아이콘 및 스플래시 화면 디자인
- 스토어 스크린샷 및 설명
- 개인정보 처리방침 및 서비스 약관
- TestFlight/Google Play 내부 테스트
- 최종 QA 및 버그 수정

**예상 기간**: 2-3주

---

### 4-3단계 완료 (다음 우선순위)

**남은 UI 작업**:
1. PremiumLandingScreen (7개 위젯 테스트)
2. ManageSubscriptionScreen (6개 위젯 테스트)
3. SubscriptionProductCard 위젯 (5개 테스트)
4. PurchaseButton 위젯 (4개 테스트)
5. UpsellDialog 위젯 (4개 테스트)
6. 성경 구절 피드 통합 (3개 테스트)
7. 기도 보관함 통합 (3개 테스트)
8. iOS/Android 구매 플로우 (17개 통합 테스트)

**예상 기간**: 1-2주

---

## 문서 업데이트

**최종 업데이트**: 2026-01-21

**관리자**: 개발팀
**리포지토리**: GitHub (비공개)
**Supabase 프로젝트**: [프로젝트 URL]

**관련 문서**:
- `CLAUDE.md`: 프로젝트 지침 및 에이전트 사용법
- `PLANNER.md`: 상위 수준 개발 계획
- `README.md`: 시작 가이드
- `checklist/phase*.md`: 상세 TDD 체크리스트

---

## 결론

One Message는 다음과 같이 잘 설계된 영적 성장 애플리케이션입니다:
- **클린 아키텍처**로 유지보수성 확보
- **TDD 방법론**으로 신뢰성 확보 (198개 테스트)
- **함수형 프로그래밍**으로 예측 가능성 확보
- **Supabase BaaS**로 확장성 확보
- **프리미엄 모델**로 지속 가능성 확보

현재 상태: **74% 완료**, 4-3단계 UI 구현 및 5단계 출시 준비 완료.

---

*이 명세서는 살아있는 문서이며 프로젝트가 발전함에 따라 업데이트될 것입니다.*
