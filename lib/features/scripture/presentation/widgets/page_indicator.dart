import 'package:flutter/material.dart';

/// A dot indicator widget for page views
class PageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;
  final double activeDotWidth;
  final double spacing;

  const PageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 8,
    this.activeDotWidth = 24,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        pageCount,
        (index) => _buildDot(context, index),
      ),
    );
  }

  Widget _buildDot(BuildContext context, int index) {
    final isActive = index == currentPage;
    final color = isActive
        ? (activeColor ?? Theme.of(context).colorScheme.primary)
        : (inactiveColor ??
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.3));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing / 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
