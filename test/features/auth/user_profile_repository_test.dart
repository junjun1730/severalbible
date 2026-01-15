import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:severalbible/features/auth/data/user_profile_data_source.dart';
import 'package:severalbible/features/auth/data/user_profile_repository.dart';
import 'package:severalbible/features/auth/domain/user_tier.dart';

// Mock
class MockUserProfileDataSource extends Mock implements UserProfileDataSource {}

void main() {
  late MockUserProfileDataSource mockDataSource;
  late UserProfileRepository repository;

  setUp(() {
    mockDataSource = MockUserProfileDataSource();
    repository = UserProfileRepository(mockDataSource);
  });

  group('UserProfileRepository', () {
    group('getUserProfile', () {
      test('returns UserProfile when found', () async {
        final profileData = {
          'id': 'test-user-id',
          'tier': 'member',
          'created_at': '2026-01-14T10:00:00Z',
          'updated_at': '2026-01-14T10:00:00Z',
        };

        when(() => mockDataSource.getProfile('test-user-id'))
            .thenAnswer((_) async => profileData);

        final result = await repository.getUserProfile('test-user-id');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not be a failure'),
          (profile) {
            expect(profile.id, 'test-user-id');
            expect(profile.tier, UserTier.member);
          },
        );
        verify(() => mockDataSource.getProfile('test-user-id')).called(1);
      });

      test('returns failure when profile not found', () async {
        when(() => mockDataSource.getProfile('nonexistent-id'))
            .thenAnswer((_) async => null);

        final result = await repository.getUserProfile('nonexistent-id');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, contains('not found')),
          (profile) => fail('Should not return profile'),
        );
      });

      test('returns failure on PostgrestException', () async {
        when(() => mockDataSource.getProfile('test-user-id'))
            .thenThrow(PostgrestException(message: 'Database error'));

        final result = await repository.getUserProfile('test-user-id');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, contains('Database error')),
          (profile) => fail('Should not return profile'),
        );
      });

      test('returns failure on unexpected error', () async {
        when(() => mockDataSource.getProfile('test-user-id'))
            .thenThrow(Exception('Unexpected'));

        final result = await repository.getUserProfile('test-user-id');

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, contains('Unexpected error')),
          (profile) => fail('Should not return profile'),
        );
      });
    });

    group('getUserTier', () {
      test('returns UserTier when profile exists', () async {
        final profileData = {
          'id': 'test-user-id',
          'tier': 'premium',
          'created_at': '2026-01-14T10:00:00Z',
          'updated_at': '2026-01-14T10:00:00Z',
        };

        when(() => mockDataSource.getProfile('test-user-id'))
            .thenAnswer((_) async => profileData);

        final result = await repository.getUserTier('test-user-id');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not be a failure'),
          (tier) => expect(tier, UserTier.premium),
        );
      });

      test('returns guest tier when profile not found', () async {
        when(() => mockDataSource.getProfile('nonexistent-id'))
            .thenAnswer((_) async => null);

        final result = await repository.getUserTier('nonexistent-id');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not be a failure'),
          (tier) => expect(tier, UserTier.guest),
        );
      });

      test('returns member tier for member user', () async {
        final profileData = {
          'id': 'member-user',
          'tier': 'member',
          'created_at': '2026-01-14T10:00:00Z',
          'updated_at': '2026-01-14T10:00:00Z',
        };

        when(() => mockDataSource.getProfile('member-user'))
            .thenAnswer((_) async => profileData);

        final result = await repository.getUserTier('member-user');

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not be a failure'),
          (tier) => expect(tier, UserTier.member),
        );
      });

      test('returns failure on database error', () async {
        when(() => mockDataSource.getProfile('test-user-id'))
            .thenThrow(PostgrestException(message: 'Connection failed'));

        final result = await repository.getUserTier('test-user-id');

        expect(result.isLeft(), true);
      });
    });

    group('updateUserTier', () {
      test('updates tier successfully', () async {
        final updatedData = {
          'id': 'test-user-id',
          'tier': 'premium',
          'created_at': '2026-01-14T10:00:00Z',
          'updated_at': '2026-01-14T12:00:00Z',
        };

        when(() => mockDataSource.updateTier('test-user-id', 'premium'))
            .thenAnswer((_) async => updatedData);

        final result = await repository.updateUserTier(
          userId: 'test-user-id',
          tier: UserTier.premium,
        );

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not be a failure'),
          (profile) {
            expect(profile.id, 'test-user-id');
            expect(profile.tier, UserTier.premium);
          },
        );
        verify(() => mockDataSource.updateTier('test-user-id', 'premium'))
            .called(1);
      });

      test('returns failure on update error', () async {
        when(() => mockDataSource.updateTier('test-user-id', 'premium'))
            .thenThrow(PostgrestException(message: 'Update failed'));

        final result = await repository.updateUserTier(
          userId: 'test-user-id',
          tier: UserTier.premium,
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, contains('Database error')),
          (profile) => fail('Should not return profile'),
        );
      });
    });

    group('createUserProfile', () {
      test('creates profile with default member tier', () async {
        final createdData = {
          'id': 'new-user-id',
          'tier': 'member',
          'created_at': '2026-01-14T10:00:00Z',
          'updated_at': '2026-01-14T10:00:00Z',
        };

        when(() => mockDataSource.createProfile('new-user-id', 'member'))
            .thenAnswer((_) async => createdData);

        final result = await repository.createUserProfile(
          userId: 'new-user-id',
        );

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not be a failure'),
          (profile) {
            expect(profile.id, 'new-user-id');
            expect(profile.tier, UserTier.member);
          },
        );
      });

      test('creates profile with specified tier', () async {
        final createdData = {
          'id': 'premium-user-id',
          'tier': 'premium',
          'created_at': '2026-01-14T10:00:00Z',
          'updated_at': '2026-01-14T10:00:00Z',
        };

        when(() => mockDataSource.createProfile('premium-user-id', 'premium'))
            .thenAnswer((_) async => createdData);

        final result = await repository.createUserProfile(
          userId: 'premium-user-id',
          tier: UserTier.premium,
        );

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not be a failure'),
          (profile) => expect(profile.tier, UserTier.premium),
        );
      });

      test('returns failure on create error', () async {
        when(() => mockDataSource.createProfile('new-user-id', 'member'))
            .thenThrow(PostgrestException(message: 'Duplicate key'));

        final result = await repository.createUserProfile(
          userId: 'new-user-id',
        );

        expect(result.isLeft(), true);
      });
    });
  });
}
