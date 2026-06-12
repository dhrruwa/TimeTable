// Weekly timetable as a zoomable, continuous spreadsheet: rows = dated weekdays
// (current week + the next few), columns = periods with hatched break columns.
// Long-press a class -> action bar at the TOP (Duplicate / Move / Edit / Delete);
// Move/Duplicate enters placement mode (top bar with Undo / Done). Pinch to zoom.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/period_models.dart';
import '../providers/community_providers.dart';
import '../providers/providers.dart';
import '../providers/widget_providers.dart';
import '../state/placement_state.dart';
import '../theme.dart';
import '../widgets/time_utils.dart';
import 'edit_day_screen.dart';

// ─── selection (long-pressed cell) ───────────────────────────────────────────

class WeekCellSelection {
  final int day;
  final int pos;
  final Period period;
  final Subject subject;
  const WeekCellSelection(this.day, this.pos, this.period, this.subject);
}

final weekSelectionProvider =
    StateProvider<WeekCellSelection?>((ref) => null);

// ─── helpers ──────────────────────────────────────────────────────────────────

String _minToHHMM(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return '$h:${m.toString().padLeft(2, '0')}';
}

class _PeriodHeader {
  final int classPos;
  final String label;
  final String timeRange;
  final int startMin;
  final int endMin;
  const _PeriodHeader({
    required this.classPos,
    required this.label,
    required this.timeRange,
    required this.startMin,
    required this.endMin,
  });
}

List<_PeriodHeader> _buildPeriodHeaders(TimetableConfig cfg, int classCount) {
  final headers = <_PeriodHeader>[];
  int cursor = cfg.dayStartMin;
  for (int i = 1; i <= classCount; i++) {
    final start = cursor;
    final end = cursor + cfg.classMins;
    headers.add(_PeriodHeader(
      classPos: i,
      label: 'P$i',
      timeRange: '${_minToHHMM(start)}–${_minToHHMM(end)}',
      startMin: start,
      endMin: end,
    ));
    cursor = end;
    if (i == cfg.teaAfter) cursor += cfg.teaMins;
    if (i == cfg.lunchAfter) cursor += cfg.lunchMins;
  }
  return headers;
}

class _Col {
  final int? classPos;
  final EntryKind? breakKind;
  const _Col.classIndex(this.classPos) : breakKind = null;
  const _Col.brk(this.breakKind) : classPos = null;
  bool get isBreak => breakKind != null;
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

// ─── WeekScreen ────────────────────────────────────────────────────────────────

class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  static const double _dayColW = 60;
  static const double _cellW = 138;
  static const double _breakW = 36;
  static const double _cellH = 92;
  static const double _headerH = 56;
  static const int _weeksToShow = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(timetableProvider);
    final now = ref.watch(nowProvider);
    final placement = ref.watch(placementProvider);
    final selection = ref.watch(weekSelectionProvider);
    final deviceId = ref.watch(appPrefsProvider).deviceId;
    final isCreator = t.meta.creatorId == null || t.meta.creatorId == deviceId;
    final scheme = Theme.of(context).colorScheme;

    final startMonday = TimeUtils.mondayOf(now);
    final todayDate = DateTime(now.year, now.month, now.day);
    final todayWeekday = now.weekday;

    final dayTimelines = {
      for (var d = 1; d <= 6; d++) d: ref.watch(timelineForDayProvider(d)),
    };
    final dayClasses = {
      for (var d = 1; d <= 6; d++)
        d: dayTimelines[d]!.where((e) => e.isClass).toList()
    };

    final maxClasses = dayClasses.values
        .map((l) => l.length)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final classCount = maxClasses == 0 ? 6 : maxClasses;

    final columns = <_Col>[];
    for (var i = 1; i <= classCount; i++) {
      columns.add(_Col.classIndex(i));
      if (i == t.config.teaAfter) columns.add(const _Col.brk(EntryKind.tea));
      if (i == t.config.lunchAfter) columns.add(const _Col.brk(EntryKind.lunch));
    }

