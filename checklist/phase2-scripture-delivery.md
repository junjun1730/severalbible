# Phase 2: Scripture Delivery System - TDD Checklist

**Goal**: Provide scripture cards, the core content, according to tier-based logic.

**Total Items**: 92
**Coverage Target**: Repository 95%+, Service 95%+, Provider 90%+, Widget 80%+
**Estimated Duration**: 8-10 days

---

## 2-1. Database & RPC

### Scriptures Table

#### Create Scriptures Table
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.1 | 🟢 GREEN | Create `scriptures` table with schema | [x] |
| 1.1 | 🟢 GREEN | Insert dummy data (minimum 20 items, 5 premium) | [x] |
| 1.1 | 🔵 REFACTOR | Verify data integrity and indexes | [ ] |

**Migration Files Created**:
- `supabase/migrations/002_create_scriptures.sql`
- `supabase/migrations/005_insert_scripture_dummy_data.sql` (23 items: 15 regular + 8 premium)

**SQL Schema**:
```sql
CREATE TABLE scriptures (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  book TEXT NOT NULL,
  chapter INTEGER NOT NULL,
  verse INTEGER NOT NULL,
  content TEXT NOT NULL,
  reference TEXT NOT NULL, -- e.g., "John 3:16"
  is_premium BOOLEAN DEFAULT FALSE,
  category TEXT, -- e.g., "wisdom", "hope", "faith"
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_scriptures_is_premium ON scriptures(is_premium);
CREATE INDEX idx_scriptures_category ON scriptures(category);
```

**Dummy Data Example**:
```sql
INSERT INTO scriptures (book, chapter, verse, content, reference, is_premium, category) VALUES
('John', 3, 16, 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.', 'John 3:16', false, 'hope'),
('Proverbs', 3, 5, 'Trust in the LORD with all your heart and lean not on your own understanding.', 'Proverbs 3:5', false, 'wisdom'),
('Philippians', 4, 13, 'I can do all this through him who gives me strength.', 'Philippians 4:13', false, 'faith'),
('Psalms', 23, 1, 'The LORD is my shepherd, I lack nothing.', 'Psalms 23:1', true, 'hope'),
('Romans', 8, 28, 'And we know that in all things God works for the good of those who love him.', 'Romans 8:28', true, 'faith');
-- Add 15+ more entries...
```

### User Scripture History Table

#### Create User Scripture History Table
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.2 | 🟢 GREEN | Create `user_scripture_history` table | [x] |
| 1.2 | 🟢 GREEN | Set RLS policies for history tracking | [x] |
| 1.2 | 🔵 REFACTOR | Add indexes for query optimization | [x] |

**Migration File Created**: `supabase/migrations/003_create_user_scripture_history.sql`

**SQL Schema**:
```sql
CREATE TABLE user_scripture_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  scripture_id UUID NOT NULL REFERENCES scriptures(id) ON DELETE CASCADE,
  viewed_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, scripture_id, DATE(viewed_at))
);

-- Enable RLS
ALTER TABLE user_scripture_history ENABLE ROW LEVEL SECURITY;

-- Users can view their own history
CREATE POLICY "Users can view own history" ON user_scripture_history
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own history
CREATE POLICY "Users can insert own history" ON user_scripture_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create indexes
CREATE INDEX idx_user_scripture_history_user_id ON user_scripture_history(user_id);
CREATE INDEX idx_user_scripture_history_viewed_at ON user_scripture_history(viewed_at);
CREATE INDEX idx_user_scripture_history_user_date ON user_scripture_history(user_id, DATE(viewed_at));
```

### RPC Functions

#### RPC: get_random_scripture (Guest)
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.3 | 🔴 RED | Write SQL test for random scripture selection | [ ] |
| 1.3 | 🔴 RED | Test returns exactly 1 scripture | [ ] |
| 1.3 | 🔴 RED | Test excludes premium scriptures | [ ] |
| 1.3 | 🟢 GREEN | Implement `get_random_scripture` RPC | [x] |
| 1.3 | 🔵 REFACTOR | Optimize query performance | [x] |

