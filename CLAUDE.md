# Claude.md - One Message Project

## Document Information

- **Project Name**: One Message
- **Document Version**: v1.3 (Simpler MVP)
- **Platform**: Flutter (iOS/Android)
- **Backend**: Supabase (BaaS)
- **Last Modified**: 2026-01-14
- **Changes**: Removed emotion-based prescriptions, reduced non-login benefits (to 1)

---

## 1. Project Overview

### Core Values

This project is designed around three core values:

1. **Read**: Read daily scriptures and fables carefully.
2. **Write**: Record meditations and prayers on the word.
3. **Archive**: Accumulate your own spiritual assets.

### Project Goals

- Provide daily spiritual content to users.
- Support spiritual growth through meditation records.
- Build a sustainable business model through premium subscriptions.

### Reason for Tech Stack Selection

- **Flutter**: Simultaneous iOS/Android development with a single codebase.
- **Supabase**:
  - PostgreSQL-based real-time database.
  - Built-in authentication system (including OAuth).
  - Enhanced security with Row Level Security (RLS).
  - Serverless backend with Edge Functions.
  - Media management with Storage.

---

## 2. User Tiers & Benefits

| Category        | Guest (Non-login)                      | Member (Free)                    | Premium (Paid Subscription) |
| --------------- | -------------------------------------- | -------------------------------- | --------------------------- |
| **Data Logic**  | Completely Random (Duplicates allowed) | No-Duplicate                     | No-Duplicate + Premium DB   |
| **Quantity**    | 1 per day                              | 3 per day                        | 3 per day + 'See 3 More'    |
| **Prayer Note** | Cannot write                           | Write enabled / View last 3 days | Unlimited view of all time  |
| **Archiving**   | Cannot save                            | Save last 7 days records         | Unlimited permanent storage |

### Core Differentiators by Tier

- **Guest**: For trial purposes, offering minimal features to induce sign-up.
- **Member**: Can perform basic spiritual routines, but with limited record retention.
- **Premium**: Access to complete spiritual journey archiving and expanded content.

---

## 3. Core Feature Requirements

### F1. Onboarding Funnel

**Goal**: Convert Guest users to Members.

**Implementation Timing**:

1. **App Launch**
   - Show popup to Guest: "Log in and receive 3 times more grace daily."
2. **Content Exhaustion**
   - When a non-login user finishes reading 1 card and attempts to scroll.
   - Show login induction screen (Blocker).

**Supabase Auth**:

- Google OAuth
- Apple Sign-In
- Email/Password (Optional)

**UX Considerations**:

- Use value-centric messages without being too aggressive.
- Utilize keywords like "Grace", "Wisdom", "Spiritual Growth".

---

### F2. Main Screen (Daily Feed)

**Screen Composition**: Vertical scrolling card format (Flutter ListView/PageView).

**Behavior by Tier**:

1. **Guest**

   - Show only 1 card.
   - Completely random (Same content may appear the next day).
   - Supabase RPC: `get_random_scripture(1, false)`

2. **Member**

   - Provide 3 cards with vertical scrolling.
   - Apply non-duplicate logic (Exclude already viewed).
   - Wait until tomorrow after consuming all 3 for the day.
   - Supabase RPC: `get_daily_scriptures(user_id, 3, false)`

3. **Premium**
   - Provide basic 3 cards (Same as Member).
   - **[Get More Words]** button activates at the bottom after 3 cards.
   - Provide additional 3 from Premium-exclusive DB.
   - Supabase RPC: `get_premium_scriptures(user_id, 3)`

**Supabase Database Structure**:

- `scriptures` table: All scripture content (is_premium flag).
- `user_scripture_history` table: Reading history.
- Row Level Security (RLS) for permission management.

---

### F3. Prayer Note

**Writing Feature**:

- Location: **[Leave Meditation]** button at the bottom of the scripture card.
- Form: Flutter TextField (Multi-line).
- Restriction: Not accessible to Guests.
- Storage: Real-time saving to Supabase `prayer_notes` table.

**Viewing Feature (Calendar View)**:

- Location: 'My Library' tab.
- UI: Utilize Flutter `table_calendar` package.
- Data: Supabase Realtime Subscription.

**Restrictions by Tier**:

| Tier    | View Range  | Restriction             | Supabase RLS                              |
| ------- | ----------- | ----------------------- | ----------------------------------------- |
| Guest   | N/A         | Writing impossible      | -                                         |
| Member  | Last 3 days | Lock🔒 on older records | `created_at >= now() - interval '3 days'` |
| Premium | All time    | Unlimited view & edit   | `user_id = auth.uid()`                    |

**Retention Policy**:

- Member: Auto-delete records older than 7 days via Supabase Edge Function.
- Premium: Permanent storage (Protected by RLS policy).

---

### F4. Monetization Model (Upselling)

**Conversion Points**:

1. **Archives (Storage Limit)**

   - Situation: Member attempts to view records older than 3 days.
   - Message: "Revisit past prayers and meditate on the grace."
   - CTA: Guide to Premium Subscription.

