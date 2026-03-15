# Feature Flag System Guide

## Overview

The Feature Flag System enables server-side toggling between **Free Mode** and **Paid Mode** without requiring app updates. This allows instant promotional campaigns, A/B testing, and flexible monetization strategies.

---

## Modes Comparison

| Feature | Paid Mode (Original) | Free Mode (Promotional) |
|---------|---------------------|------------------------|
| **Guest Users** | 1 card/day, no prayers | 1 card/day, no prayers (unchanged) |
| **Member Users** | 3 cards/day, today's prayers | 3 cards/day, ALL prayers (premium features) |
| **Premium Users** | 3 cards/day, all prayers | 3 cards/day, all prayers (unchanged) |

**Key Insight**: Free mode upgrades Members to Premium features temporarily, while keeping Guests and Premium users unchanged.

---

## How to Toggle Modes

### Enable Free Mode (Promotional Period)

```sql
-- Execute in Supabase SQL Editor
UPDATE app_config
SET value = '{"enabled": true}', updated_at = now()
WHERE key = 'is_free_mode';

-- Verify change
SELECT key, value, updated_at FROM app_config WHERE key = 'is_free_mode';
-- Expected: {"enabled": true}
```

**Effect**:
- Takes effect within 5 minutes (client-side cache expiry)
- All Member users gain Premium features immediately after cache refresh
- No app restart required
- Zero downtime

---

### Disable Free Mode (Return to Normal)

```sql
-- Execute in Supabase SQL Editor
UPDATE app_config
SET value = '{"enabled": false}', updated_at = now()
WHERE key = 'is_free_mode';

-- Verify change
SELECT key, value, updated_at FROM app_config WHERE key = 'is_free_mode';
-- Expected: {"enabled": false}
```

**Effect**:
- Takes effect within 5 minutes
- Member users revert to standard Member tier restrictions
- Premium subscribers unaffected
- No app restart required

---

## Verification Checklist

After toggling mode, verify the change took effect:

### 1. Database Verification (Immediate)
```sql
-- Check current mode
SELECT key, value, updated_at FROM app_config WHERE key = 'is_free_mode';

-- Test get_user_tier RPC with a member user
SELECT get_user_tier('<member-user-id-here>');
-- Free Mode: Returns 'premium'
-- Paid Mode: Returns 'member'
```

### 2. Client Verification (5-10 minutes)
- [ ] Open app as Member user (or use TestFlight)
- [ ] Force close and reopen app (clears cache immediately)
- [ ] Navigate to My Library
- [ ] **Free Mode**: All past dates unlocked, no lock icons
- [ ] **Paid Mode**: Only today's prayers accessible, lock icons on old dates
- [ ] Verify no errors in console

### 3. Monitoring (1-24 hours)
- [ ] Check Supabase logs for `get_app_config` RPC calls
- [ ] Monitor error rates in Sentry/Crashlytics
- [ ] Track user behavior analytics (prayer writes, library views)
- [ ] Verify conversion metrics (Member → Premium upgrades)

---

## Troubleshooting

### Issue: Mode change not taking effect after 10 minutes

**Possible Causes**:
1. Client cache not expiring (rare Riverpod issue)
2. User hasn't restarted app
3. Database update failed

**Solutions**:
```sql
-- 1. Verify database value
SELECT * FROM app_config WHERE key = 'is_free_mode';

-- 2. Check RPC function reads config correctly
SELECT get_user_tier('<test-member-user-id>');

-- 3. Force cache invalidation (optional, for emergency)
-- Increment a version number to force client refresh
UPDATE app_config
SET value = jsonb_set(value, '{version}', to_jsonb(now()::text))
WHERE key = 'is_free_mode';
```

**Client-side Debug**:
- Ask users to force quit app and reopen
- Check if `isFreeModeProvider` returns correct value in logs
- Verify `effectiveUserTierProvider` applies transformation

---

### Issue: Guest users seeing premium features (BUG!)

**This should NEVER happen.** If it does:

**Immediate Action**:
```sql
-- Disable free mode immediately
UPDATE app_config SET value = '{"enabled": false}' WHERE key = 'is_free_mode';
```

**Investigation**:
```dart
// Check effectiveUserTierProvider logic
// Guest should ALWAYS return UserTier.guest
final effectiveUserTierProvider = FutureProvider<UserTier>((ref) async {
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    return UserTier.guest; // ← This path should be taken for guests
  }
  // ...
});
```

**Root Cause**: Likely a bug in `effectiveUserTierProvider` transformation logic.

**Fix**: Review Phase 3 implementation in `lib/features/auth/providers/auth_providers.dart`.

