# UI Upgrade - Quick Start Guide

## Overview

This UI Upgrade transforms the One Message app to match the ui-sample reference designs with:
- **Purple branding** (#7C6FE8)
- **Material 3** design system
- **System fonts** (no google_fonts)
- **Modal presentations** (bottom sheets)
- **Custom animations** (fade, scale, slide)

## Checklist Location

**Main Checklist**: `checklist/ui-upgrade/ui-upgrade-checklist.md`

## Progress Summary

- **Total Items**: 158 tests
- **Estimated Duration**: 8-10 days
- **Current Status**: Not Started (0%)

## Phase Breakdown

### Phase 1: Theme System Foundation (1.5-2 days)
Create the foundation with AppTheme, AppColors, AppTypography, and design tokens.

**Key Deliverables**:
- `lib/core/theme/app_theme.dart`
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_typography.dart`
- `lib/core/theme/app_spacing.dart`
- `lib/core/theme/theme_extensions.dart`

**Tests**: 38 tests

### Phase 2: Core UI Components (2-3 days)
Redesign ScriptureCard, create unified button system, and modal infrastructure.

**Key Deliverables**:
- Redesigned `ScriptureCard` (clean, centered, purple badge)
- `lib/core/widgets/app_button.dart` (unified button system)
- `lib/core/widgets/empty_state.dart` (minimal design)
- `lib/core/widgets/app_bottom_sheet.dart` (modal infrastructure)
- Settings as modal
- PrayerNoteInput as modal

**Tests**: 52 tests

### Phase 3: Screen-Level Updates (2-3 days)
Update all screens to use the new design system.

**Key Deliverables**:
- Redesigned PageIndicator
- Updated DailyFeedScreen layout
- Updated auth screens (Login, Splash, Onboarding)
- Updated subscription screens (PremiumLanding, UpsellDialog)

**Tests**: 38 tests

### Phase 4: Animations & Polish (2-3 days)
Add custom animations and polish interactions.

**Key Deliverables**:
- `lib/core/animations/app_animations.dart` (animation utilities)
- ScriptureCard entrance animation
- MeditationButton tap animation
- Modal slide-up animation
- PageIndicator dot transitions
- EmptyState fade-in
- Button hover/press states

**Tests**: 30 tests

## Getting Started

### Step 1: Review Reference Designs
Examine the ui-sample images:
- `ui-sample/main page.png` - ScriptureCard design, page indicators, purple CTA
- `ui-sample/list page.png` - Empty state design (My Library)
- `ui-sample/write page.png` - Modal presentation for meditation notes
- `ui-sample/side bar.png` - Settings modal presentation

### Step 2: Start with Phase 1
Begin with the theme system foundation:

```bash
# Start Phase 1, Cycle 1.1: AppTheme Core Configuration
# See checklist for detailed TDD steps
```

### Step 3: Follow TDD Cycles
For each cycle:
1. **RED**: Write failing tests first
2. **GREEN**: Implement minimum code to pass
3. **REFACTOR**: Improve code quality

### Step 4: Update Checklist
After each cycle, update `ui-upgrade-checklist.md`:
- Change `[ ]` to `[x]` for completed items
- Update Progress Summary
- Add notes about test results

## Test Coverage Goals

| Layer | Goal | Priority |
|-------|------|----------|
| Theme System (Unit) | 95%+ | Highest |
| Core Widgets (Widget) | 90%+ | High |
| Screen Updates (Widget) | 90%+ | High |
| Animations (Unit) | 95%+ | Medium |

## Key Design Tokens

### Colors
```dart
// Primary
Color(0xFF7C6FE8) // Purple brand color

// From ui-sample observations:
// - Card backgrounds: White or very light purple tint
// - Text on purple: White
// - Empty state icon container: Light purple/blue
// - Active page dot: Solid purple
// - Inactive page dot: Light gray or light purple with transparency
```

### Typography
```dart
// Use system fonts only (no google_fonts)
// Observed from ui-sample:
// - Scripture content: 18sp, line height 1.6, center-aligned
// - Reference: Smaller, purple color
// - Button text: 16sp, medium weight
// - Empty state title: ~20-24sp, bold
// - Empty state subtitle: ~14-16sp, gray
```

### Spacing & Dimensions
```dart
// From ui-sample:
// - Button height: 56dp (Material 3 standard)
// - Button border radius: 16px
// - Card border radius: 24px
// - Card padding: 24px
// - Spacing between elements: 16-24px
```

## Critical Rules

### TDD Non-Negotiables
1. Write tests FIRST (RED phase)
2. Write minimum code to pass (GREEN phase)
3. Refactor after passing (REFACTOR phase)
4. Never commit without updating checklist

### UI Design Principles
1. Match ui-sample designs exactly
2. Use AppTheme for all styling (no hardcoded colors)
3. Use AppButton for all buttons (consistency)
4. Use AppBottomSheet for all modals
5. Add animations subtly (200-500ms, smooth)

### Testing Principles
1. Mock all external dependencies
2. Test accessibility (semantic labels, contrast)
3. Test responsive layouts
4. Test animations don't break functionality
5. Achieve coverage goals (90-95%+)

## Dependencies

### Phase Dependencies
```
Phase 1 (Theme) → Phase 2 (Components) → Phase 3 (Screens) → Phase 4 (Animations)
```

### No External Dependencies
All work is internal Flutter/Dart code. No Supabase changes needed.

## Troubleshooting

### If Tests Fail
1. Check mock setup is correct
2. Verify widget tree structure
3. Use `pumpAndSettle()` for animations
4. Check async operations are awaited

### If Design Doesn't Match
1. Re-examine ui-sample reference images
2. Verify AppTheme values are applied
3. Check spacing and sizing with Flutter DevTools
4. Compare with design token specifications

### If Performance Issues
1. Check animation durations (keep 200-500ms)
2. Verify no unnecessary rebuilds
3. Use `const` constructors where possible
4. Profile with Flutter DevTools

## Resources

### Documentation
- Main Checklist: `checklist/ui-upgrade/ui-upgrade-checklist.md`
- Project Instructions: `CLAUDE.md`
- Overall Plan: `PLANNER.md`

### Reference Designs
- UI Samples: `ui-sample/` directory
- Material 3 Spec: https://m3.material.io/

### Testing
- Flutter Testing: https://docs.flutter.dev/testing
- Widget Testing: https://docs.flutter.dev/cookbook/testing/widget
- Golden Tests: https://pub.dev/packages/golden_toolkit

## Success Metrics

- [ ] 158/158 tests passing (100%)
- [ ] 90-95%+ coverage achieved
- [ ] Visual design matches ui-sample
- [ ] No breaking functionality changes
- [ ] Smooth animations (60fps)
- [ ] Accessible (WCAG AA compliance)

## Questions?

Refer to the main checklist for detailed TDD steps for each cycle. Each cycle includes:
- Test file location
- Test cases with assertions
- Implementation guidance
- Refactoring suggestions
- Time estimates
- Dependencies

---

**Ready to start? Begin with Phase 1, Cycle 1.1 in the main checklist!**
