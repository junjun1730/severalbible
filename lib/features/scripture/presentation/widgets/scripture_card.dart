import 'package:flutter/material.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/scripture.dart';

/// A card widget displaying a scripture verse with Material 3 design.
///
/// ## Design Features (Phase 4.5 Cycle 2.1 + Cycle 3.2)
/// - Solid background color (no gradient) using Material 3 Card
/// - Purple circular icon badge at top center (book icon)
/// - Center-aligned scripture content with proper typography
/// - Reference text in purple at bottom
/// - 24px border radius and padding (from design tokens)
/// - Clean, minimal aesthetic matching ui-sample reference
///
/// ## Layout Structure
/// ```
/// Card (solid background, 24px border radius)
///   └─ Padding (24px all around)
///       └─ Column (center-aligned)
///           ├─ Icon Badge (purple circle, book icon)
///           ├─ Scripture Content (center-aligned, body text)
///           └─ Reference (center-aligned, purple color)
/// ```
///
/// ## Usage
/// ```dart
/// ScriptureCard(
///   scripture: scripture,
/// )
/// ```
///
/// ## Design Tokens Used
/// - `AppSpacing.cardRadius` - Border radius (24px)
/// - `AppSpacing.lg` - Internal padding and spacing (24px)
/// - `AppSpacing.md` - Medium spacing (16px)
/// - `AppColors.primary` - Icon and reference color (Purple #7C6FE8)
/// - `AppColors.onSurface` - Text content color
/// - `AppTypography.textTheme.bodyLarge` - Content text style (18sp, 1.6 line height)
/// - `AppTypography.textTheme.labelSmall` - Reference text style
///
/// ## Changes from Original Design (Cycle 3.2)
/// - ✅ Replaced gradient background with solid Card
/// - ✅ Added icon badge at top center
/// - ✅ Changed from left-aligned to center-aligned content
/// - ✅ Moved reference from top header to bottom (below content)
/// - ✅ Removed premium badge from card
/// - ✅ Removed category chip from card
/// - ✅ Removed MeditationButton from card (moved to DailyFeedScreen)
///
/// ## Animations (Cycle 4.2)
/// - ✅ Fade-in entrance animation (0.0 to 1.0 opacity)
/// - ✅ Scale-in entrance animation (0.9 to 1.0 scale)
/// - ✅ 300ms duration with easeOut curve
/// - ✅ Triggered on mount (initState)
class ScriptureCard extends StatefulWidget {
  final Scripture scripture;

  const ScriptureCard({
    super.key,
    required this.scripture,
  });

  @override
  State<ScriptureCard> createState() => _ScriptureCardState();
}

class _ScriptureCardState extends State<ScriptureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.normal, // 300ms
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.easeOut, // Curves.easeOut
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.easeOut,
    ));

    // Trigger animation on mount
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildIconBadge(context),
                SizedBox(height: AppSpacing.lg),
                _buildContent(context),
                SizedBox(height: AppSpacing.md),
                _buildReference(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconBadge(BuildContext context) {
    return Container(
      key: const Key('scripture_icon_badge'),
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F3FF),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.menu_book_rounded,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Text(
      widget.scripture.content,
      textAlign: TextAlign.center,
      style: AppTypography.textTheme.bodyLarge?.copyWith(
        fontSize: 18,
        height: 1.6,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildReference(BuildContext context) {
    return Text(
      widget.scripture.reference,
      textAlign: TextAlign.center,
      style: AppTypography.textTheme.labelSmall?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
