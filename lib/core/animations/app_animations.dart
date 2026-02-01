import 'package:flutter/material.dart';

/// Animation utilities for the One Message app.
///
/// Provides:
/// - Standard animation durations (fast, normal, slow)
/// - Standard animation curves (easeIn, easeOut, easeInOut)
/// - Animation builders (fade, scale, slide)
///
/// Usage:
/// ```dart
/// // Use standard durations
/// AnimatedOpacity(
///   duration: AppAnimations.fast,
///   opacity: isVisible ? 1.0 : 0.0,
///   child: child,
/// )
///
/// // Use animation builders
/// AppAnimations.fade(
///   controller: _controller,
///   child: MyWidget(),
/// )
/// ```
class AppAnimations {
  // Private constructor to prevent instantiation
  AppAnimations._();

  // ===== Duration Constants =====

  /// Fast animation duration: 200ms
  /// Use for: Quick feedback, button states, hover effects
  static const Duration fast = Duration(milliseconds: 200);

  /// Normal animation duration: 300ms
  /// Use for: Card entrances, modal slides, general transitions
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow animation duration: 500ms
  /// Use for: Empty states, large screen transitions, loading states
  static const Duration slow = Duration(milliseconds: 500);

  // ===== Curve Constants =====

  /// Ease-in curve: Slow start, fast end
  /// Use for: Exit animations, fade outs
  static const Curve easeIn = Curves.easeIn;

  /// Ease-out curve: Fast start, slow end
  /// Use for: Entry animations, fade ins, most transitions
  static const Curve easeOut = Curves.easeOut;

  /// Ease-in-out curve: Slow start and end, fast middle
  /// Use for: Reversible animations, state changes
  static const Curve easeInOut = Curves.easeInOut;

  // ===== Animation Builders =====

  /// Creates a fade transition.
  ///
  /// Parameters:
  /// - [controller]: The animation controller
  /// - [child]: The child widget to animate
  /// - [curve]: Optional curve (defaults to easeOut)
  ///
  /// Example:
  /// ```dart
  /// AppAnimations.fade(
  ///   controller: _controller,
  ///   child: Text('Hello'),
  /// )
  /// ```
  static Widget fade({
    required AnimationController controller,
    required Widget child,
    Curve curve = Curves.easeOut,
  }) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: curve,
    );

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Creates a scale transition.
  ///
  /// Parameters:
  /// - [controller]: The animation controller
  /// - [child]: The child widget to animate
  /// - [curve]: Optional curve (defaults to easeOut)
  /// - [begin]: Starting scale (defaults to 0.9)
  /// - [end]: Ending scale (defaults to 1.0)
  ///
  /// Example:
  /// ```dart
  /// AppAnimations.scale(
  ///   controller: _controller,
  ///   child: ScriptureCard(),
  /// )
  /// ```
  static Widget scale({
    required AnimationController controller,
    required Widget child,
    Curve curve = Curves.easeOut,
    double begin = 0.9,
    double end = 1.0,
  }) {
    final animation = Tween<double>(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );

    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }

  /// Creates a slide transition.
  ///
  /// Parameters:
  /// - [controller]: The animation controller
  /// - [child]: The child widget to animate
  /// - [curve]: Optional curve (defaults to easeOut)
  /// - [begin]: Starting offset (e.g., Offset(0, 1) for bottom)
  /// - [end]: Ending offset (defaults to Offset.zero)
  ///
  /// Example:
  /// ```dart
  /// AppAnimations.slide(
  ///   controller: _controller,
  ///   begin: Offset(0, 1), // Slide from bottom
  ///   end: Offset.zero,
  ///   child: ModalContent(),
  /// )
  /// ```
  static Widget slide({
    required AnimationController controller,
    required Widget child,
    required Offset begin,
    Offset end = Offset.zero,
    Curve curve = Curves.easeOut,
  }) {
    final animation = Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );

    return SlideTransition(
      position: animation,
      child: child,
    );
  }
}