    final headers = _buildPeriodHeaders(t.config, classCount);
    final headerMap = {for (final h in headers) h.classPos: h};

    final hhmm = now.hour * 60 + now.minute;
    int? currentClassPos;
    for (final h in headers) {
      if (hhmm >= h.startMin && hhmm < h.endMin) {
        currentClassPos = h.classPos;
        break;
      }
    }

    final saturday = startMonday.add(const Duration(days: 5));
    final rangeLabel = '${startMonday.day} ${_months[startMonday.month - 1]} – '
        '${saturday.day} ${_months[saturday.month - 1]} ${saturday.year}';

    // ── handlers ──────────────────────────────────────────────────────────
    void clearSelection() =>
        ref.read(weekSelectionProvider.notifier).state = null;

    void longPressCell(int day, int pos, Period period) {
      final subject = t.subjectById(period.subjectId);
      if (subject == null) return;
      ref.read(weekSelectionProvider.notifier).state =
          WeekCellSelection(day, pos, period, subject);
    }

    void startPlacement(WeekCellSelection sel, {required bool move}) {
      clearSelection();
      final targets =
          computeValidTargets(t, sel.day, sel.pos, sel.period.isLab);
      ref.read(placementProvider.notifier).state = PlacementState(
        active: true,
        isMove: move,
        sourceDay: sel.day,
        sourcePeriodPos: sel.pos,
        snapshot: sel.period,
        subject: sel.subject,
        validTargets: targets,
        placed: const [],
      );
      if (targets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No free slots to place into')),
        );
      }
    }

    void cancelPlacement() =>
        ref.read(placementProvider.notifier).state = PlacementState.inactive;

    Future<void> roomPrompt(int day, String id, String? room) async {
      final hasRoom = room != null && room.isNotEmpty;
      final keep = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(hasRoom ? 'Same room ($room)?' : 'Set a room?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Change')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(hasRoom ? 'Keep' : 'Skip')),
          ],
        ),
      );
      if (keep != false || !context.mounted) return;
      final controller = TextEditingController(text: room ?? '');
      final newRoom = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Room number'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'e.g. LH-101'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                child: const Text('Save')),
          ],
        ),
      );
      if (newRoom == null || newRoom.isEmpty) return;
      final list = ref.read(timetableProvider).periodsOn(day);
      final idx = list.indexWhere((p) => p.id == id);
      if (idx >= 0) {
        await ref
            .read(timetableProvider.notifier)
            .updatePeriod(day, list[idx].copyWith(room: newRoom));
      }
    }

    Future<void> placeAt(int day, int pos) async {
      final ps = ref.read(placementProvider);
      if (!ps.active || ps.snapshot == null) return;
      final notifier = ref.read(timetableProvider.notifier);
      final newId = notifier.newId();
      final copy = ps.snapshot!.copyWith(id: newId);
      await notifier.addPeriod(day, copy);
      if (ps.isMove && ps.sourceDay != null) {
        await notifier.deletePeriod(ps.sourceDay!, ps.snapshot!.id);
      }
      final t2 = ref.read(timetableProvider);
      ref.read(placementProvider.notifier).state = ps.copyWith(
        isMove: false,
        validTargets: computeValidTargets(t2, ps.sourceDay ?? day,
            ps.sourcePeriodPos ?? pos, ps.snapshot!.isLab),
        placed: [...ps.placed, (day: day, id: newId)],
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          duration: const Duration(milliseconds: 1100),
          content: Text(
              '${ps.subject?.name ?? 'Class'} added to ${TimeUtils.dayName(day)}'),
        ));
      await roomPrompt(day, newId, copy.room);
    }

    Future<void> undo() async {
      final ps = ref.read(placementProvider);
      if (ps.placed.isEmpty) return;
      final last = ps.placed.last;
      await ref.read(timetableProvider.notifier).deletePeriod(last.day, last.id);
      final t2 = ref.read(timetableProvider);
      ref.read(placementProvider.notifier).state = ps.copyWith(
        placed: ps.placed.sublist(0, ps.placed.length - 1),
        validTargets: computeValidTargets(t2, ps.sourceDay ?? 1,
            ps.sourcePeriodPos ?? 0, ps.snapshot?.isLab ?? false),
      );
    }

    Future<void> confirmDelete(WeekCellSelection sel) async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Delete ${sel.subject.name}?'),
          content:
              Text('Remove this class from ${TimeUtils.dayName(sel.day)}?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton.tonal(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete')),
          ],
        ),
      );
      clearSelection();
      if (ok == true) {
        await ref
            .read(timetableProvider.notifier)
            .deletePeriod(sel.day, sel.period.id);
      }
    }

    void openDay(int day) => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EditDayScreen(weekday: day)),
        );

    // ── top bar (animated) ──────────────────────────────────────────────────
    Widget topBar = const SizedBox.shrink();
    if (placement.active) {
      topBar = _PlacementBar(
        key: const ValueKey('placement'),
        subjectName: placement.subject?.name ?? 'class',
        isMove: placement.isMove,
        onCancel: cancelPlacement,
        onUndo: placement.placed.isNotEmpty ? undo : null,
      );
    } else if (selection != null) {
      topBar = _ActionBar(
        key: const ValueKey('actions'),
        subjectName: selection.subject.name,
        onDuplicate: () => startPlacement(selection, move: false),
        onMove: () => startPlacement(selection, move: true),
        onEdit: () {
          clearSelection();
          openDay(selection.day);
        },
        onDelete: () => confirmDelete(selection),
        onClose: clearSelection,
      );
    }

    // ── continuous canvas of dated weekday rows ─────────────────────────────
    final rows = <Widget>[
      _HeaderRow(columns: columns, headerMap: headerMap, current: currentClassPos),
    ];
    for (var w = 0; w < _weeksToShow; w++) {
      for (var d = 1; d <= 6; d++) {
        final date = startMonday.add(Duration(days: w * 7 + (d - 1)));
        final isToday = DateTime(date.year, date.month, date.day) == todayDate;
        rows.add(_DayRow(
          weekday: d,
          date: date,
          isToday: isToday,
          isPast: DateTime(date.year, date.month, date.day).isBefore(todayDate),
          currentClassPos: isToday ? currentClassPos : null,
          todayWeekday: todayWeekday,
          columns: columns,
          classes: dayClasses[d]!,
          periods: t.periodsOn(d),
          placement: placement,
          selection: selection,
          canEdit: isCreator,
          onTapDay: () => openDay(d),
          onLongPressCell: longPressCell,
          onPlace: placeAt,
        ));
      }
    }

    final breakCount = columns.where((c) => c.isBreak).length;
    final totalW = _dayColW + classCount * _cellW + breakCount * _breakW;
    const totalH = _headerH + (_weeksToShow * 6) * _cellH;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Week'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(22),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(rangeLabel,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant)),
          ),
        ),
      ),
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => SizeTransition(
              sizeFactor: anim,
              axisAlignment: -1,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: topBar,
          ),
          // A single canvas keeps pinch-zoom and two-dimensional panning from
          // competing with separate horizontal and vertical scroll views.
          Expanded(
            child: InteractiveViewer(
              constrained: false,
              panEnabled: true,
              scaleEnabled: true,
              minScale: 0.45,
              maxScale: 3,
              boundaryMargin: const EdgeInsets.all(80),
              trackpadScrollCausesScale: true,
              scaleFactor: 160,
              child: SizedBox(
                width: totalW,
                height: totalH + 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: rows,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── top action bar (long-press) ──────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final String subjectName;
  final VoidCallback onDuplicate;
  final VoidCallback onMove;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onClose;
  const _ActionBar({
    super.key,
    required this.subjectName,
    required this.onDuplicate,
    required this.onMove,
    required this.onEdit,
    required this.onDelete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.secondaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Row(
            children: [
              const SizedBox(width: 4),
              Expanded(
                child: Text(subjectName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: scheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700)),
              ),
              _act(context, Icons.content_copy_outlined, 'Copy', onDuplicate),
              _act(context, Icons.swap_horiz, 'Move', onMove),
              _act(context, Icons.edit_outlined, 'Edit', onEdit),
              _act(context, Icons.delete_outline, 'Delete', onDelete),
              IconButton(
                  onPressed: onClose,
                  icon: Icon(Icons.close, color: scheme.onSecondaryContainer)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _act(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: scheme.onSecondaryContainer),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSecondaryContainer)),
          ],
        ),
      ),
    );
  }
}

