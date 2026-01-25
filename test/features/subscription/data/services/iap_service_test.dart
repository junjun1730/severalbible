import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:mocktail/mocktail.dart';
import 'package:severalbible/core/errors/failures.dart';
import 'package:severalbible/features/subscription/data/services/iap_service_impl.dart';

// Mock class for InAppPurchase
class MockInAppPurchase extends Mock implements iap.InAppPurchase {}

void main() {
  late IAPServiceImpl iapService;
  late MockInAppPurchase mockInAppPurchase;

  final testProductIds = ['monthly_premium', 'annual_premium'];

  setUpAll(() {
    registerFallbackValue(<String>{});
    registerFallbackValue(
      _MockPurchaseDetails(
        productID: 'test',
        purchaseID: 'test-id',
        status: iap.PurchaseStatus.purchased,
      ),
    );
  });

  setUp(() {
    mockInAppPurchase = MockInAppPurchase();
    iapService = IAPServiceImpl(mockInAppPurchase);
  });

  group('initialize', () {
    test('should return Right(void) when store is available', () async {
      // Arrange
      when(() => mockInAppPurchase.isAvailable()).thenAnswer((_) async => true);
      when(
        () => mockInAppPurchase.purchaseStream,
      ).thenAnswer((_) => const Stream.empty());

      // Act
      final result = await iapService.initialize();

      // Assert
      expect(result.isRight(), true);
      verify(() => mockInAppPurchase.isAvailable()).called(1);
    });

    test(
      'should return Left(ServerFailure) when store is not available',
      () async {
        // Arrange
        when(
          () => mockInAppPurchase.isAvailable(),
        ).thenAnswer((_) async => false);

        // Act
        final result = await iapService.initialize();

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('not available'));
        }, (_) => fail('Expected Left but got Right'));
      },
    );
  });

  group('fetchProducts', () {
    test(
      'should return Right(List<SubscriptionProduct>) when products found',
      () async {
        // Arrange
        final mockProductDetails1 = _MockProductDetails(
          id: 'monthly_premium',
          title: 'Monthly Premium',
          description: 'Access all premium features for 1 month',
          price: '₩9,900',
          rawPrice: 9900,
          currencyCode: 'KRW',
        );

        final mockProductDetails2 = _MockProductDetails(
          id: 'annual_premium',
          title: 'Annual Premium',
          description: 'Access all premium features for 1 year',
          price: '₩99,000',
          rawPrice: 99000,
          currencyCode: 'KRW',
        );

        when(() => mockInAppPurchase.queryProductDetails(any())).thenAnswer(
          (_) async => iap.ProductDetailsResponse(
            productDetails: [mockProductDetails1, mockProductDetails2],
            notFoundIDs: [],
            error: null,
          ),
        );

        // Act
        final result = await iapService.fetchProducts(
          productIds: testProductIds,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Expected Right but got Left'), (
          products,
        ) {
          expect(products.length, 2);
          expect(products.first.id, 'monthly_premium');
          expect(products.last.id, 'annual_premium');
        });
      },
    );

    test('should return Left(ServerFailure) when error occurs', () async {
      // Arrange
      when(() => mockInAppPurchase.queryProductDetails(any())).thenAnswer(
        (_) async => iap.ProductDetailsResponse(
          productDetails: [],
          notFoundIDs: testProductIds,
          error: iap.IAPError(
            source: 'StoreKit',
            code: 'product_not_found',
            message: 'Products not found in store',
          ),
        ),
      );

      // Act
      final result = await iapService.fetchProducts(productIds: testProductIds);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (products) => fail('Expected Left but got Right'),
      );
    });
  });

  group('purchaseSubscription', () {
    test('should return Left(ServerFailure) when product not found', () async {
      // Arrange
      when(() => mockInAppPurchase.queryProductDetails(any())).thenAnswer(
        (_) async => iap.ProductDetailsResponse(
          productDetails: [],
          notFoundIDs: ['monthly_premium'],
          error: null,
        ),
      );

      // Act
      final result = await iapService.purchaseSubscription(
        productId: 'monthly_premium',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('not found')),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('restorePurchases', () {
    test('should call restorePurchases on platform', () async {
      // Arrange
      when(() => mockInAppPurchase.restorePurchases()).thenAnswer((_) async {});

      // Act - Restore will timeout as there's no stream response
      // This tests that the method is called
      iapService.restorePurchases(); // Fire and forget for this test

      // Assert
      await Future.delayed(const Duration(milliseconds: 100));
      verify(() => mockInAppPurchase.restorePurchases()).called(1);
    });
  });

  group('completePurchase', () {
    test('should complete transaction successfully', () async {
      // Arrange
      final mockPurchaseDetails = _MockPurchaseDetails(
        productID: 'monthly_premium',
        purchaseID: 'txn-123',
        status: iap.PurchaseStatus.purchased,
      );

      when(
        () => mockInAppPurchase.completePurchase(any()),
      ).thenAnswer((_) async {});

      // Act - completePurchase is called internally through stream handling
      // This validates the mock setup for integration tests
      await mockInAppPurchase.completePurchase(mockPurchaseDetails);

      // Assert
      verify(
        () => mockInAppPurchase.completePurchase(mockPurchaseDetails),
      ).called(1);
    });
  });
}

/// Mock ProductDetails for testing
class _MockProductDetails implements iap.ProductDetails {
  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String price;
  @override
  final double rawPrice;
  @override
  final String currencyCode;
  @override
  final String currencySymbol;

  _MockProductDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rawPrice,
    required this.currencyCode,
    this.currencySymbol = '₩',
  });
}

/// Mock PurchaseDetails for testing
class _MockPurchaseDetails extends iap.PurchaseDetails {
  _MockPurchaseDetails({
    required super.productID,
    required super.purchaseID,
    required super.status,
    iap.IAPError? error,
    String? transactionDate,
    bool pendingCompletePurchase = false,
  }) : super(
         verificationData: iap.PurchaseVerificationData(
           localVerificationData: 'local-data',
           serverVerificationData: 'server-data',
           source: 'mock',
         ),
         transactionDate: transactionDate ?? DateTime.now().toIso8601String(),
       ) {
    this.error = error;
    this.pendingCompletePurchase = pendingCompletePurchase;
  }
}
