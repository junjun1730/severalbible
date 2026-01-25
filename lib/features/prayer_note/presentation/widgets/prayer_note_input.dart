import 'package:flutter/material.dart';

/// A widget for entering prayer note/meditation content
/// Displays character count and handles save action
class PrayerNoteInput extends StatefulWidget {
  final TextEditingController controller;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback? onSave;
  final int maxLength;

  const PrayerNoteInput({
    super.key,
    required this.controller,
    this.isEnabled = true,
    this.isLoading = false,
    this.onSave,
    this.maxLength = 500,
  });

  @override
  State<PrayerNoteInput> createState() => _PrayerNoteInputState();
}

class _PrayerNoteInputState extends State<PrayerNoteInput> {
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _characterCount = widget.controller.text.length;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _characterCount = widget.controller.text.length;
    });
  }

  void _handleSave() {
    if (widget.controller.text.trim().isEmpty) {
      return;
    }
    widget.onSave?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: widget.controller,
            enabled: widget.isEnabled,
            maxLines: 4,
            maxLength: widget.maxLength,
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) {
                  return null;
                },
            decoration: InputDecoration(
              hintText: 'Write your meditation...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_characterCount/${widget.maxLength}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      onPressed: widget.isEnabled ? _handleSave : null,
                      icon: Icon(
                        Icons.save,
                        color: widget.isEnabled
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
