# Test Accounts & Development Scripts

This directory contains SQL scripts and utilities for creating test accounts with premium subscriptions for development and testing purposes.

## 📋 Overview

The test account system provides:
- **3 pre-configured premium test accounts** with known credentials
- **Reusable SQL script** for creating additional test accounts
- **CLI wrapper script** for easy execution
- **Debug email login UI** in the Flutter app (debug mode only)

## 🔑 Pre-configured Test Accounts

| # | Email | Password | UUID | Purpose |
|---|-------|----------|------|---------|
| 1 | `premium.test@onemessage.app` | `Premium123!` | `aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa` | General premium testing |
| 2 | `prayer.test@onemessage.app` | `Prayer123!` | `bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb` | Prayer note feature testing |
| 3 | `scripture.test@onemessage.app` | `Scripture123!` | `cccccccc-cccc-cccc-cccc-cccccccccccc` | Scripture delivery testing |

### Account Features
All test accounts have:
- ✅ **Tier**: `premium`
- ✅ **Subscription**: `monthly_premium` (active)
- ✅ **Expires**: 30 days from creation
- ✅ **Email**: Auto-confirmed
- ✅ **Provider**: `email`

## 🚀 Quick Start

### Option 1: Using CLI Script (Recommended)

```bash
# From project root
./scripts/create-test-accounts.sh
```

**Prerequisites**:
- Supabase CLI installed
- Docker running (for local database)
- OR remote Supabase project configured

### Option 2: Supabase Dashboard (No Docker Required)

1. Open [Supabase Dashboard](https://supabase.com/dashboard)
2. Navigate to **SQL Editor**
3. Copy contents of `supabase/snippets/create_test_accounts.sql`
4. Click **Run** to execute

### Option 3: Direct SQL Execution

```bash
# Using psql
psql YOUR_DATABASE_URL -f supabase/snippets/create_test_accounts.sql

# Using Supabase CLI
cat supabase/snippets/create_test_accounts.sql | supabase db execute
```

## 📱 Using Test Accounts in the App

### Debug Email Login UI

The Flutter app includes a **debug-only email login form** visible only in debug mode (`kDebugMode`):

1. Run the app in debug mode:
   ```bash
   flutter run
   ```

2. On the login screen, look for the **orange "DEBUG: Email Login"** section

3. Expand the section and enter test credentials:
   - Email: `premium.test@onemessage.app`
   - Password: `Premium123!`

4. Tap **Sign In with Email**

### Verify Premium Features

After logging in, verify these premium features work:
- ✅ **3 daily scripture cards** displayed
- ✅ **"See 3 More" button** visible after scrolling
- ✅ **Prayer notes** can be written
- ✅ **Unlimited history access** in "My Library"
- ✅ No 3-day restriction on viewing old notes

## 🛠️ Creating Additional Test Accounts

### Using the SQL Function

You can create custom test accounts by calling the `create_test_premium_account()` function:

```sql
-- Create a custom test account
SELECT create_test_premium_account(
  p_email := 'custom.test@onemessage.app',
  p_password := 'CustomPass123!',
  p_user_id := 'dddddddd-dddd-dddd-dddd-dddddddddddd'::uuid
);
```

### Verification Query

Check if accounts were created successfully:

```sql
SELECT
  u.email,
  u.id as user_id,
  p.tier,
  s.subscription_status,
  s.product_id,
  s.expires_at
FROM auth.users u
JOIN user_profiles p ON u.id = p.id
LEFT JOIN user_subscriptions s ON u.id = s.user_id
WHERE u.email LIKE '%test@onemessage.app'
ORDER BY u.email;
```

## 🗑️ Cleanup

### Delete All Test Accounts

```sql
-- Delete all test accounts (cascade will remove related data)
DELETE FROM auth.users WHERE email LIKE '%test@onemessage.app';
```

### Delete Specific Account

```sql
-- Delete by email
DELETE FROM auth.users WHERE email = 'premium.test@onemessage.app';

-- Delete by UUID
DELETE FROM auth.users WHERE id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid;
```

## 🔒 Security Considerations

### Safe Practices ✅
- Test accounts use fake domain (`@onemessage.app`)
- Passwords documented in code (test-only, not sensitive)
- Transaction IDs prefixed with `test-` for tracking
- UUIDs use predictable pattern for consistency
- Debug UI only visible in `kDebugMode` (stripped from release builds)

### Warnings ⚠️
- **Never use these credentials in production database**
- **Delete test accounts before public launch**
- **SQL script only safe for test/development environments**
- **Don't commit actual production passwords to git**

## 📖 Script Details

### SQL Script Components

The `create_test_accounts.sql` script includes:

1. **`create_test_premium_account()` function**
   - Inserts user into `auth.users`
   - Hashes password with `crypt()`
   - Auto-confirms email
   - Creates user profile
   - Activates premium subscription

2. **Pre-configured account creation**
   - Creates 3 test accounts with known UUIDs
   - Sets up premium subscriptions

3. **Verification query**
   - Lists all test accounts with details

4. **Cleanup query** (commented out)
   - Safe deletion of test accounts

### CLI Script Features

The `create-test-accounts.sh` script:
- ✅ Checks for Supabase CLI installation
- ✅ Validates Docker is running
- ✅ Executes SQL script
- ✅ Displays formatted credentials
- ✅ Provides helpful error messages
- ✅ Colorized output for readability

## 🔧 Troubleshooting

### Docker Not Running

**Error**: `Cannot connect to the Docker daemon`

**Solution**:
1. Start Docker Desktop
2. Wait for Docker to fully start
3. Run the script again
4. OR use Option 2 (Supabase Dashboard)

### Supabase CLI Not Installed

**Error**: `command not found: supabase`

**Solution**:
```bash
# Install Supabase CLI
npm install -g supabase

# Or using Homebrew (macOS)
brew install supabase/tap/supabase
```

### Accounts Already Exist

The script is **idempotent** - safe to run multiple times. It uses `ON CONFLICT DO UPDATE` to:
- Update existing accounts with new passwords
- Reset subscription to active
- Extend expiration by 30 days

### Release Build Shows Debug UI

**Issue**: Debug email login visible in production

**Check**:
1. Verify build mode: `flutter build apk --release`
2. Confirm `kDebugMode` is `false` in release
3. The debug UI should be automatically stripped

If still visible, manually remove the code block wrapped in `if (kDebugMode) ...`

## 📚 Related Documentation

- [Supabase Authentication Docs](https://supabase.com/docs/guides/auth)
- [Flutter Supabase Integration](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [One Message Project: CLAUDE.md](../../CLAUDE.md)
- [TDD Workflow Guide](../../PLANNER.md)

## 🤝 Contributing

When adding new test accounts or modifying the script:

1. **Update this README** with new credentials
2. **Use consistent UUID patterns** (e.g., `eeee...eeee`)
3. **Follow naming convention**: `purpose.test@onemessage.app`
4. **Document the purpose** of each account
5. **Test the script** before committing

## 📝 Changelog

### v1.0.0 (2026-01-26)
- Initial creation of test account system
- 3 pre-configured premium accounts
- CLI wrapper script with colorized output
- Debug email login UI in Flutter app
- Comprehensive documentation

---

**Last Updated**: 2026-01-26
**Maintainer**: Development Team
**Status**: Active Development
