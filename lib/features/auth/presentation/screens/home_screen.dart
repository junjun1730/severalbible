import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:severalbible/core/widgets/app_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_providers.dart';
import '../../domain/user_tier.dart';
import '../../../../core/router/app_router.dart';
import '../../../scripture/presentation/screens/daily_feed_screen.dart';
import '../../../prayer_note/presentation/utils/my_library_navigation.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

/// Home screen - Daily scripture feed
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndShowLoginPrompt();
  }

  Future<void> _checkAndShowLoginPrompt() async {
    // Small delay to let the screen build
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final tierAsync = ref.read(currentUserTierProvider);
    final tier = tierAsync.valueOrNull ?? UserTier.guest;

    if (tier != UserTier.guest) return;

    final prefs = await SharedPreferences.getInstance();
    final lastShown = prefs.getString('last_login_prompt_date');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastShown != today) {
      await prefs.setString('last_login_prompt_date', today);
      if (mounted) {
        _showLoginInducementModal();
      }
    }
  }

  void _showLoginInducementModal() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('더 많은 은혜를 받으세요'),
        content: const Text('로그인하면 하루 3배 더 많은 말씀을 받을 수 있습니다.\n지금 바로 시작해보세요!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('나중에'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRoutes.login);
            },
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tierAsync = ref.watch(currentUserTierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () => navigateToMyLibrary(context, ref),
            tooltip: 'My Library',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              AppBottomSheet.show(
                context: context,
                builder: (context) => const SettingsScreen(),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: tierAsync.when(
        data: (tier) => const DailyFeedScreen(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
