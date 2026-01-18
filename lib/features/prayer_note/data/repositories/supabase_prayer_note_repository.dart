import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/prayer_note.dart';
import '../../domain/repositories/prayer_note_repository.dart';
import '../datasources/prayer_note_datasource.dart';

/// Supabase implementation of PrayerNoteRepository
/// Handles prayer note data operations through Supabase RPC calls
class SupabasePrayerNoteRepository implements PrayerNoteRepository {
  final PrayerNoteDataSource _dataSource;

  SupabasePrayerNoteRepository(this._dataSource);

  /// Maps JSON list to PrayerNote entities
  List<PrayerNote> _mapJsonListToPrayerNotes(
      List<Map<String, dynamic>> jsonList) {
    return jsonList.map((json) => PrayerNote.fromJson(json)).toList();
  }

  @override
  Future<Either<Failure, PrayerNote>> createPrayerNote({
    required String userId,
    required String content,
    String? scriptureId,
  }) async {
    // Validate content is not empty
    if (content.trim().isEmpty) {
      return const Left(
          ValidationFailure('Content cannot be empty', code: 'EMPTY_CONTENT'));
    }

    try {
      final result = await _dataSource.createPrayerNote(
        userId: userId,
        content: content,
        scriptureId: scriptureId,
      );
      final prayerNote = PrayerNote.fromJson(result);
      return Right(prayerNote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PrayerNote>>> getPrayerNotes({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _dataSource.getPrayerNotes(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      final prayerNotes = _mapJsonListToPrayerNotes(result);
      return Right(prayerNotes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PrayerNote>>> getPrayerNotesByDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final result = await _dataSource.getPrayerNotesByDate(
        userId: userId,
        date: date,
      );
      final prayerNotes = _mapJsonListToPrayerNotes(result);
      return Right(prayerNotes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PrayerNote>> updatePrayerNote({
    required String noteId,
    required String content,
  }) async {
    try {
      final result = await _dataSource.updatePrayerNote(
        noteId: noteId,
        content: content,
      );
      final prayerNote = PrayerNote.fromJson(result);
      return Right(prayerNote);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePrayerNote({
    required String noteId,
  }) async {
    try {
      await _dataSource.deletePrayerNote(noteId: noteId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isDateAccessible({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final result = await _dataSource.isDateAccessible(
        userId: userId,
        date: date,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