---

### Issue: Premium users losing features (BUG!)

**This should NEVER happen.** Premium users must be unaffected by free mode.

**Immediate Action**:
```sql
-- Disable free mode immediately
UPDATE app_config SET value = '{"enabled": false}' WHERE key = 'is_free_mode';
```

**Investigation**:
```dart
// Check effectiveUserTierProvider logic
// Premium should ALWAYS return UserTier.premium
if (isFreeMode && baseTier == UserTier.member) {
  return UserTier.premium; // Only transform member
}
return baseTier; // ← Premium should hit this path unchanged
```

**Root Cause**: Likely incorrect subscription status check or tier resolution.

**Fix**: Verify `get_user_tier` RPC returns 'premium' for premium users in both modes.

---

## Emergency Rollback Procedure

If serious issues arise (crashes, data loss, widespread bugs):

### Step 1: Immediate Database Revert (30 seconds)
```sql
-- Disable free mode
UPDATE app_config SET value = '{"enabled": false}' WHERE key = 'is_free_mode';
```

### Step 2: Monitor Recovery (5-10 minutes)
- Check error rates drop
- Verify users revert to paid mode behavior
- Monitor support tickets/app store reviews

### Step 3: Code Rollback (if database revert insufficient)
```bash
# On server/CI
git revert <feature-flag-commit-hash>
git push origin main

# Trigger production deployment
# Users get reverted code on next app update
```

### Step 4: Incident Report
- Document what went wrong
- Root cause analysis
- Update tests to prevent recurrence
- Schedule post-mortem meeting

---

## Best Practices

### Before Enabling Free Mode
1. ✅ Test in staging environment first
2. ✅ Run full integration test suite
3. ✅ Verify rollback procedure works
4. ✅ Schedule off-peak hours (low user activity)
5. ✅ Have team members on standby for monitoring
6. ✅ Set up alerting for error rate spikes

### During Free Mode
1. 📊 Monitor conversion metrics daily
2. 📊 Track Member engagement (prayer writes, library views)
3. 📊 Compare Member retention vs baseline
4. 📧 Send in-app messaging explaining free mode benefits
5. 📧 Encourage upgrades to Premium before mode ends

