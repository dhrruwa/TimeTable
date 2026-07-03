import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/import_mapper.dart';
import '../providers/community_providers.dart';
import '../providers/widget_providers.dart';
import '../widgets/time_utils.dart';

/// Mandatory review step after a magic import. The extracted [DraftTimetable] is
/// fully editable here — meta, per-day class order (order = time in this app),
/// subject/teacher/room, and lab toggle — and is only written to local storage
/// when the user confirms. Cancelling discards everything.
class ImportReviewScreen extends ConsumerStatefulWidget {
  final DraftTimetable draft;
  const ImportReviewScreen({super.key, required this.draft});

  @override
  ConsumerState<ImportReviewScreen> createState() => _ImportReviewScreenState();
}

class _ImportReviewScreenState extends ConsumerState<ImportReviewScreen> {
  late final DraftTimetable _draft = widget.draft;
  late final TextEditingController _university =
      TextEditingController(text: _draft.university);
  late final TextEditingController _branch =
      TextEditingController(text: _draft.branch);
  late final TextEditingController _semester =
      TextEditingController(text: _draft.semester);
  late final TextEditingController _section =
      TextEditingController(text: _draft.section);
  bool _saving = false;

  static const _dayNames = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
  };

  @override
  void dispose() {
    _university.dispose();
    _branch.dispose();
    _semester.dispose();
    _section.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_draft.periodCount == 0) {
      _toast('Add at least one class before saving.');
      return;
    }
    setState(() => _saving = true);
    _draft
      ..university = _university.text
      ..branch = _branch.text
      ..semester = _semester.text
      ..section = _section.text;

    final timetable =
        _draft.toTimetable(nowMs: DateTime.now().millisecondsSinceEpoch);

    try {
      // The part that matters — save locally. Fast and fully offline.
      await ref.read(timetableProvider.notifier).replaceWith(timetable);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        _toast("Couldn't save. Please try again.");
      }
      return;
    }

    // Register interest in the community entry in the background — never block
    // the save (or trap the user on a spinner) on a network round-trip.
    if (timetable.meta.isComplete) {
      ref.read(communityRepositoryProvider).join(timetable.meta.matchKey).ignore();
    }

    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Timetable imported')),
    );
  }

  Future<bool> _confirmDiscard() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard import?'),
        content: const Text("The extracted timetable hasn't been saved yet."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep editing')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Discard')),
        ],
      ),
    );
    return ok ?? false;
  }

  void _toast(String m) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(m)));

  // ---- Row editing -------------------------------------------------------

  Future<void> _editPeriod(int weekday, int index) async {
    final list = _draft.week[weekday]!;
    final edited = await showModalBottomSheet<DraftPeriod>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PeriodEditor(original: list[index]),
    );
    if (edited != null) setState(() => list[index] = edited);
  }

  Future<void> _addPeriod(int weekday) async {
    final created = await showModalBottomSheet<DraftPeriod>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PeriodEditor(original: DraftPeriod(subject: '')),
    );
    if (created != null) {
      setState(() => (_draft.week[weekday] ??= []).add(created));
    }
  }

  void _deletePeriod(int weekday, int index) {
    setState(() {
      final list = _draft.week[weekday]!;
      list.removeAt(index);
      if (list.isEmpty) _draft.week.remove(weekday);
    });
  }

  void _reorder(int weekday, int oldIndex, int newIndex) {
    setState(() {
      final list = _draft.week[weekday]!;
      if (newIndex > oldIndex) newIndex -= 1;
      list.insert(newIndex, list.removeAt(oldIndex));
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = _dayNames.keys
        .where((d) => (_draft.week[d]?.isNotEmpty ?? false))
        .toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard() && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Review import'),
        ),
        body: AbsorbPointer(
          absorbing: _saving,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: scheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Check the classes below and fix anything. Order = time, '
                        'so drag to reorder. Nothing is saved until you confirm.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _metaField(_university, 'University', Icons.school_outlined),
              _metaField(_branch, 'Branch / Department', Icons.account_tree_outlined),
              Row(
                children: [
                  Expanded(
                      child:
                          _metaField(_semester, 'Semester', Icons.timelapse)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _metaField(
                          _section, 'Section', Icons.groups_outlined)),
                ],
              ),
              const SizedBox(height: 12),
              _detectedTimings(context),
              const SizedBox(height: 4),
              if (days.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('No classes left. Add some below.',
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                  ),
                ),
              for (final weekday in days) _daySection(weekday),
              const SizedBox(height: 8),
              // Let the user add a class to a day that has none yet.
              Wrap(
                spacing: 8,
                children: [
                  for (final d in _dayNames.keys)
                    if (!(_draft.week[d]?.isNotEmpty ?? false))
                      ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: Text(_dayNames[d]!.substring(0, 3)),
                        onPressed: () => _addPeriod(d),
                      ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.download_done),
                label: const Text('Save timetable'),
                style:
                    FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Read-only summary of the timings detected from the image. These flow into
  /// the saved timetable; fine-tune them later in Schedule settings.
  Widget _detectedTimings(BuildContext context) {
    final cfg = _draft.config;
    final scheme = Theme.of(context).colorScheme;
    final parts = <String>[
      'Starts ${TimeUtils.formatMinutes(context, cfg.dayStartMin)}',
      '${cfg.classMins}-min periods',
      if (cfg.teaMins > 0) 'tea after P${cfg.teaAfter}',
      if (cfg.lunchMins > 0) 'lunch after P${cfg.lunchAfter}',
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Detected timings: ${parts.join(' · ')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaField(
      TextEditingController c, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _daySection(int weekday) {
    final list = _draft.week[weekday] ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
          child: Row(
            children: [
              Text(_dayNames[weekday]!,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _addPeriod(weekday),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: list.length,
          onReorder: (o, n) => _reorder(weekday, o, n),
          itemBuilder: (context, i) {
            final p = list[i];
            return _periodTile(weekday, i, p);
          },
        ),
      ],
    );
  }

  Widget _periodTile(int weekday, int index, DraftPeriod p) {
    final scheme = Theme.of(context).colorScheme;
    final subtitleParts = [
      if ((p.teacher ?? '').isNotEmpty) p.teacher!,
      if ((p.room ?? '').isNotEmpty) p.room!,
    ];
    return Card(
      // Key must track the item's identity (not its index) so reordering works.
      key: ObjectKey(p),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                p.subject.trim().isEmpty ? 'Unknown' : p.subject,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (p.isLab) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('LAB',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: scheme.onTertiaryContainer)),
              ),
            ],
          ],
        ),
        subtitle:
            subtitleParts.isEmpty ? null : Text(subtitleParts.join(' · ')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editPeriod(weekday, index),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: scheme.error),
              onPressed: () => _deletePeriod(weekday, index),
            ),
          ],
        ),
        onTap: () => _editPeriod(weekday, index),
      ),
    );
  }
}

