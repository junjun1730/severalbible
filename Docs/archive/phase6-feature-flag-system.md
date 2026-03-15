# ~~Phase 6: Feature Flag System (Free/Paid Mode Switching) - TDD Checklist~~

> ## ⚠️ CANCELLED — 2026-03-15
> **Reason**: Business model pivot to ad-based revenue (광고 수익 모델로 전환).
> The subscription tier system that motivated this feature flag system no longer exists.
> All authenticated users (member) now receive the same features — no premium gating.
> The feature flag infrastructure (011, 012 migrations + app_config Flutter code) remains as dead code.
> Do NOT delete these files; they may be referenced for future pivots.

---

# Phase 6: Feature Flag System (Free/Paid Mode Switching) - TDD Checklist

## Overview
**Goal**: Implement server-side feature flag system to toggle between free and paid modes without app updates
**Duration**: 6-8 days
**Total Items**: 93
**Total Tests**: 78
**Risk Level**: Medium (Requires careful tier logic integration)
**Last Updated**: February 23, 2026

---

## Progress Summary

| Category | Total | Completed | Percentage |
|----------|-------|-----------|------------|
| **Overall** | 93 | 17 | 18.3% |
| Phase 1: Backend (Supabase) | 21 | 6 | 28.6% |
| Phase 2: Flutter Core (App Config) | 23 | 11 | 47.8% |
| Phase 3: Effective Tier Logic | 12 | 0 | 0% |
| Phase 4: Code Migration | 14 | 0 | 0% |
| Phase 5: Integration Testing | 13 | 0 | 0% |
| Documentation | 10 | 0 | 0% |

---

## Feature Overview

### Business Logic
- **Free Mode**: Members get Premium features, Guests remain restricted
- **Paid Mode**: Original tier system (Guest → Member → Premium)
- **Toggle**: Server-side switch, no app update required
- **Cache**: 5-minute client-side cache for app_config
- **Single Source**: `effectiveUserTierProvider` replaces `currentUserTierProvider`

### Technical Architecture
```
Supabase (app_config table)
    ↓
SupabaseAppConfigDataSource
    ↓
AppConfigRepository (Either<Failure, AppConfig>)
    ↓
AppConfigProvider (5min cache via Riverpod)
    ↓
isFreeModeProvider (bool)
    ↓
effectiveUserTierProvider (UserTier)
    ↓
All UI Components (11 locations)
```

---

## Pre-requisites

- [ ] **[Setup]** Review current tier check locations (11 files using `currentUserTierProvider`)
- [ ] **[Setup]** Backup `supabase/migrations/` before creating new migrations
- [ ] **[Setup]** Create feature branch: `feature/feature-flag-system`
- [ ] **[Setup]** Install pgTAP for testing: `brew install pgtap` (if not already installed)

---

## Phase 1: Backend (Supabase) - 21 items

**Estimated Duration**: 2 days
**Complexity**: Medium
**Test Coverage Goal**: 95%+ (pgTAP tests)

### Migration 011: Create app_config Table

#### Cycle 1.1: app_config Table Schema
**RED** 🔴
- **Test**: `supabase/tests/app_config_test.sql`
- **Test Case 1**: `should_create_app_config_table_with_correct_schema`
  - Verify columns: id, key (text), value (jsonb), created_at, updated_at
  - Verify primary key on id
  - Verify unique constraint on key
  - Mock: None (DDL test)
  - Assertions:
    - Table exists
    - Columns have correct types
    - Constraints are enforced

- **Test Case 2**: `should_have_is_free_mode_config_row`
  - Verify default row exists: `key = 'is_free_mode', value = '{"enabled": false}'`
  - Assertions: Row count = 1, value.enabled = false

**GREEN** 🟢
- **Implementation**: `supabase/migrations/011_create_app_config.sql`
- **Minimum Code**:
  ```sql
  CREATE TABLE app_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key TEXT NOT NULL UNIQUE,
    value JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
  );

  -- Insert default free mode config (disabled)
  INSERT INTO app_config (key, value)
  VALUES ('is_free_mode', '{"enabled": false}');

  -- RLS: Public read-only access
  ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "app_config_public_read" ON app_config FOR SELECT USING (true);
  ```
- **Supabase**: Table `app_config` with RLS

**REFACTOR** 🔵
- [x] Add `updated_at` trigger function for automatic timestamp updates (✅ Implemented in migration 011)
- [x] Add comments to document table purpose (✅ COMMENT ON TABLE/COLUMN added)

**Estimate**: 3 hours | **Dependencies**: None

---

#### Cycle 1.2: RLS Policies for app_config
**RED** 🔴
- **Test**: `supabase/tests/app_config_test.sql`
- **Test Case 3**: `should_allow_public_read_access`
  - Test with anonymous user
  - Assertions: SELECT query succeeds

- **Test Case 4**: `should_deny_public_write_access`
  - Test INSERT/UPDATE/DELETE with anonymous user
  - Assertions: All write operations fail

- **Test Case 5**: `should_allow_admin_write_access` (Service Role Key)
  - Test UPDATE with service role
  - Assertions: UPDATE succeeds

**GREEN** 🟢
- **Implementation**: Already included in 011_create_app_config.sql
- **RLS Policies**:
  - Public: SELECT only
  - Admin: Full access via service role (bypasses RLS)

**REFACTOR** 🔵
- [x] Document RLS policy design in migration comments (✅ Added policy documentation)
- [x] Add policy names for easier debugging (✅ Named policy: "Anyone can read app_config")

**Estimate**: 2 hours | **Dependencies**: Cycle 1.1

---

### Migration 012: Update get_user_tier RPC

#### Cycle 1.3: get_user_tier RPC with Free Mode Logic
**RED** 🔴
- **Test**: `supabase/tests/app_config_test.sql`
- **Test Case 6**: `should_return_member_tier_when_free_mode_disabled`
  - Mock: User with tier='member', is_free_mode=false
  - Assertions: get_user_tier() returns 'member'

- **Test Case 7**: `should_return_premium_tier_when_free_mode_enabled_and_user_is_member`
  - Mock: User with tier='member', is_free_mode=true
  - Assertions: get_user_tier() returns 'premium'

- **Test Case 8**: `should_return_guest_tier_when_free_mode_enabled_and_user_is_guest`
  - Mock: User with tier='guest', is_free_mode=true
  - Assertions: get_user_tier() returns 'guest' (unchanged)

- **Test Case 9**: `should_return_premium_tier_when_user_is_already_premium`
  - Mock: User with tier='premium', is_free_mode=true or false
  - Assertions: get_user_tier() returns 'premium' (unchanged)