**RPC Implementation**:
```sql
CREATE OR REPLACE FUNCTION get_random_scripture(limit_count INTEGER DEFAULT 1)
RETURNS SETOF scriptures
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT *
  FROM scriptures
  WHERE is_premium = FALSE
  ORDER BY RANDOM()
  LIMIT limit_count;
$$;
```

#### RPC: get_daily_scriptures (Member - No Duplicate)
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.4 | 🔴 RED | Write SQL test for no-duplicate logic | [ ] |
| 1.4 | 🔴 RED | Test returns up to 3 scriptures | [ ] |
| 1.4 | 🔴 RED | Test excludes already viewed (today) | [ ] |
| 1.4 | 🔴 RED | Test excludes premium scriptures | [ ] |
| 1.4 | 🔴 RED | Test handles user with no history | [ ] |
| 1.4 | 🟢 GREEN | Implement `get_daily_scriptures` RPC | [x] |
| 1.4 | 🔵 REFACTOR | Add error handling and edge cases | [x] |

**RPC Implementation**:
```sql
CREATE OR REPLACE FUNCTION get_daily_scriptures(
  p_user_id UUID,
  limit_count INTEGER DEFAULT 3,
  include_premium BOOLEAN DEFAULT FALSE
)
RETURNS SETOF scriptures
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT s.*
  FROM scriptures s
  WHERE s.is_premium = FALSE
    AND s.id NOT IN (
      -- Exclude scriptures viewed today
      SELECT scripture_id
      FROM user_scripture_history
      WHERE user_id = p_user_id
        AND DATE(viewed_at) = CURRENT_DATE
    )
  ORDER BY RANDOM()
  LIMIT limit_count;
END;
$$;
```

#### RPC: get_premium_scriptures (Premium)
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.5 | 🔴 RED | Write SQL test for premium scripture selection | [ ] |
| 1.5 | 🔴 RED | Test returns only premium scriptures | [ ] |
| 1.5 | 🔴 RED | Test applies no-duplicate logic | [ ] |
| 1.5 | 🔴 RED | Test returns up to 3 additional scriptures | [ ] |
| 1.5 | 🟢 GREEN | Implement `get_premium_scriptures` RPC | [x] |
| 1.5 | 🔵 REFACTOR | Verify premium tier validation | [x] |

**RPC Implementation**:
```sql
CREATE OR REPLACE FUNCTION get_premium_scriptures(
  p_user_id UUID,
  limit_count INTEGER DEFAULT 3
)
RETURNS SETOF scriptures
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT s.*
  FROM scriptures s
  WHERE s.is_premium = TRUE
    AND s.id NOT IN (
      -- Exclude scriptures viewed today
      SELECT scripture_id
      FROM user_scripture_history
      WHERE user_id = p_user_id
        AND DATE(viewed_at) = CURRENT_DATE
    )
  ORDER BY RANDOM()
  LIMIT limit_count;
END;
$$;
```

#### RPC: record_scripture_view
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.6 | 🔴 RED | Test successful history recording | [ ] |
| 1.6 | 🔴 RED | Test prevents duplicate entries (same day) | [ ] |
| 1.6 | 🟢 GREEN | Implement `record_scripture_view` RPC | [x] |

**All RPC Functions implemented in**: `supabase/migrations/004_create_scripture_rpc_functions.sql`
- `get_random_scripture(limit_count)` - For Guest
- `get_daily_scriptures(p_user_id, limit_count)` - For Member
- `get_premium_scriptures(p_user_id, limit_count)` - For Premium
- `record_scripture_view(p_user_id, p_scripture_id)` - History tracking
- `get_scripture_history(p_user_id, p_date)` - View history by date

**RPC Implementation**:
```sql
CREATE OR REPLACE FUNCTION record_scripture_view(
  p_user_id UUID,
  p_scripture_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO user_scripture_history (user_id, scripture_id, viewed_at)
  VALUES (p_user_id, p_scripture_id, NOW())
  ON CONFLICT (user_id, scripture_id, DATE(viewed_at)) DO NOTHING;
END;
$$;
```

