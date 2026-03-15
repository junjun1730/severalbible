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

## ⚠️ CRITICAL: Checklist Update Rules

**MANDATORY**: Before ANY git commit, you MUST update all related checklists.

### Files to Update
| File | Purpose | When |
|------|---------|------|
| `PLANNER.md` | High-level phase progress | Every task completion |
| `checklist/phase{N}-*.md` | Detailed TDD checklist | Every TDD cycle |

### Update Checklist (Do This EVERY Time)
1. ✅ Change `[ ]` to `[x]` for completed items
2. ✅ Update Progress Summary (Total/Completed/%)
3. ✅ Update "Last Updated" date
4. ✅ Add notes about what was done (e.g., "11 tests passing")

### Warning
```
❌ Failure to update checklists = Incomplete work
❌ NEVER commit code without updating PLANNER.md
❌ NEVER finish a phase without updating the detailed checklist
```

**This is NON-NEGOTIABLE. Always update checklists before committing.**

---

## 2. User Tiers & Benefits

> **⚠️ Updated 2026-03-15**: Pivoted to ad-based revenue model. 3-tier system (guest/member/premium)
> replaced with 2-tier. `UserTier.premium` remains in code for data compatibility but is treated
> identically to `member`.

| Category        | Guest (비로그인)                        | Member (로그인)                          |
| --------------- | --------------------------------------- | ---------------------------------------- |
| **Data Logic**  | Completely Random (Duplicates allowed)  | No-Duplicate                             |
| **Quantity**    | 1 per day                               | 3 per day                                |
| **Prayer Note** | Cannot write                            | Write + View all time                    |
| **Library**     | Login prompt                            | Full access                              |
| **Archiving**   | Cannot save                             | Unlimited permanent storage              |
| **Ads**         | Banner + Interstitial                   | Banner + Interstitial                    |
| **Revenue**     | Ad revenue                              | Ad revenue                               |

### Core Differentiators by Tier

- **Guest**: For trial purposes. Shows 1 daily random scripture. Daily login prompt (once per day) to encourage sign-up.
- **Member**: Full spiritual routine. 3 no-duplicate scriptures/day. All prayer notes accessible. Ad-supported.

### Revenue Model

- **Monetization**: AdMob banner ads (always visible) + interstitial ads (triggered when member exhausts daily cards).
- **No subscription / No IAP**: Subscription model has been removed as of 2026-03-15.

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

**Navigation & Access**:

- **Library Icon**: Top-right AppBar icon (`Icons.library_books`) before Settings
  - Premium users: Direct access to MyLibrary screen
  - Non-premium users: Shows UpsellDialog with archiveLocked trigger
  - Tooltip: "My Library" for accessibility

---

### F3. Prayer Note

**Writing Feature**:

- Location: Full-width **[Leave Meditation]** button at bottom of scripture card (below category chip).
- Design: Material 3 FilledButton.icon with Icons.edit_note, 56dp height, 16px border radius.
- Accessibility: Proper touch targets (≥ 48dp) and semantic labels.
- Form: Flutter TextField (Multi-line).
- Restriction: Not accessible to Guests (button appears disabled).
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

### F4. Monetization Model (Ad-Based)

> **Updated 2026-03-15**: Subscription/IAP model removed. Revenue from AdMob ads.

**Ad Placements**:

1. **Banner Ad** — Always visible between PageIndicator and MeditationButton (`BannerAdWidget`).
2. **Interstitial Ad** — Shown when a member reaches the last card in the daily feed.

**Ad System**:

- Flutter Package: `google_mobile_ads: ^5.x.x`
- Ad Unit IDs: Google test IDs in debug, real AdMob IDs in production
- Location: `lib/features/ads/` (services, providers, widgets)

**Login Inducement** (replaces upsell):

- Guest sees daily login prompt (once per day, stored in `SharedPreferences`)
- Message: "로그인하면 하루 3배 더 많은 말씀을 받을 수 있습니다"

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

### Checklist Update Rules

> ⚠️ **See Section "CRITICAL: Checklist Update Rules" above for full details.**

**Quick Reference Example**:
```markdown
# Before
- [ ] **[Test]** Write AuthRepository tests

# After
- [x] **[Test]** Write AuthRepository tests (11 tests passing)
```

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

