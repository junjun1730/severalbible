import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:severalbible/core/errors/failures.dart';
import 'package:severalbible/features/scripture/data/datasources/scripture_datasource.dart';
import 'package:severalbible/features/scripture/data/repositories/supabase_scripture_repository.dart';

// Mock class for ScriptureDataSource
class MockScriptureDataSource extends Mock implements ScriptureDataSource {}

void main() {
  late SupabaseScriptureRepository repository;
  late MockScriptureDataSource mockDataSource;

  // Test fixtures
  final testDateTime = DateTime(2026, 1, 16, 12, 0, 0);

  final sampleScriptureJson = {
    'id': '123e4567-e89b-12d3-a456-426614174000',
    'book': 'John',
    'chapter': 3,
    'verse': 16,
    'content':
        'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
    'reference': 'John 3:16',
    'is_premium': false,
    'category': 'hope',
    'created_at': testDateTime.toIso8601String(),
    'updated_at': testDateTime.toIso8601String(),
  };

  final samplePremiumScriptureJson = {
    'id': '223e4567-e89b-12d3-a456-426614174001',
    'book': 'Psalms',
    'chapter': 23,
    'verse': 1,
    'content': 'The LORD is my shepherd, I lack nothing.',
    'reference': 'Psalms 23:1',
    'is_premium': true,
    'category': 'comfort',
    'created_at': testDateTime.toIso8601String(),
    'updated_at': testDateTime.toIso8601String(),
  };

  const testUserId = 'user-123-abc';
  const testScriptureId = '123e4567-e89b-12d3-a456-426614174000';

  setUp(() {
    mockDataSource = MockScriptureDataSource();
    repository = SupabaseScriptureRepository(mockDataSource);
  });

  group('getRandomScripture', () {
    test(
      'should return Right(List<Scripture>) when datasource succeeds',
      () async {
        // Arrange
        when(
          () => mockDataSource.getRandomScripture(any()),
        ).thenAnswer((_) async => [sampleScriptureJson]);

        // Act
        final result = await repository.getRandomScripture(1);

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Expected Right but got Left'), (
          scriptures,
        ) {
          expect(scriptures.length, 1);
          expect(scriptures.first.book, 'John');
          expect(scriptures.first.reference, 'John 3:16');
          expect(scriptures.first.isPremium, false);
        });
        verify(() => mockDataSource.getRandomScripture(1)).called(1);
      },
    );

    test('should return exactly requested count of scriptures', () async {
      // Arrange
      when(() => mockDataSource.getRandomScripture(any())).thenAnswer(
        (_) async => [
          sampleScriptureJson,
          {...sampleScriptureJson, 'id': 'scripture-2'},
          {...sampleScriptureJson, 'id': 'scripture-3'},
        ],
      );

      // Act
      final result = await repository.getRandomScripture(3);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (scriptures) => expect(scriptures.length, 3),
      );
    });

    test(
      'should return Left(ServerFailure) when datasource throws exception',
      () async {
        // Arrange
        when(
          () => mockDataSource.getRandomScripture(any()),
        ).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getRandomScripture(1);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Database error'));
        }, (scriptures) => fail('Expected Left but got Right'));
      },
    );

    test(
      'should return Right with empty list when no scriptures available',
      () async {
        // Arrange
        when(
          () => mockDataSource.getRandomScripture(any()),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getRandomScripture(1);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (scriptures) => expect(scriptures, isEmpty),
        );
      },
    );
  });

  group('getDailyScriptures', () {
    test(
      'should return Right(List<Scripture>) when datasource succeeds',
      () async {
        // Arrange
        when(
          () => mockDataSource.getDailyScriptures(
            userId: any(named: 'userId'),
            count: any(named: 'count'),
          ),
        ).thenAnswer((_) async => [sampleScriptureJson]);

        // Act
        final result = await repository.getDailyScriptures(
          userId: testUserId,
          count: 3,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Expected Right but got Left'), (
          scriptures,
        ) {
          expect(scriptures.length, 1);
          expect(scriptures.first.book, 'John');
        });
        verify(
          () => mockDataSource.getDailyScriptures(userId: testUserId, count: 3),
        ).called(1);
      },
    );

    test(
      'should return up to requested count from getDailyScriptures',
      () async {
        // Arrange
        when(
          () => mockDataSource.getDailyScriptures(
            userId: any(named: 'userId'),
            count: any(named: 'count'),
          ),
        ).thenAnswer(
          (_) async => [
            sampleScriptureJson,
            {...sampleScriptureJson, 'id': 'scripture-2'},
            {...sampleScriptureJson, 'id': 'scripture-3'},
          ],
        );

        // Act
        final result = await repository.getDailyScriptures(
          userId: testUserId,
          count: 3,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (scriptures) => expect(scriptures.length, 3),
        );
      },
    );

    test(
      'should return Left(ServerFailure) when getDailyScriptures throws exception',
      () async {
        // Arrange
        when(
          () => mockDataSource.getDailyScriptures(
            userId: any(named: 'userId'),
            count: any(named: 'count'),
          ),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await repository.getDailyScriptures(
          userId: testUserId,
          count: 3,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (scriptures) => fail('Expected Left but got Right'),
        );
      },
    );

    test('should handle user with no history returning empty list', () async {
      // Arrange
      when(
        () => mockDataSource.getDailyScriptures(
          userId: any(named: 'userId'),
          count: any(named: 'count'),
        ),
      ).thenAnswer((_) async => []);

      // Act
      final result = await repository.getDailyScriptures(
        userId: testUserId,
        count: 3,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (scriptures) => expect(scriptures, isEmpty),
      );
    });
  });

  group('getPremiumScriptures', () {
    test(
      'should return only premium scriptures when datasource succeeds',
      () async {
        // Arrange
        when(
          () => mockDataSource.getPremiumScriptures(
            userId: any(named: 'userId'),
            count: any(named: 'count'),
          ),
        ).thenAnswer((_) async => [samplePremiumScriptureJson]);

        // Act
        final result = await repository.getPremiumScriptures(
          userId: testUserId,
          count: 3,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Expected Right but got Left'), (
          scriptures,
        ) {
          expect(scriptures.length, 1);
          expect(scriptures.first.isPremium, true);
          expect(scriptures.first.book, 'Psalms');
        });
        verify(
          () =>
              mockDataSource.getPremiumScriptures(userId: testUserId, count: 3),
        ).called(1);
      },
    );

    test(
      'should return up to requested count from getPremiumScriptures',
      () async {
        // Arrange
        when(
          () => mockDataSource.getPremiumScriptures(
            userId: any(named: 'userId'),
            count: any(named: 'count'),
          ),
        ).thenAnswer(
          (_) async => [
            samplePremiumScriptureJson,
            {...samplePremiumScriptureJson, 'id': 'premium-2'},
            {...samplePremiumScriptureJson, 'id': 'premium-3'},
          ],
        );

        // Act
        final result = await repository.getPremiumScriptures(
          userId: testUserId,
          count: 3,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (scriptures) => expect(scriptures.length, 3),
        );
      },
    );

    test(
      'should return Left(ServerFailure) when getPremiumScriptures throws exception',
      () async {
        // Arrange
        when(
          () => mockDataSource.getPremiumScriptures(
            userId: any(named: 'userId'),
            count: any(named: 'count'),
          ),
        ).thenThrow(Exception('Premium access denied'));

        // Act
        final result = await repository.getPremiumScriptures(
          userId: testUserId,
          count: 3,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (scriptures) => fail('Expected Left but got Right'),
        );
      },
    );
  });

  group('recordScriptureView', () {
    test('should return Right(void) when recording succeeds', () async {
      // Arrange
      when(
        () => mockDataSource.recordScriptureView(
          userId: any(named: 'userId'),
          scriptureId: any(named: 'scriptureId'),
        ),
      ).thenAnswer((_) async => {});

      // Act
      final result = await repository.recordScriptureView(
        userId: testUserId,
        scriptureId: testScriptureId,
      );

      // Assert
      expect(result.isRight(), true);
      verify(
        () => mockDataSource.recordScriptureView(
          userId: testUserId,
          scriptureId: testScriptureId,
        ),
      ).called(1);
    });

    test('should handle duplicate view gracefully (same day)', () async {
      // Arrange - datasource should handle ON CONFLICT DO NOTHING
      when(
        () => mockDataSource.recordScriptureView(
          userId: any(named: 'userId'),
          scriptureId: any(named: 'scriptureId'),
        ),
      ).thenAnswer((_) async => {});

      // Act
      final result1 = await repository.recordScriptureView(
        userId: testUserId,
        scriptureId: testScriptureId,
      );
      final result2 = await repository.recordScriptureView(
        userId: testUserId,
        scriptureId: testScriptureId,
      );

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);
    });

    test(
      'should return Left(ServerFailure) when recordScriptureView throws exception',
      () async {
        // Arrange
        when(
          () => mockDataSource.recordScriptureView(
            userId: any(named: 'userId'),
            scriptureId: any(named: 'scriptureId'),
          ),
        ).thenThrow(Exception('Insert failed'));

        // Act
        final result = await repository.recordScriptureView(
          userId: testUserId,
          scriptureId: testScriptureId,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      },
    );
  });

  group('getScriptureHistory', () {
    test(
      'should return scriptures for given date when history exists',
      () async {
        // Arrange
        when(
          () => mockDataSource.getScriptureHistory(
            userId: any(named: 'userId'),
            date: any(named: 'date'),
          ),
        ).thenAnswer((_) async => [sampleScriptureJson]);

        // Act
        final result = await repository.getScriptureHistory(
          userId: testUserId,
          date: testDateTime,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Expected Right but got Left'), (
          scriptures,
        ) {
          expect(scriptures.length, 1);
          expect(scriptures.first.book, 'John');
        });
        verify(
          () => mockDataSource.getScriptureHistory(
            userId: testUserId,
            date: testDateTime,
          ),
        ).called(1);
      },
    );

    test('should return empty list when no history exists for date', () async {
      // Arrange
      when(
        () => mockDataSource.getScriptureHistory(
          userId: any(named: 'userId'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async => []);

      // Act
      final result = await repository.getScriptureHistory(
        userId: testUserId,
        date: testDateTime,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (scriptures) => expect(scriptures, isEmpty),
      );
    });

    test(
      'should return Left(ServerFailure) when getScriptureHistory throws exception',
      () async {
        // Arrange
        when(
          () => mockDataSource.getScriptureHistory(
            userId: any(named: 'userId'),
            date: any(named: 'date'),
          ),
        ).thenThrow(Exception('Query failed'));

        // Act
        final result = await repository.getScriptureHistory(
          userId: testUserId,
          date: testDateTime,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (scriptures) => fail('Expected Left but got Right'),
        );
      },
    );
  });
}
