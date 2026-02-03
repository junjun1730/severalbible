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
- [x] **[Test]** Write pgTAP tests for all RPC functions (15 tests)

**Migration Files Created**:
- `002_create_scriptures.sql`
- `003_create_user_scripture_history.sql`
- `004_create_scripture_rpc_functions.sql`
- `005_insert_scripture_dummy_data.sql`

**Test Files Created**:
- `supabase/tests/scripture_rpc_test.sql` (15 pgTAP tests)

### 2-2. Scripture Feature (TDD) ✅
- [x] **[Domain]** Define `Scripture` Entity (Apply `freezed`)
- [x] **[Domain]** Define `ScriptureRepository` Interface
- [x] **[Test]** Write `ScriptureRepository` Unit Tests (17 tests passing)
- [x] **[Data]** Implement `SupabaseScriptureRepository` with `SupabaseScriptureDataSource`
- [x] **[State]** Implement Providers (DailyScriptures, PremiumScriptures, ScriptureViewTracker)

**Implementation Files Created**:
- `lib/core/errors/failures.dart` - Failure types for error handling
- `lib/features/scripture/domain/entities/scripture.dart` - Scripture entity with freezed
- `lib/features/scripture/domain/repositories/scripture_repository.dart` - Repository interface
- `lib/features/scripture/data/datasources/scripture_datasource.dart` - DataSource interface
- `lib/features/scripture/data/datasources/supabase_scripture_datasource.dart` - Supabase implementation
- `lib/features/scripture/data/repositories/supabase_scripture_repository.dart` - Repository implementation
- `lib/features/scripture/presentation/providers/scripture_providers.dart` - Riverpod providers

### 2-3. UI Implementation ✅
- [x] **[UI]** Implement `ScriptureCard` Widget (Apply design system: fonts, background, etc.) - 9 tests passing
- [x] **[UI]** Implement `DailyFeedScreen` (Utilize PageView/ListView) - 6 tests passing
- [x] **[Logic]** Connect UI with logic for Guest (1/day) and Member (3/day) limits
- [x] **[UI]** Implement Blocker Widget (Induce login/payment when limit reached) - 9 tests passing
- [x] **[UI]** Implement PageIndicator Widget - 4 tests passing

### 2-4. UI/UX Improvements ✅
- [x] **[UI]** NavigationArrowButton widget (8 tests)
- [x] **[UI]** Arrow navigation in DailyFeedScreen (12 tests)
- [x] **[UI]** Remove AppBar title (3 tests)
- [x] **[UI]** MyLibrary navigation guard (3 tests)
- [x] **[UI]** Library icon in HomeScreen AppBar (3 tests)
- [x] **[UI]** MeditationButton widget (6 tests)
- [x] **[UI]** ScriptureCard footer refactor (4 tests)

**Implementation Files**:
- `lib/features/scripture/presentation/widgets/navigation_arrow_button.dart`
- `lib/features/scripture/presentation/widgets/meditation_button.dart` [NEW]
- `lib/features/scripture/presentation/screens/daily_feed_screen.dart`
- `lib/features/scripture/presentation/widgets/scripture_card.dart`
- `lib/features/auth/presentation/screens/home_screen.dart`
- `lib/features/prayer_note/presentation/utils/my_library_navigation.dart`

**Test Files** (39 tests total):
- `test/features/scripture/presentation/widgets/navigation_arrow_button_test.dart` (8 tests)
- `test/features/scripture/presentation/widgets/meditation_button_test.dart` (6 tests) [NEW]
- `test/features/scripture/presentation/screens/daily_feed_screen_test.dart` (12 tests)
- `test/features/scripture/presentation/widgets/scripture_card_test.dart` (13 tests)
- `test/features/auth/presentation/screens/home_screen_test.dart` (6 tests)
- `test/features/prayer_note/presentation/utils/my_library_navigation_test.dart` (3 tests)

**Coverage**: 85%+ overall

---

## Phase 3: Prayer Note System
**Goal**: Implement features for users to record and view meditations. Apply tier-based view restrictions.
**Detailed TDD Checklist**: See `checklist/phase3-prayer-note.md` (99 items, 85 tests, 6-8 days)

