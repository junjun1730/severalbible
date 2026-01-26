import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/user_tier.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/scripture.dart';
import '../providers/scripture_providers.dart';
import '../widgets/scripture_card.dart';
import '../widgets/page_indicator.dart';
import '../widgets/content_blocker.dart';
import '../widgets/navigation_arrow_button.dart';
import 'package:severalbible/features/subscription/presentation/widgets/upsell_dialog.dart';

/// Main screen displaying daily scriptures in a PageView
class DailyFeedScreen extends ConsumerStatefulWidget {
  const DailyFeedScreen({super.key});

  @override
  ConsumerState<DailyFeedScreen> createState() => _DailyFeedScreenState();
}

class _DailyFeedScreenState extends ConsumerState<DailyFeedScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scripturesAsync = ref.watch(dailyScripturesProvider);
    final currentIndex = ref.watch(currentScriptureIndexProvider);
    final tierAsync = ref.watch(currentUserTierProvider);

    return Scaffold(
      body: SafeArea(
        child: scripturesAsync.when(
          data: (scriptures) {
            if (scriptures.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildContent(
              context,
              scriptures: scriptures,
              currentIndex: currentIndex,
              tier: tierAsync.valueOrNull ?? UserTier.guest,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(context, error),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required List<Scripture> scriptures,
    required int currentIndex,
    required UserTier tier,
  }) {
    final hasReachedLimit = currentIndex >= scriptures.length;
    final showBlocker = hasReachedLimit && tier != UserTier.premium;
    final itemCount = showBlocker ? scriptures.length + 1 : scriptures.length;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                onPageChanged: (index) {
                  ref.read(currentScriptureIndexProvider.notifier).state = index;

                  // Track view if within scriptures
                  if (index < scriptures.length) {
                    ref
                        .read(scriptureViewTrackerProvider.notifier)
                        .trackView(scriptures[index].id);
                  }
                },
                itemBuilder: (context, index) {
                  if (index >= scriptures.length) {
                    return ContentBlocker(
                      tier: tier,
                      onAction: () => _handleBlockerAction(tier),
                    );
                  }
                  return Center(
                    child: ScriptureCard(
                      scripture: scriptures[index],
                      onMeditationTap: tier != UserTier.guest
                          ? () => _openMeditationSheet(scriptures[index])
                          : null,
                    ),
                  );
                },
              ),
              // Left arrow
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: NavigationArrowButton(
                    icon: Icons.arrow_back_ios,
                    onPressed: () => _navigateToPage(currentIndex - 1),
                    isEnabled: currentIndex > 0,
                    side: NavigationSide.left,
                  ),
                ),
              ),
              // Right arrow
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: NavigationArrowButton(
                    icon: Icons.arrow_forward_ios,
                    onPressed: () => _navigateToPage(currentIndex + 1),
                    isEnabled: currentIndex < itemCount - 1,
                    side: NavigationSide.right,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PageIndicator(
          pageCount: itemCount,
          currentPage: currentIndex,
        ),
        const SizedBox(height: 24),
        if (tier == UserTier.premium && hasReachedLimit)
          _buildSeeMoreButton(context),
      ],
    );
  }

  void _navigateToPage(int targetIndex) {
    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No scriptures available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check back later',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading scriptures',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.invalidate(dailyScripturesProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSeeMoreButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _loadPremiumScriptures,
          icon: const Icon(Icons.add),
          label: const Text('See 3 More'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  void _handleBlockerAction(UserTier tier) {
    if (tier == UserTier.guest) {
      context.go(AppRoutes.login);
    } else {
      // Show Upsell Dialog for premium features
      showDialog(
        context: context,
        builder: (context) =>
            const UpsellDialog(trigger: UpsellTrigger.contentExhausted),
      );
    }
  }

  void _openMeditationSheet(Scripture scripture) {
    // To be implemented in Phase 3 (Prayer Note System)
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Leave Meditation',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                scripture.reference,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Write your meditation...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Prayer note feature coming in Phase 3!'),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadPremiumScriptures() {
    // Load additional premium scriptures
    ref.read(premiumScripturesProvider(null));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loading premium scriptures...')),
    );
  }
}
