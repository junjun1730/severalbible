# Claude.md - 오늘을 여는 말씀 (One Message) 프로젝트

## 문서 정보

- **프로젝트명**: 오늘을 여는 말씀 (One Message)
- **문서 버전**: v1.3 (Simpler MVP)
- **플랫폼**: Flutter (iOS/Android)
- **백엔드**: Supabase (BaaS)
- **최종 수정일**: 2026-01-14
- **변경 사항**: 감정 기반 처방 삭제, 비로그인 혜택 축소(1개)

---

## 1. 프로젝트 개요

### 핵심 가치

이 프로젝트는 세 가지 핵심 가치를 중심으로 설계되었습니다:

1. **Read (읽기)**: 매일 제공되는 경전과 설화를 정독
2. **Write (쓰기)**: 말씀에 대한 묵상과 기도를 기록
3. **Archive (보관)**: 나만의 영적 자산을 축적

### 프로젝트 목표

- 사용자에게 일일 영적 콘텐츠 제공
- 묵상 기록을 통한 영적 성장 지원
- 프리미엄 구독을 통한 지속 가능한 비즈니스 모델 구축

### 기술 스택 선택 이유

- **Flutter**: 단일 코드베이스로 iOS/Android 동시 개발
- **Supabase**:
  - PostgreSQL 기반 실시간 데이터베이스
  - 내장 인증 시스템 (OAuth 포함)
  - Row Level Security (RLS)로 보안 강화
  - Edge Functions로 서버리스 백엔드
  - Storage로 미디어 관리

---

## 2. 사용자 등급 및 혜택

| 구분            | Guest (비로그인)      | Member (무료 회원)            | Premium (유료 구독)      |
| --------------- | --------------------- | ----------------------------- | ------------------------ |
| **데이터 로직** | 완전 랜덤 (중복 가능) | 노-중복 (No-Duplicate)        | 노-중복 + 프리미엄 DB    |
| **제공 수량**   | 매일 1개              | 매일 3개                      | 매일 3개 + '3개 더 보기' |
| **기도 노트**   | 작성 불가             | 작성 가능 / 최근 3일치만 조회 | 전체 기간 무제한 조회    |
| **아카이빙**    | 저장 불가             | 최근 7일 기록 저장            | 무제한 영구 보관         |

### 등급별 핵심 차별점

- **Guest**: 체험용, 최소한의 기능만 제공하여 회원가입 유도
- **Member**: 기본적인 영적 일과 수행 가능, 단 기록 보관 제한
- **Premium**: 완전한 영적 여정 아카이빙 및 확장 콘텐츠 접근

---

## 3. 핵심 기능 요구사항

### F1. 로그인 유도 (Onboarding Funnel)

**목적**: Guest 사용자를 Member로 전환

**구현 시점**:

1. **앱 실행 시**
   - Guest에게 팝업 노출: "로그인하고 매일 3배 더 많은 은혜를 받으세요"
2. **콘텐츠 소진 시**
   - 비로그인 상태에서 1개 카드를 다 읽고 스크롤 시도 시
   - 로그인 유도 화면(Blocker) 노출

**Supabase 인증**:

- Google OAuth
- Apple Sign-In
- 이메일/비밀번호 (선택적)

**UX 고려사항**:

- 너무 공격적이지 않게, 가치 중심 메시지 사용
- "은혜", "지혜", "영적 성장" 등의 키워드 활용

---

### F2. 메인 화면 (Daily Feed)

**화면 구성**: 수직 스크롤 카드 형태 (Flutter ListView/PageView)

**등급별 동작**:

1. **Guest**

   - 카드 1장만 노출
   - 완전 랜덤 (같은 내용이 다음 날 다시 나올 수 있음)
   - Supabase RPC: `get_random_scripture(1, false)`

2. **Member**

   - 카드 3장 수직 스크롤 제공
   - 중복 방지 로직 적용 (이미 본 것은 제외)
   - 하루에 3개 모두 소진 후에는 내일까지 대기
   - Supabase RPC: `get_daily_scriptures(user_id, 3, false)`

3. **Premium**
   - 기본 3장 제공 (Member와 동일)
   - 3장 이후 하단에 **[말씀 더 받기]** 버튼 활성화
   - 프리미엄 전용 DB에서 추가 3개 제공
   - Supabase RPC: `get_premium_scriptures(user_id, 3)`

**Supabase 데이터베이스 구조**:

- `scriptures` 테이블: 모든 경전 콘텐츠 (is_premium 플래그)
- `user_scripture_history` 테이블: 읽은 기록
- Row Level Security (RLS)로 권한 관리