**GREEN** 🟢
- **Implementation**: `supabase/migrations/012_update_get_user_tier_rpc.sql`
- **Minimum Code**:
  ```sql
  CREATE OR REPLACE FUNCTION get_user_tier(user_id_param UUID)
  RETURNS TEXT AS $$
  DECLARE
    base_tier TEXT;
    is_free_mode BOOLEAN;
  BEGIN
    -- Get base tier from user_profiles
    SELECT tier INTO base_tier FROM user_profiles WHERE id = user_id_param;

    -- Get free mode flag from app_config
    SELECT (value->>'enabled')::BOOLEAN INTO is_free_mode
    FROM app_config WHERE key = 'is_free_mode';

    -- Apply free mode logic
    IF is_free_mode AND base_tier = 'member' THEN
      RETURN 'premium';
    ELSE
      RETURN base_tier;
    END IF;
  END;
  $$ LANGUAGE plpgsql SECURITY DEFINER;
  ```
- **Supabase**: Updated RPC function

**REFACTOR** 🔵
- [x] Add error handling for missing user_id (✅ COALESCE used for tier)
- [x] Add null checks for app_config (fallback to paid mode if missing) (✅ COALESCE(v_is_free_mode, false))
- [x] Add function comments explaining free mode logic (✅ COMMENT ON FUNCTION added)

**Estimate**: 3 hours | **Dependencies**: Cycle 1.2

---

#### Cycle 1.4: get_app_config RPC Function
**RED** 🔴
- **Test**: `supabase/tests/app_config_test.sql`
- **Test Case 10**: `should_return_config_by_key`
  - Mock: app_config with key='is_free_mode'
  - Assertions: get_app_config('is_free_mode') returns correct jsonb

- **Test Case 11**: `should_return_null_for_nonexistent_key`
  - Mock: app_config without key='nonexistent'
  - Assertions: get_app_config('nonexistent') returns null

**GREEN** 🟢
- **Implementation**: `supabase/migrations/011_create_app_config.sql` (append)
- **Minimum Code**:
  ```sql
  CREATE OR REPLACE FUNCTION get_app_config(config_key TEXT)
  RETURNS JSONB AS $$
  BEGIN
    RETURN (SELECT value FROM app_config WHERE key = config_key);
  END;
  $$ LANGUAGE plpgsql SECURITY DEFINER;
  ```

**REFACTOR** 🔵
- [ ] Consider caching strategy at database level (optional)
- [ ] Add logging for config access (optional)

**Estimate**: 2 hours | **Dependencies**: Cycle 1.1

---

### pgTAP Test Suite

#### Cycle 1.5: Comprehensive pgTAP Tests
**RED** 🔴
- **Test**: `supabase/tests/app_config_test.sql`
- **Test Case 12**: `should_handle_concurrent_config_reads`
  - Test multiple simultaneous reads
  - Assertions: No race conditions, consistent results

- **Test Case 13**: `should_update_updated_at_timestamp`
  - Test UPDATE on app_config
  - Assertions: updated_at changes

- **Test Case 14**: `should_prevent_duplicate_keys`
  - Test INSERT with duplicate key
  - Assertions: Unique constraint violation

- **Test Case 15**: `should_validate_jsonb_structure`
  - Test INSERT with invalid JSON
  - Assertions: Insert fails or coerces to valid JSON

**GREEN** 🟢
- **Implementation**: `supabase/tests/app_config_test.sql`
- **Minimum Code**: 15 pgTAP test functions
- **Test Framework**: pgTAP

**REFACTOR** 🔵
- [ ] Group tests by concern (schema, RLS, RPC, edge cases)
- [ ] Add test setup/teardown for isolation
- [ ] Document test cases in comments

**Estimate**: 4 hours | **Dependencies**: Cycles 1.1-1.4

---

### Phase 1 Checklist

#### Database Migrations
- [ ] **[DB]** Create migration 011: `app_config` table with RLS
- [ ] **[DB]** Insert default `is_free_mode` config (disabled)
- [ ] **[DB]** Create migration 012: Update `get_user_tier` RPC
- [ ] **[DB]** Create `get_app_config` RPC function
- [ ] **[DB]** Add `updated_at` trigger for `app_config`

#### pgTAP Tests (15 tests)
- [ ] **[Test]** Test Case 1: Table schema validation
- [ ] **[Test]** Test Case 2: Default config row exists
- [ ] **[Test]** Test Case 3: Public read access
- [ ] **[Test]** Test Case 4: Public write denied
- [ ] **[Test]** Test Case 5: Admin write access
- [ ] **[Test]** Test Case 6: Member tier (free mode OFF)
- [ ] **[Test]** Test Case 7: Member→Premium (free mode ON)
- [ ] **[Test]** Test Case 8: Guest stays guest (free mode ON)
- [ ] **[Test]** Test Case 9: Premium stays premium (both modes)
- [ ] **[Test]** Test Case 10: get_app_config returns value
- [ ] **[Test]** Test Case 11: get_app_config returns null
- [ ] **[Test]** Test Case 12: Concurrent reads
- [ ] **[Test]** Test Case 13: updated_at trigger
- [ ] **[Test]** Test Case 14: Unique key constraint
- [ ] **[Test]** Test Case 15: JSONB validation

#### Verification
- [ ] **[Run]** Execute migrations on local Supabase
- [ ] **[Run]** Run pgTAP test suite: `pg_prove supabase/tests/app_config_test.sql`
- [ ] **[Verify]** All 15 tests passing
- [ ] **[Manual]** Toggle `is_free_mode` via Supabase Dashboard
- [ ] **[Manual]** Verify `get_user_tier()` behavior changes

---

## Phase 2: Flutter Core (App Config) - 23 items

**Estimated Duration**: 2 days
**Complexity**: Medium
**Test Coverage Goal**: 95%+ (Unit tests for Repository, DataSource, Providers)

### Cycle 2.1: AppConfig Entity (Freezed)
**RED** 🔴
- **Test**: `test/core/config/domain/entities/app_config_test.dart`
- **Test Case 1**: `should_create_app_config_with_free_mode_enabled`
  - Assertions: AppConfig(isFreeModeEnabled: true).isFreeModeEnabled == true

- **Test Case 2**: `should_create_app_config_with_free_mode_disabled`
  - Assertions: AppConfig(isFreeModeEnabled: false).isFreeModeEnabled == false

- **Test Case 3**: `should_support_equality_comparison`
  - Assertions: Two instances with same values are equal (freezed)

- **Test Case 4**: `should_support_copyWith`
  - Assertions: copyWith works correctly

**GREEN** 🟢
- **Implementation**: `lib/core/config/domain/entities/app_config.dart`
- **Minimum Code**:
  ```dart
  import 'package:freezed_annotation/freezed_annotation.dart';

  part 'app_config.freezed.dart';

  @freezed
  class AppConfig with _$AppConfig {
    const factory AppConfig({
      required bool isFreeModeEnabled,
    }) = _AppConfig;
  }
  ```

**REFACTOR** 🔵
- [ ] Add JSON serialization (if needed for caching)
- [ ] Add default constructor for fallback values
- [ ] Consider adding other app-level configs (future-proofing)

**Estimate**: 2 hours | **Dependencies**: None

---

