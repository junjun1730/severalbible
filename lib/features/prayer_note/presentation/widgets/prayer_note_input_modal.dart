import 'package:flutter/material.dart';
import 'package:severalbible/core/widgets/app_button.dart';
import 'package:severalbible/features/scripture/domain/entities/scripture.dart';

/// Modal bottom sheet for entering prayer notes/meditations
///
/// Displays scripture content in a purple container and provides
/// a multiline text field for writing meditations with Korean UI.
class PrayerNoteInputModal extends StatelessWidget {
  final Scripture scripture;
  final TextEditingController controller;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  const PrayerNoteInputModal({
    super.key,
    required this.scripture,
    required this.controller,
    this.onSave,
    this.onCancel,
  });

  void _handleSave() {
    if (controller.text.trim().isEmpty) {
      return;
    }
    onSave?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal Header
            _buildHeader(context),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Scripture Preview
                    _ScripturePreview(scripture: scripture),

                    const SizedBox(height: 24),

                    // Text Field
                    _buildTextField(context),

                    const SizedBox(height: 24),

                    // Action Buttons
                    _ActionButtons(
                      onCancel: onCancel ?? () {},
                      onSave: _handleSave,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
      child: Row(
        children: [
          Text(
            '감상문 쓰기',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 8,
      minLines: 5,
      maxLength: 500,
      decoration: InputDecoration(
        hintText: '이 말씀을 읽고 떠오른 생각이나 감사한 마음을 적어보세요',
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

/// Scripture preview widget showing content in a purple container
class _ScripturePreview extends StatelessWidget {
  final Scripture scripture;

  const _ScripturePreview({required this.scripture});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            scripture.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            scripture.reference,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action buttons row with Cancel and Save buttons
class _ActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _ActionButtons({
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton.text(
            onPressed: onCancel,
            text: '취소',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: AppButton.primary(
            onPressed: onSave,
            text: '저장하기',
          ),
        ),
      ],
    );
  }
}
