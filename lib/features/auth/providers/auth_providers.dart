import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../data/auth_repository.dart';
import '../data/user_profile_data_source.dart';
import '../data/user_profile_repository.dart';
import '../domain/user_tier.dart';

/// Provider for Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for SupabaseService abstraction
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseServiceImpl(client);
});

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthRepository(supabaseService);
});

/// Provider for UserProfileDataSource
final userProfileDataSourceProvider = Provider<UserProfileDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseUserProfileDataSource(client);
});

/// Provider for UserProfileRepository
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final dataSource = ref.watch(userProfileDataSourceProvider);
  return UserProfileRepository(dataSource);
});

/// Provider for current user (nullable) - Reactive
final currentUserProvider = Provider<User?>((ref) {
  // Watch the auth state changes to force rebuild when auth state changes
  final authState = ref.watch(authStateChangesProvider);
  
  // Also get the repo to access current user synchronously
  final authRepo = ref.watch(authRepositoryProvider);
  
  // If the stream emitted a state, we can trust authRepo.currentUser is updated (or use state.session?.user)
  // We return authRepo.currentUser to be safe as it's the source of truth
  return authRepo.currentUser;
});

/// Provider for auth state changes stream
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

/// Provider for current user's tier
/// Returns guest if not logged in
final currentUserTierProvider = FutureProvider<UserTier>((ref) async {
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    return UserTier.guest;
  }

  final userProfileRepo = ref.watch(userProfileRepositoryProvider);
  final result = await userProfileRepo.getUserTier(currentUser.id);

  return result.fold(
    (failure) => UserTier.guest,
    (tier) => tier,
  );
});

/// Provider for checking if user is logged in
/// Derives from currentUserProvider to ensure reactivity to auth state changes
final isLoggedInProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser != null;
});