### Cycle 2.2: AppConfigRepository Interface
**RED** 🔴
- **Test**: `test/core/config/domain/repositories/app_config_repository_test.dart`
- **Test Case 5**: `should_define_getAppConfig_method`
  - Verify interface has `Future<Either<Failure, AppConfig>> getAppConfig()`

**GREEN** 🟢
- **Implementation**: `lib/core/config/domain/repositories/app_config_repository.dart`
- **Minimum Code**:
  ```dart
  import 'package:dartz/dartz.dart';
  import '../../../../core/errors/failures.dart';
  import '../entities/app_config.dart';

  abstract class AppConfigRepository {
    Future<Either<Failure, AppConfig>> getAppConfig();
  }
  ```

**REFACTOR** 🔵
- [ ] Add documentation explaining repository purpose
- [ ] Consider adding `refreshConfig()` method for cache invalidation

**Estimate**: 1 hour | **Dependencies**: Cycle 2.1

---

### Cycle 2.3: SupabaseAppConfigDataSource
**RED** 🔴
- **Test**: `test/core/config/data/datasources/supabase_app_config_datasource_test.dart`
- **Test Case 6**: `should_fetch_app_config_from_supabase`
  - Mock: Supabase client returns `{"enabled": true}`
  - Assertions: getAppConfig() returns AppConfig(isFreeModeEnabled: true)

- **Test Case 7**: `should_handle_supabase_error`
  - Mock: Supabase client throws exception
  - Assertions: Throws exception (handled by repository layer)

- **Test Case 8**: `should_parse_enabled_false_correctly`
  - Mock: Supabase returns `{"enabled": false}`
  - Assertions: isFreeModeEnabled == false

- **Test Case 9**: `should_handle_missing_config_key`
  - Mock: Supabase returns null
  - Assertions: Throws or returns default (false)

**GREEN** 🟢
- **Implementation**: `lib/core/config/data/datasources/supabase_app_config_datasource.dart`
- **Minimum Code**:
  ```dart
  import 'package:supabase_flutter/supabase_flutter.dart';
  import '../entities/app_config.dart';

  abstract class AppConfigDataSource {
    Future<AppConfig> getAppConfig();
  }

  class SupabaseAppConfigDataSource implements AppConfigDataSource {
    final SupabaseClient _client;

    SupabaseAppConfigDataSource(this._client);

    @override
    Future<AppConfig> getAppConfig() async {
      final response = await _client.rpc('get_app_config', params: {'config_key': 'is_free_mode'});
      final enabled = response['enabled'] as bool? ?? false;
      return AppConfig(isFreeModeEnabled: enabled);
    }
  }
  ```

**REFACTOR** 🔵
- [ ] Add error handling with custom exceptions
- [ ] Add logging for debugging
- [ ] Consider caching at DataSource level (optional)

**Estimate**: 3 hours | **Dependencies**: Cycle 2.2

---

### Cycle 2.4: AppConfigRepository Implementation
**RED** 🔴
- **Test**: `test/core/config/data/repositories/app_config_repository_impl_test.dart`
- **Test Case 10**: `should_return_app_config_on_success`
  - Mock: DataSource returns AppConfig(isFreeModeEnabled: true)
  - Assertions: Result is Right(AppConfig)

- **Test Case 11**: `should_return_server_failure_on_exception`
  - Mock: DataSource throws exception
  - Assertions: Result is Left(ServerFailure)

- **Test Case 12**: `should_return_default_config_on_null`
  - Mock: DataSource returns null
  - Assertions: Result is Right(AppConfig(isFreeModeEnabled: false))

**GREEN** 🟢
- **Implementation**: `lib/core/config/data/repositories/app_config_repository_impl.dart`
- **Minimum Code**:
  ```dart
  import 'package:dartz/dartz.dart';
  import '../../../../core/errors/failures.dart';
  import '../../domain/entities/app_config.dart';
  import '../../domain/repositories/app_config_repository.dart';
  import '../datasources/supabase_app_config_datasource.dart';

  class AppConfigRepositoryImpl implements AppConfigRepository {
    final AppConfigDataSource _dataSource;

    AppConfigRepositoryImpl(this._dataSource);

    @override
    Future<Either<Failure, AppConfig>> getAppConfig() async {
      try {
        final config = await _dataSource.getAppConfig();
        return Right(config);
      } catch (e) {
        return Left(ServerFailure('Failed to fetch app config'));
      }
    }
  }
  ```

**REFACTOR** 🔵
- [ ] Add specific failure types (NetworkFailure, CacheFailure)
- [ ] Implement offline fallback (cached config)
- [ ] Add retry logic for transient failures

**Estimate**: 3 hours | **Dependencies**: Cycle 2.3

---

### Cycle 2.5: AppConfigProvider with Caching
**RED** 🔴
- **Test**: `test/core/config/presentation/providers/app_config_provider_test.dart`
- **Test Case 13**: `should_fetch_config_on_first_access`
  - Mock: Repository returns Right(AppConfig)
  - Assertions: Provider state is AsyncData(AppConfig)

- **Test Case 14**: `should_cache_config_for_5_minutes`
  - Mock: Repository called once, accessed twice within 5 min
  - Assertions: Repository only called once

- **Test Case 15**: `should_refresh_config_after_5_minutes`
  - Mock: Time advances 6 minutes
  - Assertions: Repository called again

- **Test Case 16**: `should_handle_fetch_failure`
  - Mock: Repository returns Left(ServerFailure)
  - Assertions: Provider state is AsyncError

**GREEN** 🟢
- **Implementation**: `lib/core/config/presentation/providers/app_config_provider.dart`
- **Minimum Code**:
  ```dart
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../domain/entities/app_config.dart';
  import '../../domain/repositories/app_config_repository.dart';

  final appConfigRepositoryProvider = Provider<AppConfigRepository>((ref) {
    // Implementation via DI
    throw UnimplementedError();
  });

  final appConfigProvider = FutureProvider.autoDispose<AppConfig>((ref) async {
    final repository = ref.watch(appConfigRepositoryProvider);
    final result = await repository.getAppConfig();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (config) => config,
    );
  });

  // Cache for 5 minutes using keepAlive
  final cachedAppConfigProvider = FutureProvider<AppConfig>((ref) async {
    final config = await ref.watch(appConfigProvider.future);

    // Keep alive for 5 minutes
    final timer = Timer(Duration(minutes: 5), () {
      ref.invalidateSelf();
    });
    ref.onDispose(() => timer.cancel());

    return config;
  });
  ```

**REFACTOR** 🔵
- [ ] Use Riverpod 2.x caching strategies (cacheTime)
- [ ] Add manual refresh method
- [ ] Add debug logging for cache hits/misses

**Estimate**: 4 hours | **Dependencies**: Cycle 2.4

---

### Cycle 2.6: isFreeModeProvider
**RED** 🔴
- **Test**: `test/core/config/presentation/providers/app_config_provider_test.dart`
- **Test Case 17**: `should_return_true_when_free_mode_enabled`
  - Mock: AppConfig(isFreeModeEnabled: true)
  - Assertions: isFreeModeProvider returns true

