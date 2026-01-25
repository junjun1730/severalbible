import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/scripture.dart';
import '../../domain/repositories/scripture_repository.dart';
import '../datasources/scripture_datasource.dart';

/// Supabase implementation of ScriptureRepository
/// Handles scripture data operations through Supabase RPC calls
class SupabaseScriptureRepository implements ScriptureRepository {
  final ScriptureDataSource _dataSource;

  SupabaseScriptureRepository(this._dataSource);

  /// Maps JSON list to Scripture entities
  List<Scripture> _mapJsonListToScriptures(
    List<Map<String, dynamic>> jsonList,
  ) {
    return jsonList.map((json) => Scripture.fromJson(json)).toList();
  }

  @override
  Future<Either<Failure, List<Scripture>>> getRandomScripture(int count) async {
    try {
      final result = await _dataSource.getRandomScripture(count);
      final scriptures = _mapJsonListToScriptures(result);
      return Right(scriptures);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Scripture>>> getDailyScriptures({
    required String userId,
    required int count,
  }) async {
    try {
      final result = await _dataSource.getDailyScriptures(
        userId: userId,
        count: count,
      );
      final scriptures = _mapJsonListToScriptures(result);
      return Right(scriptures);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Scripture>>> getPremiumScriptures({
    required String userId,
    required int count,
  }) async {
    try {
      final result = await _dataSource.getPremiumScriptures(
        userId: userId,
        count: count,
      );
      final scriptures = _mapJsonListToScriptures(result);
      return Right(scriptures);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> recordScriptureView({
    required String userId,
    required String scriptureId,
  }) async {
    try {
      await _dataSource.recordScriptureView(
        userId: userId,
        scriptureId: scriptureId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Scripture>>> getScriptureHistory({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final result = await _dataSource.getScriptureHistory(
        userId: userId,
        date: date,
      );
      final scriptures = _mapJsonListToScriptures(result);
      return Right(scriptures);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
