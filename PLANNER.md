# Detailed Development Plan

## Phase 1: Environment & Auth
**Goal**: Establish the project foundation and integrate Supabase Auth to start managing user tiers.

### 1-1. Project Initialization
- [x] **[Setup]** Create Flutter project and set up folder structure (Clean Architecture: layer/domain, layer/data, layer/presentation)
- [x] **[Setup]** Add essential packages (`flutter_riverpod`, `supabase_flutter`, `go_router`, `freezed`, etc.) and configure `analysis_options.yaml`
- [x] **[Setup]** Basic CI/CD and Github Actions setup (Build test)

### 1-2. Supabase Environment Configuration
- [x] **[DB]** Create Supabase project
- [x] **[DB]** Create `user_profiles` table (id, tier, created_at, etc.)
- [x] **[DB]** Set RLS policies: `user_profiles` (View/Edit own profile)
- [x] **[DB]** Set Trigger function: Auto-create `user_profiles` on sign-up (Tier: 'guest' or 'member')

### 1-3. Auth Feature (TDD)
- [x] **[Domain]** Define `UserTier` Enum and `UserProfile` Entity (freezed)
- [x] **[Core]** Create `SupabaseService` abstraction for testability
- [x] **[Test]** Write `AuthRepository` Unit Tests (11 tests: Sign-in, Sign-out, Sign-up, Current User, Auth State)
- [x] **[Data]** Implement `AuthRepository` with Either type for error handling
- [x] **[Test]** Write `UserProfileRepository` Unit Tests (13 tests: CRUD operations, tier management)
- [x] **[Data]** Implement `UserProfileRepository` with `UserProfileDataSource` abstraction
- [x] **[State]** Implement Riverpod Providers (auth, userProfile, tier providers)

### 1-4. UI Implementation
- [x] **[UI]** Implement Splash Screen (Auto-login check and routing)
- [x] **[UI]** Implement Login/Sign-up Screen (Include Social Login buttons)
- [x] **[UI]** Implement Onboarding Funnel (Popup to induce Guest → Member conversion)

---

## Phase 2: Scripture Delivery System
**Goal**: Provide scripture cards, the core content, according to tier-based logic.
**Detailed TDD Checklist**: See `checklist/phase2-scripture-delivery.md` (92 items, 84 tests, 8-10 days)

### 2-1. Database & RPC ✅
- [x] **[DB]** Create `scriptures` table and insert dummy data (23 items: 15 regular + 8 premium)
- [x] **[DB]** Create `user_scripture_history` table with RLS policies
- [x] **[DB]** Implement RPC function: `get_random_scripture` (For Guest)
- [x] **[DB]** Implement RPC function: `get_daily_scriptures` (For Member - No Duplicate)
- [x] **[DB]** Implement RPC function: `get_premium_scriptures` (For Premium)
- [x] **[DB]** Implement RPC function: `record_scripture_view` (History tracking)

**Migration Files Created**:
- `002_create_scriptures.sql`
- `003_create_user_scripture_history.sql`
- `004_create_scripture_rpc_functions.sql`
- `005_insert_scripture_dummy_data.sql`

### 2-2. Scripture Feature (TDD)
- [ ] **[Domain]** Define `Scripture` Entity (Apply `freezed`)
- [ ] **[Domain]** Define `ScriptureRepository` Interface
- [ ] **[Test]** Write `ScriptureRepository` Unit Tests (Verify each RPC call and mapping)
- [ ] **[Data]** Implement `SupabaseScriptureRepository`
- [ ] **[State]** Implement `DailyScriptureProvider` (Manage daily scripture caching and loading state)

### 2-3. UI Implementation
- [ ] **[UI]** Implement `ScriptureCard` Widget (Apply design system: fonts, background, etc.)
- [ ] **[UI]** Implement `DailyFeedScreen` (Utilize PageView/ListView)
- [ ] **[Logic]** Connect UI with logic for Guest (1/day) and Member (3/day) limits
- [ ] **[UI]** Implement Blocker Widget (Induce login/payment when limit reached)

---

## Phase 3: Prayer Note System
**Goal**: Implement features for users to record and view meditations. Apply tier-based view restrictions.

### 3-1. Database & RLS
- [ ] **[DB]** Create `prayer_notes` table
- [ ] **[DB]** Set RLS policies: Verify Member (last 3 days), Premium (all), Guest (forbidden) policies
- [ ] **[Edge]** Deploy Auto-delete Edge Function (7-day limit for Member)

### 3-2. Prayer Note Feature (TDD)
- [ ] **[Domain]** Define `PrayerNote` Entity
- [ ] **[Domain]** Define `PrayerNoteRepository` Interface (CRUD)
- [ ] **[Test]** Write `PrayerNoteRepository` Tests (Create, Read, Update, Delete)
- [ ] **[Data]** Implement `SupabasePrayerNoteRepository`
- [ ] **[State]** Implement `PrayerNoteListProvider` and `PrayerNoteFormController`

### 3-3. UI Implementation
- [ ] **[UI]** Implement 'Leave Meditation' input form Widget at bottom of scripture card
- [ ] **[UI]** Implement `MyLibraryScreen` tab
- [ ] **[UI]** Integrate `TableCalendar` and display meditations by date
- [ ] **[Logic]** Implement logic to display Lock icon for past records for Member tier

---

## Phase 4: Monetization
**Goal**: Attach revenue model and induce conversion to Premium users.

### 4-1. In-App Purchase Setup
- [ ] **[Setup]** Register app and create products (subscriptions) in App Store Connect / Google Play Console
- [ ] **[Pkg]** Configure `in_app_purchase` package

### 4-2. Payment Feature (TDD)
- [ ] **[Domain]** Define `SubscriptionRepository` Interface
- [ ] **[Data]** Implement IAP verification and processing logic
- [ ] **[DB]** Logic to update `tier` in `user_profiles` upon payment success (or Webhook)

### 4-3. UI Implementation
- [ ] **[UI]** Implement `PremiumLandingScreen` (Subscription guide page)
- [ ] **[UI]** Connect Upselling popup when clicking "See More Words" or "View Past Records"
- [ ] **[UI]** Implement 'Manage Subscription' menu in Settings page

---

## Phase 5: Optimization & Launch
**Goal**: Improve app completeness and release to stores.

### 5-1. Optimization
- [ ] **[Perf]** Verify image caching (`cached_network_image`) application
- [ ] **[Perf]** Check ListView Lazy Loading
- [ ] **[Local]** Offline support (Cache recently viewed scriptures using Hive, etc. - Optional)

### 5-2. Preparation for Release
- [ ] **[Asset]** Create App Icon (Launcher Icon) and Splash Screen
- [ ] **[Store]** Capture screenshots and write store descriptions
- [ ] **[Policy]** Link Privacy Policy and Terms of Service
- [ ] **[Test]** Distribute to TestFlight / Google Play Internal Test and QA
