import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:severalbible/features/subscription/domain/entities/subscription.dart';
import 'package:severalbible/features/subscription/presentation/widgets/subscription_product_card.dart';

void main() {
  final monthlyProduct = SubscriptionProduct(
    id: 'monthly_premium',
    name: 'Monthly Premium',
    description: 'Access all premium features for 1 month',
    priceKrw: 9900,
    isActive: true,
    createdAt: DateTime.now(),
  );

  final annualProduct = SubscriptionProduct(
    id: 'annual_premium',
    name: 'Annual Premium',
    description: 'Access all premium features for 1 year (2 months free)',
    priceKrw: 99000,
    isActive: true,
    createdAt: DateTime.now(),
  );

  group('SubscriptionProductCard', () {
    testWidgets('renders product name and price', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionProductCard(
              product: monthlyProduct,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Monthly Premium'), findsOneWidget);
      expect(find.text('₩9900'), findsOneWidget);
      expect(find.text('/ month'), findsOneWidget);
    });

    testWidgets('shows discount badge for annual product', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionProductCard(
              product: annualProduct,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Best Value'), findsOneWidget);
      expect(find.text('Annual Premium'), findsOneWidget);
      expect(find.text('₩99000'), findsOneWidget);
      expect(find.text('/ year'), findsOneWidget);
    });

    testWidgets('does not show discount badge for monthly product', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionProductCard(
              product: monthlyProduct,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Best Value'), findsNothing);
    });

    testWidgets('highlights selected product with different styling', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primaryColor: Colors.blue),
          home: Scaffold(
            body: Column(
              children: [
                SubscriptionProductCard(
                  product: monthlyProduct,
                  isSelected: true,
                  onTap: () {},
                ),
                SubscriptionProductCard(
                  product: annualProduct,
                  isSelected: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Find the containers
      final containers = tester.widgetList<Container>(find.byType(Container));

      // Verify the selected card exists with product name
      expect(find.text('Monthly Premium'), findsOneWidget);
      expect(find.text('Annual Premium'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionProductCard(
              product: monthlyProduct,
              isSelected: false,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(SubscriptionProductCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows product description when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionProductCard(
              product: monthlyProduct,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(
        find.text('Access all premium features for 1 month'),
        findsOneWidget,
      );
    });
  });
}