- **Test Case 18**: `should_return_false_when_free_mode_disabled`
  - Mock: AppConfig(isFreeModeEnabled: false)
  - Assertions: isFreeModeProvider returns false

- **Test Case 19**: `should_return_false_on_config_error`
  - Mock: appConfigProvider throws error
  - Assertions: isFreeModeProvider returns false (safe default)

**GREEN** 🟢
- **Implementation**: `lib/core/config/presentation/providers/app_config_provider.dart` (append)
- **Minimum Code**:
  ```dart
  final isFreeModeProvider = Provider<bool>((ref) {
    final configAsync = ref.watch(cachedAppConfigProvider);
    return configAsync.when(
      data: (config) => config.isFreeModeEnabled,
      loading: () => false, // Default to paid mode during load
      error: (_, __) => false, // Default to paid mode on error
    );
  });
  ```

**REFACTOR** 🔵
- [ ] Consider logging when defaulting to false
- [ ] Add telemetry for free mode usage

**Estimate**: 2 hours | **Dependencies**: Cycle 2.5

---

### Phase 2 Checklist

#### Domain Layer
- [ ] **[Entity]** Create AppConfig entity with freezed (4 tests)
- [ ] **[Repository]** Define AppConfigRepository interface (1 test)
- [ ] **[Run]** Generate freezed code: `flutter pub run build_runner build`

#### Data Layer
- [ ] **[DataSource]** Create AppConfigDataSource interface
- [ ] **[DataSource]** Implement SupabaseAppConfigDataSource (4 tests)
- [ ] **[Repository]** Implement AppConfigRepositoryImpl (3 tests)

#### Presentation Layer
- [ ] **[Provider]** Create appConfigRepositoryProvider
- [ ] **[Provider]** Create appConfigProvider (base, no cache)
- [ ] **[Provider]** Create cachedAppConfigProvider with 5min cache (4 tests)
- [ ] **[Provider]** Create isFreeModeProvider (3 tests)

#### Testing
- [ ] **[Test]** Write 4 AppConfig entity tests
- [ ] **[Test]** Write 1 repository interface test
- [ ] **[Test]** Write 4 DataSource tests
- [ ] **[Test]** Write 3 Repository implementation tests
- [ ] **[Test]** Write 7 Provider tests (4 caching + 3 isFreeMode)
- [ ] **[Run]** All 19 tests passing

#### Integration
- [ ] **[Wire]** Wire AppConfigRepository DI in main.dart
- [ ] **[Wire]** Connect SupabaseAppConfigDataSource to SupabaseClient
- [ ] **[Verify]** Providers accessible throughout app

---

## Phase 3: Effective Tier Logic - 12 items

**Estimated Duration**: 1.5 days
**Complexity**: High (Critical business logic)
**Test Coverage Goal**: 95%+

### Cycle 3.1: effectiveUserTierProvider Logic
**RED** 🔴
- **Test**: `test/features/auth/providers/auth_providers_test.dart`
- **Test Case 20**: `should_return_guest_when_not_logged_in`
  - Mock: currentUser = null, isFreeMode = false
  - Assertions: effectiveUserTier == UserTier.guest

- **Test Case 21**: `should_return_member_when_logged_in_as_member_and_paid_mode`
  - Mock: currentUser exists, tier=member, isFreeMode=false
  - Assertions: effectiveUserTier == UserTier.member

- **Test Case 22**: `should_return_premium_when_logged_in_as_member_and_free_mode`
  - Mock: currentUser exists, tier=member, isFreeMode=true
  - Assertions: effectiveUserTier == UserTier.premium

- **Test Case 23**: `should_return_guest_when_guest_in_free_mode`
  - Mock: currentUser exists, tier=guest, isFreeMode=true
  - Assertions: effectiveUserTier == UserTier.guest (unchanged)

- **Test Case 24**: `should_return_premium_when_already_premium_regardless_of_mode`
  - Mock: currentUser exists, tier=premium, isFreeMode=true/false
  - Assertions: effectiveUserTier == UserTier.premium

- **Test Case 25**: `should_handle_tier_fetch_failure`
  - Mock: getUserTier() throws error
  - Assertions: Defaults to guest or throws appropriately

**GREEN** 🟢
- **Implementation**: `lib/features/auth/providers/auth_providers.dart` (append)
- **Minimum Code**:
  ```dart
  import '../../../core/config/presentation/providers/app_config_provider.dart';

  /// Provider for effective user tier (applies free mode logic)
  /// Replaces currentUserTierProvider in all UI code
  final effectiveUserTierProvider = FutureProvider<UserTier>((ref) async {
    final currentUser = ref.watch(currentUserProvider);
    final isFreeMode = ref.watch(isFreeModeProvider);

    if (currentUser == null) {
      return UserTier.guest;
    }

    // Get base tier from database
    final userProfileRepo = ref.watch(userProfileRepositoryProvider);
    final result = await userProfileRepo.getUserTier(currentUser.id);

    final baseTier = result.fold(
      (failure) => UserTier.guest,
      (tier) => tier,
    );

    // Apply free mode logic: member → premium, others unchanged
    if (isFreeMode && baseTier == UserTier.member) {
      return UserTier.premium;
    }

    return baseTier;
  });
  ```

**REFACTOR** 🔵
- [ ] Add documentation explaining free mode transformation
- [ ] Consider adding telemetry for tier transformations
- [ ] Add debug logging for tier resolution

**Estimate**: 4 hours | **Dependencies**: Phase 2 complete

---

### Cycle 3.2: Cache Invalidation on Auth Changes
**RED** 🔴
- **Test**: `test/features/auth/providers/auth_providers_test.dart`
- **Test Case 26**: `should_refresh_effective_tier_on_login`
  - Mock: User logs in
  - Assertions: effectiveUserTierProvider rebuilds with new user

- **Test Case 27**: `should_refresh_effective_tier_on_logout`
  - Mock: User logs out
  - Assertions: effectiveUserTierProvider resets to guest

**GREEN** 🟢
- **Implementation**: Already handled by Riverpod's reactivity
- **Verify**: effectiveUserTierProvider watches currentUserProvider
- **No additional code needed** (Riverpod auto-invalidates)

**REFACTOR** 🔵
- [ ] Add test to verify reactivity chain
- [ ] Document provider dependency graph

**Estimate**: 2 hours | **Dependencies**: Cycle 3.1

---

### Phase 3 Checklist

#### Implementation
- [ ] **[Provider]** Add effectiveUserTierProvider to auth_providers.dart
- [ ] **[Import]** Import app_config_provider in auth_providers.dart
- [ ] **[Logic]** Implement free mode transformation logic
- [ ] **[Verify]** Provider watches currentUserProvider and isFreeModeProvider