### After Disabling Free Mode
1. 📈 Analyze conversion lift (Member → Premium)
2. 📈 Calculate revenue impact
3. 📈 User feedback survey (why did/didn't you upgrade?)
4. 📈 Document learnings for next promotional campaign

---

## Technical Architecture

### Provider Dependency Chain
```
SupabaseClient
    ↓
SupabaseAppConfigDataSource
    ↓
AppConfigRepository
    ↓
appConfigProvider (5min cache)
    ↓
isFreeModeProvider (bool)
    ↓
effectiveUserTierProvider
    ↓
All UI Components (11 locations)
```

### Cache Behavior
- **Cache Duration**: 5 minutes
- **Cache Key**: App-wide singleton (shared across user sessions)
- **Invalidation**: Automatic after 5 minutes
- **Manual Refresh**: Force quit app or call `ref.invalidate(appConfigProvider)`

### RPC Function Logic
```sql
-- get_user_tier RPC (simplified)
CREATE OR REPLACE FUNCTION get_user_tier(user_id_param UUID)
RETURNS TEXT AS $$
DECLARE
  base_tier TEXT;
  is_free_mode BOOLEAN;
BEGIN
  -- Get base tier from user_profiles
  SELECT tier INTO base_tier FROM user_profiles WHERE id = user_id_param;

  -- Get free mode flag
  SELECT (value->>'enabled')::BOOLEAN INTO is_free_mode
  FROM app_config WHERE key = 'is_free_mode';

  -- Apply transformation
  IF is_free_mode AND base_tier = 'member' THEN
    RETURN 'premium';
  ELSE
    RETURN base_tier;
  END IF;
END;
$$ LANGUAGE plpgsql;
```

---

## Use Cases

### Use Case 1: Holiday Promotion (1 week)
**Scenario**: Christmas week, give all members premium access to boost engagement.

**Steps**:
1. December 18: Enable free mode
2. December 18-25: Monitor engagement, send upgrade prompts
3. December 25: Disable free mode
4. Analyze conversion rate vs normal week

**Expected Outcome**: 10-20% of members upgrade to premium after experiencing full features.

---

### Use Case 2: A/B Testing (30 days)
**Scenario**: Test if giving members premium access increases long-term retention.

**Steps**:
1. Split users into control (paid mode) and test (free mode)
2. Track 30-day retention for both groups
3. Measure conversion rates
4. Make data-driven decision on permanent free tier

**Implementation Note**: Requires user-level feature flags (not app-level). Consider adding `user_id` column to `app_config` or using a dedicated A/B testing tool.

---

### Use Case 3: Post-Launch Growth Hack (3 months)
**Scenario**: After app launch, boost reviews by giving early adopters premium features.

**Steps**:
1. Week 1-4: Free mode ON (all members = premium)
2. Week 5-8: Free mode OFF, show "upgrade to keep features" prompt
3. Week 9-12: Gradual price increase ($4.99 → $9.99)
4. Measure conversion at each stage

**Expected Outcome**: High initial engagement, conversion boost with urgency messaging.

---

## Security Considerations

### RLS Policies
```sql
-- app_config table
CREATE POLICY "app_config_public_read" ON app_config
  FOR SELECT USING (true); -- Anyone can read

-- Only service role can write (bypasses RLS)
-- This prevents malicious users from toggling free mode
```

**Why Public Read?**:
- App needs to fetch config without authentication (for Guest users)
- No sensitive data in app_config (just boolean flags)
- Writes restricted to service role (Dashboard/API only)

**Alternative (More Secure)**:
- Expose `get_app_config` RPC instead of direct table access
- Add rate limiting to RPC (prevent DDoS)
- Cache in Supabase Edge Functions for better performance

---

## Monitoring & Telemetry

### Key Metrics to Track

**Technical**:
- `app_config_fetch_count`: How often clients fetch config
- `app_config_fetch_latency`: RPC response time
- `cache_hit_rate`: % of requests served from cache
- `effective_tier_transformations`: Count of member→premium transformations

**Business**:
- `free_mode_active_users`: Daily active users in free mode
- `premium_feature_usage`: Prayer writes, library views by members
- `conversion_rate`: Member → Premium upgrades during/after free mode
- `churn_rate`: Members who downgrade/delete after free mode ends

### Example Telemetry Code
```dart
// In effectiveUserTierProvider
if (isFreeMode && baseTier == UserTier.member) {
  // Log transformation
  analytics.logEvent('tier_transformed', {
    'from': 'member',
    'to': 'premium',
    'reason': 'free_mode',
  });
  return UserTier.premium;
}
```

---

## Future Enhancements

### Phase 6.5: User-Level Feature Flags
- Per-user free mode (A/B testing)
- Gradual rollout (10% → 50% → 100%)
- User segmentation (new users vs returning)

### Phase 6.5: Time-Based Expiry
- Auto-disable free mode after N days
- Scheduled promotions (start/end dates in database)
- Countdown timer in UI ("Premium access expires in 3 days")

### Phase 6.5: Advanced Config
- Multiple config flags (dark_mode, experimental_features)
- Config versioning (rollback to previous config)
- Config analytics (which flags are most used)

---

## FAQ

### Q: How long does it take for mode change to take effect?
**A**: Maximum 5 minutes due to client-side cache. Users who force quit and reopen the app will see changes immediately.

### Q: Can I toggle mode multiple times per day?
**A**: Technically yes, but not recommended. Frequent toggling may confuse users and cause cache thrashing. Best practice: toggle at most once per 24 hours.

### Q: What happens if Supabase is down when app tries to fetch config?
**A**: App defaults to Paid Mode (safe fallback). Error is logged, user experience is unaffected (though members won't get premium features).

### Q: Can I schedule automatic mode toggles?
**A**: Not built-in. You can use:
- Supabase Cron Jobs (Edge Functions)
- External scheduler (Zapier, n8n) calling Supabase API
- Custom admin dashboard with scheduling

### Q: Will this work offline?
**A**: Config is cached for 5 minutes, so users retain the last fetched mode while offline. When they reconnect, the cache refreshes.

### Q: How do I test free mode in development?
**A**:
1. Use local Supabase: `UPDATE app_config SET value = '{"enabled": true}'`
2. Or mock `isFreeModeProvider` in tests: `when(ref.watch(isFreeModeProvider)).thenReturn(true)`

---

## Support & Documentation

- **Implementation Details**: See `checklist/phase6-feature-flag-system.md`
- **Code Location**: `lib/core/config/` and `lib/features/auth/providers/auth_providers.dart`
- **Tests**: `test/core/config/` and `integration_test/feature_flag_*.dart`
- **Supabase Migrations**: `supabase/migrations/011_create_app_config.sql`, `012_update_get_user_tier_rpc.sql`

---

**Document Version**: 1.0
**Last Updated**: February 23, 2026
**Status**: Implementation guide (Phase 6 not yet implemented)
