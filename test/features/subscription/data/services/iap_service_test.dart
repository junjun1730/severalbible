// DEAD CODE: in_app_purchase removed as part of ad-based revenue model pivot (2026-03-15)
// IAP functionality replaced by AdMob. These tests are skipped.
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/subscription/data/services/iap_service_impl.dart';

void main() {
  group('IAPServiceImpl (DEAD CODE — stub only)', () {
    test('initialize returns Left failure (stub)', () async {
      final service = IAPServiceImpl();
      final result = await service.initialize();
      expect(result.isLeft(), isTrue);
    });

    test('fetchProducts returns Left failure (stub)', () async {
      final service = IAPServiceImpl();
      final result = await service.fetchProducts(productIds: ['monthly_premium']);
      expect(result.isLeft(), isTrue);
    });

    test('purchaseSubscription returns Left failure (stub)', () async {
      final service = IAPServiceImpl();
      final result = await service.purchaseSubscription(productId: 'monthly_premium');
      expect(result.isLeft(), isTrue);
    });

    test('restorePurchases returns Left failure (stub)', () async {
      final service = IAPServiceImpl();
      final result = await service.restorePurchases();
      expect(result.isLeft(), isTrue);
    });
  });
}
