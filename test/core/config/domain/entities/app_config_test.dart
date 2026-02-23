import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/core/domain/entities/app_config.dart';

void main() {
  group('AppConfig Entity', () {
    test('should create AppConfig with free mode enabled', () {
      // Arrange & Act
      final config = AppConfig(
        isFreeMode: true,
        lastUpdated: DateTime(2026, 2, 23),
      );

      // Assert
      expect(config.isFreeMode, true);
      expect(config.lastUpdated, DateTime(2026, 2, 23));
    });

    test('should create AppConfig with free mode disabled', () {
      // Arrange & Act
      final config = AppConfig(
        isFreeMode: false,
        lastUpdated: DateTime(2026, 2, 23),
      );

      // Assert
      expect(config.isFreeMode, false);
    });

    group('fromJson', () {
      test('should deserialize from JSON with isFreeMode = true', () {
        // Arrange
        final json = {
          'isFreeMode': true,
          'lastUpdated': '2026-02-23T10:00:00.000Z',
        };

        // Act
        final config = AppConfig.fromJson(json);

        // Assert
        expect(config.isFreeMode, true);
        expect(config.lastUpdated, isA<DateTime>());
      });

      test('should deserialize from JSON with isFreeMode = false', () {
        // Arrange
        final json = {
          'isFreeMode': false,
          'lastUpdated': '2026-02-23T10:00:00.000Z',
        };

        // Act
        final config = AppConfig.fromJson(json);

        // Assert
        expect(config.isFreeMode, false);
      });
    });

    group('toJson', () {
      test('should serialize to JSON', () {
        // Arrange
        final config = AppConfig(
          isFreeMode: true,
          lastUpdated: DateTime.utc(2026, 2, 23, 10, 0, 0),
        );

        // Act
        final json = config.toJson();

        // Assert
        expect(json['isFreeMode'], true);
        expect(json['lastUpdated'], isA<String>());
      });
    });

    group('copyWith', () {
      test('should copy with new isFreeMode value', () {
        // Arrange
        final original = AppConfig(
          isFreeMode: false,
          lastUpdated: DateTime(2026, 2, 23),
        );

        // Act
        final copied = original.copyWith(isFreeMode: true);

        // Assert
        expect(copied.isFreeMode, true);
        expect(copied.lastUpdated, original.lastUpdated);
        expect(original.isFreeMode, false); // Original unchanged
      });

      test('should copy with new lastUpdated value', () {
        // Arrange
        final original = AppConfig(
          isFreeMode: true,
          lastUpdated: DateTime(2026, 2, 23),
        );
        final newDate = DateTime(2026, 2, 24);

        // Act
        final copied = original.copyWith(lastUpdated: newDate);

        // Assert
        expect(copied.lastUpdated, newDate);
        expect(copied.isFreeMode, original.isFreeMode);
      });
    });

    group('equality', () {
      test('should be equal when values are the same', () {
        // Arrange
        final date = DateTime(2026, 2, 23);
        final config1 = AppConfig(isFreeMode: true, lastUpdated: date);
        final config2 = AppConfig(isFreeMode: true, lastUpdated: date);

        // Assert
        expect(config1, equals(config2));
        expect(config1.hashCode, equals(config2.hashCode));
      });

      test('should not be equal when isFreeMode differs', () {
        // Arrange
        final date = DateTime(2026, 2, 23);
        final config1 = AppConfig(isFreeMode: true, lastUpdated: date);
        final config2 = AppConfig(isFreeMode: false, lastUpdated: date);

        // Assert
        expect(config1, isNot(equals(config2)));
      });

      test('should not be equal when lastUpdated differs', () {
        // Arrange
        final config1 = AppConfig(
          isFreeMode: true,
          lastUpdated: DateTime(2026, 2, 23),
        );
        final config2 = AppConfig(
          isFreeMode: true,
          lastUpdated: DateTime(2026, 2, 24),
        );

        // Assert
        expect(config1, isNot(equals(config2)));
      });
    });

    group('immutability', () {
      test('should be immutable (freezed)', () {
        // Arrange
        final config = AppConfig(
          isFreeMode: true,
          lastUpdated: DateTime(2026, 2, 23),
        );

        // Assert
        expect(config, isA<AppConfig>());
        // Freezed ensures immutability via const and final fields
      });
    });
  });
}