---

### F3. 기도 노트 (Prayer Note)

**작성 기능**:

- 위치: 말씀 카드 하단 **[묵상 남기기]** 버튼
- 형태: Flutter TextField (다중 라인)
- 제한: Guest는 접근 불가
- 저장: Supabase `prayer_notes` 테이블에 실시간 저장

**조회 기능 (Calendar View)**:

- 위치: '내 서재' 탭
- UI: Flutter `table_calendar` 패키지 활용
- 데이터: Supabase Realtime Subscription

**등급별 제한**:

| 등급    | 조회 범위 | 제약                      | Supabase RLS                              |
| ------- | --------- | ------------------------- | ----------------------------------------- |
| Guest   | 불가      | 작성 자체가 불가능        | -                                         |
| Member  | 최근 3일  | 이전 기록은 자물쇠🔒 표시 | `created_at >= now() - interval '3 days'` |
| Premium | 전체 기간 | 무제한 열람 및 수정 가능  | `user_id = auth.uid()`                    |

**저장 정책**:

- Member: Supabase Edge Function으로 7일 경과 기록 자동 삭제
- Premium: 영구 보관 (RLS 정책으로 보호)

---

### F4. 유료화 모델 (Upselling)

**전환 포인트 (Conversion Points)**:

1. **Archives (보관 제한)**

   - 상황: Member가 3일 이전 기록 조회 시도
   - 메시지: "지난 기도를 다시 읽어보며 은혜를 되새기세요"
   - CTA: 프리미엄 구독 안내

2. **More Content (콘텐츠 확장)**
   - 상황: Member가 당일 3개 카드 모두 소진
   - 메시지: "오늘 더 많은 지혜가 필요하신가요?"
   - CTA: 프리미엄 구독 안내

**결제 시스템**:

- iOS: In-App Purchase (StoreKit)
- Android: Google Play Billing
- Flutter 패키지: `in_app_purchase` 또는 `purchases_flutter` (RevenueCat)
- Supabase: `user_subscriptions` 테이블에 구독 상태 저장

**가격 정책**:

- 월간 구독: ₩9,900 (추후 조정 가능)
- 연간 구독: ₩99,000 (2개월 무료)

---

## 4. 개발 워크플로우 (TDD 기반)

이 프로젝트는 **Test-Driven Development (TDD)** 방법론을 기반으로 개발됩니다.

### TDD 개발 플로우

```
페이즈 시작
    ↓
[Phase Planning Agent]
    - 페이즈별 개발 계획 수립
    - TDD 체크리스트 생성
    - 구현 순서 결정
    ↓
[TDD Cycle 반복]
    ✓ 테스트 케이스 1 작성 (Red)
    ✓ 구현 1 (테스트 통과) (Green)
    ✓ 리팩토링 1 (Refactor)
    ✓ 테스트 케이스 2 작성
    ✓ 구현 2 (테스트 통과)
    ✓ 리팩토링 2
    ...
    ↓
[TDD Checklist Manager]
    - 진행 중 실시간 체크리스트 업데이트
    - 완료/미완료 항목 추적
    - 다음 작업 우선순위 제시
    ↓
[Test-First Validator]
    - TDD 원칙 준수 확인
    - 테스트 커버리지 검증
    - 테스트 품질 검토
    ↓
페이즈 완료
    ↓
[Documentation Generator]
    - API 문서 자동 생성
    - 기술 문서 작성
    - 코드 주석 추가
    - 아키텍처 다이어그램 업데이트
    ↓
[Code Review Agent]
    - 최종 코드 리뷰
    - 베스트 프랙티스 준수 확인
    - 성능 및 보안 검토
    ↓
다음 페이즈로
```

### TDD 핵심 원칙

**Red-Green-Refactor 사이클**:

1. **Red**: 실패하는 테스트 먼저 작성
2. **Green**: 테스트를 통과하는 최소한의 코드 작성
3. **Refactor**: 중복 제거 및 코드 개선

**TDD 규칙**:

- 테스트 없이는 프로덕션 코드를 작성하지 않는다
- 실패하는 테스트 없이는 새로운 테스트를 작성하지 않는다
- 테스트를 통과하는 최소한의 코드만 작성한다

### Flutter TDD 특화 사항

**테스트 레이어**:

1. **Unit Tests**: 비즈니스 로직, Service, Repository
2. **Widget Tests**: UI 컴포넌트, 상태 관리
3. **Integration Tests**: 전체 플로우, Supabase 통합

**Mocking 전략**:

- Supabase Client: `mockito` 또는 `mocktail`로 모킹
- 실제 DB 호출 없이 로컬에서 테스트 가능