---

## 2-2. Scripture Feature (TDD)

### Domain Layer

#### Scripture Entity
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.1 | 🟢 GREEN | Create `Scripture` entity with freezed | [ ] |
| 2.1 | 🔵 REFACTOR | Verify immutability and copyWith | [ ] |

**Entity Definition** (`lib/features/scripture/domain/entities/scripture.dart`):
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scripture.freezed.dart';
part 'scripture.g.dart';

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

  factory Scripture.fromJson(Map<String, dynamic> json) =>
      _$ScriptureFromJson(json);
}
```

#### ScriptureRepository Interface
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.2 | 🟢 GREEN | Create `ScriptureRepository` interface | [ ] |

**Repository Interface** (`lib/features/scripture/domain/repositories/scripture_repository.dart`):
```dart
import 'package:dartz/dartz.dart';
import '../entities/scripture.dart';
import '../../../../core/errors/failures.dart';

abstract class ScriptureRepository {
  /// Get random scripture for guest users (1 item, duplicates allowed)
  Future<Either<Failure, List<Scripture>>> getRandomScripture(int count);

  /// Get daily scriptures for member users (no duplicates)
  Future<Either<Failure, List<Scripture>>> getDailyScriptures({
    required String userId,
    required int count,
  });

  /// Get premium scriptures for premium users
  Future<Either<Failure, List<Scripture>>> getPremiumScriptures({
    required String userId,
    required int count,
  });

  /// Record that user viewed a scripture
  Future<Either<Failure, void>> recordScriptureView({
    required String userId,
    required String scriptureId,
  });

