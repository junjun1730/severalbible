import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/subscription.dart';
import '../providers/subscription_providers.dart';
import '../widgets/purchase_button.dart';
import '../widgets/subscription_product_card.dart';

class PremiumLandingScreen extends ConsumerStatefulWidget {
  const PremiumLandingScreen({super.key});

  @override
  ConsumerState<PremiumLandingScreen> createState() => _PremiumLandingScreenState();
}

class _PremiumLandingScreenState extends ConsumerState<PremiumLandingScreen> {
  String? _selectedProductId;

  @override
  Widget build(BuildContext context) {
    final availableProductsAsync = ref.watch(availableProductsProvider);
    final purchaseState = ref.watch(purchaseControllerProvider);
    final restoreState = ref.watch(restorePurchaseControllerProvider);

    // Listen for purchase success
    ref.listen(purchaseControllerProvider, (previous, next) {
      next.when(
        data: (state) {
          if (state == PurchaseState.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successfully subscribed!')),
            );
            context.pop(); // Go back after success
          } else if (state == PurchaseState.canceled) {
            // Optional: User canceled
          }
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Purchase failed: $error')),
          );
        },
        loading: () {},
      );
    });

     // Listen for restore success
    ref.listen(restorePurchaseControllerProvider, (previous, next) {
      next.when(
        data: (_) {
           // Success handled by showing nothing or success message?
           // The controller returns void on success, only error throws
        },
        error: (error, stack) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Restore failed: $error')),
          );
        },
        loading: () {},
      );
    });


    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: availableProductsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return const Center(child: Text('No products available'));
            }

            // Default selection
            final annualProduct = products.firstWhere(
              (p) => p.id.contains('annual'),
              orElse: () => products.first,
            );
            _selectedProductId ??= annualProduct.id;
            
            final selectedProduct = products.firstWhere((p) => p.id == _selectedProductId);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  // Hero Section
                  const Text(
                    'Unlock Unlimited Grace',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Deepen your spiritual journey with\npremium features designed for you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Benefits List
                  _buildBenefitItem(Icons.library_books, 'Access all premium scriptures'),
                  _buildBenefitItem(Icons.history, 'Unlimited prayer note archive'),
                  _buildBenefitItem(Icons.block, 'Ad-free experience'),
                  _buildBenefitItem(Icons.star, 'Support our mission'),

                  const SizedBox(height: 32),

                  // Product Cards
                  ...products.map((product) => SubscriptionProductCard(
                    product: product,
                    isSelected: product.id == _selectedProductId,
                    onTap: () {
                      setState(() {
                        _selectedProductId = product.id;
                      });
                    },
                  )),

                  const SizedBox(height: 24),

                  // Purchase Button
                  PurchaseButton(
                    text: purchaseState.isLoading 
                        ? 'Processing...' 
                        : 'Start ${selectedProduct.name}',
                    isLoading: purchaseState.isLoading || restoreState.isLoading,
                    onPressed: () {
                      if (_selectedProductId != null) {
                        ref.read(purchaseControllerProvider.notifier).purchaseProduct(_selectedProductId!);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Restore Purchase Link
                  TextButton(
                    onPressed: restoreState.isLoading 
                      ? null 
                      : () {
                          ref.read(restorePurchaseControllerProvider.notifier).restorePurchases().then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Purchases restored successfully')),
                              );
                          });
                        },
                    child: Text(
                      'Restore Purchases',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Terms and Privacy
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildFooterLink('Terms of Service'),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      _buildFooterLink('Privacy Policy'),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {
        // TODO: Launch URL
      },
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
        ),
      ),
    );
  }
}
