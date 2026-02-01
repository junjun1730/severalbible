import 'package:flutter/material.dart';
import '../../../../core/animations/app_animations.dart';

/// Reusable Material 3 button for meditation entry
///
/// This button provides a consistent, full-width interface for users to
/// leave meditation notes on scripture cards.
///
/// ## Animations (Cycle 4.3)
/// - ✅ Tap animation: scales down to 0.95 on press
/// - ✅ Release animation: scales back to 1.0 on release
/// - ✅ 200ms fast duration for responsive feel
/// - ✅ Smooth AnimatedScale transition
class MeditationButton extends StatefulWidget {
  final bool isEnabled;
  final VoidCallback onTap;

  const MeditationButton({
    super.key,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  State<MeditationButton> createState() => _MeditationButtonState();
}

class _MeditationButtonState extends State<MeditationButton> {
  bool _isPressed = false;

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.isEnabled) {
      setState(() {
        _isPressed = true;
      });
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (widget.isEnabled) {
      setState(() {
        _isPressed = false;
      });
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (widget.isEnabled) {
      setState(() {
        _isPressed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: AppAnimations.fast, // 200ms
        curve: Curves.easeInOut,
        child: FilledButton.icon(
          onPressed: widget.isEnabled ? widget.onTap : null,
          icon: const Icon(Icons.edit_note),
          label: const Text('Leave Meditation'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