#### Testing
- [ ] **[Test]** Test Case 20: Guest when not logged in
- [ ] **[Test]** Test Case 21: Member in paid mode
- [ ] **[Test]** Test Case 22: Member→Premium in free mode
- [ ] **[Test]** Test Case 23: Guest stays guest in free mode
- [ ] **[Test]** Test Case 24: Premium unchanged in both modes
- [ ] **[Test]** Test Case 25: Tier fetch failure handling
- [ ] **[Test]** Test Case 26: Refresh on login
- [ ] **[Test]** Test Case 27: Refresh on logout
- [ ] **[Run]** All 8 effectiveUserTier tests passing

#### Documentation
- [ ] **[Doc]** Add inline comments explaining free mode logic
- [ ] **[Doc]** Update auth_providers.dart header documentation
- [ ] **[Doc]** Document migration path from currentUserTierProvider

---

## Phase 4: Code Migration - 14 items

**Estimated Duration**: 1.5 days
**Complexity**: Low (Refactoring)
**Risk**: Medium (Breaking existing functionality if not careful)

### Migration Strategy

**Search Pattern**: `currentUserTierProvider`
**Replace With**: `effectiveUserTierProvider`
**Files Affected**: 11 files (from grep results)

### Cycle 4.1: Update Scripture Providers
**RED** 🔴
- **Test**: `test/features/scripture/presentation/providers/scripture_providers_test.dart`
- **Test Case 28**: `should_use_effective_tier_for_daily_scriptures`
  - Mock: effectiveUserTier = premium (member in free mode)
  - Assertions: dailyScripturesProvider calls getRandomScripture(3)

- **Test Case 29**: `should_handle_tier_changes_reactively`
  - Mock: Switch from paid to free mode
  - Assertions: Provider rebuilds with new tier

**GREEN** 🟢
- **Implementation**: `lib/features/scripture/presentation/providers/scripture_providers.dart`
- **Changes**:
  ```dart
  // BEFORE
  final tier = await ref.watch(currentUserTierProvider.future);

  // AFTER
  final tier = await ref.watch(effectiveUserTierProvider.future);
  ```

**REFACTOR** 🔵
- [ ] Update tests to use effectiveUserTierProvider
- [ ] Verify no tier logic duplication

**Estimate**: 2 hours | **Dependencies**: Phase 3 complete

---

### Cycle 4.2: Update UI Components (Daily Feed, Library, etc.)
**RED** 🔴
- **Test**: Update existing widget tests to use effectiveUserTierProvider
- **Test Case 30**: `should_show_correct_content_based_on_effective_tier`
  - Test DailyFeedScreen, MyLibraryScreen, HomeScreen
  - Mock: effectiveUserTier
  - Assertions: UI reflects effective tier, not base tier

**GREEN** 🟢
- **Implementation**: Update 9 files:
  1. `lib/features/scripture/presentation/screens/daily_feed_screen.dart`
  2. `lib/features/prayer_note/presentation/screens/my_library_screen.dart`
  3. `lib/features/auth/presentation/screens/home_screen.dart`
  4. `lib/features/prayer_note/presentation/utils/my_library_navigation.dart`
  5. `lib/features/subscription/presentation/providers/subscription_providers.dart`
  6. Corresponding test files

**REFACTOR** 🔵
- [ ] Search for any remaining `currentUserTierProvider` references
- [ ] Update all imports if needed
- [ ] Run full test suite to catch regressions

**Estimate**: 3 hours | **Dependencies**: Cycle 4.1

---

### Cycle 4.3: Update Subscription Invalidation Logic
**RED** 🔴
- **Test**: `test/features/subscription/presentation/providers/subscription_providers_test.dart`
- **Test Case 31**: `should_invalidate_effective_tier_on_subscription_change`
  - Mock: User purchases premium
  - Assertions: effectiveUserTierProvider refreshes

**GREEN** 🟢
- **Implementation**: `lib/features/subscription/presentation/providers/subscription_providers.dart`
- **Changes**:
  ```dart
  // BEFORE
  ref.invalidate(currentUserTierProvider);

  // AFTER
  ref.invalidate(effectiveUserTierProvider);
  // Note: May also need to invalidate currentUserTierProvider for base tier
  ```

**REFACTOR** 🔵
- [ ] Verify invalidation cascade works correctly
- [ ] Document why both providers may need invalidation

**Estimate**: 2 hours | **Dependencies**: Cycle 4.2

---

### Phase 4 Checklist

#### File-by-File Migration
- [ ] **[Migrate]** scripture_providers.dart (1 reference)
- [ ] **[Migrate]** daily_feed_screen.dart (1 reference)
- [ ] **[Migrate]** my_library_screen.dart (1 reference)
- [ ] **[Migrate]** home_screen.dart (1 reference)
- [ ] **[Migrate]** my_library_navigation.dart (1 reference)
- [ ] **[Migrate]** subscription_providers.dart (2 references: read + invalidate)
- [ ] **[Migrate]** Test files (6 files with currentUserTierProvider mocks)

#### Test Updates
- [ ] **[Update]** scripture_providers_test.dart
- [ ] **[Update]** daily_feed_screen_test.dart
- [ ] **[Update]** my_library_screen_test.dart
- [ ] **[Update]** home_screen_test.dart
- [ ] **[Update]** subscription_providers_test.dart
- [ ] **[Update]** integration_test/scripture_upsell_flow_test.dart

#### Verification
- [ ] **[Search]** Run `grep -r "currentUserTierProvider" lib/` to find any remaining references
- [ ] **[Verify]** Zero results (or only in deprecated/comment context)
- [ ] **[Run]** Full test suite: `flutter test`
- [ ] **[Run]** Integration tests: `flutter test integration_test/`

---

## Phase 5: Integration Testing - 13 items

**Estimated Duration**: 1.5 days
**Complexity**: Medium
**Test Coverage Goal**: 90%+

### Cycle 5.1: Free Mode Toggle Integration Test
**RED** 🔴
- **Test**: `integration_test/feature_flag_mode_switching_test.dart`
- **Test Case 32**: `should_switch_from_paid_to_free_mode_for_member`
  - Setup: Member user logged in, paid mode
  - Action: Toggle app_config to free mode
  - Wait 5min for cache expiry (or force refresh)
  - Assertions: UI shows premium features

- **Test Case 33**: `should_switch_from_free_to_paid_mode_for_member`
  - Setup: Member user logged in, free mode
  - Action: Toggle app_config to paid mode
  - Wait for cache expiry
  - Assertions: UI shows member restrictions

- **Test Case 34**: `should_not_affect_guest_users`
  - Setup: Guest user (no login)
  - Action: Toggle free mode on/off
  - Assertions: Guest always sees guest restrictions

- **Test Case 35**: `should_not_affect_premium_users`
  - Setup: Premium subscriber logged in
  - Action: Toggle free mode on/off
  - Assertions: Premium always sees premium features