### 3-1. Database & RLS
- [x] **[DB]** Create `prayer_notes` table
- [x] **[DB]** Set RLS policies: Verify Member (last 3 days), Premium (all), Guest (forbidden) policies
- [x] **[DB]** Implement RPC functions (7 functions: CRUD + utilities)
- [x] **[Test]** Write pgTAP tests for RLS and RPC functions (20 tests)
- [x] **[Edge]** Create Auto-delete Edge Function (7-day limit for Member)

**Migration Files Created**:
- `006_create_prayer_notes.sql`
- `007_create_prayer_note_rpc_functions.sql`

**Test Files Created**:
- `supabase/tests/prayer_note_test.sql` (20 pgTAP tests)

**Edge Function Created**:
- `supabase/functions/cleanup-old-notes/index.ts`

### 3-2. Prayer Note Feature (TDD) ✅
- [x] **[Domain]** Define `PrayerNote` Entity (freezed)
- [x] **[Domain]** Define `PrayerNoteRepository` Interface (CRUD + isDateAccessible)
- [x] **[Test]** Write `PrayerNoteRepository` Tests (23 tests passing)
- [x] **[Data]** Implement `SupabasePrayerNoteRepository` with `SupabasePrayerNoteDataSource`
- [x] **[State]** Implement Providers (PrayerNoteList, FormController, DateAccessibility)

**Implementation Files Created**:
- `lib/features/prayer_note/domain/entities/prayer_note.dart` - PrayerNote entity with freezed
- `lib/features/prayer_note/domain/repositories/prayer_note_repository.dart` - Repository interface
- `lib/features/prayer_note/data/datasources/prayer_note_datasource.dart` - DataSource interface
- `lib/features/prayer_note/data/datasources/supabase_prayer_note_datasource.dart` - Supabase implementation
- `lib/features/prayer_note/data/repositories/supabase_prayer_note_repository.dart` - Repository implementation
- `lib/features/prayer_note/presentation/providers/prayer_note_providers.dart` - Riverpod providers

**Test Files Created**:
- `test/features/prayer_note/data/repositories/prayer_note_repository_test.dart` (23 tests)

### 3-3. UI Implementation ✅
- [x] **[UI]** Implement 'Leave Meditation' input form Widget at bottom of scripture card (PrayerNoteInput - 9 tests)
- [x] **[UI]** Implement `MyLibraryScreen` tab (6 tests passing)
- [x] **[UI]** Integrate `TableCalendar` and display meditations by date (PrayerCalendar - 5 tests)
- [x] **[UI]** Implement logic to display Lock icon for past records for Member tier (DateAccessibilityIndicator - 6 tests)
- [x] **[UI]** Implement `PrayerNoteCard` widget (10 tests)

**Implementation Files Created**:
- `lib/features/prayer_note/presentation/widgets/prayer_note_input.dart` - Meditation input widget
- `lib/features/prayer_note/presentation/widgets/prayer_note_card.dart` - Note card display widget
- `lib/features/prayer_note/presentation/widgets/prayer_calendar.dart` - Calendar with table_calendar
- `lib/features/prayer_note/presentation/widgets/date_accessibility_indicator.dart` - Lock/unlock indicator
- `lib/features/prayer_note/presentation/screens/my_library_screen.dart` - My Library screen

**Test Files Created**:
- `test/features/prayer_note/presentation/widgets/prayer_note_input_test.dart` (9 tests)
- `test/features/prayer_note/presentation/widgets/prayer_note_card_test.dart` (10 tests)
- `test/features/prayer_note/presentation/widgets/prayer_calendar_test.dart` (5 tests)
- `test/features/prayer_note/presentation/widgets/date_accessibility_indicator_test.dart` (6 tests)
- `test/features/prayer_note/presentation/screens/my_library_screen_test.dart` (6 tests)

---

## Phase 4: Monetization
**Goal**: Attach revenue model and induce conversion to Premium users.
**Detailed TDD Checklist**: See `checklist/phase4-monetization.md` (112 items, 143 tests, 8-10 days)

### 4-1. Database & Subscription Schema ✅
- [x] **[DB]** Create `subscription_products` table with pricing info
- [x] **[DB]** Create `user_subscriptions` table with status tracking
- [x] **[DB]** Implement RLS policies for subscription tables
- [x] **[DB]** Implement RPC functions (get_subscription_status, activate_subscription, cancel_subscription, get_available_products, has_active_premium)
- [x] **[Test]** Write pgTAP tests for RLS and RPC functions (25 tests)
- [x] **[Edge]** Create Edge Functions (verify-ios-receipt, verify-android-receipt, subscription-webhook, check-expired-subscriptions)