// ─── placement bar ─────────────────────────────────────────────────────────────

class _PlacementBar extends StatelessWidget {
  final String subjectName;
  final bool isMove;
  final VoidCallback onCancel;
  final VoidCallback? onUndo;
  const _PlacementBar({
    super.key,
    required this.subjectName,
    required this.isMove,
    required this.onCancel,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
          child: Row(
            children: [
              Icon(isMove ? Icons.swap_horiz : Icons.add_location_alt_outlined,
                  size: 18, color: scheme.onPrimaryContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tap a glowing slot to ${isMove ? 'move' : 'place'} $subjectName',
                  style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
              if (onUndo != null)
                TextButton.icon(
                  onPressed: onUndo,
                  icon: const Icon(Icons.undo, size: 16),
                  label: const Text('Undo'),
                ),
              FilledButton(
                onPressed: onCancel,
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(0, 38),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── header row ────────────────────────────────────────────────────────────────

class _HeaderRow extends StatelessWidget {
  final List<_Col> columns;
  final Map<int, _PeriodHeader> headerMap;
  final int? current;
  const _HeaderRow(
      {required this.columns, required this.headerMap, required this.current});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final grid =
        BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5), width: 0.7);
    return SizedBox(
      height: WeekScreen._headerH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // corner
          Container(
            width: WeekScreen._dayColW,
            decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                border: Border(right: grid, bottom: grid)),
          ),
          for (final col in columns)
            if (col.isBreak)
              Container(
                width: WeekScreen._breakW,
                decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    border: Border(right: grid, bottom: grid)),
                alignment: Alignment.center,
                child: Text(col.breakKind == EntryKind.tea ? '☕' : '🍽',
                    style: const TextStyle(fontSize: 15)),
              )
            else
              _PeriodHeaderCell(
                  header: headerMap[col.classPos]!,
                  isNow: col.classPos == current,
                  grid: grid),
        ],
      ),
    );
  }
}