  /// Get user's scripture history for a specific date
  Future<Either<Failure, List<Scripture>>> getScriptureHistory({
    required String userId,
    required DateTime date,
  });
}
```

### Data Layer - ScriptureRepository Tests

#### Test Setup & Mocks
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.3 | 🔴 RED | Setup test file and mocks | [ ] |
| 2.3 | 🔴 RED | Create `MockSupabaseService` | [ ] |

**Test File**: `test/features/scripture/data/scripture_repository_test.dart`

#### getRandomScripture Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.4 | 🔴 RED | Test `getRandomScripture` returns Right(scriptures) on success | [ ] |
| 2.4 | 🔴 RED | Test `getRandomScripture` returns exactly requested count | [ ] |
| 2.4 | 🔴 RED | Test `getRandomScripture` excludes premium scriptures | [ ] |
| 2.4 | 🔴 RED | Test `getRandomScripture` returns Left(failure) on error | [ ] |
| 2.4 | 🔴 RED | Test `getRandomScripture` handles empty result | [ ] |
| 2.4 | 🟢 GREEN | Implement `getRandomScripture` | [ ] |
| 2.4 | 🔵 REFACTOR | Extract common error handling | [ ] |

#### getDailyScriptures Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.5 | 🔴 RED | Test `getDailyScriptures` returns Right(scriptures) on success | [ ] |
| 2.5 | 🔴 RED | Test `getDailyScriptures` returns up to requested count | [ ] |
| 2.5 | 🔴 RED | Test `getDailyScriptures` excludes already viewed (today) | [ ] |
| 2.5 | 🔴 RED | Test `getDailyScriptures` excludes premium scriptures | [ ] |
| 2.5 | 🔴 RED | Test `getDailyScriptures` handles user with no history | [ ] |
| 2.5 | 🔴 RED | Test `getDailyScriptures` returns Left(failure) on error | [ ] |
| 2.5 | 🟢 GREEN | Implement `getDailyScriptures` | [ ] |
| 2.5 | 🔵 REFACTOR | Extract RPC call logic to datasource | [ ] |

#### getPremiumScriptures Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.6 | 🔴 RED | Test `getPremiumScriptures` returns only premium scriptures | [ ] |
| 2.6 | 🔴 RED | Test `getPremiumScriptures` applies no-duplicate logic | [ ] |
| 2.6 | 🔴 RED | Test `getPremiumScriptures` returns up to requested count | [ ] |
| 2.6 | 🔴 RED | Test `getPremiumScriptures` returns Left(failure) on error | [ ] |
| 2.6 | 🟢 GREEN | Implement `getPremiumScriptures` | [ ] |

#### recordScriptureView Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.7 | 🔴 RED | Test `recordScriptureView` succeeds | [ ] |
| 2.7 | 🔴 RED | Test `recordScriptureView` handles duplicate (same day) | [ ] |
| 2.7 | 🔴 RED | Test `recordScriptureView` returns Left(failure) on error | [ ] |
| 2.7 | 🟢 GREEN | Implement `recordScriptureView` | [ ] |

#### getScriptureHistory Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.8 | 🔴 RED | Test `getScriptureHistory` returns scriptures for date | [ ] |
| 2.8 | 🔴 RED | Test `getScriptureHistory` returns empty for no history | [ ] |
| 2.8 | 🔴 RED | Test `getScriptureHistory` returns Left(failure) on error | [ ] |
| 2.8 | 🟢 GREEN | Implement `getScriptureHistory` | [ ] |

### Data Layer - Implementation

#### ScriptureDataSource
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.9 | 🟢 GREEN | Create `ScriptureDataSource` interface | [ ] |
| 2.9 | 🟢 GREEN | Implement `SupabaseScriptureDataSource` | [ ] |
| 2.9 | 🔵 REFACTOR | Extract JSON mapping logic | [ ] |

**DataSource File**: `lib/features/scripture/data/datasources/scripture_datasource.dart`

#### ScriptureRepository Implementation
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.10 | 🟢 GREEN | Implement `SupabaseScriptureRepository` | [ ] |
| 2.10 | 🔵 REFACTOR | Add comprehensive error handling | [ ] |
| 2.10 | 🔵 REFACTOR | Verify all tests pass (25+ tests) | [ ] |

**Repository File**: `lib/features/scripture/data/repositories/supabase_scripture_repository.dart`

### State Layer - Providers

#### DailyScriptureProvider (AsyncNotifier)
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 3.1 | 🔴 RED | Test provider loads scriptures based on user tier | [ ] |
| 3.1 | 🔴 RED | Test provider caches daily scriptures | [ ] |
| 3.1 | 🔴 RED | Test provider handles loading states | [ ] |
| 3.1 | 🔴 RED | Test provider handles error states | [ ] |
| 3.1 | 🔴 RED | Test provider refreshes on date change | [ ] |
| 3.1 | 🟢 GREEN | Implement `DailyScriptureProvider` | [ ] |
| 3.1 | 🔵 REFACTOR | Add state persistence (optional) | [ ] |

**Provider File**: `lib/features/scripture/presentation/providers/daily_scripture_provider.dart`

#### PremiumScriptureProvider
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 3.2 | 🔴 RED | Test provider loads premium scriptures | [ ] |
| 3.2 | 🔴 RED | Test provider handles "See 3 More" action | [ ] |
| 3.2 | 🔴 RED | Test provider verifies premium tier | [ ] |
| 3.2 | 🟢 GREEN | Implement `PremiumScriptureProvider` | [ ] |

#### ScriptureViewTracker
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 3.3 | 🔴 RED | Test tracks scripture view | [ ] |
| 3.3 | 🔴 RED | Test debounces multiple view events | [ ] |
| 3.3 | 🟢 GREEN | Implement `ScriptureViewTracker` | [ ] |

#### Provider Setup
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 3.4 | 🟢 GREEN | Create `scriptureRepositoryProvider` | [ ] |
| 3.4 | 🟢 GREEN | Create `scriptureDataSourceProvider` | [ ] |
| 3.4 | 🟢 GREEN | Create `dailyScripturesProvider` | [ ] |
| 3.4 | 🟢 GREEN | Create `premiumScripturesProvider` | [ ] |
| 3.4 | 🟢 GREEN | Create `currentScriptureIndexProvider` | [ ] |

---

## 2-3. UI Implementation

### ScriptureCard Widget

#### ScriptureCard Widget Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.1 | 🔴 RED | Widget test: renders scripture reference | [ ] |
| 4.1 | 🔴 RED | Widget test: renders scripture content | [ ] |
| 4.1 | 🔴 RED | Widget test: renders scripture book/chapter/verse | [ ] |
| 4.1 | 🔴 RED | Widget test: shows premium badge for premium scriptures | [ ] |
| 4.1 | 🔴 RED | Widget test: applies correct typography | [ ] |
| 4.1 | 🔴 RED | Widget test: has gradient background | [ ] |
| 4.1 | 🔴 RED | Widget test: renders category tag (if present) | [ ] |
| 4.1 | 🟢 GREEN | Implement `ScriptureCard` widget | [ ] |
| 4.1 | 🔵 REFACTOR | Extract design tokens (colors, fonts) | [ ] |

**Widget File**: `lib/features/scripture/presentation/widgets/scripture_card.dart`

**Test File**: `test/features/scripture/presentation/widgets/scripture_card_test.dart`

### DailyFeedScreen

#### DailyFeedScreen Widget Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.2 | 🔴 RED | Widget test: shows loading indicator on initial load | [ ] |
| 4.2 | 🔴 RED | Widget test: renders PageView with scriptures | [ ] |
| 4.2 | 🔴 RED | Widget test: shows error message on failure | [ ] |
| 4.2 | 🔴 RED | Widget test: shows retry button on error | [ ] |
| 4.2 | 🔴 RED | Widget test: displays page indicators | [ ] |
| 4.2 | 🔴 RED | Widget test: updates current page on swipe | [ ] |
| 4.2 | 🟢 GREEN | Implement `DailyFeedScreen` | [ ] |
| 4.2 | 🔵 REFACTOR | Add pull-to-refresh (optional) | [ ] |

**Screen File**: `lib/features/scripture/presentation/screens/daily_feed_screen.dart`

**Test File**: `test/features/scripture/presentation/screens/daily_feed_screen_test.dart`

### Tier-Based Logic (Guest/Member)

#### Guest Tier Logic (1 card/day)
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.3 | 🔴 RED | Integration test: guest sees exactly 1 scripture | [ ] |
| 4.3 | 🔴 RED | Integration test: guest gets random (duplicate allowed) | [ ] |
| 4.3 | 🔴 RED | Integration test: blocker appears after 1 card | [ ] |
| 4.3 | 🟢 GREEN | Implement guest tier scripture limit | [ ] |

#### Member Tier Logic (3 cards/day)
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.4 | 🔴 RED | Integration test: member sees up to 3 scriptures | [ ] |
| 4.4 | 🔴 RED | Integration test: member gets no duplicates (today) | [ ] |
| 4.4 | 🔴 RED | Integration test: blocker appears after 3 cards | [ ] |
| 4.4 | 🔴 RED | Integration test: new scriptures available tomorrow | [ ] |
| 4.4 | 🟢 GREEN | Implement member tier scripture limit | [ ] |

#### Premium Tier Logic (3+3 cards/day)
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.5 | 🔴 RED | Integration test: premium sees 3 regular scriptures | [ ] |
| 4.5 | 🔴 RED | Integration test: "See 3 More" button appears | [ ] |
| 4.5 | 🔴 RED | Integration test: loads 3 additional premium scriptures | [ ] |
| 4.5 | 🔴 RED | Integration test: premium scriptures are exclusive | [ ] |
| 4.5 | 🟢 GREEN | Implement premium tier "See More" feature | [ ] |

### ContentBlocker Widget (Login/Payment Induction)

#### ContentBlocker Widget Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.6 | 🔴 RED | Widget test: displays blocker message | [ ] |
| 4.6 | 🔴 RED | Widget test: shows CTA button based on tier | [ ] |
| 4.6 | 🔴 RED | Widget test: guest blocker prompts login | [ ] |
| 4.6 | 🔴 RED | Widget test: member blocker prompts premium upgrade | [ ] |
| 4.6 | 🔴 RED | Widget test: displays benefit list | [ ] |
| 4.6 | 🔴 RED | Widget test: calls onAction callback | [ ] |
| 4.6 | 🟢 GREEN | Implement `ContentBlocker` widget | [ ] |
| 4.6 | 🔵 REFACTOR | Extract blocker messages to constants | [ ] |

**Widget File**: `lib/features/scripture/presentation/widgets/content_blocker.dart`

**Test File**: `test/features/scripture/presentation/widgets/content_blocker_test.dart`

### PageIndicator Widget

#### PageIndicator Widget Tests
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.7 | 🔴 RED | Widget test: renders dots for each page | [ ] |
| 4.7 | 🔴 RED | Widget test: highlights current page | [ ] |
| 4.7 | 🔴 RED | Widget test: updates on page change | [ ] |
| 4.7 | 🟢 GREEN | Implement `PageIndicator` widget | [ ] |

**Widget File**: `lib/features/scripture/presentation/widgets/page_indicator.dart`

---

## Test File Locations

| Test Type | File Path | Tests |
|-----------|-----------|-------|
| RPC Tests (SQL) | `supabase/tests/scripture_rpc_test.sql` | 15 |
| ScriptureRepository | `test/features/scripture/data/scripture_repository_test.dart` | 25 |
| DailyScriptureProvider | `test/features/scripture/presentation/providers/daily_scripture_provider_test.dart` | 8 |
| PremiumScriptureProvider | `test/features/scripture/presentation/providers/premium_scripture_provider_test.dart` | 3 |
| ScriptureCard Widget | `test/features/scripture/presentation/widgets/scripture_card_test.dart` | 7 |
| DailyFeedScreen Widget | `test/features/scripture/presentation/screens/daily_feed_screen_test.dart` | 6 |
| ContentBlocker Widget | `test/features/scripture/presentation/widgets/content_blocker_test.dart` | 6 |
| PageIndicator Widget | `test/features/scripture/presentation/widgets/page_indicator_test.dart` | 3 |
| Guest Tier Integration | `integration_test/guest_scripture_flow_test.dart` | 3 |
| Member Tier Integration | `integration_test/member_scripture_flow_test.dart` | 4 |
| Premium Tier Integration | `integration_test/premium_scripture_flow_test.dart` | 4 |

**Total Test Cases**: 84 tests

---

## Implementation File Locations

| Component | File Path |
|-----------|-----------|
| Scripture Entity | `lib/features/scripture/domain/entities/scripture.dart` |
| ScriptureRepository Interface | `lib/features/scripture/domain/repositories/scripture_repository.dart` |
| ScriptureDataSource | `lib/features/scripture/data/datasources/scripture_datasource.dart` |
| SupabaseScriptureRepository | `lib/features/scripture/data/repositories/supabase_scripture_repository.dart` |
| DailyScriptureProvider | `lib/features/scripture/presentation/providers/daily_scripture_provider.dart` |
| PremiumScriptureProvider | `lib/features/scripture/presentation/providers/premium_scripture_provider.dart` |
| Scripture Providers | `lib/features/scripture/presentation/providers/scripture_providers.dart` |
| ScriptureCard Widget | `lib/features/scripture/presentation/widgets/scripture_card.dart` |
| ContentBlocker Widget | `lib/features/scripture/presentation/widgets/content_blocker.dart` |
| PageIndicator Widget | `lib/features/scripture/presentation/widgets/page_indicator.dart` |
| DailyFeedScreen | `lib/features/scripture/presentation/screens/daily_feed_screen.dart` |

---

## Dependency Graph

```
Phase 2-1 (Database & RPC)
    ↓
