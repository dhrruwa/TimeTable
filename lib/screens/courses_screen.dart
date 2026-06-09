import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/timetable_models.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/empty_state.dart';
import 'edit_course_screen.dart';

/// List of courses with add / edit / delete. Deleting a course that still has
/// slots prompts for confirmation first.
class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timetable = ref.watch(timetableProvider);
    final courses = [...timetable.courses]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Course'),
      ),
      body: courses.isEmpty
          ? EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No courses yet',
              message: 'Add the courses you take, then schedule their classes.',
              action: FilledButton.icon(
                onPressed: () => _openEditor(context),
                icon: const Icon(Icons.add),
                label: const Text('Add course'),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final course = courses[i];
                final slotCount = ref
                    .read(timetableProvider.notifier)
                    .slotCountForCourse(course.id);
                return _CourseTile(
                  course: course,
                  slotCount: slotCount,
                  onEdit: () => _openEditor(context, course),
                  onDelete: () => _confirmDelete(context, ref, course, slotCount),
                );
              },
            ),
    );
  }

  void _openEditor(BuildContext context, [Course? course]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditCourseScreen(existing: course)),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Course course,
    int slotCount,
  ) async {
    // Only prompt when there are slots that would be removed too.
    if (slotCount > 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Delete "${course.name}"?'),
          content: Text(
            'This course has $slotCount scheduled '
            '${slotCount == 1 ? 'class' : 'classes'}. '
            'Deleting it will remove ${slotCount == 1 ? 'that class' : 'them'} too.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.errorContainer,
                foregroundColor: Theme.of(ctx).colorScheme.onErrorContainer,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await ref.read(timetableProvider.notifier).deleteCourse(course.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${course.name}"')),
      );
    }
  }
}

class _CourseTile extends StatelessWidget {
  final Course course;
  final int slotCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CourseTile({
    required this.course,
    required this.slotCount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(course.color);
    final subtitleParts = <String>[
      if (course.instructor != null && course.instructor!.isNotEmpty)
        course.instructor!,
      if (course.room != null && course.room!.isNotEmpty) course.room!,
    ];

    return Card(
      child: ListTile(
        onTap: onEdit,
        leading: CircleAvatar(backgroundColor: color, radius: 14),
        title: Text(course.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          [
            if (subtitleParts.isNotEmpty) subtitleParts.join(' · '),
            '$slotCount ${slotCount == 1 ? 'class' : 'classes'}/week',
          ].join('  •  '),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
