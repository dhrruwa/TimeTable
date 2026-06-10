import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/period_models.dart';
import '../providers/widget_providers.dart';
import '../widgets/empty_state.dart';
import 'edit_day_screen.dart' show SubjectSheet;

/// Manage subjects and their colors. Deleting a subject that's still scheduled
/// asks for confirmation (and removes its periods).
class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = [...ref.watch(timetableProvider).subjects]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add),
        label: const Text('Subject'),
      ),
      body: subjects.isEmpty
          ? EmptyState(
              icon: Icons.palette_outlined,
              title: 'No subjects yet',
              message: 'Add your subjects and give each one a color.',
              action: FilledButton.icon(
                onPressed: () => _edit(context),
                icon: const Icon(Icons.add),
                label: const Text('Add subject'),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
              itemCount: subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final s = subjects[i];
                final count = ref
                    .read(timetableProvider.notifier)
                    .subjectUsageCount(s.id);
                return Card(
                  child: ListTile(
                    onTap: () => _edit(context, s),
                    leading: CircleAvatar(
                        radius: 14, backgroundColor: Color(s.color)),
                    title: Text(s.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '$count ${count == 1 ? 'class' : 'classes'} / week'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(context, ref, s, count),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _edit(BuildContext context, [Subject? subject]) {
    showModalBottomSheet<Subject>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SubjectSheet(existing: subject),
    );
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, Subject s, int count) async {
    if (count > 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Delete "${s.name}"?'),
          content: Text(
              'This subject is used by $count ${count == 1 ? 'class' : 'classes'}. '
              'Deleting it removes ${count == 1 ? 'that class' : 'them'} too.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await ref.read(timetableProvider.notifier).deleteSubject(s.id);
  }
}
