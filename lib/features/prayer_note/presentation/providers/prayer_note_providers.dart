import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../data/datasources/prayer_note_datasource.dart';
import '../../data/datasources/supabase_prayer_note_datasource.dart';
import '../../data/repositories/supabase_prayer_note_repository.dart';
import '../../domain/entities/prayer_note.dart';
import '../../domain/repositories/prayer_note_repository.dart';

/// Provider for PrayerNoteDataSource
final prayerNoteDataSourceProvider = Provider<PrayerNoteDataSource>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return SupabasePrayerNoteDataSource(supabaseService);
});

/// Provider for PrayerNoteRepository
final prayerNoteRepositoryProvider = Provider<PrayerNoteRepository>((ref) {
  final dataSource = ref.watch(prayerNoteDataSourceProvider);
  return SupabasePrayerNoteRepository(dataSource);
});

/// Provider for selected date in calendar
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// Provider for prayer notes list based on selected date
final prayerNoteListProvider = FutureProvider<List<PrayerNote>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final repository = ref.watch(prayerNoteRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  if (currentUser == null) {
    return [];
  }

  final result = await repository.getPrayerNotesByDate(
    userId: currentUser.id,
    date: selectedDate,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (notes) => notes,
  );
});

/// Provider for prayer notes in a date range (for calendar markers)
final prayerNotesForRangeProvider =
    FutureProvider.family<List<PrayerNote>, ({DateTime start, DateTime end})>(
        (ref, range) async {
  final currentUser = ref.watch(currentUserProvider);
  final repository = ref.watch(prayerNoteRepositoryProvider);

  if (currentUser == null) {
    return [];
  }

  final result = await repository.getPrayerNotes(
    userId: currentUser.id,
    startDate: range.start,
    endDate: range.end,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (notes) => notes,
  );
});

/// Provider for checking if a date is accessible based on user tier
final dateAccessibilityProvider =
    FutureProvider.family<bool, DateTime>((ref, date) async {
  final currentUser = ref.watch(currentUserProvider);
  final repository = ref.watch(prayerNoteRepositoryProvider);

  if (currentUser == null) {
    return false;
  }

  final result = await repository.isDateAccessible(
    userId: currentUser.id,
    date: date,
  );

  return result.fold(
    (failure) => false,
    (accessible) => accessible,
  );
});

/// State class for prayer note form
class PrayerNoteFormState {
  final bool isLoading;
  final String? errorMessage;
  final PrayerNote? savedNote;

  const PrayerNoteFormState({
    this.isLoading = false,
    this.errorMessage,
    this.savedNote,
  });

  PrayerNoteFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    PrayerNote? savedNote,
  }) {
    return PrayerNoteFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      savedNote: savedNote ?? this.savedNote,
    );
  }
}

/// Controller for prayer note form operations (create, update, delete)
class PrayerNoteFormController extends StateNotifier<PrayerNoteFormState> {
  final PrayerNoteRepository _repository;
  final String? _userId;
  final Ref _ref;

  PrayerNoteFormController(this._repository, this._userId, this._ref)
      : super(const PrayerNoteFormState());

  /// Create a new prayer note
  Future<bool> createNote({
    required String content,
    String? scriptureId,
  }) async {
    if (_userId == null) {
      state = state.copyWith(errorMessage: 'User must be logged in');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.createPrayerNote(
      userId: _userId,
      content: content,
      scriptureId: scriptureId,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (note) {
        state = state.copyWith(isLoading: false, savedNote: note);
        // Invalidate the notes list to refresh
        _ref.invalidate(prayerNoteListProvider);
        return true;
      },
    );
  }

  /// Update an existing prayer note
  Future<bool> updateNote({
    required String noteId,
    required String content,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.updatePrayerNote(
      noteId: noteId,
      content: content,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (note) {
        state = state.copyWith(isLoading: false, savedNote: note);
        // Invalidate the notes list to refresh
        _ref.invalidate(prayerNoteListProvider);
        return true;
      },
    );
  }

  /// Delete a prayer note
  Future<bool> deleteNote({required String noteId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.deletePrayerNote(noteId: noteId);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        // Invalidate the notes list to refresh
        _ref.invalidate(prayerNoteListProvider);
        return true;
      },
    );
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset state
  void reset() {
    state = const PrayerNoteFormState();
  }
}

/// Provider for prayer note form controller
final prayerNoteFormControllerProvider =
    StateNotifierProvider<PrayerNoteFormController, PrayerNoteFormState>((ref) {
  final repository = ref.watch(prayerNoteRepositoryProvider);
  final currentUser = ref.watch(currentUserProvider);
  return PrayerNoteFormController(repository, currentUser?.id, ref);
});

/// Provider for dates that have prayer notes in current month
final datesWithNotesProvider =
    FutureProvider.family<Set<DateTime>, DateTime>((ref, monthDate) async {
  final currentUser = ref.watch(currentUserProvider);
  final repository = ref.watch(prayerNoteRepositoryProvider);

  if (currentUser == null) {
    return {};
  }

  // Get first and last day of the month
  final firstDay = DateTime(monthDate.year, monthDate.month, 1);
  final lastDay = DateTime(monthDate.year, monthDate.month + 1, 0);

  final result = await repository.getPrayerNotes(
    userId: currentUser.id,
    startDate: firstDay,
    endDate: lastDay,
  );

  return result.fold(
    (failure) => {},
    (notes) {
      // Extract unique dates (without time)
      return notes
          .map((note) => DateTime(
                note.createdAt.year,
                note.createdAt.month,
                note.createdAt.day,
              ))
          .toSet();
    },
  );
});
