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
- [ ] Create Supabase project and get credentials
- [ ] Create `.env` file (add to `.gitignore`)
  ```
  SUPABASE_URL=your_project_url
  SUPABASE_ANON_KEY=your_anon_key
  ```
- [ ] Initialize Supabase in `main.dart`

### User Profiles Table
- [ ] Create `user_profiles` table
  ```sql
  CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    tier TEXT NOT NULL DEFAULT 'member' CHECK (tier IN ('guest', 'member', 'premium')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
  );
  ```
- [ ] Set RLS policies for `user_profiles`
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
- [ ] Create trigger for auto-creating profile on sign-up
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

#### User Entity
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.1 | 🔴 RED | Write `User` entity test (`test/domain/entities/user_test.dart`) | [ ] |
| 1.1 | 🟢 GREEN | Implement `User` entity with freezed (`lib/domain/entities/user.dart`) | [ ] |
| 1.1 | 🔵 REFACTOR | Verify immutability and copyWith | [ ] |

#### AuthRepository Interface
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 1.2 | 🔴 RED | Define `AuthRepository` interface contract | [ ] |
| 1.2 | 🟢 GREEN | Create `lib/domain/repositories/auth_repository.dart` | [ ] |

### Data Layer - SupabaseAuthRepository

#### Sign In with Google
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.1 | 🔴 RED | Test `signInWithGoogle` returns `Right(User)` on success | [ ] |
| 2.1 | 🔴 RED | Test `signInWithGoogle` returns `Left(AuthFailure)` on error | [ ] |
| 2.1 | 🟢 GREEN | Implement `signInWithGoogle` in `SupabaseAuthRepository` | [ ] |
| 2.1 | 🔵 REFACTOR | Extract error handling to helper | [ ] |

#### Sign In with Apple
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.2 | 🔴 RED | Test `signInWithApple` returns `Right(User)` on success | [ ] |
| 2.2 | 🔴 RED | Test `signInWithApple` returns `Left(AuthFailure)` on error | [ ] |
| 2.2 | 🟢 GREEN | Implement `signInWithApple` in `SupabaseAuthRepository` | [ ] |
| 2.2 | 🔵 REFACTOR | Consolidate OAuth logic | [ ] |

#### Sign Out
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.3 | 🔴 RED | Test `signOut` completes successfully | [ ] |
| 2.3 | 🔴 RED | Test `signOut` returns `Left(AuthFailure)` on error | [ ] |
| 2.3 | 🟢 GREEN | Implement `signOut` | [ ] |
| 2.3 | 🔵 REFACTOR | Clean up | [ ] |

#### Get Current User
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.4 | 🔴 RED | Test `getCurrentUser` returns `Right(User)` when logged in | [ ] |
| 2.4 | 🔴 RED | Test `getCurrentUser` returns `Right(null)` when not logged in | [ ] |
| 2.4 | 🟢 GREEN | Implement `getCurrentUser` | [ ] |
| 2.4 | 🔵 REFACTOR | Optimize user mapping | [ ] |

#### Auth State Changes Stream
| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 2.5 | 🔴 RED | Test `authStateChanges` emits user on login | [ ] |
| 2.5 | 🔴 RED | Test `authStateChanges` emits null on logout | [ ] |
| 2.5 | 🟢 GREEN | Implement `authStateChanges` stream | [ ] |
| 2.5 | 🔵 REFACTOR | Final repository cleanup | [ ] |

### State Layer - AuthProvider (Riverpod)

| Cycle | Phase | Task | Status |
|-------|-------|------|--------|
| 3.1 | 🔴 RED | Test `AuthProvider` initial state is `AuthState.initial` | [ ] |
| 3.1 | 🔴 RED | Test `AuthProvider` state changes to `authenticated` on login | [ ] |
| 3.1 | 🔴 RED | Test `AuthProvider` state changes to `unauthenticated` on logout | [ ] |
| 3.1 | 🟢 GREEN | Implement `AuthProvider` with `StateNotifier` | [ ] |
| 3.1 | 🔵 REFACTOR | Optimize state transitions | [ ] |

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

| Test Type | File Path |
|-----------|-----------|
| User Entity | `test/domain/entities/user_test.dart` |
| AuthRepository | `test/data/repositories/auth_repository_test.dart` |
| AuthProvider | `test/presentation/providers/auth_provider_test.dart` |
| SplashScreen | `test/presentation/screens/splash_screen_test.dart` |
| LoginScreen | `test/presentation/screens/login_screen_test.dart` |
| OnboardingPopup | `test/presentation/widgets/onboarding_popup_test.dart` |

## Implementation File Locations

| Component | File Path |
|-----------|-----------|
| User Entity | `lib/domain/entities/user.dart` |
| AuthRepository Interface | `lib/domain/repositories/auth_repository.dart` |
| SupabaseAuthRepository | `lib/data/repositories/supabase_auth_repository.dart` |
| AuthProvider | `lib/presentation/providers/auth_provider.dart` |
| SplashScreen | `lib/presentation/screens/splash_screen.dart` |
| LoginScreen | `lib/presentation/screens/login_screen.dart` |
| OnboardingPopup | `lib/presentation/widgets/onboarding_popup.dart` |

---

## Progress Summary

| Section | Total | Completed | Progress |
|---------|-------|-----------|----------|
| 1-1. Project Setup | 4 | 4 | 100% |
| 1-2. Supabase Setup | 6 | 0 | 0% |
| 1-3. Auth Feature (TDD) | 28 | 0 | 0% |
| 1-4. UI Implementation | 17 | 0 | 0% |
| **Total** | **55** | **4** | **7%** |

---

**Last Updated**: 2026-01-14
**Phase Status**: In Progress (1-1 Complete)