class _PeriodHeaderCell extends StatelessWidget {
  final _PeriodHeader header;
  final bool isNow;
  final BorderSide grid;
  const _PeriodHeaderCell(
      {required this.header, required this.isNow, required this.grid});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: WeekScreen._cellW,
      decoration: BoxDecoration(
        color: isNow
            ? scheme.primary.withValues(alpha: 0.10)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border(right: grid, bottom: grid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(header.label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isNow ? scheme.primary : scheme.onSurfaceVariant)),
          if (isNow) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                  color: scheme.primary, borderRadius: BorderRadius.circular(20)),
              child: Text('NOW',
                  style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: scheme.onPrimary)),
            ),
          ],
          const SizedBox(height: 2),
          Text(header.timeRange,
              style: TextStyle(
                  fontSize: 9.5,
                  color: isNow
                      ? scheme.primary.withValues(alpha: 0.8)
                      : scheme.onSurfaceVariant.withValues(alpha: 0.7))),
        ],
      ),
    );
  }
}

// ─── day row ───────────────────────────────────────────────────────────────────

class _DayRow extends StatelessWidget {
  final int weekday;
  final DateTime date;
  final bool isToday;
  final bool isPast;
  final int? currentClassPos;
  final int todayWeekday;
  final List<_Col> columns;
  final List<TimelineEntry> classes;
  final List<Period> periods;
  final PlacementState placement;
  final WeekCellSelection? selection;
  final bool canEdit;
  final VoidCallback onTapDay;
  final void Function(int day, int pos, Period period) onLongPressCell;
  final Future<void> Function(int day, int pos) onPlace;

