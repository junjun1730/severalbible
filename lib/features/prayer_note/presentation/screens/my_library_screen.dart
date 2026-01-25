import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/prayer_note_providers.dart';
import '../widgets/prayer_calendar.dart';
import '../widgets/prayer_note_card.dart';
import 'package:severalbible/features/subscription/presentation/widgets/upsell_dialog.dart';
import '../../../auth/domain/user_tier.dart';
import '../../../auth/providers/auth_providers.dart';

/// My Library screen showing calendar and prayer notes
class MyLibraryScreen extends ConsumerStatefulWidget {
  const MyLibraryScreen({super.key});

  @override
  ConsumerState<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends ConsumerState<MyLibraryScreen> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    ref.read(selectedDateProvider.notifier).state = selectedDay;
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final notesAsync = ref.watch(prayerNoteListProvider);
    final datesWithNotesAsync = ref.watch(datesWithNotesProvider(_focusedDay));

    return Scaffold(
      appBar: AppBar(title: const Text('My Library'), centerTitle: true),
      body: Column(
        children: [
          // Calendar section
          datesWithNotesAsync.when(
            data: (datesWithNotes) => PrayerCalendar(
              focusedDay: _focusedDay,
              selectedDay: selectedDate,
              datesWithNotes: datesWithNotes,
              onDaySelected: _onDaySelected,
              onPageChanged: _onPageChanged,
            ),
            loading: () => PrayerCalendar(
              focusedDay: _focusedDay,
              selectedDay: selectedDate,
              datesWithNotes: const {},
              onDaySelected: _onDaySelected,
              onPageChanged: _onPageChanged,
            ),
            error: (_, __) => PrayerCalendar(
              focusedDay: _focusedDay,
              selectedDay: selectedDate,
              datesWithNotes: const {},
              onDaySelected: _onDaySelected,
              onPageChanged: _onPageChanged,
            ),
          ),
          const Divider(height: 1),
          // Notes list section
          Expanded(
            child: notesAsync.when(
              data: (notes) {
                if (notes.isEmpty) {
                  return _buildEmptyState(context);
                }

                final tierAsync = ref.watch(currentUserTierProvider);
                final tier = tierAsync.valueOrNull ?? UserTier.guest;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];

                    // Lock logic: Free users can only see notes from the last 3 days
                    final isLocked =
                        tier != UserTier.premium &&
                        note.createdAt.isBefore(
                          DateTime.now().subtract(const Duration(days: 3)),
                        );

                    return PrayerNoteCard(
                      note: note,
                      isLocked: isLocked,
                      onTap: isLocked
                          ? () => showDialog(
                              context: context,
                              builder: (context) => const UpsellDialog(
                                trigger: UpsellTrigger.archiveLocked,
                              ),
                            )
                          : null,
                      onEdit: isLocked ? null : () => _handleEdit(note.id),
                      onDelete: isLocked ? null : () => _handleDelete(note.id),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _buildErrorState(context, error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No meditations for this day',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by reading today\'s scripture',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading notes',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => ref.invalidate(prayerNoteListProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _handleEdit(String noteId) {
    // TODO: Navigate to edit screen or show edit dialog
  }

  void _handleDelete(String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meditation'),
        content: const Text('Are you sure you want to delete this meditation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final controller = ref.read(
                prayerNoteFormControllerProvider.notifier,
              );
              await controller.deleteNote(noteId: noteId);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