Phase 2-2 (Scripture Feature - TDD)
    ├─ Domain Layer (Entities, Interfaces)
    ├─ Data Layer Tests (ScriptureRepository)
    ├─ Data Layer Implementation
    └─ State Layer (Providers)
        ↓
Phase 2-3 (UI Implementation)
    ├─ ScriptureCard Widget
    ├─ DailyFeedScreen
    ├─ Tier-Based Logic
    ├─ ContentBlocker Widget
    └─ Integration Tests
```

---

## Daily Progress Milestones

### Day 1-2: Database & RPC Setup
- Create scriptures table
- Insert dummy data (20+ items)
- Create user_scripture_history table
- Implement all RPC functions
- Write SQL tests (pgTAP)
- Set RLS policies

### Day 3-4: Domain & Data Layer (TDD)
- Define Scripture entity
- Create repository interface
- Write 25+ repository tests
- Implement datasource
- Implement repository
- Verify all tests pass

### Day 5-6: State Layer & Providers
- Implement DailyScriptureProvider
- Implement PremiumScriptureProvider
- Write provider tests (11+ tests)
- Setup all provider dependencies
- Test tier-based logic

### Day 7-8: UI Implementation
- Implement ScriptureCard widget (7 tests)
- Implement DailyFeedScreen (6 tests)
- Implement ContentBlocker widget (6 tests)
- Implement PageIndicator (3 tests)
- Connect UI with providers

### Day 9-10: Integration & Testing
- Write guest tier integration tests (3 tests)
- Write member tier integration tests (4 tests)
- Write premium tier integration tests (4 tests)
- End-to-end flow testing
- Bug fixes and refinement
- Update documentation

---

## RLS Policy Examples

### Scriptures Table (Read-Only for All)
```sql
-- Enable RLS
ALTER TABLE scriptures ENABLE ROW LEVEL SECURITY;

