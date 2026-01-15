import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:severalbible/features/auth/presentation/screens/splash_screen.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';
import 'package:severalbible/features/auth/data/auth_repository.dart';
import 'package:severalbible/core/services/supabase_service.dart';

// Mocks
class MockAuthRepository extends Mock implements AuthRepository {}

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSupabaseService mockSupabaseService;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSupabaseService = MockSupabaseService();
  });

  Widget createTestWidget({required bool isLoggedIn}) {
    when(() => mockAuthRepository.isLoggedIn).thenReturn(isLoggedIn);

    return ProviderScope(
      overrides: [
        supabaseServiceProvider.overrideWithValue(mockSupabaseService),
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        isLoggedInProvider.overrideWith((ref) => isLoggedIn),
      ],
      child: const MaterialApp(
        home: SplashScreen(autoNavigate: false),
      ),
    );
  }

  group('SplashScreen', () {
    testWidgets('shows loading indicator', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoggedIn: false));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows app title', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoggedIn: false));

      expect(find.text('One Message'), findsOneWidget);
    });

    testWidgets('shows welcome message with grace keyword', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoggedIn: false));

      expect(find.textContaining('grace'), findsOneWidget);
    });

    testWidgets('shows app icon', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoggedIn: false));

      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    });

    testWidgets('has gradient background', (tester) async {
      await tester.pumpWidget(createTestWidget(isLoggedIn: false));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Scaffold),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.decoration, isNotNull);
    });
  });
}
