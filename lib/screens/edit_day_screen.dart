import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/timetable_builder.dart';
import '../models/period_models.dart';
import '../providers/widget_providers.dart';
import '../widgets/color_picker.dart';
import '../widgets/time_utils.dart';

/// Edit one weekday's ordered list of periods. The order determines the times
/// (computed live), so reordering is the same as rescheduling.
class EditDayScreen extends ConsumerWidget {
  final int weekday;
  const EditDayScreen({super.key, required this.weekday});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(timetableProvider);
    final periods = t.periodsOn(weekday);
    final timeline =
        TimetableBuilder.buildDay(periods, t.subjectsById, t.config);
    // Map period id -> its computed class entry (for showing times).
    final classEntries = timeline.where((e) => e.isClass).toList();

    return Scaffold(
      appBar: AppBar(title: Text(TimeUtils.dayName(weekday))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Class'),
      ),
      body: periods.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_note_outlined,
                        size: 56, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('No classes on ${TimeUtils.dayName(weekday)}',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text('Add classes in order — times are filled in for you.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                  ],
                ),
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
              itemCount: periods.length,
              onReorder: (oldI, newI) {
                final list = [...periods];
                if (newI > oldI) newI -= 1;
                final item = list.removeAt(oldI);
                list.insert(newI, item);
                ref
                    .read(timetableProvider.notifier)
                    .setDayPeriods(weekday, list);
              },
              itemBuilder: (context, i) {
                final p = periods[i];
                final subject = t.subjectById(p.subjectId);
                final entry = i < classEntries.length ? classEntries[i] : null;
                return _PeriodRow(
                  key: ValueKey(p.id),
                  index: i,
                  period: p,
                  subject: subject,
                  timeLabel: entry == null
                      ? ''
                      : '${TimeUtils.formatMinutes(context, entry.startMin)}'
                          ' – ${TimeUtils.formatMinutes(context, entry.endMin)}',
                  onTap: () => _addOrEdit(context, ref, existing: p),
                  onDelete: () => ref
                      .read(timetableProvider.notifier)
                      .deletePeriod(weekday, p.id),
                );
              },
            ),
    );
  }

  Future<void> _addOrEdit(BuildContext context, WidgetRef ref,
      {Period? existing}) async {
    final result = await showModalBottomSheet<Period>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PeriodSheet(weekday: weekday, existing: existing),
    );
    if (result == null) return;
    final notifier = ref.read(timetableProvider.notifier);
    if (existing == null) {
      notifier.addPeriod(weekday, result);
    } else {
      notifier.updatePeriod(weekday, result);
    }
  }
}

class _PeriodRow extends StatelessWidget {
  final int index;
  final Period period;
  final Subject? subject;
  final String timeLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PeriodRow({
    required super.key,
    required this.index,
    required this.period,
    required this.subject,
    required this.timeLabel,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(subject?.color ?? 0xFF888888);
    final subtitle = [
      timeLabel,
      if (period.teacher != null && period.teacher!.isNotEmpty) period.teacher!,
      if (period.room != null && period.room!.isNotEmpty) period.room!,
    ].where((s) => s.isNotEmpty).join('  ·  ');

    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(radius: 12, backgroundColor: color),
        title: Row(
          children: [
            Flexible(
              child: Text(subject?.name ?? 'Unknown',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            if (period.isLab)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(5)),
                child: Text('LAB',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
          ],
        ),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.drag_handle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet to add/edit a period: pick subject (or quick-add), room,
/// teacher, and the Lab toggle.
class _PeriodSheet extends ConsumerStatefulWidget {
  final int weekday;
  final Period? existing;
  const _PeriodSheet({required this.weekday, this.existing});

  @override
  ConsumerState<_PeriodSheet> createState() => _PeriodSheetState();
}

class _PeriodSheetState extends ConsumerState<_PeriodSheet> {
  String? _subjectId;
  late final TextEditingController _room;
  late final TextEditingController _teacher;
  bool _isLab = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _subjectId = e?.subjectId;
    _room = TextEditingController(text: e?.room ?? '');
    _teacher = TextEditingController(text: e?.teacher ?? '');
    _isLab = e?.isLab ?? false;
  }

  @override
  void dispose() {
    _room.dispose();
    _teacher.dispose();
    super.dispose();
  }

  void _save() {
    if (_subjectId == null) return;
    final notifier = ref.read(timetableProvider.notifier);
    final room = _room.text.trim();
    final teacher = _teacher.text.trim();
    final period = (widget.existing ??
            Period(id: notifier.newId(), subjectId: _subjectId!))
        .copyWith(
      subjectId: _subjectId,
      room: room.isEmpty ? null : room,
      teacher: teacher.isEmpty ? null : teacher,
      isLab: _isLab,
    );
    Navigator.of(context).pop(period);
  }

  @override
  Widget build(BuildContext context) {
    final subjects = [...ref.watch(timetableProvider).subjects]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.existing == null ? 'Add class' : 'Edit class',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: subjects.any((s) => s.id == _subjectId)
                      ? _subjectId
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    prefixIcon: Icon(Icons.menu_book_outlined),
                  ),
                  items: [
                    for (final s in subjects)
                      DropdownMenuItem(
                        value: s.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                                radius: 7, backgroundColor: Color(s.color)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(s.name,
                                    overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _subjectId = v),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'New subject',
                onPressed: _quickAddSubject,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _room,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
                labelText: 'Room (optional)',
                prefixIcon: Icon(Icons.place_outlined)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _teacher,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                labelText: 'Teacher (optional)',
                prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Lab (2-hour block)'),
            value: _isLab,
            onChanged: (v) => setState(() => _isLab = v),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _subjectId == null ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(widget.existing == null ? 'Add' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _quickAddSubject() async {
    final created = await showModalBottomSheet<Subject>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SubjectSheet(),
    );
    if (created != null) setState(() => _subjectId = created.id);
  }
}

/// Reusable add/edit-subject sheet (name + color). Returns the saved [Subject].
class SubjectSheet extends ConsumerStatefulWidget {
  final Subject? existing;
  const SubjectSheet({super.key, this.existing});

  @override
  ConsumerState<SubjectSheet> createState() => _SubjectSheetState();
}

class _SubjectSheetState extends ConsumerState<SubjectSheet> {
  late final TextEditingController _name;
  late int _color;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _color = widget.existing?.color ??
        ref.read(timetableProvider.notifier).nextSubjectColor();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = true);
      return;
    }
    final notifier = ref.read(timetableProvider.notifier);
    final subject = (widget.existing ??
            Subject(id: notifier.newId(), name: name, color: _color))
        .copyWith(name: name, color: _color);
    notifier.upsertSubject(subject);
    Navigator.of(context).pop(subject);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.existing == null ? 'New subject' : 'Edit subject',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: 'Subject name',
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
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Save subject'),
            ),
          ),
        ],
      ),
    );
  }
}
