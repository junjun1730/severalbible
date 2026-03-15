import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../../core/router/app_router.dart';

/// Navigates to MyLibrary screen with login-based access control
///
/// - Logged-in users: Direct navigation to MyLibraryScreen
/// - Guests (not logged in): Shows login prompt dialog
Future<void> navigateToMyLibrary(BuildContext context, WidgetRef ref) async {
  final currentUser = ref.read(currentUserProvider);

  if (!context.mounted) return;

  if (currentUser != null && !(currentUser.isAnonymous)) {
    context.push(AppRoutes.myLibrary);
  } else {
    _showLoginPromptDialog(context);
  }
}

void _showLoginPromptDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('로그인이 필요합니다'),
      content: const Text('감상문을 보려면 로그인하세요.\n로그인하면 모든 기간의 감상문을 열람할 수 있습니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
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
