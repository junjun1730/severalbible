# 🚀 Quick Setup: Test Accounts for Development

Since Docker is not currently running, follow these steps to create test accounts in your Supabase project:

## Step 1: Open Supabase Dashboard SQL Editor

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your **One Message** project
3. Click **SQL Editor** in the left sidebar
4. Click **New Query**

## Step 2: Run the SQL Script

1. Open the file: `/Users/js/Desktop/severalbible/supabase/snippets/create_test_accounts.sql`
2. Copy **ALL** the contents
3. Paste into the Supabase SQL Editor
4. Click **Run** (or press `Cmd+Enter`)

## Step 3: Verify Accounts Created

You should see output showing 3 test accounts were created. To verify, run this query:

```sql
SELECT
  u.email,
  p.tier,
  s.subscription_status,
  s.expires_at
FROM auth.users u
JOIN user_profiles p ON u.id = p.id
LEFT JOIN user_subscriptions s ON u.id = s.user_id
WHERE u.email LIKE '%test@onemessage.app'
ORDER BY u.email;
```

Expected result: **3 rows** showing premium accounts.

## Step 4: Test Login in the App

1. Run the Flutter app in debug mode:
   ```bash
   flutter run
   ```

2. On the login screen, look for the **orange "DEBUG: Email Login"** section

3. Expand it and enter:
   - Email: `premium.test@onemessage.app`
   - Password: `Premium123!`

4. Tap **Sign In with Email**

5. Verify you can access premium features:
   - ✅ See 3 daily scripture cards
   - ✅ "See 3 More" button appears after scrolling
   - ✅ Can write prayer notes
   - ✅ Can view all prayer note history (no 3-day limit)

## 📋 Available Test Accounts

| Email | Password | Purpose |
|-------|----------|---------|
| `premium.test@onemessage.app` | `Premium123!` | General premium testing |
| `prayer.test@onemessage.app` | `Prayer123!` | Prayer note feature testing |
| `scripture.test@onemessage.app` | `Scripture123!` | Scripture delivery testing |

## 🔄 Alternative: Use CLI Script (Requires Docker)

If you want to use the automated script:

1. Start Docker Desktop
2. Wait for it to fully start
3. Run:
   ```bash
   ./scripts/create-test-accounts.sh
   ```

## 📚 Full Documentation

See `/Users/js/Desktop/severalbible/supabase/snippets/README.md` for complete documentation.

---

**Quick Reference**:
- SQL Script: `supabase/snippets/create_test_accounts.sql`
- CLI Script: `scripts/create-test-accounts.sh`
- Documentation: `supabase/snippets/README.md`