**Migration Files Created**:
- `008_create_user_subscriptions.sql`
- `009_create_subscription_rpc_functions.sql`

**Test Files Created**:
- `supabase/tests/subscription_test.sql` (25 pgTAP tests)

**Edge Functions Created**:
- `supabase/functions/verify-ios-receipt/index.ts`
- `supabase/functions/verify-android-receipt/index.ts`
- `supabase/functions/subscription-webhook/index.ts`
- `supabase/functions/check-expired-subscriptions/index.ts`

### 4-2. Subscription Feature (TDD) ✅
- [x] **[Domain]** Define `Subscription` and `SubscriptionProduct` Entities (freezed)
- [x] **[Domain]** Define `SubscriptionRepository` Interface
- [x] **[Domain]** Define `IAPService` Interface
- [x] **[Test]** Write `SubscriptionRepository` Unit Tests (32 tests passing)
- [x] **[Test]** Write `IAPService` Unit Tests (7 tests passing)
- [x] **[Data]** Implement `SupabaseSubscriptionRepository` with `SupabaseSubscriptionDataSource`
- [x] **[Data]** Implement `IAPService` for iOS/Android using `in_app_purchase`
- [x] **[State]** Implement Providers (16 tests passing: SubscriptionStatus, AvailableProducts, PurchaseController, RestorePurchaseController, HasPremium)

**Implementation Files Created**:
- `lib/features/subscription/domain/entities/subscription.dart` - Subscription, SubscriptionProduct, PurchaseResult entities with freezed
- `lib/features/subscription/domain/repositories/subscription_repository.dart` - Repository interface
- `lib/features/subscription/domain/services/iap_service.dart` - IAP service interface
- `lib/features/subscription/data/datasources/subscription_datasource.dart` - DataSource interface
- `lib/features/subscription/data/datasources/supabase_subscription_datasource.dart` - Supabase implementation
- `lib/features/subscription/data/repositories/supabase_subscription_repository.dart` - Repository implementation
- `lib/features/subscription/data/services/iap_service_impl.dart` - IAP service implementation
- `lib/features/subscription/presentation/providers/subscription_providers.dart` - All Riverpod providers

**Test Files Created**:
- `test/features/subscription/data/repositories/subscription_repository_test.dart` (32 tests)
- `test/features/subscription/data/services/iap_service_test.dart` (7 tests)
- `test/features/subscription/presentation/providers/subscription_providers_test.dart` (16 tests)

### 4-3. UI Implementation ✅
- [x] **[UI]** Implement `PremiumLandingScreen` (Subscription guide page) - 2 tests passing
- [x] **[UI]** Implement `SubscriptionProductCard` widget
- [x] **[UI]** Implement `PurchaseButton` widget
- [x] **[UI]** Implement `UpsellDialog` widget - 1 test passing
- [x] **[UI]** Implement `ManageSubscriptionScreen` - 1 test passing
- [x] **[UI]** Integrate upselling into Scripture Feed and Prayer Archive
- [x] **[UI]** Add Settings screen with subscription management - 7 tests passing
- [ ] **[Test]** Write integration tests for purchase flows (iOS/Android)

**Implementation Files Created**:
- `lib/features/subscription/presentation/screens/premium_landing_screen.dart`
- `lib/features/subscription/presentation/screens/manage_subscription_screen.dart`
- `lib/features/subscription/presentation/widgets/subscription_product_card.dart`
- `lib/features/subscription/presentation/widgets/purchase_button.dart`
- `lib/features/subscription/presentation/widgets/upsell_dialog.dart`
- `lib/features/settings/presentation/screens/settings_screen.dart`

**Test Files Created**:
- `test/features/subscription/presentation/screens/premium_landing_screen_test.dart` (2 tests)
- `test/features/subscription/presentation/screens/manage_subscription_screen_test.dart`
- `test/features/subscription/presentation/widgets/upsell_dialog_test.dart`
- `test/features/settings/presentation/screens/settings_screen_test.dart` (7 tests)

---

