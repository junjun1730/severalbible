# One Message - Technical Specification

**Project Name**: One Message (severalbible)
**Version**: 1.0.0
**Last Updated**: 2026-01-21
**Development Status**: Phase 4 (Monetization - 70% Complete)

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [Architecture & Design Patterns](#architecture--design-patterns)
4. [User Tiers & Feature Matrix](#user-tiers--feature-matrix)
5. [Development Progress](#development-progress)
6. [Database Schema](#database-schema)
7. [Domain Entities](#domain-entities)
8. [Repository Interfaces](#repository-interfaces)
9. [Implemented Features](#implemented-features)
10. [State Management](#state-management)
11. [Test Coverage](#test-coverage)
12. [File Structure](#file-structure)
13. [API Documentation](#api-documentation)

---

## Project Overview

### Mission Statement

One Message is a spiritual growth application designed to help users:
- **Read**: Daily scriptures and spiritual content
- **Write**: Personal meditations and prayer notes
- **Archive**: Build a spiritual asset library over time

### Core Values

1. **Simplicity**: Clean, focused spiritual content delivery
2. **Sustainability**: Freemium business model with premium subscriptions
3. **Quality**: TDD-driven development ensuring reliability

### Target Platform

- **iOS**: iPhone/iPad (iOS 13+)
- **Android**: Smartphones/Tablets (Android 6.0+)
- **Primary Market**: South Korea (Korean language)

---

## Technology Stack

### Frontend

| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.10.4+ | Cross-platform UI framework |
| Dart | 3.10.4+ | Programming language |
| Riverpod | 2.4.0 | State management |
| GoRouter | 13.0.0 | Navigation & routing |
| Freezed | 2.4.0 | Immutable data classes |
| Dartz | 0.10.1 | Functional programming (Either type) |

### Backend (Supabase)

| Technology | Purpose |
|------------|---------|
| Supabase Auth | User authentication (Email, Google, Apple) |
| PostgreSQL | Primary database |
| Row Level Security | Authorization & data isolation |
| RPC Functions | Server-side business logic |
| Edge Functions | Serverless TypeScript/Deno functions |
| Realtime | Live data subscriptions |

### Testing & Quality

| Technology | Purpose |
|------------|---------|
| flutter_test | Unit & widget testing |
| integration_test | E2E testing |
| mockito/mocktail | Mocking framework |
| pgTAP | PostgreSQL function testing |
| GitHub Actions | CI/CD pipeline |

### Additional Libraries

```yaml
dependencies:
  table_calendar: ^3.1.0      # Calendar UI for prayer notes
  in_app_purchase: ^3.2.0     # iOS/Android IAP
  intl: ^0.19.0               # Internationalization
  flutter_dotenv: ^5.1.0      # Environment configuration
```

---

## Architecture & Design Patterns

### Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│          Presentation Layer             │
│  (Screens, Widgets, Providers)          │
│  - UI Components                        │
│  - State Management (Riverpod)          │
│  - User Interactions                    │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│           Domain Layer                  │
│  (Entities, Repository Interfaces)      │
│  - Business Logic                       │
│  - Pure Dart (No Dependencies)          │
│  - Immutable Entities (Freezed)         │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│            Data Layer                   │
│  (Repositories, DataSources, Services)  │
│  - Supabase Integration                 │
│  - Error Handling (Either<L, R>)        │
│  - Data Transformation                  │
└─────────────────────────────────────────┘
```

### Key Design Patterns

#### 1. Repository Pattern
- Abstracts data sources from business logic
- Interface in Domain layer, implementation in Data layer
- Enables easy testing with mocks

#### 2. Functional Programming Principles

**Immutability**:
```dart
@freezed
class Scripture with _$Scripture {
  const factory Scripture({
    required String id,
    required String content,
    // ... immutable fields
  }) = _Scripture;
}
```

**Either Type for Error Handling**:
```dart
Future<Either<Failure, List<Scripture>>> getDailyScriptures({
  required String userId,
  required int count,
});
// Left = Error, Right = Success
```

**Pure Functions**:
- Same input → Same output
- No side effects
- Testable and predictable

#### 3. Provider Pattern (Riverpod)
- Dependency injection
- State management
- Automatic disposal
- Provider composition

#### 4. Dependency Injection
```dart
// Providers automatically inject dependencies
final scriptureRepositoryProvider = Provider<ScriptureRepository>((ref) {
  final dataSource = ref.watch(scriptureDataSourceProvider);
  return SupabaseScriptureRepository(dataSource);
});
```

---

## User Tiers & Feature Matrix

### Tier Comparison

| Feature | Guest (Non-login) | Member (Free) | Premium (Paid) |
|---------|-------------------|---------------|----------------|
| **Scripture Access** | ||||
| Daily scriptures | 1 (random, duplicates) | 3 (no duplicates) | 3 regular + 3 premium |
| Premium content | ❌ | ❌ | ✅ |
| **Prayer Notes** | ||||
| Write notes | ❌ | ✅ | ✅ |
| View history | ❌ | Last 3 days | Unlimited |
| Archive retention | ❌ | 7 days | Permanent |
| **Monetization** | ||||
| Upsell prompts | Login blocker | Archive & content limits | None |
| Price | Free | Free | ₩9,900/month or ₩99,000/year |

### Tier Implementation

**Database**:
```sql
-- user_profiles.tier enum
CHECK (tier IN ('guest', 'member', 'premium'))
```

**Flutter**:
```dart
enum UserTier {
  guest,    // Non-authenticated or trial
  member,   // Free registered user
  premium,  // Paid subscriber
}
```

---

## Development Progress

### Phase Summary

| Phase | Description | Status | Tests | Progress |
|-------|-------------|--------|-------|----------|
| Phase 1 | Environment & Auth | ✅ Complete | 24 tests | 100% |
| Phase 2 | Scripture Delivery | ✅ Complete | 60 tests | 100% |
| Phase 3 | Prayer Note System | ✅ Complete | 59 tests | 100% |
| Phase 4 | Monetization | 🔄 In Progress | 55/145 tests | 70% |
| Phase 5 | Optimization & Launch | ⏳ Pending | 0 tests | 0% |

### Phase 4 Breakdown (Current)

| Sub-Phase | Description | Status | Tests |
|-----------|-------------|--------|-------|
| 4-1 | Database & Subscription Schema | ✅ Complete | 25 pgTAP + 4 Edge Function |
| 4-2 | Subscription Feature (TDD) | ✅ Complete | 55 Dart tests |
| 4-3 | UI Implementation | ⏳ Pending | 0/26 tests |

**Total Completion**: 4 out of 5 phases, ~74% overall

---

## Database Schema

### Tables Overview

#### 1. user_profiles
**Purpose**: Store user tier and profile information

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key, references auth.users(id) |
| tier | TEXT | User tier: 'guest', 'member', 'premium' |
| created_at | TIMESTAMPTZ | Account creation timestamp |
| updated_at | TIMESTAMPTZ | Last update timestamp |

**RLS Policies**:
- Users can view/update own profile
- Service role has full access

---

#### 2. scriptures
**Purpose**: Store daily scripture content

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| book | TEXT | Bible book name (e.g., "John") |
| chapter | INTEGER | Chapter number |
| verse | INTEGER | Verse number |
| content | TEXT | Scripture text |
| reference | TEXT | Formatted reference (e.g., "John 3:16") |
| is_premium | BOOLEAN | Premium-only content flag |
| category | TEXT | Category (wisdom, hope, faith, etc.) |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Update timestamp |

**RLS Policies**:
- All authenticated users can view regular scriptures
- Only premium users can view `is_premium = true` scriptures

**Dummy Data**: 23 scriptures (15 regular + 8 premium)

---

#### 3. user_scripture_history
**Purpose**: Track which scriptures users have viewed

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID | References auth.users(id) |
| scripture_id | UUID | References scriptures(id) |
| viewed_at | TIMESTAMPTZ | Timestamp of view |

**RLS Policies**:
- Users can only view/insert their own history
- Used for no-duplicate logic

---

#### 4. prayer_notes
**Purpose**: Store user meditation and prayer records

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID | References auth.users(id) |
| scripture_id | UUID | Optional scripture reference |
| content | TEXT | Note content |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Update timestamp |

**RLS Policies**:
- Member: Can view notes from last 3 days only
- Premium: Can view all notes
- Guest: No access

**Retention**:
- Member notes older than 7 days are auto-deleted
- Premium notes are permanent

---

#### 5. user_subscriptions
**Purpose**: Track premium subscription status

| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Primary key |
| user_id | UUID | References auth.users(id), UNIQUE |
| product_id | TEXT | 'monthly_premium' or 'annual_premium' |
| platform | TEXT | 'ios', 'android', or 'web' |
| store_transaction_id | TEXT | Receipt validation ID |
| original_transaction_id | TEXT | Original purchase ID (renewals) |
| subscription_status | TEXT | 'active', 'canceled', 'expired', 'pending', 'grace_period' |
| started_at | TIMESTAMPTZ | Subscription start date |
| expires_at | TIMESTAMPTZ | Expiration date (NULL for lifetime) |
| auto_renew | BOOLEAN | Auto-renewal enabled |
| cancellation_reason | TEXT | Reason for cancellation |
| created_at | TIMESTAMPTZ | Creation timestamp |
| updated_at | TIMESTAMPTZ | Update timestamp |

**RLS Policies**:
- Users can view only their own subscription
- Only service role can insert/update/delete

---

#### 6. subscription_products
**Purpose**: Define available subscription products

| Column | Type | Description |
|--------|------|-------------|
| id | TEXT | Primary key ('monthly_premium', 'annual_premium') |
| name | TEXT | Product name |
| description | TEXT | Product description |
| duration_days | INTEGER | 30 (monthly), 365 (annual), NULL (lifetime) |
| price_krw | INTEGER | Price in Korean Won |
| price_usd | DECIMAL | Price in USD |
| ios_product_id | TEXT | App Store Connect product ID |
| android_product_id | TEXT | Google Play product ID |
| is_active | BOOLEAN | Product availability |
| created_at | TIMESTAMPTZ | Creation timestamp |

**RLS Policies**:
- All users can view active products

**Products**:
1. `monthly_premium`: ₩9,900/month
2. `annual_premium`: ₩99,000/year (2 months free)

---

### RPC Functions

#### Scripture Functions (4 functions)

1. **get_random_scripture**(count INTEGER)
   - Returns random scriptures for guest users
   - Duplicates allowed

2. **get_daily_scriptures**(user_id UUID, count INTEGER)
   - Returns non-duplicate scriptures for members
   - Excludes already-viewed scriptures today

3. **get_premium_scriptures**(user_id UUID, count INTEGER)
   - Returns premium scriptures for premium users
   - Applies no-duplicate logic

4. **record_scripture_view**(user_id UUID, scripture_id UUID)
   - Records viewing history
   - Used for duplicate prevention

#### Prayer Note Functions (7 functions)

1. **create_prayer_note**(user_id UUID, content TEXT, scripture_id UUID)
2. **get_prayer_notes**(user_id UUID, start_date DATE, end_date DATE)
3. **get_prayer_notes_by_date**(user_id UUID, date DATE)
4. **update_prayer_note**(note_id UUID, content TEXT)
5. **delete_prayer_note**(note_id UUID)
6. **is_date_accessible**(user_id UUID, date DATE)
7. **get_notes_with_scripture**(user_id UUID, start_date DATE, end_date DATE)

#### Subscription Functions (5 functions)

1. **get_subscription_status**(user_id UUID)
   - Returns current subscription with active status

2. **activate_subscription**(user_id, product_id, platform, transaction_id, original_transaction_id)
   - Activates subscription after purchase verification
   - Updates user tier to premium

3. **cancel_subscription**(user_id UUID, reason TEXT)
   - Cancels subscription (keeps access until expiry)

4. **get_available_products**(platform TEXT)
   - Returns active subscription products

5. **has_active_premium**(user_id UUID)
   - Boolean check for premium access

---

### Edge Functions (5 functions)

#### 1. verify-ios-receipt
**Purpose**: Verify iOS purchase receipts with Apple

**Endpoint**: `POST /functions/v1/verify-ios-receipt`

**Request**:
```json
{
  "receipt": "base64_encoded_receipt",
  "userId": "user_uuid"
}
```

**Response**:
```json
{
  "valid": true,
  "transactionId": "1000000123456789",
  "originalTransactionId": "1000000123456789",
  "productId": "com.onemessage.monthly",
  "expiresDate": "1704067200000"
}
```

---

#### 2. verify-android-receipt
**Purpose**: Verify Android purchase with Google Play

**Endpoint**: `POST /functions/v1/verify-android-receipt`

**Request**:
```json
{
  "purchaseToken": "google_purchase_token",
  "productId": "monthly_premium_sub",
  "userId": "user_uuid"
}
```

---

#### 3. subscription-webhook
**Purpose**: Handle subscription renewal/cancellation webhooks from Apple/Google

**Endpoint**: `POST /functions/v1/subscription-webhook`

**Handles**:
- Subscription renewals
- Subscription cancellations
- Subscription expirations
- Grace period notifications

---

#### 4. check-expired-subscriptions
**Purpose**: Cron job to check and downgrade expired subscriptions

**Schedule**: Daily at 2 AM UTC

**Actions**:
- Find subscriptions where `expires_at < NOW()` and status = 'active'
- Update status to 'expired'
- Downgrade user tier from 'premium' to 'member'

---

#### 5. cleanup-old-notes
**Purpose**: Delete prayer notes older than 7 days for member tier

**Schedule**: Daily at 3 AM UTC

**Logic**:
```sql
DELETE FROM prayer_notes
WHERE user_id IN (SELECT id FROM user_profiles WHERE tier = 'member')
  AND created_at < NOW() - INTERVAL '7 days';
```

---

## Domain Entities

### 1. UserProfile

**File**: `lib/features/auth/domain/user_profile.dart`

```dart
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required UserTier tier,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfile;
}

enum UserTier {
  guest,
  member,
  premium,
}
```

---

### 2. Scripture

**File**: `lib/features/scripture/domain/entities/scripture.dart`

```dart
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
}
```

**Properties**:
- `id`: Unique identifier (UUID)
- `book`: Bible book name (e.g., "Genesis", "John")
- `chapter`: Chapter number (positive integer)
- `verse`: Verse number (positive integer)
- `content`: Full scripture text
- `reference`: Formatted string (e.g., "John 3:16")
- `isPremium`: Flag for premium-only content
- `category`: Optional categorization (wisdom, hope, faith, etc.)

---

### 3. PrayerNote

**File**: `lib/features/prayer_note/domain/entities/prayer_note.dart`

```dart
@freezed
class PrayerNote with _$PrayerNote {
  const factory PrayerNote({
    required String id,
    required String userId,
    String? scriptureId,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
    // Joined scripture data (optional)
    String? scriptureReference,
    String? scriptureContent,
  }) = _PrayerNote;
}
```

**Properties**:
- `id`: Unique identifier
- `userId`: Owner of the prayer note
- `scriptureId`: Optional reference to scripture
- `content`: User's meditation/prayer text
- `createdAt`: Creation timestamp
- `scriptureReference`: Joined field from scriptures table
- `scriptureContent`: Joined field from scriptures table

---

### 4. Subscription

**File**: `lib/features/subscription/domain/entities/subscription.dart`

```dart
@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String userId,
    required String productId,
    required SubscriptionPlatform platform,
    String? storeTransactionId,
    String? originalTransactionId,
    required SubscriptionStatus status,
    required DateTime startedAt,
    DateTime? expiresAt,
    @Default(true) bool autoRenew,
    String? cancellationReason,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Subscription;
}

enum SubscriptionStatus {
  active,
  canceled,
  expired,
  pending,
  gracePeriod,
}

enum SubscriptionPlatform {
  ios,
  android,
  web,
}
```

---

### 5. SubscriptionProduct

```dart
@freezed
class SubscriptionProduct with _$SubscriptionProduct {
  const factory SubscriptionProduct({
    required String id,
    required String name,
    String? description,
    int? durationDays,
    required int priceKrw,
    double? priceUsd,
    String? iosProductId,
    String? androidProductId,
    @Default(true) bool isActive,
    required DateTime createdAt,
  }) = _SubscriptionProduct;
}
```

---

### 6. PurchaseResult

```dart
@freezed
class PurchaseResult with _$PurchaseResult {
  const factory PurchaseResult({
    required String productId,
    required String transactionId,
    String? originalTransactionId,
    required SubscriptionPlatform platform,
    String? receipt, // iOS
    String? purchaseToken, // Android
    required DateTime purchaseDate,
    required IAPPurchaseStatus status,
  }) = _PurchaseResult;
}

enum IAPPurchaseStatus {
  purchased,
  pending,
  restored,
  canceled,
  error,
}
```

---

## Repository Interfaces

### 1. AuthRepository

**File**: `lib/features/auth/data/auth_repository.dart`

**Methods**:
```dart
class AuthRepository {
  User? get currentUser;
  bool get isLoggedIn;
  Stream<AuthState> get authStateChanges;

  Future<Either<String, User>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<String, User>> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<Either<String, Unit>> signOut();
  Future<Either<String, Unit>> signInWithGoogle();
  Future<Either<String, Unit>> signInWithApple();
}
```

---

### 2. UserProfileRepository

**File**: `lib/features/auth/data/user_profile_repository.dart`

**Methods**:
```dart
class UserProfileRepository {
  Future<Either<String, UserProfile>> getUserProfile(String userId);

  Future<Either<String, UserTier>> getUserTier(String userId);

  Future<Either<String, UserProfile>> updateUserTier({
    required String userId,
    required UserTier tier,
  });

  Future<Either<String, UserProfile>> createUserProfile({
    required String userId,
    UserTier tier = UserTier.member,
  });
}
```

---

### 3. ScriptureRepository

**File**: `lib/features/scripture/domain/repositories/scripture_repository.dart`

**Methods**:
```dart
abstract class ScriptureRepository {
  /// Get random scripture for guest users (duplicates allowed)
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

  /// Record that a user viewed a scripture
  Future<Either<Failure, void>> recordScriptureView({
    required String userId,
    required String scriptureId,
  });

  /// Get user's scripture viewing history for a specific date
  Future<Either<Failure, List<Scripture>>> getScriptureHistory({
    required String userId,
    required DateTime date,
  });
}
```

**Implementation**: `SupabaseScriptureRepository`
**Tests**: 17 passing tests

---

### 4. PrayerNoteRepository

**File**: `lib/features/prayer_note/domain/repositories/prayer_note_repository.dart`

**Methods**:
```dart
abstract class PrayerNoteRepository {
  /// Create a new prayer note
  Future<Either<Failure, PrayerNote>> createPrayerNote({
    required String userId,
    required String content,
    String? scriptureId,
  });

  /// Get prayer notes for a date range (tier-based filtering)
  Future<Either<Failure, List<PrayerNote>>> getPrayerNotes({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get prayer notes for a specific date
  Future<Either<Failure, List<PrayerNote>>> getPrayerNotesByDate({
    required String userId,
    required DateTime date,
  });

  /// Update an existing prayer note
  Future<Either<Failure, PrayerNote>> updatePrayerNote({
    required String noteId,
    required String content,
  });

  /// Delete a prayer note
  Future<Either<Failure, void>> deletePrayerNote({
    required String noteId,
  });

  /// Check if a date is accessible based on user tier
  /// Member: last 3 days accessible
  /// Premium: all dates accessible
  Future<Either<Failure, bool>> isDateAccessible({
    required String userId,
    required DateTime date,
  });
}
```

**Implementation**: `SupabasePrayerNoteRepository`
**Tests**: 23 passing tests

---

### 5. SubscriptionRepository

**File**: `lib/features/subscription/domain/repositories/subscription_repository.dart`

**Methods**:
```dart
abstract class SubscriptionRepository {
  /// Get current user's subscription status
  Future<Either<Failure, Subscription?>> getSubscriptionStatus({
    required String userId,
  });

  /// Get available subscription products
  Future<Either<Failure, List<SubscriptionProduct>>> getAvailableProducts({
    SubscriptionPlatform? platform,
  });

  /// Activate a subscription after successful purchase verification
  Future<Either<Failure, Subscription>> activateSubscription({
    required String userId,
    required String productId,
    required SubscriptionPlatform platform,
    required String transactionId,
    String? originalTransactionId,
  });

  /// Cancel current subscription (remains active until expiration)
  Future<Either<Failure, void>> cancelSubscription({
    required String userId,
    String? reason,
  });

  /// Verify iOS receipt with Apple
  Future<Either<Failure, Map<String, dynamic>>> verifyIosReceipt({
    required String receipt,
    required String userId,
  });

  /// Verify Android purchase with Google Play
  Future<Either<Failure, Map<String, dynamic>>> verifyAndroidPurchase({
    required String purchaseToken,
    required String productId,
    required String userId,
  });

  /// Check if user has active premium subscription
  Future<Either<Failure, bool>> hasActivePremium({
    required String userId,
  });
}
```

**Implementation**: `SupabaseSubscriptionRepository`
**Tests**: 32 passing tests

---

### 6. IAPService

**File**: `lib/features/subscription/domain/services/iap_service.dart`

**Methods**:
```dart
abstract class IAPService {
  /// Initialize IAP service (platform-specific)
  Future<Either<Failure, void>> initialize();

  /// Fetch available products from store
  Future<Either<Failure, List<SubscriptionProduct>>> fetchProducts({
    required List<String> productIds,
  });

  /// Purchase a subscription product
  Future<Either<Failure, PurchaseResult>> purchaseSubscription({
    required String productId,
  });

  /// Restore previous purchases
  Future<Either<Failure, List<PurchaseResult>>> restorePurchases();

  /// Get pending purchases (incomplete transactions)
  Future<Either<Failure, List<PurchaseResult>>> getPendingPurchases();

  /// Complete a purchase transaction
  Future<Either<Failure, void>> completePurchase({
    required String transactionId,
  });

  /// Dispose resources and listeners
  void dispose();
}
```

**Implementation**: `IAPServiceImpl` (iOS/Android using `in_app_purchase` package)
**Tests**: 7 passing tests

---

## Implemented Features

### Phase 1: Environment & Auth ✅

#### Features
1. **Authentication System**
   - Email/password sign-in and sign-up
   - Google OAuth integration
   - Apple Sign-In integration
   - Session management with Supabase Auth

2. **User Profile Management**
   - Automatic profile creation on sign-up
   - Tier management (guest/member/premium)
   - Profile retrieval and updates

3. **Onboarding Flow**
   - Splash screen with auto-login check
   - Login/signup screens
   - Onboarding popup for guest users

#### Files Implemented
- `lib/features/auth/data/auth_repository.dart`
- `lib/features/auth/data/user_profile_repository.dart`
- `lib/features/auth/domain/user_profile.dart`
- `lib/features/auth/presentation/screens/splash_screen.dart`
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/auth/presentation/widgets/onboarding_popup.dart`

#### Tests
- **AuthRepository**: 11 tests
- **UserProfileRepository**: 13 tests
- **Total**: 24 passing tests

---

### Phase 2: Scripture Delivery System ✅

#### Features
1. **Tier-Based Scripture Delivery**
   - **Guest**: 1 random scripture/day (duplicates allowed)
   - **Member**: 3 scriptures/day (no duplicates)
   - **Premium**: 3 regular + 3 premium scriptures/day

2. **Scripture Card UI**
   - Beautiful card design with scripture content
   - Reference display
   - Category badges
   - Responsive layout

3. **Daily Feed Screen**
   - Vertical scrolling PageView
   - Page indicators
   - Content blocker when limit reached

4. **No-Duplicate Logic**
   - Tracks viewing history
   - Excludes already-viewed scriptures for the day
   - RPC function with JOIN optimization

#### Files Implemented
- `lib/features/scripture/domain/entities/scripture.dart`
- `lib/features/scripture/domain/repositories/scripture_repository.dart`
- `lib/features/scripture/data/repositories/supabase_scripture_repository.dart`
- `lib/features/scripture/presentation/screens/daily_feed_screen.dart`
- `lib/features/scripture/presentation/widgets/scripture_card.dart`
- `lib/features/scripture/presentation/widgets/content_blocker.dart`
- `lib/features/scripture/presentation/widgets/page_indicator.dart`

#### Database
- **Migration 002**: `scriptures` table (23 records: 15 regular + 8 premium)
- **Migration 003**: `user_scripture_history` table
- **Migration 004**: 4 RPC functions
- **pgTAP Tests**: 15 SQL tests

#### Tests
- **ScriptureRepository**: 17 tests
- **ScriptureCard Widget**: 9 tests
- **DailyFeedScreen Widget**: 6 tests
- **ContentBlocker Widget**: 9 tests
- **PageIndicator Widget**: 4 tests
- **pgTAP (SQL)**: 15 tests
- **Total**: 60 tests

---

### Phase 3: Prayer Note System ✅

#### Features
1. **Prayer Note Creation**
   - Multi-line text input
   - Optional scripture reference
   - Real-time save to Supabase

2. **Calendar View (My Library)**
   - `table_calendar` integration
   - Date-based note display
   - Lock/unlock indicators by tier

3. **Tier-Based Access Control**
   - **Guest**: Cannot write or view notes
   - **Member**: Can write, view last 3 days only
   - **Premium**: Unlimited access to all notes

4. **Automatic Cleanup**
   - Edge Function deletes member notes older than 7 days
   - Premium notes are permanent

#### Files Implemented
- `lib/features/prayer_note/domain/entities/prayer_note.dart`
- `lib/features/prayer_note/domain/repositories/prayer_note_repository.dart`
- `lib/features/prayer_note/data/repositories/supabase_prayer_note_repository.dart`
- `lib/features/prayer_note/presentation/screens/my_library_screen.dart`
- `lib/features/prayer_note/presentation/widgets/prayer_note_input.dart`
- `lib/features/prayer_note/presentation/widgets/prayer_note_card.dart`
- `lib/features/prayer_note/presentation/widgets/prayer_calendar.dart`
- `lib/features/prayer_note/presentation/widgets/date_accessibility_indicator.dart`

#### Database
- **Migration 006**: `prayer_notes` table with RLS policies
- **Migration 007**: 7 RPC functions (CRUD + utilities)
- **Edge Function**: `cleanup-old-notes` (scheduled daily)
- **pgTAP Tests**: 20 SQL tests

#### Tests
- **PrayerNoteRepository**: 23 tests
- **MyLibraryScreen Widget**: 6 tests
- **PrayerNoteInput Widget**: 9 tests
- **PrayerNoteCard Widget**: 10 tests
- **PrayerCalendar Widget**: 5 tests
- **DateAccessibilityIndicator Widget**: 6 tests
- **Total**: 59 tests

---

### Phase 4: Monetization (70% Complete) 🔄

#### Features Implemented (4-1 & 4-2)

**4-1. Database & Subscription Schema** ✅
1. **Subscription Tables**
   - `user_subscriptions` table with comprehensive status tracking
   - `subscription_products` table with pricing info
   - RLS policies for security

2. **RPC Functions** (5 functions)
   - `get_subscription_status`
   - `activate_subscription`
   - `cancel_subscription`
   - `get_available_products`
   - `has_active_premium`

3. **Edge Functions** (4 functions)
   - `verify-ios-receipt`: Apple receipt verification
   - `verify-android-receipt`: Google Play purchase verification
   - `subscription-webhook`: Handle store notifications
   - `check-expired-subscriptions`: Cron job for expiry checks

**4-2. Subscription Feature (TDD)** ✅
1. **Domain Layer**
   - Subscription, SubscriptionProduct, PurchaseResult entities
   - SubscriptionRepository interface (7 methods)
   - IAPService interface (7 methods)

2. **Data Layer**
   - SupabaseSubscriptionRepository implementation
   - IAPServiceImpl for iOS/Android (using `in_app_purchase` package)

3. **State Layer (Riverpod Providers)**
   - `subscriptionStatusProvider`: Load current subscription
   - `availableProductsProvider`: Fetch products from store
   - `purchaseControllerProvider`: Handle purchase flow
   - `restorePurchaseControllerProvider`: Restore previous purchases
   - `hasPremiumProvider`: Boolean check for premium access

#### Files Implemented
- `lib/features/subscription/domain/entities/subscription.dart`
- `lib/features/subscription/domain/repositories/subscription_repository.dart`
- `lib/features/subscription/domain/services/iap_service.dart`
- `lib/features/subscription/data/repositories/supabase_subscription_repository.dart`
- `lib/features/subscription/data/services/iap_service_impl.dart`
- `lib/features/subscription/presentation/providers/subscription_providers.dart`

#### Database
- **Migration 008**: `user_subscriptions` and `subscription_products` tables
- **Migration 009**: 5 RPC functions
- **Edge Functions**: 4 TypeScript/Deno functions
- **pgTAP Tests**: 25 SQL tests

#### Tests
- **SubscriptionRepository**: 32 tests
- **IAPService**: 7 tests
- **SubscriptionProviders**: 16 tests
- **pgTAP (SQL)**: 25 tests
- **Total**: 55 tests (UI tests pending)

#### Features Pending (4-3)
- PremiumLandingScreen UI
- ManageSubscriptionScreen UI
- SubscriptionProductCard widget
- PurchaseButton widget
- UpsellDialog widget
- Integration with Scripture Feed and Prayer Archive
- iOS/Android purchase flow integration tests

**Estimated**: 26 additional widget/integration tests

---

## State Management

### Riverpod Providers

#### Auth Providers

**File**: `lib/features/auth/providers/auth_providers.dart`

```dart
// Core providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {...});
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {...});

// State providers
final currentUserProvider = StreamProvider<User?>((ref) {...});
final authStateProvider = StreamProvider<AuthState>((ref) {...});

// User profile providers
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {...});
final currentUserTierProvider = FutureProvider<UserTier>((ref) async {...});
```

**Usage**:
```dart
// In widgets
final userTier = ref.watch(currentUserTierProvider);
userTier.when(
  data: (tier) => Text('Tier: $tier'),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

---

#### Scripture Providers

**File**: `lib/features/scripture/presentation/providers/scripture_providers.dart`

```dart
// Repository provider
final scriptureRepositoryProvider = Provider<ScriptureRepository>((ref) {...});

// Daily scriptures (tier-based)
final dailyScripturesProvider = FutureProvider<List<Scripture>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  final tier = await ref.watch(currentUserTierProvider.future);
  final repository = ref.watch(scriptureRepositoryProvider);

  if (tier == UserTier.guest) {
    return repository.getRandomScripture(1);
  } else {
    return repository.getDailyScriptures(userId: user!.id, count: 3);
  }
});

// Premium scriptures (premium users only)
final premiumScripturesProvider = FutureProvider<List<Scripture>>((ref) async {...});

// Scripture view tracker
final scriptureViewTrackerProvider = Provider((ref) {
  return ScriptureViewTracker(ref.watch(scriptureRepositoryProvider));
});
```

---

#### Prayer Note Providers

**File**: `lib/features/prayer_note/presentation/providers/prayer_note_providers.dart`

```dart
// Repository provider
final prayerNoteRepositoryProvider = Provider<PrayerNoteRepository>((ref) {...});

// Prayer notes list (auto-refresh)
final prayerNotesProvider = StreamProvider.family<List<PrayerNote>, DateTime>(
  (ref, date) {
    final userId = ref.watch(currentUserProvider).value!.id;
    return ref.watch(prayerNoteRepositoryProvider)
      .getPrayerNotesByDate(userId: userId, date: date);
  }
);

// Date accessibility checker
final dateAccessibilityProvider = FutureProvider.family<bool, DateTime>(
  (ref, date) async {
    final userId = ref.watch(currentUserProvider).value!.id;
    final result = await ref.watch(prayerNoteRepositoryProvider)
      .isDateAccessible(userId: userId, date: date);
    return result.fold((l) => false, (r) => r);
  }
);

// Note creation controller
final createPrayerNoteProvider = StateNotifierProvider<CreatePrayerNoteNotifier, AsyncValue<PrayerNote?>>(
  (ref) => CreatePrayerNoteNotifier(ref.watch(prayerNoteRepositoryProvider))
);
```

---

#### Subscription Providers

**File**: `lib/features/subscription/presentation/providers/subscription_providers.dart`

```dart
// Repository and service providers
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {...});
final iapServiceProvider = Provider<IAPService>((ref) {...});

// Subscription status
final subscriptionStatusProvider = FutureProvider<Subscription?>((ref) async {
  final userId = ref.watch(currentUserProvider).value?.id;
  if (userId == null) return null;

  final result = await ref.watch(subscriptionRepositoryProvider)
    .getSubscriptionStatus(userId: userId);
  return result.fold((l) => null, (r) => r);
});

// Available products
final availableProductsProvider = FutureProvider<List<SubscriptionProduct>>((ref) async {
  final result = await ref.watch(subscriptionRepositoryProvider)
    .getAvailableProducts();
  return result.fold((l) => [], (r) => r);
});

// Has premium (boolean)
final hasPremiumProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(currentUserProvider).value?.id;
  if (userId == null) return false;

  final result = await ref.watch(subscriptionRepositoryProvider)
    .hasActivePremium(userId: userId);
  return result.fold((l) => false, (r) => r);
});

// Purchase controller
final purchaseControllerProvider = StateNotifierProvider<PurchaseController, AsyncValue<PurchaseResult?>>(
  (ref) => PurchaseController(
    ref.watch(iapServiceProvider),
    ref.watch(subscriptionRepositoryProvider),
  )
);

// Restore purchase controller
final restorePurchaseControllerProvider = StateNotifierProvider<RestorePurchaseController, AsyncValue<List<PurchaseResult>>>(
  (ref) => RestorePurchaseController(
    ref.watch(iapServiceProvider),
    ref.watch(subscriptionRepositoryProvider),
  )
);
```

---

## Test Coverage

### Test Statistics

| Category | Test Files | Test Cases | Status |
|----------|------------|------------|--------|
| **Auth** | 5 | 24 | ✅ Passing |
| **Scripture** | 5 + 1 SQL | 60 (45 Dart + 15 pgTAP) | ✅ Passing |
| **Prayer Note** | 6 + 1 SQL | 59 (39 Dart + 20 pgTAP) | ✅ Passing |
| **Subscription** | 3 + 1 SQL | 55 (55 Dart + 25 pgTAP) | ✅ Passing |
| **Total** | 20 | 198 | ✅ Passing |

### Coverage by Layer

| Layer | Target | Current |
|-------|--------|---------|
| Repository | 95%+ | ~95% |
| Service | 95%+ | ~95% |
| Provider | 90%+ | ~90% |
| Widget | 80%+ | ~85% |
| Screen | 70%+ | ~70% |

### Test Files

#### Phase 1: Auth
```
test/features/auth/
├── auth_repository_test.dart (11 tests)
├── user_profile_repository_test.dart (13 tests)
└── presentation/
    ├── splash_screen_test.dart
    ├── login_screen_test.dart
    └── onboarding_popup_test.dart
```

#### Phase 2: Scripture
```
test/features/scripture/
├── data/
│   └── repositories/
│       └── scripture_repository_test.dart (17 tests)
└── presentation/
    ├── screens/
    │   └── daily_feed_screen_test.dart (6 tests)
    └── widgets/
        ├── scripture_card_test.dart (9 tests)
        ├── content_blocker_test.dart (9 tests)
        └── page_indicator_test.dart (4 tests)

supabase/tests/
└── scripture_rpc_test.sql (15 pgTAP tests)
```

#### Phase 3: Prayer Note
```
test/features/prayer_note/
├── data/
│   └── repositories/
│       └── prayer_note_repository_test.dart (23 tests)
└── presentation/
    ├── screens/
    │   └── my_library_screen_test.dart (6 tests)
    └── widgets/
        ├── prayer_note_input_test.dart (9 tests)
        ├── prayer_note_card_test.dart (10 tests)
        ├── prayer_calendar_test.dart (5 tests)
        └── date_accessibility_indicator_test.dart (6 tests)

supabase/tests/
└── prayer_note_test.sql (20 pgTAP tests)
```

#### Phase 4: Subscription
```
test/features/subscription/
├── data/
│   ├── repositories/
│   │   └── subscription_repository_test.dart (32 tests)
│   └── services/
│       └── iap_service_test.dart (7 tests)
└── presentation/
    └── providers/
        └── subscription_providers_test.dart (16 tests)

supabase/tests/
└── subscription_test.sql (25 pgTAP tests)
```

### Test Commands

```bash
# Run all Dart tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific feature tests
flutter test test/features/auth/
flutter test test/features/scripture/
flutter test test/features/prayer_note/
flutter test test/features/subscription/

# Run pgTAP tests (Supabase)
cd supabase
supabase test db
```

---

## File Structure

```
severalbible/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   │   └── failures.dart
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   ├── services/
│   │   │   └── supabase_service.dart
│   │   └── utils/
│   │
│   └── features/
│       ├── auth/
│       │   ├── domain/
│       │   │   ├── user_profile.dart
│       │   │   └── user_tier.dart
│       │   ├── data/
│       │   │   ├── auth_repository.dart
│       │   │   ├── user_profile_repository.dart
│       │   │   └── user_profile_data_source.dart
│       │   ├── providers/
│       │   │   └── auth_providers.dart
│       │   └── presentation/
│       │       ├── screens/
│       │       │   ├── splash_screen.dart
│       │       │   ├── login_screen.dart
│       │       │   └── home_screen.dart
│       │       └── widgets/
│       │           └── onboarding_popup.dart
│       │
│       ├── scripture/
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── scripture.dart
│       │   │   └── repositories/
│       │   │       └── scripture_repository.dart
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── scripture_datasource.dart
│       │   │   │   └── supabase_scripture_datasource.dart
│       │   │   └── repositories/
│       │   │       └── supabase_scripture_repository.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── scripture_providers.dart
│       │       ├── screens/
│       │       │   └── daily_feed_screen.dart
│       │       └── widgets/
│       │           ├── scripture_card.dart
│       │           ├── content_blocker.dart
│       │           └── page_indicator.dart
│       │
│       ├── prayer_note/
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── prayer_note.dart
│       │   │   └── repositories/
│       │   │       └── prayer_note_repository.dart
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── prayer_note_datasource.dart
│       │   │   │   └── supabase_prayer_note_datasource.dart
│       │   │   └── repositories/
│       │   │       └── supabase_prayer_note_repository.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── prayer_note_providers.dart
│       │       ├── screens/
│       │       │   └── my_library_screen.dart
│       │       └── widgets/
│       │           ├── prayer_note_input.dart
│       │           ├── prayer_note_card.dart
│       │           ├── prayer_calendar.dart
│       │           └── date_accessibility_indicator.dart
│       │
│       └── subscription/
│           ├── domain/
│           │   ├── entities/
│           │   │   └── subscription.dart
│           │   ├── repositories/
│           │   │   └── subscription_repository.dart
│           │   └── services/
│           │       └── iap_service.dart
│           ├── data/
│           │   ├── datasources/
│           │   │   ├── subscription_datasource.dart
│           │   │   └── supabase_subscription_datasource.dart
│           │   ├── repositories/
│           │   │   └── supabase_subscription_repository.dart
│           │   └── services/
│           │       └── iap_service_impl.dart
│           └── presentation/
│               └── providers/
│                   └── subscription_providers.dart
│
├── test/
│   ├── features/
│   │   ├── auth/
│   │   ├── scripture/
│   │   ├── prayer_note/
│   │   └── subscription/
│   └── widget_test.dart
│
├── supabase/
│   ├── migrations/
│   │   ├── 001_create_user_profiles.sql
│   │   ├── 002_create_scriptures.sql
│   │   ├── 003_create_user_scripture_history.sql
│   │   ├── 004_create_scripture_rpc_functions.sql
│   │   ├── 005_insert_scripture_dummy_data.sql
│   │   ├── 006_create_prayer_notes.sql
│   │   ├── 007_create_prayer_note_rpc_functions.sql
│   │   ├── 008_create_user_subscriptions.sql
│   │   └── 009_create_subscription_rpc_functions.sql
│   ├── functions/
│   │   ├── verify-ios-receipt/
│   │   ├── verify-android-receipt/
│   │   ├── subscription-webhook/
│   │   ├── check-expired-subscriptions/
│   │   └── cleanup-old-notes/
│   └── tests/
│       ├── scripture_rpc_test.sql
│       ├── prayer_note_test.sql
│       └── subscription_test.sql
│
├── pubspec.yaml
├── CLAUDE.md
├── PLANNER.md
├── SPEC.md (this file)
└── README.md
```

**Total Dart Files**: 51
**Total Test Files**: 20
**Total Migrations**: 9
**Total Edge Functions**: 5

---

## API Documentation

### Supabase RPC Functions

#### Scripture APIs

##### 1. get_random_scripture

**Purpose**: Get random scriptures for guest users (duplicates allowed)

**Signature**:
```sql
get_random_scripture(p_count INTEGER DEFAULT 1)
RETURNS TABLE (
  id UUID,
  book TEXT,
  chapter INTEGER,
  verse INTEGER,
  content TEXT,
  reference TEXT,
  is_premium BOOLEAN,
  category TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ
)
```

**Usage**:
```dart
final result = await supabase
  .rpc('get_random_scripture', params: {'p_count': 1});
```

---

##### 2. get_daily_scriptures

**Purpose**: Get non-duplicate scriptures for member users

**Signature**:
```sql
get_daily_scriptures(
  p_user_id UUID,
  p_count INTEGER DEFAULT 3
)
RETURNS TABLE (...)
```

**Logic**:
- Excludes scriptures already viewed today
- Excludes premium scriptures
- Random selection from remaining pool

**Usage**:
```dart
final result = await supabase.rpc('get_daily_scriptures', params: {
  'p_user_id': userId,
  'p_count': 3,
});
```

---

##### 3. get_premium_scriptures

**Purpose**: Get premium scriptures for premium users

**Signature**:
```sql
get_premium_scriptures(
  p_user_id UUID,
  p_count INTEGER DEFAULT 3
)
RETURNS TABLE (...)
```

**Logic**:
- Only returns scriptures where `is_premium = true`
- Excludes already-viewed premium scriptures today
- Requires premium tier (enforced in app logic)

---

##### 4. record_scripture_view

**Purpose**: Record that a user viewed a scripture

**Signature**:
```sql
record_scripture_view(
  p_user_id UUID,
  p_scripture_id UUID
)
RETURNS VOID
```

**Usage**:
```dart
await supabase.rpc('record_scripture_view', params: {
  'p_user_id': userId,
  'p_scripture_id': scriptureId,
});
```

---

#### Prayer Note APIs

##### 1. create_prayer_note

**Signature**:
```sql
create_prayer_note(
  p_user_id UUID,
  p_content TEXT,
  p_scripture_id UUID DEFAULT NULL
)
RETURNS UUID
```

**Returns**: The ID of the newly created prayer note

---

##### 2. get_prayer_notes_by_date

**Signature**:
```sql
get_prayer_notes_by_date(
  p_user_id UUID,
  p_date DATE
)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  scripture_id UUID,
  content TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  scripture_reference TEXT,
  scripture_content TEXT
)
```

**Notes**:
- Joins with scriptures table if `scripture_id` is present
- RLS applies tier-based filtering automatically

---

##### 3. is_date_accessible

**Signature**:
```sql
is_date_accessible(
  p_user_id UUID,
  p_date DATE
)
RETURNS BOOLEAN
```

**Logic**:
```sql
-- Member tier: accessible if date is within last 3 days
-- Premium tier: always accessible
-- Guest tier: never accessible
```

---

#### Subscription APIs

##### 1. get_subscription_status

**Signature**:
```sql
get_subscription_status(p_user_id UUID DEFAULT auth.uid())
RETURNS TABLE (
  subscription_id UUID,
  product_id TEXT,
  status TEXT,
  expires_at TIMESTAMPTZ,
  is_active BOOLEAN
)
```

**Returns**: Current subscription with computed `is_active` field

---

##### 2. activate_subscription

**Signature**:
```sql
activate_subscription(
  p_user_id UUID,
  p_product_id TEXT,
  p_platform TEXT,
  p_transaction_id TEXT,
  p_original_transaction_id TEXT DEFAULT NULL
)
RETURNS JSON
```

**Side Effects**:
- Inserts or updates `user_subscriptions` table
- Updates `user_profiles.tier` to 'premium'
- Calculates `expires_at` based on product duration

**Returns**:
```json
{
  "subscription_id": "uuid",
  "expires_at": "2025-02-15T12:00:00Z",
  "status": "success"
}
```

---

##### 3. has_active_premium

**Signature**:
```sql
has_active_premium(p_user_id UUID)
RETURNS BOOLEAN
```

**Logic**:
```sql
SELECT EXISTS (
  SELECT 1 FROM user_subscriptions
  WHERE user_id = p_user_id
    AND subscription_status = 'active'
    AND (expires_at IS NULL OR expires_at > NOW())
)
```

---

### Flutter Repository Methods

All repository methods return `Either<Failure, T>` type for explicit error handling:

**Example**:
```dart
final result = await scriptureRepository.getDailyScriptures(
  userId: userId,
  count: 3,
);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (scriptures) => print('Success: ${scriptures.length} scriptures'),
);
```

**Failure Types**:
```dart
abstract class Failure {
  final String message;
}

class DatabaseFailure extends Failure {...}
class NetworkFailure extends Failure {...}
class CacheFailure extends Failure {...}
class ServerFailure extends Failure {...}
```

---

## Future Roadmap

### Phase 5: Optimization & Launch (Pending)

**Goals**:
1. Performance optimization
2. Offline support (optional)
3. App store preparation
4. QA and bug fixes

**Tasks**:
- Image caching with `cached_network_image`
- ListView lazy loading optimization
- Offline scripture caching with Hive (optional)
- App icon and splash screen design
- Store screenshots and descriptions
- Privacy policy and terms of service
- TestFlight/Google Play Internal Testing
- Final QA and bug fixes

**Estimated Duration**: 2-3 weeks

---

### Phase 4-3 Completion (Next Priority)

**Remaining UI Tasks**:
1. PremiumLandingScreen (7 widget tests)
2. ManageSubscriptionScreen (6 widget tests)
3. SubscriptionProductCard widget (5 tests)
4. PurchaseButton widget (4 tests)
5. UpsellDialog widget (4 tests)
6. Scripture Feed integration (3 tests)
7. Prayer Archive integration (3 tests)
8. iOS/Android purchase flows (17 integration tests)

**Estimated Duration**: 1-2 weeks

---

## Documentation Updates

**Last Updated**: 2026-01-21

**Maintainers**: Development Team
**Repository**: GitHub (private)
**Supabase Project**: [Project URL]

**Related Documents**:
- `CLAUDE.md`: Project instructions and agent usage
- `PLANNER.md`: High-level development plan
- `README.md`: Getting started guide
- `checklist/phase*.md`: Detailed TDD checklists

---

## Conclusion

One Message is a well-architected spiritual growth application built with:
- **Clean Architecture** for maintainability
- **TDD methodology** for reliability (198 tests)
- **Functional Programming** for predictability
- **Supabase BaaS** for scalability
- **Freemium model** for sustainability

Current status: **74% complete**, ready for Phase 4-3 UI implementation and Phase 5 launch preparation.

---

*This specification is a living document and will be updated as the project evolves.*
