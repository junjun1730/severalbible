import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../auth/domain/user_tier.dart';
import '../../data/datasources/scripture_datasource.dart';
import '../../data/datasources/supabase_scripture_datasource.dart';
import '../../data/repositories/supabase_scripture_repository.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/repositories/scripture_repository.dart';

/// Provider for ScriptureDataSource
final scriptureDataSourceProvider = Provider<ScriptureDataSource>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return SupabaseScriptureDataSource(supabaseService);
});

/// Provider for ScriptureRepository
final scriptureRepositoryProvider = Provider<ScriptureRepository>((ref) {
  final dataSource = ref.watch(scriptureDataSourceProvider);
  return SupabaseScriptureRepository(dataSource);
});

/// Provider for current scripture page index
final currentScriptureIndexProvider = StateProvider<int>((ref) => 0);

/// Provider for daily scriptures based on user tier
/// - Guest: 1 random scripture
/// - Member: 3 daily scriptures (no duplicates)
/// - Premium: 3 daily scriptures (no duplicates)
final dailyScripturesProvider = FutureProvider<List<Scripture>>((ref) async {
  final tierAsync = ref.watch(currentUserTierProvider);
  final currentUser = ref.watch(currentUserProvider);
  final repository = ref.watch(scriptureRepositoryProvider);

  final tier = tierAsync.when(
    data: (t) => t,
    loading: () => UserTier.guest,
    error: (_, __) => UserTier.guest,
  );

  switch (tier) {
    case UserTier.guest:
      final result = await repository.getRandomScripture(1);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (scriptures) => scriptures,
      );

    case UserTier.member:
    case UserTier.premium:
      if (currentUser == null) {
        throw Exception('User must be logged in');
      }
      final result = await repository.getDailyScriptures(
        userId: currentUser.id,
        count: 3,
      );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (scriptures) => scriptures,
      );
  }
});

/// Provider for premium scriptures (additional 3 for premium users)
final premiumScripturesProvider = FutureProvider.family<List<Scripture>, void>((
  ref,
  _,
) async {
  final tierAsync = ref.watch(currentUserTierProvider);
  final currentUser = ref.watch(currentUserProvider);
  final repository = ref.watch(scriptureRepositoryProvider);

  final tier = tierAsync.when(
    data: (t) => t,
    loading: () => UserTier.guest,
    error: (_, __) => UserTier.guest,
  );

  if (tier != UserTier.premium) {
    throw Exception('Premium subscription required');
  }

  if (currentUser == null) {
    throw Exception('User must be logged in');
  }

  final result = await repository.getPremiumScriptures(
    userId: currentUser.id,
    count: 3,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (scriptures) => scriptures,
  );
});

/// Notifier for tracking scripture views with debounce
class ScriptureViewTracker extends StateNotifier<Set<String>> {
  final ScriptureRepository _repository;
  final String? _userId;

  ScriptureViewTracker(this._repository, this._userId) : super({});

  Future<void> trackView(String scriptureId) async {
    // Skip if already tracked in this session
    if (state.contains(scriptureId)) return;

    // Skip if user is not logged in (guest)
    if (_userId == null) return;

    // Add to tracked set
    state = {...state, scriptureId};

    // Record view in database
    await _repository.recordScriptureView(
      userId: _userId,
      scriptureId: scriptureId,
    );

    // Remove from debounce set after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      state = Set.from(state)..remove(scriptureId);
    });
  }
}

/// Provider for scripture view tracker
final scriptureViewTrackerProvider =
    StateNotifierProvider<ScriptureViewTracker, Set<String>>((ref) {
      final repository = ref.watch(scriptureRepositoryProvider);
      final currentUser = ref.watch(currentUserProvider);
      return ScriptureViewTracker(repository, currentUser?.id);
    });

/// Provider for scripture history by date
final scriptureHistoryProvider =
    FutureProvider.family<List<Scripture>, DateTime>((ref, date) async {
      final currentUser = ref.watch(currentUserProvider);
      final repository = ref.watch(scriptureRepositoryProvider);

      if (currentUser == null) {
        return [];
      }

      final result = await repository.getScriptureHistory(
        userId: currentUser.id,
        date: date,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (scriptures) => scriptures,
      );
    });

/// Provider for checking if user has reached daily limit
final hasReachedDailyLimitProvider = Provider<bool>((ref) {
  final scripturesAsync = ref.watch(dailyScripturesProvider);
  final currentIndex = ref.watch(currentScriptureIndexProvider);

  return scripturesAsync.when(
    data: (scriptures) => currentIndex >= scriptures.length - 1,
    loading: () => false,
    error: (_, __) => true,
  );
});

/// Provider for checking if "See 3 More" button should be visible
final showSeeMoreButtonProvider = Provider<bool>((ref) {
  final tierAsync = ref.watch(currentUserTierProvider);
  final hasReachedLimit = ref.watch(hasReachedDailyLimitProvider);

  final tier = tierAsync.when(
    data: (t) => t,
    loading: () => UserTier.guest,
    error: (_, __) => UserTier.guest,
  );

  return tier == UserTier.premium && hasReachedLimit;
});
