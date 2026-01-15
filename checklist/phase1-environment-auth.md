# Phase 1: Environment & Auth - TDD Checklist

**Goal**: Establish the project foundation and integrate Supabase Auth to start managing user tiers.

**Total Items**: 48
**Coverage Target**: Repository 95%+, Service 95%+, Provider 90%+, Widget 80%+

---

## 1-1. Project Initialization

### Setup Tasks
- [x] Create folder structure (Clean Architecture)
  - `lib/domain/entities/` - Entity classes
  - `lib/domain/repositories/` - Repository interfaces
  - `lib/data/repositories/` - Repository implementations
  - `lib/data/datasources/` - Remote/Local data sources
  - `lib/presentation/screens/` - Screen widgets
  - `lib/presentation/widgets/` - Reusable widgets
  - `lib/presentation/providers/` - Riverpod providers
  - `lib/core/constants/` - App constants
  - `lib/core/errors/` - Failure classes
  - `lib/core/utils/` - Utility functions
- [x] Add essential packages to `pubspec.yaml`
  ```yaml
  dependencies:
    flutter_riverpod: ^2.4.0
    supabase_flutter: ^2.3.0
    go_router: ^13.0.0
    freezed_annotation: ^2.4.0
    dartz: ^0.10.1
    flutter_dotenv: ^5.1.0
  dev_dependencies:
    freezed: ^2.4.0
    build_runner: ^2.4.0
    mockito: ^5.4.0
    mocktail: ^1.0.0
  ```
- [x] Configure `analysis_options.yaml` (strict mode)
- [x] Setup GitHub Actions for CI/CD
  - `.github/workflows/flutter_ci.yml`
  - Build test on push/PR

---

## 1-2. Supabase Environment Configuration

### Database Setup
- [x] Create Supabase project and get credentials
- [x] Create `.env` file (add to `.gitignore`)
  ```
  SUPABASE_URL=your_project_url
  SUPABASE_ANON_KEY=your_anon_key
  ```
- [x] Initialize Supabase in `main.dart`

### User Profiles Table
- [x] Create `user_profiles` table
  ```sql
  CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    tier TEXT NOT NULL DEFAULT 'member' CHECK (tier IN ('guest', 'member', 'premium')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
  );
  ```
- [x] Set RLS policies for `user_profiles`
  ```sql
  -- Enable RLS
  ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

  -- Users can view their own profile
  CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

  -- Users can update their own profile
  CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);
  ```
- [x] Create trigger for auto-creating profile on sign-up
  ```sql
  CREATE OR REPLACE FUNCTION handle_new_user()
  RETURNS TRIGGER AS $$
  BEGIN
    INSERT INTO user_profiles (id, tier)
    VALUES (NEW.id, 'member');
    RETURN NEW;
  END;
  $$ LANGUAGE plpgsql SECURITY DEFINER;

  CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();
  ```

---

## 1-3. Auth Feature (TDD)

### Domain Layer

#### UserTier & UserProfile Entity
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.1 | 🟢 GREEN | Implement `UserTier` enum (`lib/features/auth/domain/user_tier.dart`) | [x] |
| 1.1 | 🟢 GREEN | Implement `UserProfile` entity with freezed (`lib/features/auth/domain/user_profile.dart`) | [x] |
| 1.1 | 🔵 REFACTOR | Verify immutability and copyWith | [x] |

#### SupabaseService Abstraction
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.2 | 🟢 GREEN | Create `SupabaseService` interface for testability | [x] |
| 1.2 | 🟢 GREEN | Implement `SupabaseServiceImpl` (`lib/core/services/supabase_service.dart`) | [x] |

### Data Layer - AuthRepository

#### Sign In with Email
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.1 | 🔴 RED | Test `signInWithEmail` returns `Right(User)` on success | [x] |
| 2.1 | 🔴 RED | Test `signInWithEmail` returns `Left(failure)` on error | [x] |
| 2.1 | 🟢 GREEN | Implement `signInWithEmail` in `AuthRepository` | [x] |

#### Sign Up with Email
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.2 | 🔴 RED | Test `signUpWithEmail` returns `Right(User)` on success | [x] |
| 2.2 | 🔴 RED | Test `signUpWithEmail` returns `Left(failure)` on error | [x] |
| 2.2 | 🟢 GREEN | Implement `signUpWithEmail` in `AuthRepository` | [x] |

#### OAuth Methods (Google/Apple)
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.3 | 🟢 GREEN | Implement `signInWithGoogle` method | [x] |
| 2.3 | 🟢 GREEN | Implement `signInWithApple` method | [x] |
| 2.3 | ⏳ PENDING | OAuth integration test (requires device testing) | [ ] |

#### Sign Out
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.4 | 🔴 RED | Test `signOut` completes successfully | [x] |
| 2.4 | 🔴 RED | Test `signOut` returns `Left(failure)` on error | [x] |
| 2.4 | 🟢 GREEN | Implement `signOut` | [x] |

#### Current User & Auth State
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.5 | 🔴 RED | Test `currentUser` returns User when logged in | [x] |
| 2.5 | 🔴 RED | Test `currentUser` returns null when not logged in | [x] |
| 2.5 | 🔴 RED | Test `isLoggedIn` returns correct boolean | [x] |
| 2.5 | 🔴 RED | Test `authStateChanges` emits auth state | [x] |
| 2.5 | 🟢 GREEN | Implement all currentUser/authState methods | [x] |

### Data Layer - UserProfileRepository

#### UserProfileDataSource Abstraction
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.6 | 🟢 GREEN | Create `UserProfileDataSource` interface | [x] |
| 2.6 | 🟢 GREEN | Implement `SupabaseUserProfileDataSource` | [x] |

