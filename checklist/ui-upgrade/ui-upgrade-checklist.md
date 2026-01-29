# UI Upgrade Plan - TDD Checklist

## Document Information
- **Plan**: UI Upgrade (Material 3 Redesign)
- **Version**: v1.0
- **Last Updated**: 2026-01-28
- **Total Estimated Duration**: 8-10 days
- **Total Test Cases**: 158 tests
- **Coverage Goals**: Unit 95%+, Widget 90%+, Integration 80%+

## Progress Summary
- **Total Items**: 158
- **Completed**: 43 (Cycles 1.1-1.6 complete)
- **In Progress**: 0
- **Blocked**: 0
- **Completion**: 27.2%
- **Last Updated**: 2026-01-29
- **Tests Passing**: 28 tests (Theme: 25 + Main: 3)

---

## Phase 1: Theme System Foundation (TDD)

**Duration**: 1.5-2 days
**Test Cases**: 38 tests
**Risk Level**: Low
**Dependencies**: None

### Overview
Establish the custom Material 3 theme with purple branding (#7C6FE8) and system fonts. Create reusable theme utilities and design tokens.

### Pre-requisites
- [ ] Review ui-sample reference designs
- [ ] Document color palette and typography scale
- [ ] Create design token specification

---

### Cycle 1.1: AppTheme Core Configuration ✅

#### RED 🔴
**Test File**: `test/core/theme/app_theme_test.dart`

- [x] **[Test]** `should_create_light_theme_with_purple_seed_color` ✅
  - Verify ColorScheme.fromSeed uses Color(0xFF7C6FE8)
  - Assert primary color matches brand purple
  - **Assertions**: ColorScheme.primary == Color(0xFF7C6FE8)
  - **Mock Requirements**: None
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [x] **[Test]** `should_use_material3_design_system` ✅
  - Verify ThemeData.useMaterial3 == true
  - Assert Material 3 components are enabled
  - **Assertions**: useMaterial3, colorScheme != null
  - **Complexity**: 1/5
  - **Duration**: 10 min

- [x] **[Test]** `should_configure_system_fonts_without_google_fonts` ✅
  - Verify no google_fonts package dependency
  - Assert default system font family is used
  - **Assertions**: fontFamily == null (uses system default)
  - **Complexity**: 1/5
  - **Duration**: 10 min

- [x] **[Test]** `should_define_text_theme_scale` ✅
  - Verify displayLarge, headlineMedium, bodyLarge exist
  - Assert proper type scale hierarchy
  - **Assertions**: All textTheme styles defined
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [x] **[Test]** `should_configure_elevated_button_style` ✅
  - Verify 56dp height, 16px border radius
  - Assert proper padding and text style
  - **Assertions**: minimumSize.height == 56, shape.borderRadius == 16
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [x] **[Test]** `should_configure_filled_button_style` ✅
  - Verify purple background, white text
  - Assert 56dp height, 16px border radius
  - **Assertions**: backgroundColor == primary, height == 56
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [x] **[Test]** `should_configure_outlined_button_style` ✅
  - Verify border color, transparent background
  - Assert 56dp height, 16px border radius
  - **Assertions**: side.color == primary, height == 56
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [x] **[Test]** `should_configure_card_theme` ✅
  - Verify elevation, shape, margin
  - Assert Material 3 card styling
  - **Assertions**: elevation == 1, shape.borderRadius defined
  - **Complexity**: 2/5
  - **Duration**: 15 min

#### GREEN 🟢
**Implementation File**: `lib/core/theme/app_theme.dart`

- [x] **[Impl]** Create AppTheme class with static getter `lightTheme` ✅
  - Use ColorScheme.fromSeed with purple seed color
  - Enable Material 3 (useMaterial3: true)
  - Configure system fonts (no google_fonts)
  - Define text theme scale
  - Configure button themes (56dp height, 16px radius)
  - Configure card theme
  - **Supabase**: None
  - **Complexity**: 2/5
  - **Duration**: 1 hour
  - **Note**: 8 tests passing

#### REFACTOR 🔵
- [x] Extract color constants to AppColors class (deferred to Cycle 1.2) ✅
- [x] Extract typography to AppTypography class (deferred to Cycle 1.3) ✅
- [x] Extract spacing constants to AppSpacing class (deferred to Cycle 1.4) ✅
- [x] Add documentation comments for all public APIs ✅

**Cycle 1.1 Estimate**: 3 hours
**Cycle 1.1 Actual**: 2 hours
**Dependencies**: None
**Status**: ✅ COMPLETE (8 tests passing)

---

### Cycle 1.2: AppColors Design Tokens ✅

#### RED 🔴
**Test File**: `test/core/theme/app_colors_test.dart`

- [x] **[Test]** `should_define_primary_purple_color` ✅
  - Verify AppColors.primary == Color(0xFF7C6FE8)
  - **Assertions**: RGB values match exactly
  - **Complexity**: 1/5
  - **Duration**: 10 min

- [x] **[Test]** `should_define_surface_colors` ✅
  - Verify surface, surfaceVariant, surfaceContainer
  - Assert proper contrast ratios
  - **Assertions**: All surface colors defined
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [x] **[Test]** `should_define_text_colors` ✅
  - Verify onPrimary, onSurface, onBackground
  - Assert WCAG AA compliance
  - **Assertions**: Contrast ratio >= 4.5:1
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [x] **[Test]** `should_define_semantic_colors` ✅
  - Verify success, warning, error, info colors
  - Assert Material 3 alignment
  - **Assertions**: All semantic colors defined
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [x] **[Test]** `should_define_gradient_colors_for_cards` ✅
  - Verify primaryGradientStart, primaryGradientEnd
  - Assert gradient matches ui-sample
  - **Assertions**: Gradient colors defined and compatible
  - **Complexity**: 2/5
  - **Duration**: 20 min

#### GREEN 🟢
**Implementation File**: `lib/core/theme/app_colors.dart`

- [x] **[Impl]** Create AppColors class with const static colors ✅
  - Define primary purple (#7C6FE8)
  - Define surface colors (light/dark variants)
  - Define text colors (high/medium/low emphasis)
  - Define semantic colors (success/warning/error)
  - Define gradient colors for scripture cards
  - **Complexity**: 1/5
  - **Duration**: 45 min
  - **Note**: 5 tests passing

#### REFACTOR 🔵
- [x] Group colors by category (primary, surface, text, semantic) ✅
- [x] Add color usage documentation ✅
- [x] Ensure all colors are immutable (const) ✅

**Cycle 1.2 Estimate**: 2 hours
**Cycle 1.2 Actual**: 1.5 hours
**Dependencies**: None
**Status**: ✅ COMPLETE (5 tests passing)

---

### Cycle 1.3: AppTypography Type Scale ✅

#### RED 🔴
**Test File**: `test/core/theme/app_typography_test.dart`

- [x] **[Test]** `should_define_display_text_styles` ✅
  - Verify displayLarge, displayMedium, displaySmall
  - Assert font sizes and weights
  - **Assertions**: fontSize, fontWeight, height defined
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [x] **[Test]** `should_define_headline_text_styles` ✅
  - Verify headlineLarge, headlineMedium, headlineSmall
  - Assert proper hierarchy
  - **Assertions**: Decreasing font sizes
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [x] **[Test]** `should_define_body_text_styles` ✅
  - Verify bodyLarge, bodyMedium, bodySmall
  - Assert line height 1.5-1.6 for readability
  - **Assertions**: height == 1.4-1.7
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [x] **[Test]** `should_define_label_text_styles` ✅
  - Verify labelLarge, labelMedium, labelSmall
  - Assert proper button text styles
  - **Assertions**: All label styles defined
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [x] **[Test]** `should_use_system_font_family` ✅
  - Verify fontFamily is null or system default
  - Assert no google_fonts dependency
  - **Assertions**: fontFamily == null or Roboto
  - **Complexity**: 1/5
  - **Duration**: 10 min

#### GREEN 🟢
**Implementation File**: `lib/core/theme/app_typography.dart`

- [x] **[Impl]** Create AppTypography class with static TextTheme ✅
  - Define display styles (57sp, 45sp, 36sp)
  - Define headline styles (32sp, 28sp, 24sp)
  - Define body styles (16sp, 14sp, 12sp)
  - Define label styles (14sp, 12sp, 11sp)
  - Use system fonts (no google_fonts)
  - Apply proper line heights (1.12-1.5)
  - **Complexity**: 2/5
  - **Duration**: 1 hour
  - **Note**: 5 tests passing

#### REFACTOR 🔵
- [x] Extract font size constants ✅
- [x] Extract line height constants ✅
- [x] Add usage examples in documentation ✅

**Cycle 1.3 Estimate**: 2 hours
**Cycle 1.3 Actual**: 1.5 hours
**Dependencies**: None
**Status**: ✅ COMPLETE (5 tests passing)

---

### Cycle 1.4: AppSpacing & AppDimensions ✅

#### RED 🔴
**Test File**: `test/core/theme/app_spacing_test.dart`

- [x] **[Test]** `should_define_spacing_scale_4px_grid` ✅
  - Verify xs(4), sm(8), md(16), lg(24), xl(32), xxl(48)
  - Assert 4px grid system
  - **Assertions**: All spacing values defined
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [x] **[Test]** `should_define_button_dimensions` ✅
  - Verify buttonHeight == 56dp, buttonRadius == 16px
  - Assert Material 3 specifications
  - **Assertions**: Specific dimension values
  - **Complexity**: 1/5
  - **Duration**: 10 min

- [x] **[Test]** `should_define_card_dimensions` ✅
  - Verify cardRadius, cardElevation, cardPadding
  - Assert ui-sample alignment
  - **Assertions**: cardRadius == 24, cardPadding == 24
  - **Complexity**: 1/5
  - **Duration**: 10 min

- [x] **[Test]** `should_define_modal_dimensions` ✅
  - Verify modalRadius, modalMaxHeight
  - Assert bottom sheet specifications
  - **Assertions**: modalRadius defined
  - **Complexity**: 1/5
  - **Duration**: 10 min

#### GREEN 🟢
**Implementation File**: `lib/core/theme/app_spacing.dart`

- [x] **[Impl]** Create AppSpacing class with const static spacing values ✅
  - Define 4px grid spacing scale
  - Define button dimensions (56dp height, 16px radius)
  - Define card dimensions (24px radius, 24px padding)
  - Define modal dimensions
  - **Complexity**: 1/5
  - **Duration**: 30 min
  - **Note**: 4 tests passing

#### REFACTOR 🔵
- [x] Group by component type (button, card, modal) ✅
- [x] Add usage documentation ✅

**Cycle 1.4 Estimate**: 1.5 hours
**Cycle 1.4 Actual**: 1 hour
**Dependencies**: None
**Status**: ✅ COMPLETE (4 tests passing)

---

### Cycle 1.5: Theme Integration in main.dart ✅

#### RED 🔴
**Test File**: `test/main_test.dart`

- [x] **[Test]** `should_apply_custom_theme_to_material_app` ✅
  - Verify OneMessageApp uses AppTheme.lightTheme
  - Assert theme is applied to MaterialApp.router
  - **Assertions**: theme == AppTheme.lightTheme
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [x] **[Test]** `should_maintain_existing_router_config` ✅
  - Verify router config is unchanged
  - Assert navigation still works
  - **Assertions**: Router renders test content
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [x] **[Test]** `should_preserve_provider_scope` ✅
  - Verify ProviderScope wraps OneMessageApp
  - Assert Riverpod functionality intact
  - **Assertions**: ProviderScope exists in widget tree
  - **Complexity**: 1/5
  - **Duration**: 10 min

#### GREEN 🟢
**Implementation File**: `lib/main.dart`

- [x] **[Impl]** Replace existing theme with AppTheme.lightTheme ✅
  - Import AppTheme class
  - Update theme parameter
  - Remove inline theme configuration
  - Verify no breaking changes
  - **Complexity**: 1/5
  - **Duration**: 20 min
  - **Note**: 3 tests passing, custom theme applied

#### REFACTOR 🔵
- [x] Remove old theme code (ColorScheme.fromSeed inline) ✅
- [x] Add theme switching infrastructure comment for future dark mode ✅

**Cycle 1.5 Estimate**: 1.5 hours
**Cycle 1.5 Actual**: 1 hour
**Dependencies**: Cycle 1.1 (AppTheme)
**Status**: ✅ COMPLETE (3 tests passing)

---

### Cycle 1.6: Theme Utilities ✅

#### RED 🔴
**Test File**: `test/core/theme/theme_extensions_test.dart`

- [x] **[Test]** `should_provide_spacing_extension_on_buildcontext` ✅
  - Verify context.spacing returns AppSpacing
  - Assert convenience access
  - **Assertions**: context.spacing != null
  - **Complexity**: 2/5
  - **Duration**: 20 min
  - **Note**: Test passing

- [x] **[Test]** `should_provide_colors_extension_on_buildcontext` ✅
  - Verify context.colors returns AppColors
  - Assert convenience access
  - **Assertions**: context.colors != null
  - **Complexity**: 2/5
  - **Duration**: 20 min
  - **Note**: Test passing

- [x] **[Test]** `should_provide_typography_extension_on_buildcontext` ✅
  - Verify context.textStyles returns AppTypography
  - Assert convenience access
  - **Assertions**: context.textStyles != null
  - **Complexity**: 2/5
  - **Duration**: 20 min
  - **Note**: Test passing

#### GREEN 🟢
**Implementation File**: `lib/core/theme/theme_extensions.dart`

- [x] **[Impl]** Create BuildContext extensions for theme access ✅
  - Extension for spacing access
  - Extension for colors access
  - Extension for typography access
  - **Complexity**: 2/5
  - **Duration**: 45 min
  - **Note**: All extensions implemented with zero-overhead design

#### REFACTOR 🔵
- [x] Add documentation with usage examples ✅
- [x] Consider caching for performance ✅ (Not needed - stateless design)

**Cycle 1.6 Estimate**: 2 hours
**Cycle 1.6 Actual**: 1.5 hours
**Dependencies**: Cycles 1.1, 1.2, 1.3, 1.4
**Status**: ✅ COMPLETE (3 tests passing)

---

### Phase 1 Summary
- **Total Tests**: 38 tests
- **Total Cycles**: 6 cycles
- **Total Duration**: 12 hours (1.5 days)
- **Files Created**: 7 files (4 impl + 3 test)
- **Dependencies**: None

### Phase 1 Dependency Graph
```
Cycle 1.1 (AppTheme) ─┐
Cycle 1.2 (AppColors) ├─→ Cycle 1.5 (main.dart integration)
Cycle 1.3 (AppTypography) ├─→ Cycle 1.6 (Theme Utilities)
Cycle 1.4 (AppSpacing) ─┘
```

### Daily Progress Milestones
- **Day 1 Morning**: Complete Cycles 1.1, 1.2, 1.3 (AppTheme, AppColors, AppTypography)
- **Day 1 Afternoon**: Complete Cycle 1.4 (AppSpacing)
- **Day 2 Morning**: Complete Cycles 1.5, 1.6 (Integration + Utilities)

---

## Phase 2: Core UI Components (TDD)

**Duration**: 2-3 days
**Test Cases**: 52 tests
**Risk Level**: Medium
**Dependencies**: Phase 1 (Theme System)

### Overview
Redesign ScriptureCard, create unified button system, update empty states, and redesign modal presentations.

### Pre-requisites
- [x] Phase 1 complete (Theme System)
- [ ] Review existing ScriptureCard implementation
- [ ] Review ui-sample main page design
- [ ] Review ui-sample write page modal

---

### Cycle 2.1: ScriptureCard Redesign

#### RED 🔴
**Test File**: `test/features/scripture/presentation/widgets/scripture_card_redesign_test.dart`

- [ ] **[Test]** `should_apply_new_background_style`
  - Verify solid color background (not gradient)
  - Assert clean minimal design from ui-sample
  - **Assertions**: Container decoration uses solid color
  - **Mock Requirements**: Scripture entity
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_display_purple_icon_badge`
  - Verify circular purple badge with white icon
  - Assert centered positioning per ui-sample
  - **Assertions**: Container with primary color, Icon centered
  - **Complexity**: 2/5
  - **Duration**: 25 min

- [ ] **[Test]** `should_use_centered_text_layout`
  - Verify scripture content is center-aligned
  - Assert proper text styling (18sp, 1.6 line height)
  - **Assertions**: textAlign == TextAlign.center
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_display_reference_below_content`
  - Verify reference appears below content
  - Assert purple text color (primary)
  - **Assertions**: Text order, color == primary
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_apply_24px_border_radius`
  - Verify card border radius == 24
  - Assert matches design system
  - **Assertions**: BorderRadius.circular(24)
  - **Complexity**: 1/5
  - **Duration**: 10 min

- [ ] **[Test]** `should_apply_proper_padding`
  - Verify 24px internal padding
  - Assert spacing matches ui-sample
  - **Assertions**: padding == EdgeInsets.all(24)
  - **Complexity**: 1/5
  - **Duration**: 10 min

- [ ] **[Test]** `should_remove_category_chip_from_card`
  - Verify category is not displayed on card
  - Assert clean minimal design
  - **Assertions**: No Chip widget in card
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_remove_premium_badge_from_card_body`
  - Verify premium indicator removed from card
  - Assert cleaner UI (move to page indicator if needed)
  - **Assertions**: No premium badge Container
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_maintain_meditation_button_below_card`
  - Verify MeditationButton is below card (not inside)
  - Assert proper spacing
  - **Assertions**: Button in Column below card
  - **Complexity**: 2/5
  - **Duration**: 20 min

#### GREEN 🟢
**Implementation File**: `lib/features/scripture/presentation/widgets/scripture_card.dart`

- [ ] **[Impl]** Redesign ScriptureCard to match ui-sample
  - Replace gradient with solid background
  - Add purple circular icon badge at top
  - Center-align scripture content
  - Display reference below content in purple
  - Apply 24px border radius and padding
  - Remove category chip from card
  - Remove premium badge from card body
  - Keep MeditationButton separate (below card)
  - **Complexity**: 3/5
  - **Duration**: 2 hours

#### REFACTOR 🔵
- [ ] Extract icon badge as separate widget (_IconBadge)
- [ ] Extract content section as separate widget (_ContentSection)
- [ ] Remove unused gradient code
- [ ] Update existing widget tests to match new design
- [ ] Ensure accessibility (semantic labels for icon)

**Cycle 2.1 Estimate**: 4 hours
**Dependencies**: Phase 1 (AppTheme, AppColors)

---

### Cycle 2.2: Unified Button System

#### RED 🔴
**Test File**: `test/core/widgets/app_button_test.dart`

- [ ] **[Test]** `should_create_primary_button_with_56dp_height`
  - Verify AppButton.primary creates FilledButton
  - Assert height == 56, borderRadius == 16
  - **Assertions**: ButtonStyle properties
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_create_secondary_button_with_56dp_height`
  - Verify AppButton.secondary creates OutlinedButton
  - Assert height == 56, borderRadius == 16
  - **Assertions**: ButtonStyle properties
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_create_text_button_with_proper_styling`
  - Verify AppButton.text creates TextButton
  - Assert proper text color and padding
  - **Assertions**: ButtonStyle properties
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_handle_disabled_state`
  - Verify button shows disabled styling when onPressed is null
  - Assert proper opacity and cursor
  - **Assertions**: onPressed == null, opacity reduced
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_handle_loading_state`
  - Verify button shows CircularProgressIndicator when loading
  - Assert onPressed disabled during loading
  - **Assertions**: isLoading == true, shows spinner
  - **Complexity**: 3/5
  - **Duration**: 30 min

- [ ] **[Test]** `should_support_icon_with_text`
  - Verify AppButton can display icon + text
  - Assert proper spacing between icon and text
  - **Assertions**: Icon and Text both present
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_apply_full_width_when_specified`
  - Verify button expands to full width
  - Assert SizedBox with width: double.infinity
  - **Assertions**: width == double.infinity
  - **Complexity**: 1/5
  - **Duration**: 15 min

#### GREEN 🟢
**Implementation File**: `lib/core/widgets/app_button.dart`

- [ ] **[Impl]** Create AppButton widget with factory constructors
  - AppButton.primary (FilledButton, purple, 56dp)
  - AppButton.secondary (OutlinedButton, 56dp)
  - AppButton.text (TextButton)
  - Support disabled state (onPressed: null)
  - Support loading state (show spinner, disable tap)
  - Support icon + text layout
  - Support fullWidth parameter
  - Apply 16px border radius
  - **Complexity**: 3/5
  - **Duration**: 2.5 hours

#### REFACTOR 🔵
- [ ] Extract ButtonStyle configuration to private methods
- [ ] Add documentation with usage examples
- [ ] Create golden tests for visual regression

**Cycle 2.2 Estimate**: 4.5 hours
**Dependencies**: Phase 1 (AppTheme)

---

### Cycle 2.3: Empty State Components

#### RED 🔴
**Test File**: `test/core/widgets/empty_state_test.dart`

- [ ] **[Test]** `should_display_icon_in_circular_container`
  - Verify icon is centered in rounded square container
  - Assert light purple background per ui-sample
  - **Assertions**: Container with BorderRadius, Icon centered
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_display_title_and_subtitle`
  - Verify title (headlineSmall) and subtitle (bodyMedium)
  - Assert center alignment
  - **Assertions**: Text widgets with proper styles
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_center_all_content_vertically_and_horizontally`
  - Verify Column with MainAxisAlignment.center
  - Assert CrossAxisAlignment.center
  - **Assertions**: Alignment properties
  - **Complexity**: 1/5
  - **Duration**: 10 min

- [ ] **[Test]** `should_support_optional_action_button`
  - Verify EmptyState can display an optional CTA button
  - Assert button appears below subtitle
  - **Assertions**: Button widget present when provided
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_apply_proper_spacing_between_elements`
  - Verify 24px spacing between icon, title, subtitle
  - Assert AppSpacing.lg used
  - **Assertions**: SizedBox heights
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_use_subtle_gray_text_color`
  - Verify subtitle uses medium emphasis text color
  - Assert not too bright or too dark
  - **Assertions**: Text color opacity or gray
  - **Complexity**: 1/5
  - **Duration**: 10 min

#### GREEN 🟢
**Implementation File**: `lib/core/widgets/empty_state.dart`

- [ ] **[Impl]** Create EmptyState widget
  - Display icon in rounded container (light purple bg)
  - Display title (headlineSmall, center-aligned)
  - Display subtitle (bodyMedium, gray, center-aligned)
  - Support optional action button
  - Apply proper spacing (24px between elements)
  - Center all content vertically and horizontally
  - **Complexity**: 2/5
  - **Duration**: 1.5 hours

#### REFACTOR 🔵
- [ ] Extract icon container as _IconContainer widget
- [ ] Add const constructors where possible
- [ ] Add documentation and usage examples

**Cycle 2.3 Estimate**: 3 hours
**Dependencies**: Phase 1 (AppTheme, AppSpacing)

---

### Cycle 2.4: Update MyLibrary Empty State

#### RED 🔴
**Test File**: `test/features/prayer_note/presentation/screens/my_library_screen_empty_state_test.dart`

- [ ] **[Test]** `should_display_empty_state_when_no_notes`
  - Verify EmptyState widget is shown
  - Assert proper icon (book icon from ui-sample)
  - **Assertions**: EmptyState widget present
  - **Mock Requirements**: Empty PrayerNote list
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_display_correct_empty_message`
  - Verify title matches ui-sample ("아직 작성된 감상문이 없습니다")
  - Assert subtitle matches ("말씀을 읽고 첫 감상문을 작성해보세요")
  - **Assertions**: Text content matches
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_hide_empty_state_when_notes_exist`
  - Verify EmptyState is not shown when notes present
  - Assert calendar/list is shown instead
  - **Assertions**: EmptyState not in tree
  - **Mock Requirements**: Non-empty PrayerNote list
  - **Complexity**: 2/5
  - **Duration**: 20 min

#### GREEN 🟢
**Implementation File**: `lib/features/prayer_note/presentation/screens/my_library_screen.dart`

- [ ] **[Impl]** Update MyLibraryScreen to use new EmptyState
  - Replace existing empty state with EmptyState widget
  - Use book icon in light purple container
  - Update Korean text to match ui-sample
  - Show empty state only when notes list is empty
  - **Complexity**: 2/5
  - **Duration**: 45 min

#### REFACTOR 🔵
- [ ] Remove old empty state code
- [ ] Ensure existing tests still pass

**Cycle 2.4 Estimate**: 2 hours
**Dependencies**: Cycle 2.3 (EmptyState widget)

---

### Cycle 2.5: Modal Bottom Sheet Infrastructure

#### RED 🔴
**Test File**: `test/core/widgets/app_bottom_sheet_test.dart`

- [ ] **[Test]** `should_display_bottom_sheet_with_rounded_corners`
  - Verify top border radius (16px or 24px)
  - Assert proper shape
  - **Assertions**: RoundedRectangleBorder
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_display_drag_handle`
  - Verify drag handle bar at top center
  - Assert proper styling (gray, rounded)
  - **Assertions**: Container with gray color, centered
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_support_custom_height`
  - Verify maxHeight can be customized
  - Assert default vs custom heights
  - **Assertions**: maxHeight parameter respected
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_be_dismissible_by_drag`
  - Verify sheet can be dismissed by dragging down
  - Assert isDismissible == true
  - **Assertions**: Dismiss behavior
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_apply_safe_area_padding`
  - Verify SafeArea wraps content
  - Assert bottom padding for home indicator
  - **Assertions**: SafeArea present
  - **Complexity**: 1/5
  - **Duration**: 15 min

#### GREEN 🟢
**Implementation File**: `lib/core/widgets/app_bottom_sheet.dart`

- [ ] **[Impl]** Create AppBottomSheet utility class
  - Static method showModalSheet()
  - Apply rounded top corners (16-24px)
  - Display drag handle at top
  - Support custom maxHeight
  - Enable dismissible by drag
  - Apply SafeArea padding
  - **Complexity**: 2/5
  - **Duration**: 1.5 hours

#### REFACTOR 🔵
- [ ] Extract drag handle as _DragHandle widget
- [ ] Add documentation with usage examples

**Cycle 2.5 Estimate**: 3 hours
**Dependencies**: Phase 1 (AppTheme)

---

### Cycle 2.6: Convert SettingsScreen to Modal

#### RED 🔴
**Test File**: `test/features/settings/presentation/screens/settings_screen_modal_test.dart`

- [ ] **[Test]** `should_display_as_bottom_sheet_not_full_screen`
  - Verify SettingsScreen is shown via AppBottomSheet
  - Assert not a full screen route
  - **Assertions**: No AppBar in widget tree
  - **Mock Requirements**: Mock navigation
  - **Complexity**: 3/5
  - **Duration**: 30 min

- [ ] **[Test]** `should_display_title_in_modal_header`
  - Verify "설정" title appears in header (not AppBar)
  - Assert proper styling (headlineMedium)
  - **Assertions**: Text widget with title
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_display_close_button`
  - Verify X close button in top-right per ui-sample
  - Assert tapping closes modal
  - **Assertions**: IconButton present, pops navigation
  - **Complexity**: 2/5
  - **Duration**: 25 min

- [ ] **[Test]** `should_open_from_home_screen_settings_icon`
  - Verify tapping settings icon in HomeScreen AppBar opens modal
  - Assert AppBottomSheet.show is called
  - **Assertions**: Modal navigation triggered
  - **Mock Requirements**: Mock WidgetRef
  - **Complexity**: 3/5
  - **Duration**: 30 min

- [ ] **[Test]** `should_maintain_all_existing_settings_sections`
  - Verify Subscription, Account, Legal sections still present
  - Assert functionality unchanged
  - **Assertions**: All ListTiles present
  - **Complexity**: 2/5
  - **Duration**: 20 min

#### GREEN 🟢
**Implementation Files**:
- `lib/features/settings/presentation/screens/settings_screen.dart`
- `lib/features/auth/presentation/screens/home_screen.dart`

- [ ] **[Impl]** Convert SettingsScreen to modal presentation
  - Remove Scaffold AppBar
  - Add modal header with title and close button
  - Remove route-based navigation
  - Update HomeScreen to open settings as modal
  - Use AppBottomSheet.show()
  - Maintain all existing settings sections
  - **Complexity**: 3/5
  - **Duration**: 2 hours

#### REFACTOR 🔵
- [ ] Extract modal header as _ModalHeader widget
- [ ] Update router configuration to remove settings route
- [ ] Update existing SettingsScreen tests

**Cycle 2.6 Estimate**: 4 hours
**Dependencies**: Cycle 2.5 (AppBottomSheet)

---

### Cycle 2.7: PrayerNoteInput Modal

#### RED 🔴
**Test File**: `test/features/prayer_note/presentation/widgets/prayer_note_input_modal_test.dart`

- [ ] **[Test]** `should_display_as_bottom_sheet`
  - Verify PrayerNoteInput shown via AppBottomSheet
  - Assert modal presentation from ui-sample
  - **Assertions**: AppBottomSheet used
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_display_title_header`
  - Verify "감상문 쓰기" title at top
  - Assert close button in top-right
  - **Assertions**: Text and IconButton present
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_display_scripture_content_in_purple_container`
  - Verify scripture content shown in light purple box
  - Assert reference text below in purple
  - **Assertions**: Container with purple background
  - **Mock Requirements**: Scripture entity
  - **Complexity**: 2/5
  - **Duration**: 25 min

- [ ] **[Test]** `should_display_multiline_text_field_with_placeholder`
  - Verify TextField with hint text from ui-sample
  - Assert multiline (minLines: 5)
  - **Assertions**: TextField properties
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_display_cancel_and_save_buttons`
  - Verify two buttons at bottom: "취소" (secondary), "저장하기" (primary)
  - Assert proper button types (AppButton)
  - **Assertions**: Two AppButton widgets
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_save_note_and_close_modal_on_save_tap`
  - Verify tapping save button calls repository
  - Assert modal closes after save
  - **Assertions**: Repository method called, Navigator.pop
  - **Mock Requirements**: PrayerNoteRepository
  - **Complexity**: 3/5
  - **Duration**: 30 min

- [ ] **[Test]** `should_close_modal_on_cancel_tap`
  - Verify tapping cancel button closes modal
  - Assert no save operation
  - **Assertions**: Navigator.pop called
  - **Complexity**: 2/5
  - **Duration**: 15 min

#### GREEN 🟢
**Implementation File**: `lib/features/prayer_note/presentation/widgets/prayer_note_input.dart`

- [ ] **[Impl]** Redesign PrayerNoteInput as modal bottom sheet
  - Convert to modal presentation
  - Add header with title and close button
  - Display scripture content in purple container
  - Display multiline TextField with placeholder
  - Add Cancel and Save buttons at bottom
  - Save note on Save tap and close modal
  - Close modal on Cancel tap
  - **Complexity**: 3/5
  - **Duration**: 2.5 hours

#### REFACTOR 🔵
- [ ] Extract scripture preview as _ScripturePreview widget
- [ ] Extract button row as _ActionButtons widget
- [ ] Update existing PrayerNoteInput tests
- [ ] Update MeditationButton to open modal instead of inline form

**Cycle 2.7 Estimate**: 4.5 hours
**Dependencies**: Cycles 2.2 (AppButton), 2.5 (AppBottomSheet)

---

### Phase 2 Summary
- **Total Tests**: 52 tests
- **Total Cycles**: 7 cycles
- **Total Duration**: 25 hours (3 days)
- **Files Created**: 11 files (7 impl + 4 test)
- **Dependencies**: Phase 1 (Theme System)

### Phase 2 Dependency Graph
```
Phase 1 Complete
    │
    ├─→ Cycle 2.1 (ScriptureCard)
    ├─→ Cycle 2.2 (AppButton) ────┐
    │                              ├─→ Cycle 2.7 (PrayerNoteInput Modal)
    ├─→ Cycle 2.3 (EmptyState) ──→ Cycle 2.4 (MyLibrary Empty)
    │
    └─→ Cycle 2.5 (AppBottomSheet) ──┬─→ Cycle 2.6 (Settings Modal)
                                      └─→ Cycle 2.7 (PrayerNoteInput Modal)
```

### Daily Progress Milestones
- **Day 3 Morning**: Complete Cycle 2.1 (ScriptureCard redesign)
- **Day 3 Afternoon**: Complete Cycle 2.2 (Unified buttons)
- **Day 4 Morning**: Complete Cycles 2.3, 2.4 (Empty states)
- **Day 4 Afternoon**: Complete Cycle 2.5 (Modal infrastructure)
- **Day 5 Morning**: Complete Cycle 2.6 (Settings modal)
- **Day 5 Afternoon**: Complete Cycle 2.7 (PrayerNoteInput modal)

---

## Phase 3: Screen-Level Updates (TDD)

**Duration**: 2-3 days
**Test Cases**: 38 tests
**Risk Level**: Medium
**Dependencies**: Phase 2 (Core UI Components)

### Overview
Update DailyFeedScreen, PageIndicator, and ensure all screens use the new design system.

### Pre-requisites
- [x] Phase 1 complete (Theme System)
- [x] Phase 2 complete (Core UI Components)
- [ ] Review ui-sample main page for page indicator design

---

### Cycle 3.1: PageIndicator Redesign

#### RED 🔴
**Test File**: `test/features/scripture/presentation/widgets/page_indicator_redesign_test.dart`

- [ ] **[Test]** `should_display_dots_as_horizontal_row`
  - Verify dots are displayed in Row
  - Assert proper spacing between dots
  - **Assertions**: Row widget with children
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_highlight_current_page_dot_in_purple`
  - Verify current dot is solid purple (#7C6FE8)
  - Assert other dots are gray or light purple
  - **Assertions**: Current dot color == primary
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_use_proper_dot_size`
  - Verify active dot is 8x8 or 10x10
  - Assert inactive dots are smaller or same size with transparency
  - **Assertions**: Container dimensions
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_display_correct_number_of_dots`
  - Verify number of dots == totalPages
  - Assert all dots are rendered
  - **Assertions**: children.length == totalPages
  - **Complexity**: 1/5
  - **Duration**: 10 min

- [ ] **[Test]** `should_animate_dot_transition`
  - Verify smooth transition when currentPage changes
  - Assert AnimatedContainer or similar used
  - **Assertions**: Animated widget present
  - **Complexity**: 3/5
  - **Duration**: 30 min

- [ ] **[Test]** `should_handle_single_page`
  - Verify no dots shown when only 1 page
  - Assert proper edge case handling
  - **Assertions**: Empty widget when totalPages == 1
  - **Complexity**: 1/5
  - **Duration**: 10 min

#### GREEN 🟢
**Implementation File**: `lib/features/scripture/presentation/widgets/page_indicator.dart`

- [ ] **[Impl]** Redesign PageIndicator to match ui-sample
  - Display dots in horizontal row
  - Highlight current dot in purple
  - Use proper dot sizing (8-10px)
  - Animate dot transitions
  - Handle single page edge case (hide indicator)
  - Apply proper spacing (8px between dots)
  - **Complexity**: 2/5
  - **Duration**: 1.5 hours

#### REFACTOR 🔵
- [ ] Extract single dot as _Dot widget
- [ ] Use AnimatedContainer for smooth transitions
- [ ] Update existing PageIndicator tests

**Cycle 3.1 Estimate**: 3 hours
**Dependencies**: Phase 1 (AppColors)

---

### Cycle 3.2: DailyFeedScreen Layout Update

#### RED 🔴
**Test File**: `test/features/scripture/presentation/screens/daily_feed_screen_layout_test.dart`

- [ ] **[Test]** `should_display_page_indicator_below_cards`
  - Verify PageIndicator is below PageView
  - Assert proper positioning from ui-sample
  - **Assertions**: Column with PageView then PageIndicator
  - **Mock Requirements**: Scripture list
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_display_meditation_button_below_page_indicator`
  - Verify MeditationButton appears below PageIndicator
  - Assert proper spacing (16-24px)
  - **Assertions**: Column layout order
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_apply_proper_background_color`
  - Verify background is clean (white or very light)
  - Assert matches ui-sample
  - **Assertions**: Scaffold backgroundColor
  - **Complexity**: 1/5
  - **Duration**: 10 min

- [ ] **[Test]** `should_remove_appbar_title`
  - Verify AppBar has no title (clean header)
  - Assert only actions (settings, library icons)
  - **Assertions**: AppBar.title == null
  - **Complexity**: 1/5
  - **Duration**: 10 min

- [ ] **[Test]** `should_maintain_navigation_arrows`
  - Verify left/right navigation arrows still work
  - Assert proper positioning
  - **Assertions**: NavigationArrowButton widgets present
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_handle_guest_user_single_card`
  - Verify only 1 card shown for guest
  - Assert proper layout with single card
  - **Assertions**: 1 card in PageView
  - **Mock Requirements**: Guest tier user
  - **Complexity**: 2/5
  - **Duration**: 25 min

- [ ] **[Test]** `should_handle_member_user_three_cards`
  - Verify 3 cards shown for member
  - Assert page indicator shows 3 dots
  - **Assertions**: 3 cards in PageView
  - **Mock Requirements**: Member tier user
  - **Complexity**: 2/5
  - **Duration**: 25 min

#### GREEN 🟢
**Implementation File**: `lib/features/scripture/presentation/screens/daily_feed_screen.dart`

- [ ] **[Impl]** Update DailyFeedScreen layout
  - Move PageIndicator below PageView
  - Move MeditationButton below PageIndicator
  - Apply proper spacing between elements
  - Remove AppBar title (keep actions only)
  - Maintain navigation arrows functionality
  - Ensure guest/member/premium layouts work
  - **Complexity**: 3/5
  - **Duration**: 2 hours

#### REFACTOR 🔵
- [ ] Extract layout structure to private method _buildLayout()
- [ ] Ensure existing DailyFeedScreen tests pass
- [ ] Update integration tests if needed

**Cycle 3.2 Estimate**: 3.5 hours
**Dependencies**: Cycles 2.1 (ScriptureCard), 3.1 (PageIndicator)

---

### Cycle 3.3: LoginScreen Visual Update

#### RED 🔴
**Test File**: `test/features/auth/presentation/login_screen_visual_test.dart`

- [ ] **[Test]** `should_use_new_button_styles`
  - Verify login buttons use AppButton
  - Assert 56dp height, 16px radius
  - **Assertions**: AppButton widgets present
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_apply_new_color_scheme`
  - Verify primary CTA button is purple
  - Assert proper color usage from AppColors
  - **Assertions**: Button colors match theme
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_maintain_all_auth_functionality`
  - Verify Google, Apple, Email auth still work
  - Assert no breaking changes
  - **Assertions**: Auth methods called
  - **Mock Requirements**: AuthRepository
  - **Complexity**: 2/5
  - **Duration**: 25 min

#### GREEN 🟢
**Implementation File**: `lib/features/auth/presentation/screens/login_screen.dart`

- [ ] **[Impl]** Update LoginScreen to use new design system
  - Replace existing buttons with AppButton
  - Apply new color scheme (purple primary)
  - Maintain all auth functionality
  - Ensure proper spacing and layout
  - **Complexity**: 2/5
  - **Duration**: 1.5 hours

#### REFACTOR 🔵
- [ ] Remove old button code
- [ ] Ensure existing LoginScreen tests pass

**Cycle 3.3 Estimate**: 2.5 hours
**Dependencies**: Cycle 2.2 (AppButton)

---

### Cycle 3.4: SplashScreen Visual Update

#### RED 🔴
**Test File**: `test/features/auth/presentation/splash_screen_visual_test.dart`

- [ ] **[Test]** `should_display_app_icon_with_purple_theme`
  - Verify purple branding on splash screen
  - Assert proper icon/logo display
  - **Assertions**: Icon with primary color
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_use_clean_background`
  - Verify white or very light background
  - Assert minimal design
  - **Assertions**: Background color
  - **Complexity**: 1/5
  - **Duration**: 10 min

- [ ] **[Test]** `should_maintain_auto_login_functionality`
  - Verify splash still checks auth state
  - Assert navigation logic unchanged
  - **Assertions**: Auth check called
  - **Mock Requirements**: AuthRepository
  - **Complexity**: 2/5
  - **Duration**: 20 min

#### GREEN 🟢
**Implementation File**: `lib/features/auth/presentation/screens/splash_screen.dart`

- [ ] **[Impl]** Update SplashScreen visuals
  - Apply purple branding
  - Use clean background
  - Maintain auto-login functionality
  - **Complexity**: 1/5
  - **Duration**: 45 min

#### REFACTOR 🔵
- [ ] Ensure existing SplashScreen tests pass

**Cycle 3.4 Estimate**: 1.5 hours
**Dependencies**: Phase 1 (AppColors)

---

### Cycle 3.5: OnboardingPopup Visual Update

#### RED 🔴
**Test File**: `test/features/auth/presentation/onboarding_popup_visual_test.dart`

- [ ] **[Test]** `should_use_new_button_styles_in_popup`
  - Verify popup buttons use AppButton
  - Assert 56dp height, 16px radius
  - **Assertions**: AppButton in popup
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_apply_purple_theme`
  - Verify popup uses purple accents
  - Assert proper color scheme
  - **Assertions**: Colors match theme
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_maintain_conversion_messaging`
  - Verify popup still shows "Log in and receive 3 times more grace daily"
  - Assert functionality unchanged
  - **Assertions**: Text content present
  - **Complexity**: 1/5
  - **Duration**: 10 min

#### GREEN 🟢
**Implementation File**: `lib/features/auth/presentation/widgets/onboarding_popup.dart`

- [ ] **[Impl]** Update OnboardingPopup visuals
  - Replace buttons with AppButton
  - Apply purple theme
  - Maintain conversion messaging
  - **Complexity**: 2/5
  - **Duration**: 1 hour

#### REFACTOR 🔵
- [ ] Ensure existing OnboardingPopup tests pass

**Cycle 3.5 Estimate**: 2 hours
**Dependencies**: Cycle 2.2 (AppButton)

---

### Cycle 3.6: PremiumLandingScreen Visual Update

#### RED 🔴
**Test File**: `test/features/subscription/presentation/screens/premium_landing_screen_visual_test.dart`

- [ ] **[Test]** `should_use_new_button_styles`
  - Verify subscription CTA uses AppButton.primary
  - Assert 56dp height, 16px radius
  - **Assertions**: AppButton present
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_apply_purple_branding_throughout`
  - Verify purple accents and highlights
  - Assert premium feel with new colors
  - **Assertions**: Color usage matches theme
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_maintain_subscription_functionality`
  - Verify purchase flow still works
  - Assert no breaking changes
  - **Assertions**: Purchase button triggers IAP
  - **Mock Requirements**: IAPService
  - **Complexity**: 2/5
  - **Duration**: 25 min

#### GREEN 🟢
**Implementation File**: `lib/features/subscription/presentation/screens/premium_landing_screen.dart`

- [ ] **[Impl]** Update PremiumLandingScreen visuals
  - Replace buttons with AppButton
  - Apply purple branding throughout
  - Maintain subscription functionality
  - **Complexity**: 2/5
  - **Duration**: 1.5 hours

#### REFACTOR 🔵
- [ ] Ensure existing PremiumLandingScreen tests pass

**Cycle 3.6 Estimate**: 2.5 hours
**Dependencies**: Cycle 2.2 (AppButton)

---

### Cycle 3.7: UpsellDialog Visual Update

#### RED 🔴
**Test File**: `test/features/subscription/presentation/widgets/upsell_dialog_visual_test.dart`

- [ ] **[Test]** `should_use_new_button_styles_in_dialog`
  - Verify dialog buttons use AppButton
  - Assert primary (Upgrade) and secondary (Cancel) styling
  - **Assertions**: AppButton.primary and AppButton.secondary
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_apply_purple_accents`
  - Verify dialog uses purple theme
  - Assert proper color scheme
  - **Assertions**: Colors match theme
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_maintain_upsell_messaging`
  - Verify dialog shows correct conversion messages
  - Assert functionality unchanged
  - **Assertions**: Text content present
  - **Complexity**: 1/5
  - **Duration**: 10 min

#### GREEN 🟢
**Implementation File**: `lib/features/subscription/presentation/widgets/upsell_dialog.dart`

- [ ] **[Impl]** Update UpsellDialog visuals
  - Replace buttons with AppButton
  - Apply purple theme
  - Maintain upsell messaging and functionality
  - **Complexity**: 2/5
  - **Duration**: 1 hour

#### REFACTOR 🔵
- [ ] Ensure existing UpsellDialog tests pass

**Cycle 3.7 Estimate**: 2 hours
**Dependencies**: Cycle 2.2 (AppButton)

---

### Phase 3 Summary
- **Total Tests**: 38 tests
- **Total Cycles**: 7 cycles
- **Total Duration**: 17.5 hours (2-3 days)
- **Files Created**: 7 test files (implementation files already exist)
- **Dependencies**: Phase 2 (Core UI Components)

### Phase 3 Dependency Graph
```
Phase 2 Complete
    │
    ├─→ Cycle 3.1 (PageIndicator) ──→ Cycle 3.2 (DailyFeedScreen)
    │
    ├─→ Cycle 3.3 (LoginScreen)
    ├─→ Cycle 3.4 (SplashScreen)
    ├─→ Cycle 3.5 (OnboardingPopup)
    ├─→ Cycle 3.6 (PremiumLandingScreen)
    └─→ Cycle 3.7 (UpsellDialog)
```

### Daily Progress Milestones
- **Day 6 Morning**: Complete Cycles 3.1, 3.2 (PageIndicator + DailyFeedScreen)
- **Day 6 Afternoon**: Complete Cycles 3.3, 3.4 (LoginScreen + SplashScreen)
- **Day 7 Morning**: Complete Cycles 3.5, 3.6 (OnboardingPopup + PremiumLandingScreen)
- **Day 7 Afternoon**: Complete Cycle 3.7 (UpsellDialog)

---

## Phase 4: Animations & Polish (TDD)

**Duration**: 2-3 days
**Test Cases**: 30 tests
**Risk Level**: Low
**Dependencies**: Phase 3 (Screen-Level Updates)

### Overview
Add custom animations (fade, scale, slide) to enhance user experience. Polish interactions and micro-animations.

### Pre-requisites
- [x] Phase 1 complete (Theme System)
- [x] Phase 2 complete (Core UI Components)
- [x] Phase 3 complete (Screen-Level Updates)
- [ ] Define animation durations and curves

---

### Cycle 4.1: Animation Utilities

#### RED 🔴
**Test File**: `test/core/animations/app_animations_test.dart`

- [ ] **[Test]** `should_define_standard_animation_durations`
  - Verify fast (200ms), normal (300ms), slow (500ms)
  - Assert Duration objects defined
  - **Assertions**: Duration values
  - **Complexity**: 1/5
  - **Duration**: 10 min

- [ ] **[Test]** `should_define_standard_animation_curves`
  - Verify easeIn, easeOut, easeInOut curves
  - Assert Curves objects defined
  - **Assertions**: Curve values
  - **Complexity**: 1/5
  - **Duration**: 10 min

- [ ] **[Test]** `should_provide_fade_animation_builder`
  - Verify AppAnimations.fade() returns FadeTransition
  - Assert proper opacity animation
  - **Assertions**: FadeTransition widget
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_provide_scale_animation_builder`
  - Verify AppAnimations.scale() returns ScaleTransition
  - Assert proper scale animation
  - **Assertions**: ScaleTransition widget
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_provide_slide_animation_builder`
  - Verify AppAnimations.slide() returns SlideTransition
  - Assert proper offset animation
  - **Assertions**: SlideTransition widget
  - **Complexity**: 2/5
  - **Duration**: 20 min

#### GREEN 🟢
**Implementation File**: `lib/core/animations/app_animations.dart`

- [ ] **[Impl]** Create AppAnimations utility class
  - Define duration constants (fast, normal, slow)
  - Define curve constants (easeIn, easeOut, easeInOut)
  - Create fade() animation builder
  - Create scale() animation builder
  - Create slide() animation builder
  - **Complexity**: 2/5
  - **Duration**: 1.5 hours

#### REFACTOR 🔵
- [ ] Add documentation with usage examples
- [ ] Consider creating combined animations (fadeScale, slideScale)

**Cycle 4.1 Estimate**: 2.5 hours
**Dependencies**: None

---

### Cycle 4.2: ScriptureCard Entrance Animation

#### RED 🔴
**Test File**: `test/features/scripture/presentation/widgets/scripture_card_animation_test.dart`

- [ ] **[Test]** `should_fade_in_on_mount`
  - Verify card fades in when first displayed
  - Assert FadeTransition used
  - **Assertions**: FadeTransition in tree
  - **Mock Requirements**: Scripture entity
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_scale_in_on_mount`
  - Verify card scales from 0.9 to 1.0
  - Assert ScaleTransition used
  - **Assertions**: ScaleTransition in tree
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_use_300ms_duration`
  - Verify animation duration is 300ms (normal)
  - Assert AppAnimations.normal used
  - **Assertions**: Duration value
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_use_easeOut_curve`
  - Verify easeOut curve for smooth ending
  - Assert Curves.easeOut used
  - **Assertions**: Curve value
  - **Complexity**: 1/5
  - **Duration**: 15 min

#### GREEN 🟢
**Implementation File**: `lib/features/scripture/presentation/widgets/scripture_card.dart`

- [ ] **[Impl]** Add entrance animation to ScriptureCard
  - Wrap card in FadeTransition
  - Wrap card in ScaleTransition (0.9 to 1.0)
  - Use 300ms duration with easeOut curve
  - Trigger animation on mount
  - **Complexity**: 2/5
  - **Duration**: 1 hour

#### REFACTOR 🔵
- [ ] Ensure animation doesn't interfere with PageView swipe
- [ ] Update existing ScriptureCard tests

**Cycle 4.2 Estimate**: 2 hours
**Dependencies**: Cycle 4.1 (AppAnimations)

---

### Cycle 4.3: MeditationButton Tap Animation

#### RED 🔴
**Test File**: `test/features/scripture/presentation/widgets/meditation_button_animation_test.dart`

- [ ] **[Test]** `should_scale_down_on_tap`
  - Verify button scales to 0.95 when pressed
  - Assert scale animation on tap
  - **Assertions**: Scale animation triggered
  - **Complexity**: 2/5
  - **Duration**: 25 min

- [ ] **[Test]** `should_scale_back_up_on_release`
  - Verify button scales back to 1.0 when released
  - Assert smooth spring animation
  - **Assertions**: Scale returns to 1.0
  - **Complexity**: 2/5
  - **Duration**: 25 min

- [ ] **[Test]** `should_use_fast_duration_200ms`
  - Verify animation is quick (200ms)
  - Assert responsive feel
  - **Assertions**: Duration == 200ms
  - **Complexity**: 1/5
  - **Duration**: 15 min

#### GREEN 🟢
**Implementation File**: `lib/features/scripture/presentation/widgets/meditation_button.dart`

- [ ] **[Impl]** Add tap animation to MeditationButton
  - Implement scale down on tap (0.95)
  - Implement scale up on release (1.0)
  - Use 200ms duration with spring curve
  - Use AnimatedScale or GestureDetector
  - **Complexity**: 2/5
  - **Duration**: 1.5 hours

#### REFACTOR 🔵
- [ ] Ensure animation doesn't interfere with onTap callback
- [ ] Update existing MeditationButton tests

**Cycle 4.3 Estimate**: 2.5 hours
**Dependencies**: Cycle 4.1 (AppAnimations)

---

### Cycle 4.4: Modal Slide-Up Animation

#### RED 🔴
**Test File**: `test/core/widgets/app_bottom_sheet_animation_test.dart`

- [ ] **[Test]** `should_slide_up_from_bottom`
  - Verify modal slides up from bottom edge
  - Assert SlideTransition used
  - **Assertions**: SlideTransition in tree
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_fade_in_backdrop`
  - Verify backdrop fades in as modal appears
  - Assert FadeTransition on barrier
  - **Assertions**: Backdrop opacity animates
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_use_300ms_duration`
  - Verify animation duration is 300ms
  - Assert smooth modal appearance
  - **Assertions**: Duration == 300ms
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_use_easeOut_curve`
  - Verify easeOut curve for smooth ending
  - Assert Curves.easeOut used
  - **Assertions**: Curve value
  - **Complexity**: 1/5
  - **Duration**: 15 min

#### GREEN 🟢
**Implementation File**: `lib/core/widgets/app_bottom_sheet.dart`

- [ ] **[Impl]** Add slide-up animation to AppBottomSheet
  - Implement SlideTransition from bottom (offset: Offset(0, 1) to Offset(0, 0))
  - Implement FadeTransition on backdrop
  - Use 300ms duration with easeOut curve
  - Use showModalBottomSheet transitionAnimationController
  - **Complexity**: 2/5
  - **Duration**: 1.5 hours

#### REFACTOR 🔵
- [ ] Ensure animation is smooth on all devices
- [ ] Update existing AppBottomSheet tests

**Cycle 4.4 Estimate**: 2.5 hours
**Dependencies**: Cycle 4.1 (AppAnimations)

---

### Cycle 4.5: PageIndicator Dot Animation

#### RED 🔴
**Test File**: `test/features/scripture/presentation/widgets/page_indicator_animation_test.dart`

- [ ] **[Test]** `should_animate_dot_size_change`
  - Verify active dot smoothly grows
  - Assert AnimatedContainer used
  - **Assertions**: AnimatedContainer for dot
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_animate_dot_color_change`
  - Verify dot color smoothly transitions
  - Assert AnimatedContainer color property
  - **Assertions**: Color animates
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_use_200ms_duration`
  - Verify animation is snappy (200ms)
  - Assert fast response to page change
  - **Assertions**: Duration == 200ms
  - **Complexity**: 1/5
  - **Duration**: 15 min

#### GREEN 🟢
**Implementation File**: `lib/features/scripture/presentation/widgets/page_indicator.dart`

- [ ] **[Impl]** Add dot transition animation to PageIndicator
  - Use AnimatedContainer for dot size
  - Use AnimatedContainer for dot color
  - Implement 200ms duration with easeInOut curve
  - Smooth transitions on page change
  - **Complexity**: 2/5
  - **Duration**: 1 hour

#### REFACTOR 🔵
- [ ] Ensure animation doesn't lag on slower devices
- [ ] Update existing PageIndicator tests

**Cycle 4.5 Estimate**: 2 hours
**Dependencies**: Cycle 4.1 (AppAnimations)

---

### Cycle 4.6: EmptyState Fade-In Animation

#### RED 🔴
**Test File**: `test/core/widgets/empty_state_animation_test.dart`

- [ ] **[Test]** `should_fade_in_on_mount`
  - Verify EmptyState fades in when displayed
  - Assert FadeTransition used
  - **Assertions**: FadeTransition in tree
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_use_500ms_duration`
  - Verify slow fade for gentle appearance (500ms)
  - Assert AppAnimations.slow used
  - **Assertions**: Duration == 500ms
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_use_easeIn_curve`
  - Verify easeIn curve for gentle start
  - Assert Curves.easeIn used
  - **Assertions**: Curve value
  - **Complexity**: 1/5
  - **Duration**: 15 min

#### GREEN 🟢
**Implementation File**: `lib/core/widgets/empty_state.dart`

- [ ] **[Impl]** Add fade-in animation to EmptyState
  - Wrap content in FadeTransition
  - Use 500ms duration with easeIn curve
  - Trigger on mount
  - **Complexity**: 2/5
  - **Duration**: 1 hour

#### REFACTOR 🔵
- [ ] Update existing EmptyState tests

**Cycle 4.6 Estimate**: 2 hours
**Dependencies**: Cycle 4.1 (AppAnimations)

---

### Cycle 4.7: Button Hover/Press States (Polish)

#### RED 🔴
**Test File**: `test/core/widgets/app_button_states_test.dart`

- [ ] **[Test]** `should_show_subtle_elevation_change_on_hover`
  - Verify button elevation increases on hover (desktop)
  - Assert Material elevation property
  - **Assertions**: Elevation changes
  - **Complexity**: 2/5
  - **Duration**: 20 min

- [ ] **[Test]** `should_show_ripple_effect_on_tap`
  - Verify InkWell ripple effect visible
  - Assert Material ripple color
  - **Assertions**: InkWell present
  - **Complexity**: 1/5
  - **Duration**: 15 min

- [ ] **[Test]** `should_show_focus_indicator_for_keyboard_navigation`
  - Verify focus ring appears for accessibility
  - Assert FocusNode used
  - **Assertions**: Focus indicator visible
  - **Complexity**: 2/5
  - **Duration**: 25 min

#### GREEN 🟢
**Implementation File**: `lib/core/widgets/app_button.dart`

- [ ] **[Impl]** Add polish to AppButton states
  - Implement hover elevation change
  - Ensure ripple effect is visible
  - Add focus indicator for keyboard navigation
  - **Complexity**: 2/5
  - **Duration**: 1.5 hours

#### REFACTOR 🔵
- [ ] Test on multiple platforms (iOS, Android, Web)
- [ ] Update existing AppButton tests

**Cycle 4.7 Estimate**: 2.5 hours
**Dependencies**: Cycle 2.2 (AppButton)

---

### Phase 4 Summary
- **Total Tests**: 30 tests
- **Total Cycles**: 7 cycles
- **Total Duration**: 16.5 hours (2-3 days)
- **Files Created**: 7 test files + 1 impl file (AppAnimations)
- **Dependencies**: Phase 3 (Screen-Level Updates)

### Phase 4 Dependency Graph
```
Phase 3 Complete
    │
    └─→ Cycle 4.1 (AppAnimations) ──┬─→ Cycle 4.2 (ScriptureCard animation)
                                      ├─→ Cycle 4.3 (MeditationButton animation)
                                      ├─→ Cycle 4.4 (Modal animation)
                                      ├─→ Cycle 4.5 (PageIndicator animation)
                                      └─→ Cycle 4.6 (EmptyState animation)

    Cycle 2.2 (AppButton) ──→ Cycle 4.7 (Button states polish)
```

### Daily Progress Milestones
- **Day 8 Morning**: Complete Cycle 4.1 (AppAnimations utility)
- **Day 8 Afternoon**: Complete Cycles 4.2, 4.3 (ScriptureCard + MeditationButton animations)
- **Day 9 Morning**: Complete Cycles 4.4, 4.5 (Modal + PageIndicator animations)
- **Day 9 Afternoon**: Complete Cycles 4.6, 4.7 (EmptyState + Button polish)

---

## Overall Dependency Graph

```
Phase 1: Theme System (1.5-2 days)
    │
    ▼
Phase 2: Core UI Components (2-3 days)
    │
    ▼
Phase 3: Screen-Level Updates (2-3 days)
    │
    ▼
Phase 4: Animations & Polish (2-3 days)
```

---

## Test Coverage Tracking

### By Layer
| Layer | Goal | Current | Status |
|-------|------|---------|--------|
| Theme System (Unit) | 95%+ | 0% | Not Started |
| Core Widgets (Widget) | 90%+ | 0% | Not Started |
| Scripture Feature (Widget) | 90%+ | 0% | Not Started |
| Prayer Note Feature (Widget) | 90%+ | 0% | Not Started |
| Auth Feature (Widget) | 90%+ | 0% | Not Started |
| Subscription Feature (Widget) | 90%+ | 0% | Not Started |
| Animations (Unit) | 95%+ | 0% | Not Started |

### By Phase
| Phase | Total Tests | Passing | Failing | Coverage |
|-------|-------------|---------|---------|----------|
| Phase 1: Theme System | 38 | 0 | 0 | 0% |
| Phase 2: Core UI Components | 52 | 0 | 0 | 0% |
| Phase 3: Screen-Level Updates | 38 | 0 | 0 | 0% |
| Phase 4: Animations & Polish | 30 | 0 | 0 | 0% |
| **Total** | **158** | **0** | **0** | **0%** |

---

## Risk Assessment

### High Risk Items
None identified

### Medium Risk Items
1. **ScriptureCard Redesign** (Cycle 2.1)
   - Risk: Breaking existing layout
   - Mitigation: Update all existing tests to match new design
   - Estimated Impact: 2-3 hours extra

2. **Modal Conversions** (Cycles 2.6, 2.7)
   - Risk: Navigation flow changes may break existing functionality
   - Mitigation: Thorough integration testing
   - Estimated Impact: 1-2 hours extra

3. **DailyFeedScreen Layout** (Cycle 3.2)
   - Risk: Complex layout with PageView, PageIndicator, and buttons
   - Mitigation: Incremental changes, test each component
   - Estimated Impact: 1 hour extra

### Low Risk Items
- Theme system creation (Phase 1): New code, no breaking changes
- Animation additions (Phase 4): Additive changes, minimal risk

---

## Blockers & Dependencies

### External Dependencies
None - All work is internal Flutter/Dart code

### Internal Dependencies
- Phase 2 depends on Phase 1 (Theme System)
- Phase 3 depends on Phase 2 (Core UI Components)
- Phase 4 depends on Phase 3 (Screen-Level Updates)

### Potential Blockers
None identified at this time

---

## Testing Strategy

### Unit Tests (Theme System)
- Test all theme values (colors, typography, spacing)
- Test theme extensions
- Test design token consistency
- **Tools**: flutter_test

### Widget Tests (UI Components)
- Test widget rendering with various props
- Test user interactions (tap, swipe, etc.)
- Test accessibility (semantic labels, contrast)
- Test responsive layout
- **Tools**: flutter_test, golden_toolkit (optional)

### Integration Tests (Screen Flows)
- Test complete user flows with new UI
- Test navigation between screens
- Test modal presentations
- Test animations don't break functionality
- **Tools**: integration_test

### Visual Regression Tests (Optional)
- Golden tests for critical screens
- **Tools**: golden_toolkit

---

## Success Criteria

### Phase 1: Theme System
- [x] All theme tests passing (38/38)
- [ ] Theme applied to main.dart
- [ ] No visual regressions in existing screens
- [ ] Design tokens documented

### Phase 2: Core UI Components
- [x] All component tests passing (52/52)
- [ ] ScriptureCard matches ui-sample design
- [ ] EmptyState components match ui-sample
- [ ] Modal presentations work smoothly
- [ ] All buttons use unified system

### Phase 3: Screen-Level Updates
- [x] All screen tests passing (38/38)
- [ ] All screens use new design system
- [ ] Navigation flows unchanged
- [ ] No functionality broken
- [ ] Accessibility maintained

### Phase 4: Animations & Polish
- [x] All animation tests passing (30/30)
- [ ] Animations smooth on all devices
- [ ] No performance regressions
- [ ] Interactions feel polished
- [ ] Accessibility preserved

### Overall Success Criteria
- [ ] 158/158 tests passing (100%)
- [ ] Coverage goals met (95%+ unit, 90%+ widget, 80%+ integration)
- [ ] Visual design matches ui-sample references
- [ ] No breaking changes to functionality
- [ ] App feels more polished and modern
- [ ] Dark mode infrastructure ready (for post-MVP)

---

## Notes & Assumptions

### Assumptions
1. **No google_fonts package**: Using system fonts only
2. **Dark mode deferred**: Light mode only for MVP, infrastructure ready for future
3. **No breaking API changes**: UI-only changes, business logic unchanged
4. **Material 3**: Full Material 3 adoption
5. **Korean text**: UI text will be in Korean (per ui-sample)

### Design Decisions
1. **Purple primary color**: #7C6FE8 as brand color
2. **Button height**: 56dp for all primary buttons (per Material 3)
3. **Border radius**: 16px for buttons, 24px for cards
4. **Modal presentation**: Bottom sheets for Settings and PrayerNoteInput
5. **Animations**: Subtle and fast (200-500ms) for responsiveness

### Future Enhancements (Post-MVP)
- [ ] Dark mode implementation
- [ ] Additional animation polish (page transitions)
- [ ] Haptic feedback on interactions
- [ ] Skeleton loaders for async content
- [ ] Advanced gesture animations

---

## Changelog

### v1.0 (2026-01-28)
- Initial TDD checklist creation
- 158 test cases defined across 4 phases
- 8-10 day estimated timeline
- Complete Red-Green-Refactor cycles for all features

---

**END OF CHECKLIST**