## Phase 4.5: UI Upgrade (Material 3 Redesign)
**Goal**: Modernize UI with purple branding, Material 3, and custom animations.
**Detailed TDD Checklist**: See `checklist/ui-upgrade/ui-upgrade-checklist.md` (158 tests, 8-10 days)

### 4.5-1. Theme System Foundation ✅ (6/6 complete)
- [x] **[Theme]** Create AppTheme with purple seed color (#7C6FE8) and Material 3 (8 tests passing)
- [x] **[Theme]** Create AppColors design tokens (5 tests passing)
- [x] **[Theme]** Create AppTypography type scale (system fonts only) (5 tests passing)
- [x] **[Theme]** Create AppSpacing and AppDimensions (4 tests passing)
- [x] **[Theme]** Integrate theme into main.dart (3 tests passing)
- [x] **[Theme]** Create theme utility extensions (3 tests passing)

### 4.5-2. Core UI Components ✅
- [ ] **[Widget]** Redesign ScriptureCard to match ui-sample (clean, centered, purple badge)
- [x] **[Widget]** Create unified AppButton system (56dp height, 16px radius) - 7 tests passing
- [x] **[Widget]** Create EmptyState component (minimal design from ui-sample) - 7 tests passing
- [x] **[Widget]** Update MyLibrary empty state - 9 tests passing (3 new + 6 updated)
- [x] **[Widget]** Create AppBottomSheet modal infrastructure - 5 tests passing
- [x] **[Widget]** Convert SettingsScreen to modal presentation - 17 tests passing (4 new + 13 updated)
- [x] **[Widget]** Redesign PrayerNoteInput as modal - 37 total prayer_note widget tests passing (7 new modal tests)

### 4.5-3. Screen-Level Updates ✅
- [x] **[UI]** Redesign PageIndicator (purple dots from ui-sample) - 9 tests passing
- [x] **[UI]** Update DailyFeedScreen layout (page indicator below cards) - 19 tests passing
- [x] **[UI]** Update LoginScreen with new button styles - 3 tests passing
- [x] **[UI]** Update SplashScreen with purple branding - 3 tests passing (already using theme correctly)
- [x] **[UI]** Update OnboardingPopup with new button styles - 3 tests passing
- [x] **[UI]** Update PremiumLandingScreen with purple branding - 3 tests passing
- [x] **[UI]** Update UpsellDialog with new button styles - 3 tests passing

**Phase 3 Complete! 🎉** (71.5% overall progress, 123 tests passing)

### 4.5-4. Animations & Polish ✅ (PHASE COMPLETE!)
- [x] **[Anim]** Create AppAnimations utility (fade, scale, slide) - 5 tests passing
- [x] **[Anim]** Add ScriptureCard entrance animation (fade + scale) - 6 tests passing (Cycle 4.2 complete!)
- [x] **[Anim]** Add MeditationButton tap animation (scale) - 7 tests passing (Cycle 4.3 complete!)
- [x] **[Anim]** Add modal slide-up animation - 8 tests passing (Cycle 4.4 complete!)
- [x] **[Anim]** Add PageIndicator dot transition animation - 12 tests passing (Cycle 4.5 complete!)
- [x] **[Anim]** Add EmptyState fade-in animation - 10 tests passing (Cycle 4.6 complete! 3 new animation tests)
- [x] **[Polish]** Add button hover/press states - 13 tests passing (Cycle 4.7 complete! 6 new state tests)

**Test Coverage**:
- Theme System: 38 tests (95%+ coverage goal)
- Core UI Components: 58 tests (90%+ coverage goal) - 6 new AppButton state tests
- Screen-Level Updates: 38 tests (90%+ coverage goal)
- Animations & Polish: 33 tests (95%+ coverage goal)
- **Total**: 167 tests

**Phase 4.5 Status**: ✅ **COMPLETE!** All animations and polish features implemented.

**Key Changes**:
- Primary brand color: Purple #7C6FE8
- System fonts (no google_fonts)
- Material 3 design system
- Modal presentations (bottom sheets)
- Custom animations (fade, scale, slide)
- Dark mode deferred to post-MVP

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
- [x] **[Policy]** Link Privacy Policy and Terms of Service (Legal section added to Settings, 13 tests passing)
- [x] **[Hosting]** Host legal documents on GitHub Pages (https://junjun1730.github.io/severalbible/)
- [ ] **[Test]** Distribute to TestFlight / Google Play Internal Test and QA