/// Bottom-sheet editor for one [DraftPeriod]. Returns the edited copy, or null
/// if cancelled.
class _PeriodEditor extends StatefulWidget {
  final DraftPeriod original;
  const _PeriodEditor({required this.original});

  @override
  State<_PeriodEditor> createState() => _PeriodEditorState();
}

class _PeriodEditorState extends State<_PeriodEditor> {
  late final TextEditingController _subject =
      TextEditingController(text: widget.original.subject);
  late final TextEditingController _teacher =
      TextEditingController(text: widget.original.teacher ?? '');
  late final TextEditingController _room =
      TextEditingController(text: widget.original.room ?? '');
  late bool _isLab = widget.original.isLab;

  @override
  void dispose() {
    _subject.dispose();
    _teacher.dispose();
    _room.dispose();
    super.dispose();
  }

  void _done() {
    final subject = _subject.text.trim();
    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject name is required.')),
      );
      return;
    }
    Navigator.pop(
      context,
      DraftPeriod(
        subject: subject,
        teacher: _teacher.text.trim().isEmpty ? null : _teacher.text.trim(),
        room: _room.text.trim().isEmpty ? null : _room.text.trim(),
        isLab: _isLab,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Edit class',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _subject,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _teacher,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Faculty (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _room,
            decoration: const InputDecoration(
              labelText: 'Room (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Lab (longer block)'),
            value: _isLab,
            onChanged: (v) => setState(() => _isLab = v),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _done,
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48)),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