**GREEN** 🟢
- **Implementation**: `integration_test/feature_flag_mode_switching_test.dart`
- **Test Type**: Widget Integration Test with Supabase
- **Approach**: Use mock Supabase or test project

**REFACTOR** 🔵
- [ ] Add test utilities for mode toggling
- [ ] Consider using golden tests for UI verification
- [ ] Add performance measurements for cache invalidation

**Estimate**: 6 hours | **Dependencies**: Phases 1-4 complete

---

### Cycle 5.2: Cache Behavior Integration Test
**RED** 🔴
- **Test**: `integration_test/app_config_cache_test.dart`
- **Test Case 36**: `should_cache_config_for_5_minutes`
  - Setup: Fresh app start
  - Action: Access isFreeModeProvider multiple times within 5min
  - Assertions: Supabase RPC called only once (spy/mock)

- **Test Case 37**: `should_refresh_after_cache_expiry`
  - Setup: Cached config exists
  - Action: Wait 6 minutes, access provider
  - Assertions: Supabase RPC called again

- **Test Case 38**: `should_survive_app_backgrounding`
  - Setup: Config cached
  - Action: Simulate app going to background and returning
  - Assertions: Cache persists if within 5min window

**GREEN** 🟢
- **Implementation**: `integration_test/app_config_cache_test.dart`
- **Test Type**: Widget Integration Test
- **Mock**: Track Supabase RPC call count

**REFACTOR** 🔵
- [ ] Use `fake_async` for time manipulation in tests
- [ ] Add telemetry to verify cache hit rate in production

**Estimate**: 4 hours | **Dependencies**: Phase 2 complete

---

### Cycle 5.3: End-to-End User Journey Tests
**RED** 🔴
- **Test**: `integration_test/free_mode_user_journey_test.dart`
- **Test Case 39**: `guest_sees_1_card_in_both_modes`
  - Journey: Guest opens app → views 1 card → sees login blocker
  - Modes: Test in paid and free mode
  - Assertions: Guest experience identical

- **Test Case 40**: `member_sees_3_cards_in_both_modes`
  - Journey: Member logs in → views 3 cards
  - Modes: Test in paid and free mode
  - Assertions: Card count same, features differ

- **Test Case 41**: `member_can_write_prayer_in_free_mode`
  - Journey: Member (in free mode) → writes prayer → saves successfully
  - Assertions: Prayer saved, visible in library

- **Test Case 42**: `member_views_all_prayers_in_free_mode`
  - Journey: Member (in free mode) → navigates to library → sees all dates unlocked
  - Assertions: No lock icons, all dates accessible

- **Test Case 43**: `member_views_restricted_prayers_in_paid_mode`
  - Journey: Member (in paid mode) → navigates to library → sees lock icons on old dates
  - Assertions: Only today's prayers accessible

- **Test Case 44**: `premium_experience_unchanged_in_both_modes`
  - Journey: Premium user → all features accessible
  - Modes: Test in paid and free mode
  - Assertions: Identical experience

**GREEN** 🟢
- **Implementation**: `integration_test/free_mode_user_journey_test.dart`
- **Test Type**: Full E2E integration test
- **Approach**: Use Supabase test project with controlled data

**REFACTOR** 🔵
- [ ] Reuse test utilities from existing integration tests
- [ ] Add screenshot capture for visual regression testing
- [ ] Consider adding test data seeders

**Estimate**: 8 hours | **Dependencies**: Phases 1-4 complete

---

### Phase 5 Checklist

#### Integration Test Files
- [ ] **[Create]** feature_flag_mode_switching_test.dart (4 tests)
- [ ] **[Create]** app_config_cache_test.dart (3 tests)
- [ ] **[Create]** free_mode_user_journey_test.dart (6 tests)

#### Test Scenarios
- [ ] **[Test]** Test Case 32: Member paid→free mode
- [ ] **[Test]** Test Case 33: Member free→paid mode
- [ ] **[Test]** Test Case 34: Guest unaffected
- [ ] **[Test]** Test Case 35: Premium unaffected
- [ ] **[Test]** Test Case 36: 5min cache works
- [ ] **[Test]** Test Case 37: Cache expires after 6min
- [ ] **[Test]** Test Case 38: Cache survives backgrounding
- [ ] **[Test]** Test Case 39: Guest journey (both modes)
- [ ] **[Test]** Test Case 40: Member journey (both modes)
- [ ] **[Test]** Test Case 41: Member prayer write (free mode)
- [ ] **[Test]** Test Case 42: Member prayer view (free mode)
- [ ] **[Test]** Test Case 43: Member prayer restrictions (paid mode)
- [ ] **[Test]** Test Case 44: Premium unchanged (both modes)

#### Verification
- [ ] **[Run]** All 13 integration tests passing
- [ ] **[Run]** Full regression test suite
- [ ] **[Manual]** Test on iOS Simulator
- [ ] **[Manual]** Test on Android Emulator
- [ ] **[Manual]** Test mode toggle in Supabase Dashboard

---

## Documentation - 10 items

### Cycle 6.1: Code Documentation
- [ ] **[Doc]** Add inline comments to effectiveUserTierProvider
- [ ] **[Doc]** Document AppConfig entity purpose
- [ ] **[Doc]** Add migration guide to CHANGELOG.md
- [ ] **[Doc]** Update auth_providers.dart header with free mode explanation

### Cycle 6.2: Technical Documentation
- [ ] **[Doc]** Create FEATURE_FLAG_GUIDE.md with:
  - How to toggle free mode via Supabase Dashboard
  - Expected behavior in each mode
  - Troubleshooting cache issues
  - Migration timeline from currentUserTierProvider
- [ ] **[Doc]** Update CLAUDE.md User Tiers table with free mode column
- [ ] **[Doc]** Update PLANNER.md with Phase 6 completion status
- [ ] **[Doc]** Create architecture diagram showing provider dependency chain

### Cycle 6.3: Operations Documentation
- [ ] **[Doc]** Create Supabase Dashboard toggle checklist:
  - SQL to enable: `UPDATE app_config SET value = '{"enabled": true}' WHERE key = 'is_free_mode';`
  - SQL to disable: `UPDATE app_config SET value = '{"enabled": false}' WHERE key = 'is_free_mode';`
  - Verification query: `SELECT * FROM app_config WHERE key = 'is_free_mode';`
- [ ] **[Doc]** Document rollback procedure if issues arise

---

## Files Created (7 new files)

### Supabase Migrations
1. `supabase/migrations/011_create_app_config.sql` (Table + RLS + RPC)
2. `supabase/migrations/012_update_get_user_tier_rpc.sql` (Updated RPC with free mode logic)

### Supabase Tests
3. `supabase/tests/app_config_test.sql` (15 pgTAP tests)

### Flutter Core - Domain
4. `lib/core/config/domain/entities/app_config.dart` (Freezed entity)
5. `lib/core/config/domain/repositories/app_config_repository.dart` (Interface)