#### Get User Profile
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.7 | 🔴 RED | Test `getUserProfile` returns profile when found | [x] |
| 2.7 | 🔴 RED | Test `getUserProfile` returns failure when not found | [x] |
| 2.7 | 🔴 RED | Test `getUserProfile` handles database error | [x] |
| 2.7 | 🟢 GREEN | Implement `getUserProfile` | [x] |

#### Get/Update User Tier
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.8 | 🔴 RED | Test `getUserTier` returns tier for existing user | [x] |
| 2.8 | 🔴 RED | Test `getUserTier` returns guest for non-existing user | [x] |
| 2.8 | 🔴 RED | Test `updateUserTier` updates successfully | [x] |
| 2.8 | 🔴 RED | Test `updateUserTier` handles error | [x] |
| 2.8 | 🟢 GREEN | Implement `getUserTier` and `updateUserTier` | [x] |

#### Create User Profile
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.9 | 🔴 RED | Test `createUserProfile` with default tier | [x] |
| 2.9 | 🔴 RED | Test `createUserProfile` with specified tier | [x] |
| 2.9 | 🔴 RED | Test `createUserProfile` handles error | [x] |
| 2.9 | 🟢 GREEN | Implement `createUserProfile` | [x] |

### State Layer - Riverpod Providers

| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 3.1 | 🟢 GREEN | Create `supabaseClientProvider` | [x] |
| 3.1 | 🟢 GREEN | Create `supabaseServiceProvider` | [x] |
| 3.1 | 🟢 GREEN | Create `authRepositoryProvider` | [x] |
| 3.1 | 🟢 GREEN | Create `userProfileDataSourceProvider` | [x] |
| 3.1 | 🟢 GREEN | Create `userProfileRepositoryProvider` | [x] |
| 3.1 | 🟢 GREEN | Create `currentUserProvider` | [x] |
| 3.1 | 🟢 GREEN | Create `authStateChangesProvider` | [x] |
| 3.1 | 🟢 GREEN | Create `currentUserTierProvider` | [x] |
| 3.1 | 🟢 GREEN | Create `isLoggedInProvider` | [x] |

---

## 1-4. UI Implementation

### Splash Screen

| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.1 | 🔴 RED | Widget test: shows loading indicator | [ ] |
| 4.1 | 🔴 RED | Widget test: navigates to Home when authenticated | [ ] |
| 4.1 | 🔴 RED | Widget test: navigates to Login when unauthenticated | [ ] |
| 4.1 | 🟢 GREEN | Implement `SplashScreen` | [ ] |
| 4.1 | 🔵 REFACTOR | Clean up navigation logic | [ ] |

### Login/Sign-up Screen

| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.2 | 🔴 RED | Widget test: renders Google sign-in button | [ ] |
| 4.2 | 🔴 RED | Widget test: renders Apple sign-in button | [ ] |
| 4.2 | 🔴 RED | Widget test: Google button triggers `signInWithGoogle` | [ ] |
| 4.2 | 🔴 RED | Widget test: Apple button triggers `signInWithApple` | [ ] |
| 4.2 | 🔴 RED | Widget test: shows error snackbar on failure | [ ] |
| 4.2 | 🟢 GREEN | Implement `LoginScreen` | [ ] |
| 4.2 | 🔵 REFACTOR | Extract button widgets | [ ] |

### Onboarding Funnel (Guest Conversion Popup)

| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 4.3 | 🔴 RED | Widget test: popup appears for guest user | [ ] |
| 4.3 | 🔴 RED | Widget test: popup contains conversion message | [ ] |
| 4.3 | 🔴 RED | Widget test: CTA button navigates to login | [ ] |
| 4.3 | 🟢 GREEN | Implement `OnboardingPopup` widget | [ ] |
| 4.3 | 🔵 REFACTOR | Polish UI and animations | [ ] |

---

## Test File Locations

| Test Type | File Path | Tests |
|-----------|-----------|-------|
| AuthRepository | `test/features/auth/auth_repository_test.dart` | 11 |
| UserProfileRepository | `test/features/auth/user_profile_repository_test.dart` | 13 |
| Widget Test | `test/widget_test.dart` | 1 |

## Implementation File Locations

| Component | File Path |
|-----------|-----------|
| SupabaseService | `lib/core/services/supabase_service.dart` |
| UserTier Enum | `lib/features/auth/domain/user_tier.dart` |
| UserProfile Entity | `lib/features/auth/domain/user_profile.dart` |
| AuthRepository | `lib/features/auth/data/auth_repository.dart` |
| UserProfileDataSource | `lib/features/auth/data/user_profile_data_source.dart` |
| UserProfileRepository | `lib/features/auth/data/user_profile_repository.dart` |
| Auth Providers | `lib/features/auth/providers/auth_providers.dart` |

---

## Progress Summary

| Section | Total | Completed | Progress |
|---------|-------|-----------|----------|
| 1-1. Project Setup | 4 | 4 | 100% |
| 1-2. Supabase Setup | 6 | 6 | 100% |
| 1-3. Auth Feature (TDD) | 44 | 43 | 98% |
| 1-4. UI Implementation | 17 | 0 | 0% |
| **Total** | **71** | **53** | **75%** |

### Test Summary
- AuthRepository Tests: 11 passing
- UserProfileRepository Tests: 13 passing
- Widget Tests: 1 passing
- **Total Tests: 25 passing**

---

**Last Updated**: 2026-01-15
**Phase Status**: In Progress (1-1, 1-2, 1-3 Complete)