### 테스트 커버리지 목표

| 레이어                   | 커버리지 목표 | 우선순위 |
| ------------------------ | ------------- | -------- |
| Repository (Data)        | 95% 이상      | 최우선   |
| Service (Business Logic) | 95% 이상      | 최우선   |
| Provider/BLoC (State)    | 90% 이상      | 높음     |
| Widget                   | 80% 이상      | 보통     |
| Screen                   | 70% 이상      | 보통     |
| Supabase Edge Functions  | 90% 이상      | 높음     |

### 테스트 도구 및 프레임워크

**Flutter Testing**:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mockito: ^5.4.0
  mocktail: ^1.0.0
  build_runner: ^2.4.0
```

**Supabase Testing**:

- Supabase CLI로 로컬 개발 환경 구축
- pgTAP으로 SQL 함수 테스트
- Postman/Insomnia로 Edge Functions 테스트

**CI/CD**:

- GitHub Actions
- Codemagic (Flutter 특화 CI/CD)
- 자동화된 테스트 실행 및 커버리지 리포트

### TDD 작업 시 주의사항

**해야 할 것 (Do)**:

- ✅ 테스트를 먼저 작성한다
- ✅ Supabase Client는 항상 Mock으로 테스트
- ✅ Widget 테스트 시 `pumpWidget`과 `pumpAndSettle` 활용
- ✅ 비동기 테스트는 `async/await` 명확히 사용
- ✅ 각 Repository는 독립적으로 테스트 가능하게
- ✅ RLS 정책도 테스트 시나리오에 포함

**하지 말아야 할 것 (Don't)**:

- ❌ 실제 Supabase 프로덕션 DB로 테스트하지 않는다
- ❌ UI 테스트에서 실제 네트워크 호출하지 않는다
- ❌ Widget 테스트에서 너무 많은 로직을 검증하지 않는다
- ❌ 테스트 간 의존성을 만들지 않는다 (독립적 실행 보장)
- ❌ Golden 테스트는 픽셀 퍼펙트가 목적이 아님 (레이아웃 검증용)

---

## 5. 개발 원칙 (함수형 프로그래밍 지향)

이 프로젝트는 안정적이고 예측 가능한 코드베이스를 위해 **함수형 프로그래밍(Functional Programming)** 원칙을 적극적으로 도입합니다.

### 핵심 원칙

1. **불변성 (Immutability)**

   - 모든 데이터 모델과 상태 클래스는 불변(Immutable)으로 정의합니다.
   - 데이터 변경 시 기존 객체를 수정하는 대신 `copyWith` 메서드를 통해 새로운 인스턴스를 생성합니다.
   - Flutter의 `final` 키워드와 `freezed` 패키지 활용을 권장합니다.

2. **순수 함수 (Pure Functions)**

   - 비즈니스 로직(Domain/Service 레이어)은 가능한 순수 함수로 작성합니다.
   - 동일한 입력에 대해 항상 동일한 출력을 보장하며, 외부 상태를 변경하지 않습니다.
   - 이는 TDD 환경에서 테스트 코드 작성을 매우 단순화합니다.

3. **선언적 프로그래밍 (Declarative Programming)**

   - "어떻게(How)"보다 "무엇(What)"을 할 것인지에 집중합니다.
   - UI는 현재 상태(State)의 함수로서 표현되며, 상태 변화에 따라 선언적으로 렌더링됩니다.

4. **부작용 격리 (Side Effect Isolation)**

   - IO(데이터베이스, 네트워크)와 같이 부작용이 발생하는 작업은 Repository와 Data Source 레이어로 엄격히 분리합니다.
   - 로직 내부에서 직접적인 전역 상태 접근이나 외부 API 호출을 지양합니다.

5. **표현력 있는 타입 시스템 (Expressive Type System)**
   - 함수의 시그니처만으로도 의도를 명확히 파악할 수 있도록 설계합니다.
   - 에러 처리는 예외 던지기(Throw)보다 명시적인 리턴 타입(예: Either)을 활용하는 방향을 지향합니다.

## 7. 연락처 및 리소스

- **개발 Repository**: [GitHub 링크]
- **Supabase Dashboard**: [Supabase 프로젝트 URL]
- **CI/CD Dashboard**: [Codemagic/GitHub Actions 링크]
- **테스트 커버리지**: [Codecov 링크]

**이 문서는 살아있는 문서입니다. 프로젝트 진행에 따라 지속적으로 업데이트됩니다.**

**Flutter + Supabase + TDD로 안정적이고 확장 가능한 앱을 만듭니다.**
