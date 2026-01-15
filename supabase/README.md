# Supabase Setup Guide

## 1. Create Supabase Project

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Click "New Project"
3. Enter project details:
   - Name: `one-message` (or your preferred name)
   - Database Password: Generate a strong password
   - Region: Choose closest to your users
4. Wait for project to be created

## 2. Get API Credentials

1. Go to Project Settings > API
2. Copy the following values to your `.env` file:
   - **Project URL** → `SUPABASE_URL`
   - **anon public** key → `SUPABASE_ANON_KEY`

## 3. Run Database Migrations

### Option A: Using Supabase Dashboard (Recommended for beginners)

1. Go to SQL Editor in your Supabase dashboard
2. Copy the contents of `migrations/001_create_user_profiles.sql`
3. Paste and run the SQL

### Option B: Using Supabase CLI

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link your project
supabase link --project-ref your-project-ref

# Run migrations
supabase db push
```

## 4. Configure Authentication

### Enable OAuth Providers

1. Go to Authentication > Providers
2. Enable and configure:
   - **Google**: Add Client ID and Secret from Google Cloud Console
   - **Apple**: Add Service ID and other credentials from Apple Developer

### Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add authorized redirect URI: `https://your-project.supabase.co/auth/v1/callback`

### Apple Sign-In Setup

1. Go to [Apple Developer](https://developer.apple.com/)
2. Create App ID with Sign In with Apple capability
3. Create Service ID
4. Configure domains and redirect URLs

## 5. Verify Setup

After running migrations, verify in Supabase Dashboard:

- [x] `user_profiles` table exists in Table Editor
- [x] RLS is enabled (lock icon on table)
- [x] Policies are created (check Policies tab)
- [x] Trigger is created (check Database > Triggers)

## Database Schema

### user_profiles

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key, references auth.users |
| tier | TEXT | 'guest', 'member', or 'premium' |
| created_at | TIMESTAMPTZ | Account creation time |
| updated_at | TIMESTAMPTZ | Last update time |

### RLS Policies

| Policy | Action | Rule |
|--------|--------|------|
| Users can view own profile | SELECT | auth.uid() = id |
| Users can update own profile | UPDATE | auth.uid() = id |
| Users can insert own profile | INSERT | auth.uid() = id |