-- Anyone can view non-premium scriptures
CREATE POLICY "Anyone can view non-premium scriptures" ON scriptures
  FOR SELECT USING (is_premium = FALSE);

-- Only authenticated users can view premium scriptures
CREATE POLICY "Authenticated users can view premium scriptures" ON scriptures
  FOR SELECT USING (
    auth.uid() IS NOT NULL AND is_premium = TRUE
  );
```

### User Scripture History (User-Specific)
```sql
-- Users can view their own history
CREATE POLICY "Users can view own history" ON user_scripture_history
  FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own history
CREATE POLICY "Users can insert own history" ON user_scripture_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);
```

---

## Test Coverage Goals

| Layer | Target Coverage | Priority |
|-------|----------------|----------|
| ScriptureRepository | 95%+ | Highest |
| Scripture Domain | 95%+ | Highest |
| DailyScriptureProvider | 90%+ | High |
| ScriptureCard Widget | 80%+ | Medium |
| DailyFeedScreen | 80%+ | Medium |
| RPC Functions (SQL) | 90%+ | High |
| Integration Tests | Full Flow | High |

---

## Progress Summary

| Section | Total | Completed | Progress |
|---------|-------|-----------|----------|
| 2-1. Database & RPC | 24 | 12 | 50% |
| 2-2. Scripture Feature (TDD) | 48 | 0 | 0% |
| 2-3. UI Implementation | 20 | 0 | 0% |
| **Total** | **92** | **12** | **13%** |

### Test Summary
- RPC Tests (SQL): 0/15 (pending - requires Supabase deployment)
- ScriptureRepository Tests: 0/25
- Provider Tests: 0/11
- Widget Tests: 0/22
- Integration Tests: 0/11
- **Total Tests: 0/84**

### Migration Files Created
- `002_create_scriptures.sql` - Scriptures table with RLS
- `003_create_user_scripture_history.sql` - History table with RLS
- `004_create_scripture_rpc_functions.sql` - All RPC functions
- `005_insert_scripture_dummy_data.sql` - 23 dummy scriptures

---

**Last Updated**: 2026-01-16
**Phase Status**: 2-1 Database & RPC - Migration Files Complete (Pending Supabase Deployment)
**Estimated Completion**: 8-10 days
