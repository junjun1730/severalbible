import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:severalbible/features/subscription/domain/entities/subscription.dart';
import 'package:severalbible/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:severalbible/features/subscription/presentation/screens/premium_landing_screen.dart';


void main() {
  late MockPurchaseController mockPurchaseController;
  late MockRestorePurchaseController mockRestorePurchaseController;

  setUp(() {
    mockPurchaseController = MockPurchaseController();
    mockRestorePurchaseController = MockRestorePurchaseController();

    // The physical size adjustment needs to be done within a `testWidgets` callback
    // or using `TestWidgetsFlutterBinding.ensureInitialized().window` for global setup.
    // For `setUp` to access `tester`, it would need to be `setUpAll` or passed as an argument.
    // Given the instruction, I will remove the stubs and keep the size adjustment in the tests.
    // If the intention was to move the size adjustment to setUp, the instruction was incomplete.
    // I will follow the instruction literally for the setUp block.
  });

  Widget createSubject() {
    return ProviderScope(
      overrides: [
        purchaseControllerProvider.overrideWith((ref) => mockPurchaseController),
        restorePurchaseControllerProvider.overrideWith((ref) => mockRestorePurchaseController),
        availableProductsProvider.overrideWith((ref) => Future.value([
              SubscriptionProduct(
                id: 'monthly_premium',
                name: 'Monthly Premium',
                priceKrw: 9900,
                isActive: true,
                createdAt: DateTime.now(),
              ),
              SubscriptionProduct(
                id: 'annual_premium',
                name: 'Annual Premium',
                priceKrw: 99000,
                isActive: true,
                createdAt: DateTime.now(),
              ),
            ])),
      ],
      child: const MaterialApp(
        home: PremiumLandingScreen(),
      ),
    );
  }

  testWidgets('renders premium benefits list', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();
    
    expect(find.text('Unlock Unlimited Grace'), findsOneWidget);
    expect(find.text('Access all premium scriptures'), findsOneWidget);
  });

  testWidgets('renders product cards', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.text('Monthly Premium'), findsOneWidget);
    expect(find.text('Annual Premium'), findsOneWidget);
  });

  testWidgets('shows pricing with discount badge for annual', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    // Check pricing is displayed
    expect(find.text('₩9900'), findsOneWidget);
    expect(find.text('₩99000'), findsOneWidget);

    // Check discount badge for annual
    expect(find.text('Best Value'), findsOneWidget);
  });

  testWidgets('shows loading state during purchase', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    final loadingController = MockPurchaseControllerLoading();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        purchaseControllerProvider.overrideWith((ref) => loadingController),
        restorePurchaseControllerProvider.overrideWith((ref) => mockRestorePurchaseController),
        availableProductsProvider.overrideWith((ref) => Future.value([
          SubscriptionProduct(
            id: 'monthly_premium',
            name: 'Monthly Premium',
            priceKrw: 9900,
            isActive: true,
            createdAt: DateTime.now(),
          ),
        ])),
      ],
      child: const MaterialApp(
        home: PremiumLandingScreen(),
      ),
    ));
    // Pump multiple times to allow products to load and UI to update
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // Should show 'Processing...' text when controller is in loading state
    // The PurchaseButton shows this when isLoading is true
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('shows restore purchases button', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.text('Restore Purchases'), findsOneWidget);
    expect(find.byType(TextButton), findsWidgets);
  });

  testWidgets('shows terms and privacy links', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.text('Terms of Service'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
  });

  testWidgets('shows loading indicator while products are loading', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Use a Completer that never completes to simulate loading state
    final completer = Completer<List<SubscriptionProduct>>();

    await tester.pumpWidget(ProviderScope(
      overrides: [
        purchaseControllerProvider.overrideWith((ref) => mockPurchaseController),
        restorePurchaseControllerProvider.overrideWith((ref) => mockRestorePurchaseController),
        availableProductsProvider.overrideWith((ref) => completer.future),
      ],
      child: const MaterialApp(
        home: PremiumLandingScreen(),
      ),
    ));

    // Just pump once without settling to check initial loading state
    await tester.pump();

    // Should show loading indicator initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

class MockPurchaseControllerLoading extends StateNotifier<AsyncValue<PurchaseState>> implements PurchaseController {
  MockPurchaseControllerLoading() : super(const AsyncValue.loading());

  @override
  Future<void> initialize() async {}

  @override
  Future<void> purchaseProduct(String productId) async {}

  @override
  void reset() {}
}

class MockPurchaseController extends StateNotifier<AsyncValue<PurchaseState>> implements PurchaseController {
  MockPurchaseController() : super(const AsyncValue.data(PurchaseState.idle));
  
  @override
  Future<void> initialize() async {}
  
  @override
  Future<void> purchaseProduct(String productId) async {}

  @override
  void reset() {}
}

class MockRestorePurchaseController extends StateNotifier<AsyncValue<void>> implements RestorePurchaseController {
  MockRestorePurchaseController() : super(const AsyncValue.data(null));
  
  @override
  Future<void> restorePurchases() async {}
}