## 6. Available Agents

This project includes specialized Claude agents to support the TDD workflow. Use these agents at the appropriate stages of development.

### Agent Overview

| Agent | Color | Purpose | When to Use |
|-------|-------|---------|-------------|
| **phase-planning-agent** | 🔴 Red | TDD Planning | When starting a new development phase |
| **tdd-checklist-manager** | 🔵 Blue | Progress Tracking | To check progress or when needing next steps |
| **test-first-validator** | 🟢 Green | TDD Compliance Check | After completing a TDD cycle or for code review |
| **documentation-generator** | 🟡 Yellow | Documentation | After completing a phase or adding APIs |
| **code-review-quality** | 🟣 Purple | Code Quality Review | For quality verification before completing a phase |

### Agent Usage Guide

#### 1. Phase Planning Agent (🔴 phase-planning-agent)
**Purpose**: Generates a comprehensive TDD checklist when starting a new development phase.

**When to Use**:
- "I'm starting Phase 1 development."
- "Plan the Scripture Card feature."
- "Let's move to the next phase."

**Features**:
- Red-Green-Refactor cycle breakdown
- Suggests file locations for test cases
- Dependency graph and schedule estimation
- Priority-based implementation order

---

#### 2. TDD Checklist Manager (🔵 tdd-checklist-manager)
**Purpose**: Tracks real-time development progress and suggests next steps.

**When to Use**:
- "What is the current progress of Phase 1?"
- "I've completed the AuthRepository test."
- "What should I do next?"
- "I'm stuck on the Supabase RLS test."

**Features**:
- Tracks Completed/In Progress/Pending/Blocked items
- Current status vs. coverage goals
- Blocker detection and resolution suggestions
- Priority-based next task recommendations

---

#### 3. Test-First Validator (🟢 test-first-validator)
**Purpose**: Verifies adherence to TDD principles (writing tests first).

**When to Use**:
- "ScriptureRepository implementation is done, please review."
- "Check if I'm following TDD correctly."
- "Verify before moving to the next feature."

**Features**:
- Verifies if tests were written first
- Analyzes coverage by layer
- Checks adherence to Red-Green-Refactor cycle
- TDD score and improvement recommendations

---

#### 4. Documentation Generator (🟡 documentation-generator)
**Purpose**: Generates API documentation, technical docs, code comments, and changelogs.

**When to Use**:
- "Phase 1 complete! Please document it."
- "Document the get_daily_scriptures RPC function."
- "Architecture changed, update the docs."

**Features**:
- Dart doc comment generation
- Supabase RPC/Edge Function documentation
- CHANGELOG.md update
- Architecture Decision Record (ADR)

---

#### 5. Code Review Quality (🟣 code-review-quality)
**Purpose**: Comprehensive code quality review before phase completion.

**When to Use**:
- "Review Phase 1 code."
- "Check if AuthRepository follows functional programming principles."
- "Find areas for refactoring."

**Features**:
- Code quality score (A~F)
- Identifies refactoring opportunities
- Verifies adherence to functional programming principles
- Validates Supabase/Flutter best practices
- Validation based on latest docs via Context7 MCP

---

### Recommended Workflow

```
Start New Phase
    │
    ▼
🔴 phase-planning-agent
    "Plan Phase X"
    │
    ▼
[Repeat TDD Development Cycle]
    │
    ├──▶ 🔵 tdd-checklist-manager (Check Progress)
    │        "Tell me current status"
    │
    ├──▶ 🟢 test-first-validator (Upon Cycle Completion)
    │        "Verify TDD for this implementation"
    │
    ▼
Phase Complete
    │
    ▼
🟣 code-review-quality
    "Final code review"
    │
    ▼
🟡 documentation-generator
    "Generate documentation"
    │
    ▼
To Next Phase
```

---

## 7. Contacts & Resources

- **Development Repository**: [GitHub Link]
- **Supabase Dashboard**: [Supabase Project URL]
- **CI/CD Dashboard**: [Codemagic/GitHub Actions Link]
- **Test Coverage**: [Codecov Link]

**This document is a living document. It will be continuously updated as the project progresses.**

**Building a stable and scalable app with Flutter + Supabase + TDD.**
