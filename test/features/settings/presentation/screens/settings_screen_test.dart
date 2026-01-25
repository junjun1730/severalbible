import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:severalbible/features/subscription/domain/entities/subscription.dart';
import 'package:severalbible/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:severalbible/features/settings/presentation/screens/settings_screen.dart';
import 'package:severalbible/features/auth/domain/user_tier.dart';
import 'package:severalbible/features/auth/providers/auth_providers.dart';
import 'package:severalbible/core/router/app_router.dart';

void main() {
  Widget createSubject({
    UserTier tier = UserTier.member,
    Subscription? subscription,
    GoRouter? router,
  }) {
    final testRouter =
        router ??
        GoRouter(
          initialLocation: AppRoutes.settings,
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: AppRoutes.premium,
              builder: (context, state) =>
                  const Scaffold(body: Text('Premium Landing')),
            ),
            GoRoute(
              path: AppRoutes.manageSubscription,
              builder: (context, state) =>
                  const Scaffold(body: Text('Manage Subscription Page')),
            ),
            GoRoute(
              path: AppRoutes.login,
              builder: (context, state) => const Scaffold(body: Text('Login')),
            ),
          ],
        );

    return ProviderScope(
      overrides: [
        currentUserTierProvider.overrideWith((ref) => Future.value(tier)),
        subscriptionStatusProvider.overrideWith(
          (ref) => Future.value(subscription),
        ),
        hasPremiumProvider.overrideWith(
          (ref) => Future.value(subscription != null),
        ),
      ],
      child: MaterialApp.router(routerConfig: testRouter),
    );
  }

  group('SettingsScreen', () {
    testWidgets('renders settings title', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows "Upgrade to Premium" for member tier', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject(tier: UserTier.member));
      await tester.pumpAndSettle();

      expect(find.text('Upgrade to Premium'), findsOneWidget);
    });

    testWidgets('shows "Upgrade to Premium" for guest tier', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject(tier: UserTier.guest));
      await tester.pumpAndSettle();

      expect(find.text('Upgrade to Premium'), findsOneWidget);
    });

    testWidgets('shows "Manage Subscription" for premium tier', (tester) async {
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

      await tester.pumpWidget(
        createSubject(tier: UserTier.premium, subscription: activeSubscription),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage Subscription'), findsOneWidget);
      expect(find.text('Upgrade to Premium'), findsNothing);
    });

    testWidgets('tapping "Upgrade to Premium" navigates to premium landing', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject(tier: UserTier.member));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Upgrade to Premium'));
      await tester.pumpAndSettle();

      expect(find.text('Premium Landing'), findsOneWidget);
    });

    testWidgets(
      'tapping "Manage Subscription" navigates to manage subscription screen',
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
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          createSubject(
            tier: UserTier.premium,
            subscription: activeSubscription,
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Manage Subscription'));
        await tester.pumpAndSettle();

        expect(find.text('Manage Subscription Page'), findsOneWidget);
      },
    );

    testWidgets('shows logout option', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('Sign Out'), findsOneWidget);
    });
  });
}