  const _DayRow({
    required this.weekday,
    required this.date,
    required this.isToday,
    required this.isPast,
    required this.currentClassPos,
    required this.todayWeekday,
    required this.columns,
    required this.classes,
    required this.periods,
    required this.placement,
    required this.selection,
    required this.canEdit,
    required this.onTapDay,
    required this.onLongPressCell,
    required this.onPlace,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final grid =
        BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5), width: 0.7);

    final cells = <Widget>[_DayLabelCell(weekday: weekday, date: date, isToday: isToday, grid: grid)];
    int classIdx = 0;
    bool skipNext = false;

    for (int ci = 0; ci < columns.length; ci++) {
      final col = columns[ci];
      if (col.isBreak) {
        cells.add(_BreakBand(grid: grid));
        continue;
      }
      if (skipNext) {
        skipNext = false;
        classIdx++;
        continue;
      }
      final entry = classIdx < classes.length ? classes[classIdx] : null;
      final period = classIdx < periods.length ? periods[classIdx] : null;
      final pos = classIdx;
      final isCurrent = isToday && col.classPos == currentClassPos;
      final isSource = placement.active &&
          placement.sourceDay == weekday &&
          placement.sourcePeriodPos == pos;
      final isSelected =
          selection != null && selection!.day == weekday && selection!.pos == pos;
      final isTarget = placement.active &&
          entry == null &&
          placement.isTarget(weekday, pos);
      final dimmed = placement.active && !isTarget && !isSource;

      double width = WeekScreen._cellW;
      if (entry != null && entry.isLab) {
        final nextCol = ci + 1 < columns.length ? columns[ci + 1] : null;
        if (nextCol != null && !nextCol.isBreak) {
          width = WeekScreen._cellW * 2;
          skipNext = true;
        }
      }

      cells.add(_ClassCell(
        entry: entry,
        period: period,
        day: weekday,
        pos: pos,
        width: width,
        grid: grid,
        isCurrent: isCurrent,
        isSource: isSource,
        isSelected: isSelected,
        isTarget: isTarget,
        dimmed: dimmed,
        placementActive: placement.active,
        canEdit: canEdit,
        onTapDay: onTapDay,
        onLongPressCell: onLongPressCell,
        onPlace: onPlace,
      ));
      classIdx++;
    }

    return SizedBox(
      height: WeekScreen._cellH,
      child: Opacity(
        opacity: isPast ? 0.5 : 1.0,
        child:
            Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
      ),
    );
  }
}