### Flutter Core - Data
6. `lib/core/config/data/datasources/supabase_app_config_datasource.dart` (DataSource)
7. `lib/core/config/data/repositories/app_config_repository_impl.dart` (Implementation)

### Flutter Core - Presentation
8. `lib/core/config/presentation/providers/app_config_provider.dart` (Providers)

### Tests
9. `test/core/config/domain/entities/app_config_test.dart` (4 tests)
10. `test/core/config/data/datasources/supabase_app_config_datasource_test.dart` (4 tests)
11. `test/core/config/data/repositories/app_config_repository_impl_test.dart` (3 tests)
12. `test/core/config/presentation/providers/app_config_provider_test.dart` (7 tests)
13. `test/features/auth/providers/auth_providers_effective_tier_test.dart` (8 tests)

### Integration Tests
14. `integration_test/feature_flag_mode_switching_test.dart` (4 tests)
15. `integration_test/app_config_cache_test.dart` (3 tests)
16. `integration_test/free_mode_user_journey_test.dart` (6 tests)

### Documentation
17. `FEATURE_FLAG_GUIDE.md`
18. `checklist/phase6-feature-flag-system.md` (This file)

---

## Files Modified (11+ files)

### Core
1. `lib/features/auth/providers/auth_providers.dart` (Add effectiveUserTierProvider)

### Features (Replace currentUserTierProvider → effectiveUserTierProvider)
2. `lib/features/scripture/presentation/providers/scripture_providers.dart`
3. `lib/features/scripture/presentation/screens/daily_feed_screen.dart`
4. `lib/features/prayer_note/presentation/screens/my_library_screen.dart`
5. `lib/features/prayer_note/presentation/utils/my_library_navigation.dart`
6. `lib/features/auth/presentation/screens/home_screen.dart`
7. `lib/features/subscription/presentation/providers/subscription_providers.dart`

### Tests (Update to use effectiveUserTierProvider)
8. `test/features/scripture/presentation/providers/scripture_providers_test.dart`
9. `test/features/scripture/presentation/screens/daily_feed_screen_test.dart`
10. `test/features/prayer_note/presentation/screens/my_library_screen_test.dart`
11. `test/features/auth/presentation/screens/home_screen_test.dart`
12. `test/features/subscription/presentation/providers/subscription_providers_test.dart`
13. `integration_test/scripture_upsell_flow_test.dart`

### Documentation
14. `PLANNER.md`
15. `CLAUDE.md` (Update User Tiers table)
16. `CHANGELOG.md` (Add migration notes)

---

## Test Summary

| Test Type | File Count | Test Count | Coverage Goal |
|-----------|------------|------------|---------------|
| **pgTAP (Supabase)** | 1 | 15 | 95%+ |
| **Unit (Domain)** | 1 | 4 | 100% |
| **Unit (DataSource)** | 1 | 4 | 95%+ |
| **Unit (Repository)** | 1 | 3 | 95%+ |
| **Unit (Providers)** | 2 | 15 | 95%+ |
| **Integration** | 3 | 13 | 90%+ |
| **Widget (Updated)** | 6 | 24 (updated) | 90%+ |
| **TOTAL** | 15 | 78 | 93%+ |

---

## Dependency Graph

```
Phase 1 (Backend)
    ├─ Cycle 1.1: app_config table
    ├─ Cycle 1.2: RLS policies
    ├─ Cycle 1.3: get_user_tier RPC update
    ├─ Cycle 1.4: get_app_config RPC
    └─ Cycle 1.5: pgTAP tests
           ↓
Phase 2 (Flutter Core)
    ├─ Cycle 2.1: AppConfig entity
    ├─ Cycle 2.2: Repository interface
    ├─ Cycle 2.3: DataSource
    ├─ Cycle 2.4: Repository impl
    ├─ Cycle 2.5: AppConfig provider (cached)
    └─ Cycle 2.6: isFreeMode provider
           ↓
Phase 3 (Effective Tier)
    ├─ Cycle 3.1: effectiveUserTierProvider
    └─ Cycle 3.2: Cache invalidation
           ↓
Phase 4 (Migration)
    ├─ Cycle 4.1: Scripture providers
    ├─ Cycle 4.2: UI components (9 files)
    └─ Cycle 4.3: Subscription invalidation
           ↓
Phase 5 (Integration Testing)
    ├─ Cycle 5.1: Mode switching tests
    ├─ Cycle 5.2: Cache tests
    └─ Cycle 5.3: E2E user journeys
           ↓
Documentation & Launch
```

---

## Daily Progress Milestones

### Day 1: Backend Foundation
- ✅ Morning: Cycles 1.1-1.2 (app_config table + RLS)
- ✅ Afternoon: Cycles 1.3-1.4 (RPC functions)
- ✅ End of Day: 011 & 012 migrations complete, 10 pgTAP tests passing

### Day 2: Backend Testing + Flutter Domain
- ✅ Morning: Cycle 1.5 (Complete pgTAP suite - 15 tests)
- ✅ Afternoon: Cycles 2.1-2.2 (AppConfig entity + Repository interface)
- ✅ End of Day: Phase 1 complete, Domain layer designed

### Day 3: Flutter Data + Presentation
- ✅ Morning: Cycles 2.3-2.4 (DataSource + Repository impl)
- ✅ Afternoon: Cycles 2.5-2.6 (Providers with caching)
- ✅ End of Day: Phase 2 complete, 19 Flutter unit tests passing

### Day 4: Effective Tier Logic
- ✅ Morning: Cycle 3.1 (effectiveUserTierProvider implementation)
- ✅ Afternoon: Cycle 3.2 (Cache invalidation) + Phase 3 tests
- ✅ End of Day: Phase 3 complete, 8 effective tier tests passing

### Day 5: Code Migration
- ✅ Morning: Cycle 4.1 (Scripture providers)
- ✅ Afternoon: Cycles 4.2-4.3 (UI components + subscription logic)
- ✅ End of Day: Phase 4 complete, all 11 files migrated, no `currentUserTierProvider` references

### Day 6: Integration Testing
- ✅ Morning: Cycle 5.1 (Mode switching tests)
- ✅ Afternoon: Cycle 5.2 (Cache behavior tests)
- ✅ End of Day: 7 integration tests passing

### Day 7: E2E Testing + Documentation
- ✅ Morning: Cycle 5.3 (User journey tests)
- ✅ Afternoon: Documentation (Cycles 6.1-6.3)
- ✅ End of Day: All 13 integration tests passing, docs complete

### Day 8: Final Verification + Launch
- ✅ Morning: Full regression test suite, manual QA on iOS/Android
- ✅ Afternoon: Test mode toggle in Supabase Dashboard, verify zero downtime
- ✅ End of Day: Phase 6 complete, feature flag system live

---

## Risk Factors & Mitigation

### Risk 1: Cache Invalidation Issues
**Severity**: Medium
**Probability**: Medium
**Impact**: Users stuck in wrong mode for up to 5 minutes
**Mitigation**:
- Add manual refresh mechanism (pull-to-refresh)
- Add telemetry to monitor cache hit rate
- Consider reducing cache time to 2-3 minutes if issues arise
- Add app-level cache clearing on subscription changes

