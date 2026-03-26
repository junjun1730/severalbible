import 'package:flutter/material.dart';
import 'package:severalbible/core/animations/app_animations.dart';
import 'navigation_arrow_button.dart';

/// A dot indicator widget for page views
class PageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;
  final double activeDotWidth;
  final double spacing;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool isPreviousEnabled;
  final bool isNextEnabled;

  const PageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 8,
    this.activeDotWidth = 24,
    this.spacing = 8,
    this.onPrevious,
    this.onNext,
    this.isPreviousEnabled = true,
    this.isNextEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (onPrevious == null && onNext == null) {
      return _dotsRow(context);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NavigationArrowButton(
          icon: Icons.arrow_back_ios,
          onPressed: onPrevious ?? () {},
          isEnabled: isPreviousEnabled,
          side: NavigationSide.left,
        ),
        const SizedBox(width: 8),
        _dotsRow(context),
        const SizedBox(width: 8),
        NavigationArrowButton(
          icon: Icons.arrow_forward_ios,
          onPressed: onNext ?? () {},
          isEnabled: isNextEnabled,
          side: NavigationSide.right,
        ),
      ],
    );
  }

  Widget _dotsRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, (index) => _buildDot(context, index)),
    );
  }

  Widget _buildDot(BuildContext context, int index) {
    final isActive = index == currentPage;
    final colorScheme = Theme.of(context).colorScheme;

    final color = isActive
        ? (activeColor ?? colorScheme.primary)
        : (inactiveColor ?? colorScheme.onSurface.withValues(alpha: 0.3));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing / 2),
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        curve: Curves.easeInOut,
        width: isActive ? activeDotWidth : dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(dotSize / 2),
        ),
      ),
    );
  }
}
