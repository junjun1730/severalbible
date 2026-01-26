import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/user_tier.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../subscription/presentation/widgets/upsell_dialog.dart';
import '../../../../core/router/app_router.dart';

/// Navigates to MyLibrary screen with tier-based access control
///
/// - Premium users: Direct navigation to MyLibraryScreen
/// - Non-premium users (Member/Guest): Shows UpsellDialog for upgrade
Future<void> navigateToMyLibrary(BuildContext context, WidgetRef ref) async {
  final tier = await ref.read(currentUserTierProvider.future);

  if (!context.mounted) return;

  if (tier == UserTier.premium) {
    // Premium user: navigate to MyLibrary
    context.push(AppRoutes.myLibrary);
  } else {
    // Non-premium user: show upgrade dialog
    showDialog(
      context: context,
      builder: (context) => const UpsellDialog(
        trigger: UpsellTrigger.archiveLocked,
      ),
    );
  }
}