2. **More Content (Content Expansion)**
   - Situation: Member exhausts all 3 cards for the day.
   - Message: "Do you need more wisdom today?"
   - CTA: Guide to Premium Subscription.

**Payment System**:

- iOS: In-App Purchase (StoreKit)
- Android: Google Play Billing
- Flutter Package: `in_app_purchase` or `purchases_flutter` (RevenueCat)
- Supabase: Store subscription status in `user_subscriptions` table.

**Pricing Policy**:

- Monthly Subscription: ₩9,900 (Adjustable later)
- Annual Subscription: ₩99,000 (2 months free)

---

## 4. Development Workflow (TDD Based)

This project is developed based on the **Test-Driven Development (TDD)** methodology.

### TDD Development Flow

```
Phase Start
    ↓
[Phase Planning Agent]
    - Establish development plan per phase
    - Create TDD checklist
    - Determine implementation order
    ↓
[TDD Cycle Repeat]
    ✓ Write Test Case 1 (Red)
    ✓ Implement 1 (Pass Test) (Green)
    ✓ Refactor 1 (Refactor)
    ✓ Write Test Case 2
    ✓ Implement 2 (Pass Test)
    ✓ Refactor 2
    ...
    ↓
[TDD Checklist Manager]
    - Real-time checklist update during progress
    - Track completed/incomplete items
    - Suggest next task priority
    ↓
[Test-First Validator]
    - Verify TDD principle compliance
    - Verify test coverage
    - Review test quality
    ↓
Phase Complete
    ↓
[Documentation Generator]
    - Auto-generate API documentation
    - Write technical documentation
    - Add code comments
    - Update architecture diagrams
    ↓
[Code Review Agent]
    - Final code review
    - Verify best practice compliance
    - Review performance and security
    ↓
To Next Phase
```

### TDD Core Principles

**Red-Green-Refactor Cycle**:

1. **Red**: Write a failing test first.
2. **Green**: Write the minimum code to pass the test.
3. **Refactor**: Remove duplication and improve code.

**TDD Rules**:

- Do not write production code without a test.
- Do not write a new test without a failing test.
- Write only the minimum code to pass the test.

### Flutter TDD Specifics

**Test Layers**:

1. **Unit Tests**: Business Logic, Service, Repository.
2. **Widget Tests**: UI Components, State Management.
3. **Integration Tests**: Full Flow, Supabase Integration.

**Mocking Strategy**:

- Supabase Client: Mock with `mockito` or `mocktail`.
- Enable local testing without actual DB calls.

### Test Coverage Goals

| Layer                    | Coverage Goal | Priority |
| ------------------------ | ------------- | -------- |
| Repository (Data)        | 95%+          | Highest  |
| Service (Business Logic) | 95%+          | Highest  |
| Provider/BLoC (State)    | 90%+          | High     |
| Widget                   | 80%+          | Medium   |
| Screen                   | 70%+          | Medium   |
| Supabase Edge Functions  | 90%+          | High     |

### Test Tools & Frameworks

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

- Build local development environment with Supabase CLI.
- SQL function testing with pgTAP.
- Edge Functions testing with Postman/Insomnia.

**CI/CD**:

- GitHub Actions
- Codemagic (Flutter specialized CI/CD)
- Automated test execution and coverage reports.

### Precautions During TDD

**Do**:

- ✅ Write tests first.
- ✅ Always test Supabase Client with Mocks.
- ✅ Use `pumpWidget` and `pumpAndSettle` for Widget tests.
- ✅ Clearly use `async/await` for asynchronous tests.
- ✅ Ensure each Repository can be tested independently.
- ✅ Include RLS policies in test scenarios.

**Don't**:

- ❌ Do not test with actual Supabase production DB.
- ❌ Do not make actual network calls in UI tests.
- ❌ Do not verify too much logic in Widget tests.
- ❌ Do not create dependencies between tests (Ensure independent execution).
- ❌ Golden tests are not for pixel perfection (For layout verification).

---

## 5. Development Principles (Functional Programming Orientation)

This project actively adopts **Functional Programming** principles for a stable and predictable codebase.

### Core Principles

1. **Immutability**

   - Define all data models and state classes as Immutable.
   - When changing data, create a new instance via `copyWith` method instead of modifying the existing object.
   - Recommend using Flutter's `final` keyword and the `freezed` package.

2. **Pure Functions**

   - Write Business Logic (Domain/Service layers) as pure functions whenever possible.
   - Guarantee the same output for the same input and do not change external state.
   - This greatly simplifies test code writing in the TDD environment.

3. **Declarative Programming**

   - Focus on "What" to do rather than "How".
   - UI is expressed as a function of the current State, and rendered declaratively according to state changes.

4. **Side Effect Isolation**

   - Strictly separate operations with side effects like IO (Database, Network) into Repository and Data Source layers.
   - Avoid direct global state access or external API calls within logic.

5. **Expressive Type System**
   - Design so that intentions can be clearly understood just by the function signature.
   - Aim for explicit return types (e.g., Either) rather than throwing exceptions for error handling.