class _DayLabelCell extends StatelessWidget {
  final int weekday;
  final DateTime date;
  final bool isToday;
  final BorderSide grid;
  const _DayLabelCell(
      {required this.weekday,
      required this.date,
      required this.isToday,
      required this.grid});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final isTomorrow = DateTime(date.year, date.month, date.day) ==
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    return Container(
      width: WeekScreen._dayColW,
      height: WeekScreen._cellH,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(right: grid, bottom: grid),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(3),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isToday ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(TimeUtils.dayShort(weekday).toUpperCase(),
                  style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: isToday
                          ? scheme.onPrimary.withValues(alpha: 0.8)
                          : scheme.onSurfaceVariant)),
              Text('${date.day}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      color: isToday ? scheme.onPrimary : scheme.onSurface)),
              Text(_months[date.month - 1],
                  style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? scheme.onPrimary.withValues(alpha: 0.75)
                          : scheme.onSurfaceVariant)),
              if (isTomorrow && !isToday)
                Text('tmrw',
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── class cell (solid rounded block in a gridded table) ──────────────────────

class _ClassCell extends StatelessWidget {
  final TimelineEntry? entry;
  final Period? period;
  final int day;
  final int pos;
  final double width;
  final BorderSide grid;
  final bool isCurrent;
  final bool isSource;
  final bool isSelected;
  final bool isTarget;
  final bool dimmed;
  final bool placementActive;
  final bool canEdit;
  final VoidCallback onTapDay;
  final void Function(int day, int pos, Period period) onLongPressCell;
  final Future<void> Function(int day, int pos) onPlace;

  const _ClassCell({
    required this.entry,
    required this.period,
    required this.day,
    required this.pos,
    required this.width,
    required this.grid,
    required this.isCurrent,
    required this.isSource,
    required this.isSelected,
    required this.isTarget,
    required this.dimmed,
    required this.placementActive,
    required this.canEdit,
    required this.onTapDay,
    required this.onLongPressCell,
    required this.onPlace,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget block;
    if (isTarget) {
      block = Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green, width: 2),
        ),
        child: const Center(
            child: Icon(Icons.add_circle, color: Colors.green, size: 22)),
      );
    } else if (entry == null) {
      block = Center(
        child: Icon(Icons.add,
            size: 16, color: scheme.onSurfaceVariant.withValues(alpha: 0.28)),
      );
    } else {
      final color = Color(entry!.color);
      final fg = SubjectColors.contrastOn(color);
      block = AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: color, // SOLID fill (matches the reference)
          borderRadius: BorderRadius.circular(12),
          border: (isSource || isSelected)
              ? Border.all(color: scheme.onSurface, width: 2.5)
              : isCurrent
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 1)
                ]
              : null,
        ),
        padding: const EdgeInsets.fromLTRB(8, 5, 7, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry!.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                    color: fg)),
            const Spacer(),
            if (entry!.room != null && entry!.room!.isNotEmpty)
              Text(entry!.room!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: fg.withValues(alpha: 0.92))),
            if (entry!.teacher != null && entry!.teacher!.isNotEmpty)
              Text(entry!.teacher!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      color: fg.withValues(alpha: 0.82))),
            if (entry!.isLab || isCurrent)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(children: [
                  if (entry!.isLab) _badge('LAB', fg),
                  if (entry!.isLab && isCurrent) const SizedBox(width: 4),
                  if (isCurrent) _badge('NOW', fg),
                ]),
              ),
          ],
        ),
      );
    }

    if (dimmed) block = Opacity(opacity: 0.4, child: block);

    VoidCallback? onTap;
    VoidCallback? onLongPress;
    if (placementActive) {
      if (isTarget) onTap = () => onPlace(day, pos);
    } else {
      onTap = onTapDay;
      if (period != null && canEdit) {
        onLongPress = () => onLongPressCell(day, pos, period!);
      }
    }

    return SizedBox(
      width: width,
      height: WeekScreen._cellH,
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border(right: grid, bottom: grid)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(onTap: onTap, onLongPress: onLongPress, child: block),
        ),
      ),
    );
  }

  Widget _badge(String label, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
            color: fg.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(5)),
        child: Text(label,
            style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: fg)),
      );
}

// ─── break band (hatched) ──────────────────────────────────────────────────────

class _BreakBand extends StatelessWidget {
  final BorderSide grid;
  const _BreakBand({required this.grid});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: WeekScreen._breakW,
      height: WeekScreen._cellH,
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border(right: grid, bottom: grid)),
        child: CustomPaint(
          painter: _HatchPainter(
              scheme.onSurfaceVariant.withValues(alpha: 0.18)),
        ),
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  final Color color;
  _HatchPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    const gap = 8.0;
    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
          Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_HatchPainter old) => old.color != color;
}
