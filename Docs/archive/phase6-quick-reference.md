# Phase 6: Feature Flag System - Quick Reference

## 30-Second Overview

**What**: Server-side toggle between free mode (members get premium) and paid mode (normal tiers)
**Why**: Launch promotions, A/B tests, growth hacks without app updates
**How**: Single SQL update in Supabase, 5min cache on client
**Risk**: Medium (careful tier logic required)
**Duration**: 6-8 days, 78 tests

---

## Implementation Phases (8-Day Plan)

| Day | Phase | What You'll Build | Tests |
|-----|-------|-------------------|-------|
| 1 | Backend Setup | `app_config` table + RLS | 10 pgTAP |
| 2 | Backend RPC | `get_user_tier` with free mode logic | 5 pgTAP |
| 3 | Flutter Domain/Data | AppConfig entity, Repository, DataSource | 11 unit |
| 4 | Flutter Providers | Cached config provider, effective tier logic | 15 unit |
| 5 | Code Migration | Replace `currentUserTierProvider` (11 files) | 24 widget |
| 6 | Integration Tests | Mode switching, cache behavior | 7 integration |
| 7 | E2E Tests | User journeys (guest/member/premium) | 6 integration |
| 8 | Polish & Launch | Documentation, QA, deploy | - |

---

## Key Files to Create (18 new files)

### Supabase (3 files)
```
supabase/migrations/011_create_app_config.sql
supabase/migrations/012_update_get_user_tier_rpc.sql
supabase/tests/app_config_test.sql
```

### Flutter Core (5 files)
```
lib/core/config/domain/entities/app_config.dart
lib/core/config/domain/repositories/app_config_repository.dart
lib/core/config/data/datasources/supabase_app_config_datasource.dart
lib/core/config/data/repositories/app_config_repository_impl.dart
lib/core/config/presentation/providers/app_config_provider.dart
```

### Tests (7 files)
```
test/core/config/domain/entities/app_config_test.dart
test/core/config/data/datasources/supabase_app_config_datasource_test.dart
test/core/config/data/repositories/app_config_repository_impl_test.dart
test/core/config/presentation/providers/app_config_provider_test.dart
test/features/auth/providers/auth_providers_effective_tier_test.dart
integration_test/feature_flag_mode_switching_test.dart
integration_test/app_config_cache_test.dart
integration_test/free_mode_user_journey_test.dart
```

### Documentation (3 files)
```
FEATURE_FLAG_GUIDE.md
checklist/phase6-feature-flag-system.md
checklist/phase6-quick-reference.md (this file)
```

---

## Key Files to Modify (12+ files)

### Core Logic (1 file)
```dart
// lib/features/auth/providers/auth_providers.dart
+ final effectiveUserTierProvider = FutureProvider<UserTier>((ref) async {
+   final isFreeMode = ref.watch(isFreeModeProvider);
+   if (isFreeMode && baseTier == UserTier.member) return UserTier.premium;
+   return baseTier;
+ });
```

### Replace currentUserTierProvider → effectiveUserTierProvider (11 files)
```
lib/features/scripture/presentation/providers/scripture_providers.dart
lib/features/scripture/presentation/screens/daily_feed_screen.dart
lib/features/prayer_note/presentation/screens/my_library_screen.dart
lib/features/prayer_note/presentation/utils/my_library_navigation.dart
lib/features/auth/presentation/screens/home_screen.dart
lib/features/subscription/presentation/providers/subscription_providers.dart
test/features/scripture/presentation/providers/scripture_providers_test.dart
test/features/scripture/presentation/screens/daily_feed_screen_test.dart
test/features/prayer_note/presentation/screens/my_library_screen_test.dart
test/features/auth/presentation/screens/home_screen_test.dart
test/features/subscription/presentation/providers/subscription_providers_test.dart
```

---

## Test Coverage Breakdown (78 tests total)

| Layer | Tests | Coverage Goal |
|-------|-------|---------------|
| pgTAP (Supabase) | 15 | 95%+ |
| Unit (Domain) | 4 | 100% |
| Unit (DataSource) | 4 | 95%+ |
| Unit (Repository) | 3 | 95%+ |
| Unit (Providers) | 15 | 95%+ |
| Widget (Updated) | 24 | 90%+ |
| Integration | 13 | 90%+ |

---

## Critical Test Cases (Must Pass)

### Tier Transformation Logic
```dart
// Test Case 22: Member → Premium in free mode
expect(
  effectiveUserTier,
  equals(UserTier.premium),
  reason: 'Member should become premium in free mode',
);

// Test Case 23: Guest stays guest
expect(
  effectiveUserTier,
  equals(UserTier.guest),
  reason: 'Guest must remain restricted in free mode',
);

// Test Case 24: Premium unchanged
expect(
  effectiveUserTier,
  equals(UserTier.premium),
  reason: 'Premium must be unaffected by free mode',
);
```

### Cache Behavior
```dart
// Test Case 36: 5-minute cache
verify(() => repository.getAppConfig()).called(1);
// Access again within 5 min
await ref.read(appConfigProvider.future);
verifyNever(() => repository.getAppConfig()); // Cached!
```