---

## 6. Available Agents (사용 가능한 에이전트)

This project includes specialized Claude agents to support the TDD workflow. Use these agents at the appropriate stages of development.

### Agent Overview

| Agent | Color | Purpose | When to Use |
|-------|-------|---------|-------------|
| **phase-planning-agent** | 🔴 Red | TDD 계획 수립 | 새로운 개발 페이즈 시작 시 |
| **tdd-checklist-manager** | 🔵 Blue | 진행 상황 추적 | 개발 중 진행 확인/다음 단계 필요 시 |
| **test-first-validator** | 🟢 Green | TDD 준수 검증 | TDD 사이클 완료 후/코드 리뷰 시 |
| **documentation-generator** | 🟡 Yellow | 문서화 | 페이즈 완료 후/API 추가 시 |
| **code-review-quality** | 🟣 Purple | 코드 품질 검토 | 페이즈 완료 전 품질 검증 시 |

### Agent Usage Guide

#### 1. Phase Planning Agent (🔴 phase-planning-agent)
**용도**: 새로운 개발 페이즈를 시작할 때 포괄적인 TDD 체크리스트 생성

**사용 시점**:
- "Phase 1 개발을 시작하려고 해"
- "Scripture Card 기능을 계획해줘"
- "다음 페이즈로 넘어가자"

**제공 기능**:
- Red-Green-Refactor 사이클 분해
- 테스트 케이스별 파일 위치 제안
- 의존성 그래프 및 일정 추정
- 우선순위 기반 구현 순서

---

#### 2. TDD Checklist Manager (🔵 tdd-checklist-manager)
**용도**: 개발 진행 상황 실시간 추적 및 다음 단계 제안

**사용 시점**:
- "현재 Phase 1 진행 상황이 어떻게 돼?"
- "AuthRepository 테스트 완료했어"
- "다음에 뭘 해야 해?"
- "Supabase RLS 테스트에서 막혔어"

**제공 기능**:
- 완료/진행중/대기/차단 항목 추적
- 커버리지 목표 대비 현황
- 블로커 감지 및 해결 제안
- 우선순위 기반 다음 작업 추천

---

#### 3. Test-First Validator (🟢 test-first-validator)
**용도**: TDD 원칙(테스트 우선 작성) 준수 여부 검증

**사용 시점**:
- "ScriptureRepository 구현 완료했어, 검토해줘"
- "TDD 잘 따르고 있는지 확인해줘"
- "다음 기능으로 넘어가기 전에 검증해줘"

**제공 기능**:
- 테스트 우선 작성 여부 확인
- 레이어별 커버리지 분석
- Red-Green-Refactor 사이클 준수 확인
- TDD 점수 및 개선 권고

---

#### 4. Documentation Generator (🟡 documentation-generator)
**용도**: API 문서, 기술 문서, 코드 주석, 변경 로그 생성

**사용 시점**:
- "Phase 1 완료! 문서화 해줘"
- "get_daily_scriptures RPC 함수 문서화해줘"
- "아키텍처 변경했으니 문서 업데이트해줘"

**제공 기능**:
- Dart doc 주석 생성
- Supabase RPC/Edge Function 문서화
- CHANGELOG.md 업데이트
- 아키텍처 결정 기록(ADR)

---

#### 5. Code Review Quality (🟣 code-review-quality)
**용도**: 페이즈 완료 전 코드 품질 종합 검토

**사용 시점**:
- "Phase 1 코드 리뷰해줘"
- "AuthRepository가 함수형 프로그래밍 원칙 따르는지 확인해줘"
- "리팩토링 할 부분 찾아줘"

**제공 기능**:
- 코드 품질 점수(A~F)
- 리팩토링 기회 식별
- 함수형 프로그래밍 원칙 준수 확인
- Supabase/Flutter 베스트 프랙티스 검증
- Context7 MCP를 통한 최신 문서 기반 검증

---

### Recommended Workflow

```
새 페이즈 시작
    │
    ▼
🔴 phase-planning-agent
    "Phase X 계획 세워줘"
    │
    ▼
[TDD 개발 사이클 반복]
    │
    ├──▶ 🔵 tdd-checklist-manager (진행 상황 확인)
    │        "현재 진행 상황 알려줘"
    │
    ├──▶ 🟢 test-first-validator (사이클 완료 시)
    │        "이 구현 TDD 검증해줘"
    │
    ▼
페이즈 완료
    │
    ▼
🟣 code-review-quality
    "최종 코드 리뷰해줘"
    │
    ▼
🟡 documentation-generator
    "문서화 해줘"
    │
    ▼
다음 페이즈로
```

---

## 7. Contacts & Resources

- **Development Repository**: [GitHub Link]
- **Supabase Dashboard**: [Supabase Project URL]
- **CI/CD Dashboard**: [Codemagic/GitHub Actions Link]
- **Test Coverage**: [Codecov Link]

**This document is a living document. It will be continuously updated as the project progresses.**

**Building a stable and scalable app with Flutter + Supabase + TDD.**
