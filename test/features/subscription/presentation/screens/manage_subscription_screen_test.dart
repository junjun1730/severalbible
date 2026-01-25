import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:severalbible/features/subscription/domain/entities/subscription.dart';
import 'package:severalbible/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:severalbible/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:severalbible/features/subscription/presentation/screens/manage_subscription_screen.dart';
import 'package:severalbible/core/errors/failures.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';

class MockUser extends Mock implements User {
  @override
  final String id;

  MockUser(this.id);
}

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {
  @override
  Future<Either<Failure, void>> cancelSubscription({
    required String userId,
    String? reason,
  }) {
    return super.noSuchMethod(
      Invocation.method(#cancelSubscription, [], {
        #userId: userId,
        #reason: reason,
      }),
      returnValue: Future.value(const Right(null)),
      returnValueForMissingStub: Future.value(const Right(null)),
    );
  }
}

void main() {
  late MockSubscriptionRepository mockSubscriptionRepository;

  setUp(() {
    mockSubscriptionRepository = MockSubscriptionRepository();
  });

  Widget createSubject(Subscription? subscription, {String? expirationText}) {
    final mockUser = MockUser('test_user_id');
    return ProviderScope(
      overrides: [
        subscriptionRepositoryProvider.overrideWith(
          (ref) => mockSubscriptionRepository,
        ),
        subscriptionStatusProvider.overrideWith(
          (ref) => Future.value(subscription),
        ),
        subscriptionExpirationProvider.overrideWith((ref) => expirationText),
        currentUserProvider.overrideWith((ref) => mockUser),
      ],
      child: const MaterialApp(home: ManageSubscriptionScreen()),
    );
  }

  group('ManageSubscriptionScreen', () {
    testWidgets('shows current subscription status', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      final activeSubscription = Subscription(
        id: 'sub_123',
        userId: 'test_user',
        productId: 'monthly_premium',
        platform: SubscriptionPlatform.ios,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now().subtract(const Duration(days: 10)),
        expiresAt: DateTime.now().add(const Duration(days: 20)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createSubject(activeSubscription));
      await tester.pumpAndSettle();

      expect(find.text('Manage Subscription'), findsOneWidget);
      expect(find.text('Current Plan'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
    });

    testWidgets('shows expiration date', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      final activeSubscription = Subscription(
        id: 'sub_123',
        userId: 'test_user',
        productId: 'annual_premium',
        platform: SubscriptionPlatform.ios,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now().subtract(const Duration(days: 10)),
        expiresAt: DateTime.now().add(const Duration(days: 355)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createSubject(
          activeSubscription,
          expirationText: 'Renews on 2027-01-18',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Renews on 2027-01-18'), findsOneWidget);
    });

    testWidgets('shows cancel subscription button when auto_renew is true', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      final activeSubscription = Subscription(
        id: 'sub_123',
        userId: 'test_user',
        productId: 'monthly_premium',
        platform: SubscriptionPlatform.ios,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now().subtract(const Duration(days: 10)),
        expiresAt: DateTime.now().add(const Duration(days: 20)),
        autoRenew: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createSubject(activeSubscription));
      await tester.pumpAndSettle();

      expect(find.text('Cancel Subscription'), findsOneWidget);
    });

    testWidgets('shows product name based on productId', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      final annualSubscription = Subscription(
        id: 'sub_123',
        userId: 'test_user',
        productId: 'annual_premium',
        platform: SubscriptionPlatform.ios,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 365)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createSubject(annualSubscription));
      await tester.pumpAndSettle();

      expect(find.text('Annual Premium'), findsOneWidget);
    });

    testWidgets('shows monthly plan for monthly subscription', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      final monthlySubscription = Subscription(
        id: 'sub_123',
        userId: 'test_user',
        productId: 'monthly_premium',
        platform: SubscriptionPlatform.ios,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createSubject(monthlySubscription));
      await tester.pumpAndSettle();

      expect(find.text('Monthly Premium'), findsOneWidget);
    });

    testWidgets(
      'shows no active subscription message when subscription is null',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(createSubject(null));
        await tester.pumpAndSettle();

        expect(find.text('No active subscription'), findsOneWidget);
      },
    );

    testWidgets(
      'shows cancel confirmation dialog when cancel button is tapped',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);

        final activeSubscription = Subscription(
          id: 'sub_123',
          userId: 'test_user',
          productId: 'monthly_premium',
          platform: SubscriptionPlatform.ios,
          status: SubscriptionStatus.active,
          startedAt: DateTime.now().subtract(const Duration(days: 10)),
          expiresAt: DateTime.now().add(const Duration(days: 20)),
          autoRenew: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(createSubject(activeSubscription));
        await tester.pumpAndSettle();

        // Tap cancel button
        await tester.tap(find.text('Cancel Subscription'));
        await tester.pumpAndSettle();

        // Verify confirmation dialog is shown
        expect(find.text('Cancel Subscription?'), findsOneWidget);
        expect(find.text('Keep Subscription'), findsOneWidget);
      },
    );

    testWidgets('shows info text about cancellation policy', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      final activeSubscription = Subscription(
        id: 'sub_123',
        userId: 'test_user',
        productId: 'monthly_premium',
        platform: SubscriptionPlatform.ios,
        status: SubscriptionStatus.active,
        startedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 20)),
        autoRenew: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(createSubject(activeSubscription));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('you will still have access to premium features'),
        findsOneWidget,
      );
    });
  });
}
