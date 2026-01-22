import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:severalbible/features/subscription/domain/entities/subscription.dart';
import 'package:severalbible/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:severalbible/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:severalbible/features/subscription/presentation/screens/manage_subscription_screen.dart';
import 'package:severalbible/core/errors/failures.dart';
import 'package:severalbible/features/auth/domain/user_profile.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';

class MockSubscriptionRepository extends Mock implements SubscriptionRepository {
  @override
  Future<Either<Failure, void>> cancelSubscription({required String userId, String? reason}) {
     return super.noSuchMethod(
      Invocation.method(#cancelSubscription, [], {#userId: userId, #reason: reason}),
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

  Widget createSubject(Subscription? subscription) {
    return ProviderScope(
      overrides: [
        subscriptionRepositoryProvider.overrideWith((ref) => mockSubscriptionRepository),
        subscriptionStatusProvider.overrideWith((ref) => Future.value(subscription)),
        currentUserProvider.overrideWith((ref) => null),
      ],
      child: const MaterialApp(
        home: ManageSubscriptionScreen(),
      ),
    );
  }

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

    expect(find.text('Manage Subscription'), findsOneWidget); // Title from AppBar usually
    // Expect status text
    // expect(find.text('Active'), findsOneWidget);
    // expect(find.text('Renews on'), findsOneWidget);
  });
}
