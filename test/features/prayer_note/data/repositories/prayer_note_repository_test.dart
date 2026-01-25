import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:severalbible/core/errors/failures.dart';
import 'package:severalbible/features/prayer_note/data/datasources/prayer_note_datasource.dart';
import 'package:severalbible/features/prayer_note/data/repositories/supabase_prayer_note_repository.dart';
import 'package:severalbible/features/prayer_note/domain/entities/prayer_note.dart';

// Mock class for PrayerNoteDataSource
class MockPrayerNoteDataSource extends Mock implements PrayerNoteDataSource {}

void main() {
  late SupabasePrayerNoteRepository repository;
  late MockPrayerNoteDataSource mockDataSource;

  // Test fixtures
  final testDateTime = DateTime(2026, 1, 18, 12, 0, 0);
  final testUserId = 'user-123-abc';
  final testNoteId = 'note-456-def';
  final testScriptureId = 'scripture-789-ghi';

  final samplePrayerNoteJson = {
    'id': testNoteId,
    'user_id': testUserId,
    'scripture_id': testScriptureId,
    'content': 'Today I reflected on God\'s grace and mercy.',
    'created_at': testDateTime.toIso8601String(),
    'updated_at': testDateTime.toIso8601String(),
    'scripture_reference': 'John 3:16',
    'scripture_content': 'For God so loved the world...',
  };

  final samplePrayerNoteWithoutScriptureJson = {
    'id': 'note-no-scripture',
    'user_id': testUserId,
    'scripture_id': null,
    'content': 'A personal prayer note without scripture reference.',
    'created_at': testDateTime.toIso8601String(),
    'updated_at': testDateTime.toIso8601String(),
    'scripture_reference': null,
    'scripture_content': null,
  };

  setUp(() {
    mockDataSource = MockPrayerNoteDataSource();
    repository = SupabasePrayerNoteRepository(mockDataSource);
  });

  group('createPrayerNote', () {
    test('should return Right(PrayerNote) when datasource succeeds', () async {
      // Arrange
      when(
        () => mockDataSource.createPrayerNote(
          userId: any(named: 'userId'),
          content: any(named: 'content'),
          scriptureId: any(named: 'scriptureId'),
        ),
      ).thenAnswer((_) async => samplePrayerNoteJson);

      // Act
      final result = await repository.createPrayerNote(
        userId: testUserId,
        content: 'Today I reflected on God\'s grace and mercy.',
        scriptureId: testScriptureId,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected Right but got Left'), (note) {
        expect(note.id, testNoteId);
        expect(note.userId, testUserId);
        expect(note.content, contains('grace and mercy'));
      });
      verify(
        () => mockDataSource.createPrayerNote(
          userId: testUserId,
          content: 'Today I reflected on God\'s grace and mercy.',
          scriptureId: testScriptureId,
        ),
      ).called(1);
    });

    test('should return Right(PrayerNote) with scripture reference', () async {
      // Arrange
      when(
        () => mockDataSource.createPrayerNote(
          userId: any(named: 'userId'),
          content: any(named: 'content'),
          scriptureId: any(named: 'scriptureId'),
        ),
      ).thenAnswer((_) async => samplePrayerNoteJson);

      // Act
      final result = await repository.createPrayerNote(
        userId: testUserId,
        content: 'My meditation',
        scriptureId: testScriptureId,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected Right but got Left'), (note) {
        expect(note.scriptureId, testScriptureId);
        expect(note.scriptureReference, 'John 3:16');
      });
    });

    test(
      'should return Left(ServerFailure) when datasource throws exception',
      () async {
        // Arrange
        when(
          () => mockDataSource.createPrayerNote(
            userId: any(named: 'userId'),
            content: any(named: 'content'),
            scriptureId: any(named: 'scriptureId'),
          ),
        ).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.createPrayerNote(
          userId: testUserId,
          content: 'Test content',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Database error'));
        }, (note) => fail('Expected Left but got Right'));
      },
    );

    test(
      'should return Left(ValidationFailure) when content is empty',
      () async {
        // Act
        final result = await repository.createPrayerNote(
          userId: testUserId,
          content: '',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('empty'));
        }, (note) => fail('Expected Left but got Right'));
        verifyNever(
          () => mockDataSource.createPrayerNote(
            userId: any(named: 'userId'),
            content: any(named: 'content'),
            scriptureId: any(named: 'scriptureId'),
          ),
        );
      },
    );
  });

  group('getPrayerNotes', () {
    test(
      'should return Right(List<PrayerNote>) when datasource succeeds',
      () async {
        // Arrange
        when(
          () => mockDataSource.getPrayerNotes(
            userId: any(named: 'userId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenAnswer((_) async => [samplePrayerNoteJson]);

        // Act
        final result = await repository.getPrayerNotes(userId: testUserId);

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Expected Right but got Left'), (notes) {
          expect(notes.length, 1);
          expect(notes.first.id, testNoteId);
        });
        verify(
          () => mockDataSource.getPrayerNotes(
            userId: testUserId,
            startDate: null,
            endDate: null,
          ),
        ).called(1);
      },
    );

    test('should filter by date range when provided', () async {
      // Arrange
      final startDate = DateTime(2026, 1, 15);
      final endDate = DateTime(2026, 1, 18);
      when(
        () => mockDataSource.getPrayerNotes(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => [samplePrayerNoteJson]);

      // Act
      final result = await repository.getPrayerNotes(
        userId: testUserId,
        startDate: startDate,
        endDate: endDate,
      );

      // Assert
      expect(result.isRight(), true);
      verify(
        () => mockDataSource.getPrayerNotes(
          userId: testUserId,
          startDate: startDate,
          endDate: endDate,
        ),
      ).called(1);
    });

    test('should include scripture details when present', () async {
      // Arrange
      when(
        () => mockDataSource.getPrayerNotes(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => [samplePrayerNoteJson]);

      // Act
      final result = await repository.getPrayerNotes(userId: testUserId);

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected Right but got Left'), (notes) {
        expect(notes.first.scriptureReference, 'John 3:16');
        expect(notes.first.scriptureContent, contains('loved the world'));
      });
    });

    test('should return empty list when no notes exist', () async {
      // Arrange
      when(
        () => mockDataSource.getPrayerNotes(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        ),
      ).thenAnswer((_) async => []);

      // Act
      final result = await repository.getPrayerNotes(userId: testUserId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (notes) => expect(notes, isEmpty),
      );
    });

    test(
      'should return Left(ServerFailure) when datasource throws exception',
      () async {
        // Arrange
        when(
          () => mockDataSource.getPrayerNotes(
            userId: any(named: 'userId'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          ),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await repository.getPrayerNotes(userId: testUserId);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (notes) => fail('Expected Left but got Right'),
        );
      },
    );
  });

  group('getPrayerNotesByDate', () {
    test('should return notes for specific date', () async {
      // Arrange
      when(
        () => mockDataSource.getPrayerNotesByDate(
          userId: any(named: 'userId'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async => [samplePrayerNoteJson]);

      // Act
      final result = await repository.getPrayerNotesByDate(
        userId: testUserId,
        date: testDateTime,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected Right but got Left'), (notes) {
        expect(notes.length, 1);
        expect(notes.first.id, testNoteId);
      });
      verify(
        () => mockDataSource.getPrayerNotesByDate(
          userId: testUserId,
          date: testDateTime,
        ),
      ).called(1);
    });

    test('should return empty list when no notes exist for date', () async {
      // Arrange
      when(
        () => mockDataSource.getPrayerNotesByDate(
          userId: any(named: 'userId'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async => []);

      // Act
      final result = await repository.getPrayerNotesByDate(
        userId: testUserId,
        date: testDateTime,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (notes) => expect(notes, isEmpty),
      );
    });

    test(
      'should return Left(ServerFailure) when datasource throws exception',
      () async {
        // Arrange
        when(
          () => mockDataSource.getPrayerNotesByDate(
            userId: any(named: 'userId'),
            date: any(named: 'date'),
          ),
        ).thenThrow(Exception('Query failed'));

        // Act
        final result = await repository.getPrayerNotesByDate(
          userId: testUserId,
          date: testDateTime,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (notes) => fail('Expected Left but got Right'),
        );
      },
    );
  });

  group('updatePrayerNote', () {
    final updatedNoteJson = {
      ...samplePrayerNoteJson,
      'content': 'Updated meditation content',
      'updated_at': DateTime(2026, 1, 18, 14, 0, 0).toIso8601String(),
    };

    test('should return Right(PrayerNote) with updated content', () async {
      // Arrange
      when(
        () => mockDataSource.updatePrayerNote(
          noteId: any(named: 'noteId'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => updatedNoteJson);

      // Act
      final result = await repository.updatePrayerNote(
        noteId: testNoteId,
        content: 'Updated meditation content',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected Right but got Left'), (note) {
        expect(note.content, 'Updated meditation content');
      });
      verify(
        () => mockDataSource.updatePrayerNote(
          noteId: testNoteId,
          content: 'Updated meditation content',
        ),
      ).called(1);
    });

    test('should update updated_at timestamp', () async {
      // Arrange
      final newUpdatedAt = DateTime(2026, 1, 18, 14, 0, 0);
      when(
        () => mockDataSource.updatePrayerNote(
          noteId: any(named: 'noteId'),
          content: any(named: 'content'),
        ),
      ).thenAnswer(
        (_) async => {
          ...samplePrayerNoteJson,
          'updated_at': newUpdatedAt.toIso8601String(),
        },
      );

      // Act
      final result = await repository.updatePrayerNote(
        noteId: testNoteId,
        content: 'New content',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected Right but got Left'), (note) {
        expect(note.updatedAt, newUpdatedAt);
      });
    });

    test('should return Left(ServerFailure) when note not found', () async {
      // Arrange
      when(
        () => mockDataSource.updatePrayerNote(
          noteId: any(named: 'noteId'),
          content: any(named: 'content'),
        ),
      ).thenThrow(Exception('Note not found'));

      // Act
      final result = await repository.updatePrayerNote(
        noteId: 'non-existent-id',
        content: 'New content',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, contains('not found'));
      }, (note) => fail('Expected Left but got Right'));
    });

    test(
      'should return Left(ServerFailure) when datasource throws exception',
      () async {
        // Arrange
        when(
          () => mockDataSource.updatePrayerNote(
            noteId: any(named: 'noteId'),
            content: any(named: 'content'),
          ),
        ).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.updatePrayerNote(
          noteId: testNoteId,
          content: 'New content',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (note) => fail('Expected Left but got Right'),
        );
      },
    );
  });

  group('deletePrayerNote', () {
    test('should return Right(void) when deletion succeeds', () async {
      // Arrange
      when(
        () => mockDataSource.deletePrayerNote(noteId: any(named: 'noteId')),
      ).thenAnswer((_) async => {});

      // Act
      final result = await repository.deletePrayerNote(noteId: testNoteId);

      // Assert
      expect(result.isRight(), true);
      verify(
        () => mockDataSource.deletePrayerNote(noteId: testNoteId),
      ).called(1);
    });

    test('should return Left(ServerFailure) when note not found', () async {
      // Arrange
      when(
        () => mockDataSource.deletePrayerNote(noteId: any(named: 'noteId')),
      ).thenThrow(Exception('Note not found'));

      // Act
      final result = await repository.deletePrayerNote(
        noteId: 'non-existent-id',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect(failure.message, contains('not found'));
      }, (_) => fail('Expected Left but got Right'));
    });

    test(
      'should return Left(ServerFailure) when datasource throws exception',
      () async {
        // Arrange
        when(
          () => mockDataSource.deletePrayerNote(noteId: any(named: 'noteId')),
        ).thenThrow(Exception('Delete failed'));

        // Act
        final result = await repository.deletePrayerNote(noteId: testNoteId);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      },
    );
  });

  group('isDateAccessible', () {
    test('should return true for today (all tiers)', () async {
      // Arrange
      final today = DateTime.now();
      when(
        () => mockDataSource.isDateAccessible(
          userId: any(named: 'userId'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async => true);

      // Act
      final result = await repository.isDateAccessible(
        userId: testUserId,
        date: today,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (accessible) => expect(accessible, true),
      );
    });

    test('should return true for 3 days ago (member tier)', () async {
      // Arrange
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      when(
        () => mockDataSource.isDateAccessible(
          userId: any(named: 'userId'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async => true);

      // Act
      final result = await repository.isDateAccessible(
        userId: testUserId,
        date: threeDaysAgo,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (accessible) => expect(accessible, true),
      );
    });

    test('should return false for 4+ days ago (member tier)', () async {
      // Arrange
      final fourDaysAgo = DateTime.now().subtract(const Duration(days: 4));
      when(
        () => mockDataSource.isDateAccessible(
          userId: any(named: 'userId'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async => false);

      // Act
      final result = await repository.isDateAccessible(
        userId: testUserId,
        date: fourDaysAgo,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (accessible) => expect(accessible, false),
      );
    });

    test('should return true for any date (premium tier)', () async {
      // Arrange - Premium user can access any date
      final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
      when(
        () => mockDataSource.isDateAccessible(
          userId: any(named: 'userId'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async => true);

      // Act
      final result = await repository.isDateAccessible(
        userId: testUserId,
        date: oneYearAgo,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (accessible) => expect(accessible, true),
      );
    });
  });
}