---

## Migration Checklist (Before Committing)

- [ ] Run `grep -r "currentUserTierProvider" lib/` → Zero results
- [ ] All 78 tests passing: `flutter test && pg_prove supabase/tests/`
- [ ] No runtime errors in Debug Console
- [ ] Manual QA: Toggle free mode in local Supabase, verify UI updates
- [ ] Update PLANNER.md with progress
- [ ] Update phase6-feature-flag-system.md checklist items

---

## How to Toggle Free Mode (Quick Commands)

### Enable Free Mode
```sql
UPDATE app_config SET value = '{"enabled": true}' WHERE key = 'is_free_mode';
```

### Disable Free Mode
```sql
UPDATE app_config SET value = '{"enabled": false}' WHERE key = 'is_free_mode';
```

### Verify Current Mode
```sql
SELECT key, value FROM app_config WHERE key = 'is_free_mode';
```

### Test with User
```sql
SELECT get_user_tier('<user-id-here>');
-- Free mode + member = 'premium'
-- Paid mode + member = 'member'
```

---

## Red-Green-Refactor Cycle Template

Use this template for each cycle in the detailed checklist.

### RED 🔴
```dart
test('should_[behavior]_when_[condition]', () {
  // Arrange: Set up mocks
  when(() => mockRepository.someMethod()).thenReturn(expectedValue);
  
  // Act: Call the code under test
  final result = await sut.methodUnderTest();
  
  // Assert: Verify expectations
  expect(result, equals(expectedValue));
  verify(() => mockRepository.someMethod()).called(1);
});
```

### GREEN 🟢
```dart
// Write MINIMUM code to pass the test
class MyClass {
  Future<Result> methodUnderTest() async {
    return await repository.someMethod(); // Simplest implementation
  }
}
```

### REFACTOR 🔵
- [ ] Remove duplication
- [ ] Extract constants
- [ ] Improve naming
- [ ] Add documentation
- [ ] Ensure immutability (freezed)

---

## Common Pitfalls & Solutions

### Pitfall 1: Circular Provider Dependency
**Problem**: `effectiveUserTierProvider` watches `isFreeModeProvider` which watches `appConfigProvider` which might watch auth...
**Solution**: Keep dependency chain linear: `appConfig → isFreeMode → effectiveTier`

### Pitfall 2: Cache Not Invalidating
**Problem**: Free mode enabled but users don't see changes for >10 minutes
**Solution**: 
```dart
// Add manual refresh
final cacheTimer = Timer(Duration(minutes: 5), () => ref.invalidateSelf());
ref.onDispose(() => cacheTimer.cancel());
```

### Pitfall 3: Guest Users Seeing Premium
**Problem**: Bug in `effectiveUserTierProvider` logic
**Solution**: Always check `currentUser == null` FIRST before any tier logic
```dart
if (currentUser == null) return UserTier.guest; // ← This MUST be first
```

### Pitfall 4: Tests Fail After Migration
**Problem**: Test mocks still use `currentUserTierProvider`
**Solution**: Search-replace in test files:
```bash
find test -type f -name "*.dart" -exec sed -i '' 's/currentUserTierProvider/effectiveUserTierProvider/g' {} +
```

---

## Success Metrics

### Technical
- ✅ All 78 tests passing (pgTAP + unit + integration)
- ✅ Zero `currentUserTierProvider` references in `lib/` (except deprecation notice)
- ✅ App config fetched in <500ms (p95)
- ✅ Cache hit rate >95%

### Functional
- ✅ Toggle free mode via SQL → Members see premium features within 5min
- ✅ Guest users unaffected (always restricted)
- ✅ Premium users unaffected (always premium)
- ✅ Clean revert to paid mode (single SQL update)

### Operational
- ✅ Zero app downtime during toggle
- ✅ No app update required
- ✅ Rollback works (tested in staging)
- ✅ Documentation clear for non-technical operators

---

## Next Steps After Implementation

1. **Staging Test** (Day 9):
   - Deploy to staging environment
   - Toggle free mode 3 times (on → off → on)
   - Verify no errors in logs
   - Test with real devices (iOS + Android)

2. **Production Deploy** (Day 10):
   - Merge to main branch
   - Deploy to production (App Store + Play Store)
   - Keep free mode disabled initially
   - Monitor error rates for 24 hours

3. **First Promotion** (Day 14):
   - Enable free mode during off-peak hours
   - Monitor telemetry for 1 hour
   - If stable, keep enabled for 7 days
   - Track conversion metrics daily

---

## Resources

- **Full Checklist**: `checklist/phase6-feature-flag-system.md` (93 items, detailed Red-Green-Refactor cycles)
- **Operations Guide**: `FEATURE_FLAG_GUIDE.md` (toggle commands, troubleshooting, use cases)
- **Architecture**: See `FEATURE_FLAG_GUIDE.md` → Technical Architecture section
- **TDD Principles**: `CLAUDE.md` → Section 4: Development Workflow

---

**Quick Reference Version**: 1.0
**Last Updated**: February 23, 2026
**Status**: Ready to begin Cycle 1.1 (app_config table)