### Risk 2: Provider Dependency Cycle
**Severity**: High
**Probability**: Low
**Impact**: App crashes due to circular dependency
**Mitigation**:
- Carefully review provider dependency chain in Phase 3
- Use Riverpod DevTools to visualize dependencies
- Add dependency diagram to documentation
- Test thoroughly with hot reload/restart

### Risk 3: Migration Regressions
**Severity**: High
**Probability**: Medium
**Impact**: Breaking existing tier checks, users see wrong content
**Mitigation**:
- Run full test suite after each file migration
- Use feature flag to toggle effectiveUserTierProvider (meta!)
- Deploy to staging first with comprehensive testing
- Keep currentUserTierProvider as fallback initially (deprecated)

### Risk 4: Supabase RPC Performance
**Severity**: Low
**Probability**: Low
**Impact**: Slow config fetches, perceived lag
**Mitigation**:
- Client-side 5min cache minimizes RPC calls
- Index app_config.key column
- Monitor Supabase logs for slow queries
- Consider edge caching via Supabase Edge Functions

### Risk 5: Free Mode Abuse
**Severity**: Medium
**Probability**: Medium
**Impact**: Revenue loss if users exploit free mode
**Mitigation**:
- Not a technical risk for this implementation
- Business decision to track free mode usage with telemetry
- Add analytics to monitor conversion rates in free mode
- Consider time-limited free mode promotions

---

## Success Criteria

### Technical Success
- ✅ All 78 tests passing (pgTAP + Unit + Integration)
- ✅ Zero `currentUserTierProvider` references in codebase (except deprecated marker)
- ✅ App config fetched from Supabase, cached for 5 minutes
- ✅ effectiveUserTierProvider returns correct tier in both modes
- ✅ No breaking changes to existing user experience

### Functional Success
- ✅ Toggle free mode via Supabase Dashboard (SQL update)
- ✅ Member users see Premium features in free mode within 5 minutes
- ✅ Guest users always restricted, regardless of mode
- ✅ Premium users unaffected by mode toggle
- ✅ Clean revert from free mode to paid mode

### Operational Success
- ✅ Zero app downtime during mode toggle
- ✅ No app update required to enable/disable free mode
- ✅ Rollback possible with single SQL update
- ✅ Documentation clear enough for non-technical operator to toggle mode
- ✅ Telemetry in place to monitor mode usage

---

## Rollback Plan

### If Issues Arise After Enabling Free Mode

**Step 1: Immediate Revert (SQL)**
```sql
-- Disable free mode immediately (takes effect in ≤5 minutes)
UPDATE app_config
SET value = '{"enabled": false}'
WHERE key = 'is_free_mode';
```

**Step 2: Verify Revert**
```sql
-- Verify config updated
SELECT * FROM app_config WHERE key = 'is_free_mode';
-- Expected: {"enabled": false}
```

**Step 3: Monitor Client Pickup**
- Wait 5 minutes for client cache expiry
- Monitor telemetry for tier distribution
- Verify users revert to paid tier logic

**Step 4: Investigate Issues**
- Check Supabase logs for errors
- Review client-side error reports
- Run integration test suite locally
- Identify root cause before re-enabling

### If Code Migration Causes Regressions

**Step 1: Revert Git Commit**
```bash
git revert <commit-hash>
git push origin main
```

**Step 2: Emergency Fix**
- If specific file causes issue, revert to `currentUserTierProvider` temporarily
- Deploy hotfix with fast-track CI/CD
- Schedule proper fix in next sprint

**Step 3: Test in Staging**
- Re-run full test suite
- Manual QA on staging environment
- Gradual rollout to production (phased deployment)

---

## Post-Implementation Monitoring

### Metrics to Track

**Technical Metrics**:
- AppConfig cache hit rate (target: >95%)
- AppConfig fetch latency (target: <500ms)
- effectiveUserTierProvider call count per session
- Provider rebuild frequency (avoid excessive rebuilds)

**Business Metrics**:
- % of users in free mode vs paid mode
- Member retention rate in free mode
- Conversion rate from Member (free mode) to Premium
- Revenue impact of free mode

**Error Metrics**:
- AppConfig fetch failures
- Cache invalidation errors
- Provider error states
- Tier resolution failures

### Alerting Thresholds

- ⚠️ Warning: AppConfig fetch latency >1s
- 🚨 Critical: AppConfig fetch failure rate >5%
- ⚠️ Warning: Cache hit rate <90%
- 🚨 Critical: effectiveUserTierProvider error rate >1%

---

## Additional Notes

### Why Not Use Remote Config (Firebase)?

**Decision**: Use Supabase app_config table instead of Firebase Remote Config

**Reasons**:
1. **Single Backend**: Already using Supabase, avoid additional dependency
2. **Simplicity**: One SQL update vs Firebase console navigation
3. **Testing**: Easier to mock Supabase RPC than Firebase SDK
4. **Cost**: Supabase already paid for, Firebase adds costs
5. **Consistency**: All config in one place (Supabase)

**Trade-offs**:
- Firebase has better caching and A/B testing features
- Firebase has more mature gradual rollout tools
- Supabase approach is simpler but less feature-rich

**Future Consideration**: If need A/B testing or complex rollout rules, migrate to Firebase Remote Config later.

---

### Functional Programming Principles Applied

1. **Immutability**:
   - AppConfig is a freezed entity (immutable)
   - Tier transformations create new values, never mutate

2. **Pure Functions**:
   - effectiveUserTierProvider logic is pure (same inputs → same output)
   - No side effects in tier calculation

3. **Declarative**:
   - UI declares dependency on effectiveUserTierProvider
   - Riverpod handles reactivity automatically

4. **Side Effect Isolation**:
   - Supabase calls isolated in DataSource layer
   - Repository wraps with Either for error handling
   - Providers handle async side effects

---

## Next Steps After Phase 6

### Immediate (Week 1)
1. Deploy feature flag system to production
2. Monitor telemetry for 1 week in paid mode (baseline)
3. Run limited free mode test (24 hours, 10% of users)

### Short-term (Month 1)
4. Enable free mode fully if test successful
5. Gather user feedback on free mode experience
6. Analyze conversion metrics (Member → Premium)

### Long-term (Quarter 1)
7. Consider time-limited free mode promotions
8. Implement A/B testing framework for feature flags
9. Add more app-level config flags (dark mode, experimental features)

---

**End of Phase 6 TDD Checklist**

**Total Estimated Time**: 6-8 days (48-64 hours)
**Complexity**: Medium-High
**Team Size**: 1-2 developers
**Prerequisites**: Phases 1-4 complete, Supabase CLI installed, pgTAP configured

**Last Updated**: February 23, 2026
**Status**: Ready for implementation
**Next Action**: Begin Cycle 1.1 (app_config table schema)
