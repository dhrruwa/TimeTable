import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/timetable_models.dart';
import '../providers/providers.dart';
import '../widgets/color_picker.dart';
import '../widgets/time_utils.dart';

/// Add or edit a class slot. Optimized to add a class in under 15 seconds:
/// course defaults to the first one, sensible day/time defaults, native time
/// pickers, and inline quick-add for a new course without leaving the screen.
class EditSlotScreen extends ConsumerStatefulWidget {
  final ClassSlot? existing;

  /// Optional starting day/time (e.g. when tapping an empty grid cell later).
  final int? initialDay;

  const EditSlotScreen({super.key, this.existing, this.initialDay});

  @override
  ConsumerState<EditSlotScreen> createState() => _EditSlotScreenState();
}

class _EditSlotScreenState extends ConsumerState<EditSlotScreen> {
  String? _courseId;
  late int _dayOfWeek;
  late int _startMinutes;
  late int _endMinutes;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    final courses = ref.read(timetableProvider).courses;
    _courseId = s?.courseId ??
        (courses.isNotEmpty ? courses.first.id : null);
    _dayOfWeek = s?.dayOfWeek ??
        widget.initialDay ??
        DateTime.now().weekday.clamp(1, 6);
    _startMinutes = s?.startMinutes ?? 9 * 60;
    _endMinutes = s?.endMinutes ?? 10 * 60;
  }

  Future<void> _pickStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeUtils.toTimeOfDay(_startMinutes),
      helpText: 'Start time',
    );
    if (picked == null) return;
    setState(() {
      _startMinutes = TimeUtils.toMinutes(picked);
      // Keep end after start; preserve duration if possible.
      if (_endMinutes <= _startMinutes) {
        _endMinutes = (_startMinutes + 60).clamp(0, 24 * 60);
      }
    });
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeUtils.toTimeOfDay(_endMinutes),
      helpText: 'End time',
    );
    if (picked == null) return;
    setState(() => _endMinutes = TimeUtils.toMinutes(picked));
  }

  Future<void> _quickAddCourse() async {
    final created = await showModalBottomSheet<Course>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _QuickAddCourseSheet(),
    );
    if (created != null) {
      setState(() => _courseId = created.id);
    }
  }

  String? _validate() {
    if (_courseId == null) return 'Pick or add a course first.';
    if (_endMinutes <= _startMinutes) {
      return 'End time must be after the start time.';
    }
    return null;
  }

  void _save() {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final notifier = ref.read(timetableProvider.notifier);
    final slot = (widget.existing ??
            ClassSlot(
              id: notifier.newId(),
              courseId: _courseId!,
              dayOfWeek: _dayOfWeek,
              startMinutes: _startMinutes,
              endMinutes: _endMinutes,
            ))
        .copyWith(
      courseId: _courseId,
      dayOfWeek: _dayOfWeek,
      startMinutes: _startMinutes,
      endMinutes: _endMinutes,
    );
    notifier.upsertSlot(slot);
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this class?'),
        content: const Text('This removes the class from your timetable.'),
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
    if (confirmed == true) {
      await ref
          .read(timetableProvider.notifier)
          .deleteSlot(widget.existing!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = [...ref.watch(timetableProvider).courses]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit class' : 'New class'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Course
          Text('Course', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: courses.any((c) => c.id == _courseId)
                      ? _courseId
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.menu_book_outlined),
                    hintText: 'Select a course',
                  ),
                  items: [
                    for (final c in courses)
                      DropdownMenuItem(
                        value: c.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                                radius: 7, backgroundColor: Color(c.color)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(c.name,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _courseId = v),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Quick-add course',
                onPressed: _quickAddCourse,
                icon: const Icon(Icons.add),
              ),
            ],
          ),

          const SizedBox(height: 24),
          // Day
          Text('Day', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (var d = 1; d <= 7; d++)
                ChoiceChip(
                  label: Text(TimeUtils.dayShort(d)),
                  selected: _dayOfWeek == d,
                  onSelected: (_) => setState(() => _dayOfWeek = d),
                ),
            ],
          ),

          const SizedBox(height: 24),
          // Times
          Text('Time', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  label: 'Start',
                  value: TimeUtils.formatMinutes(context, _startMinutes),
                  onTap: _pickStart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeField(
                  label: 'End',
                  value: TimeUtils.formatMinutes(context, _endMinutes),
                  onTap: _pickEnd,
                ),
              ),
            ],
          ),
          if (_endMinutes > _startMinutes)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Duration: ${TimeUtils.durationLabel(_endMinutes - _startMinutes)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),

          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: Text(_isEditing ? 'Save changes' : 'Add class'),
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.schedule),
        ),
        child: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

/// Minimal inline course creation: just a name + color, so adding a class while
/// missing its course stays fast. Returns the created [Course].
class _QuickAddCourseSheet extends ConsumerStatefulWidget {
  const _QuickAddCourseSheet();

  @override
  ConsumerState<_QuickAddCourseSheet> createState() =>
      _QuickAddCourseSheetState();
}

class _QuickAddCourseSheetState extends ConsumerState<_QuickAddCourseSheet> {
  final _name = TextEditingController();
  int _color = CoursePalettePicker.palette.first;
  bool _error = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _create() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = true);
      return;
    }
    final notifier = ref.read(timetableProvider.notifier);
    final course = Course(id: notifier.newId(), name: name, color: _color);
    notifier.upsertCourse(course);
    Navigator.of(context).pop(course);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick-add course',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _create(),
            decoration: InputDecoration(
              labelText: 'Course name',
              prefixIcon: const Icon(Icons.menu_book_outlined),
              errorText: _error ? 'Enter a name' : null,
            ),
          ),
          const SizedBox(height: 16),
          CoursePalettePicker(
            selectedColor: _color,
            onChanged: (v) => setState(() => _color = v),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.check),
              label: const Text('Add course'),
            ),
          ),
        ],
      ),
    );
  }
}
