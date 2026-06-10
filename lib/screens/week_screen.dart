import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/period_models.dart';
import '../providers/providers.dart';
import '../providers/widget_providers.dart';
import '../theme.dart';
import '../widgets/time_utils.dart';
import 'edit_day_screen.dart';

/// Weekly timetable as a college-style matrix: rows = days, columns = periods
/// with TEA/LUNCH break columns between them. Cells are colored by subject.
/// Tap any day to edit its periods.
class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  static const double _dayColW = 56;
  static const double _cellW = 124;
  static const double _breakW = 30;
  static const double _cellH = 86;
  static const double _headerH = 34;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(timetableProvider);
    final today = ref.watch(nowProvider).weekday;
    final scheme = Theme.of(context).colorScheme;

    // Resolve each day's timeline once.
    final dayTimelines = {
      for (var d = 1; d <= 6; d++) d: ref.watch(timelineForDayProvider(d)),
    };
    final maxClasses = dayTimelines.values
        .map((tl) => tl.where((e) => e.isClass).length)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final classCount = maxClasses == 0 ? 6 : maxClasses;

    // Column plan: class columns, with break columns inserted after the
    // configured counts (mirrors TimetableBuilder).
    final columns = <_Col>[];
    for (var i = 1; i <= classCount; i++) {
      columns.add(_Col.classIndex(i));
      if (i == t.config.teaAfter) columns.add(const _Col.brk(EntryKind.tea));
      if (i == t.config.lunchAfter)
        columns.add(const _Col.brk(EntryKind.lunch));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Week'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('Tap a day to edit its classes',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed day-name column.
            Column(
              children: [
                SizedBox(width: _dayColW, height: _headerH),
                for (var d = 1; d <= 6; d++)
                  _DayLabel(
                    day: d,
                    isToday: d == today,
                    onTap: () => _openDay(context, d),
                  ),
              ],
            ),
            // Horizontally scrollable grid.
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderRow(columns: columns),
                    for (var d = 1; d <= 6; d++)
                      _DayRow(
                        day: d,
                        columns: columns,
                        classes:
                            dayTimelines[d]!.where((e) => e.isClass).toList(),
                        onTap: () => _openDay(context, d),
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

  void _openDay(BuildContext context, int weekday) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditDayScreen(weekday: weekday)),
    );
  }
}

/// A column is either the Nth class of the day, or a break band.
class _Col {
  final int? classIndex; // 1-based
  final EntryKind? breakKind;
  const _Col.classIndex(this.classIndex) : breakKind = null;
  const _Col.brk(this.breakKind) : classIndex = null;
  bool get isBreak => breakKind != null;
}

class _HeaderRow extends StatelessWidget {
  final List<_Col> columns;
  const _HeaderRow({required this.columns});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: WeekScreen._headerH,
      child: Row(
        children: [
          for (final c in columns)
            if (c.isBreak)
              SizedBox(width: WeekScreen._breakW)
            else
              SizedBox(
                width: WeekScreen._cellW,
                child: Center(
                  child: Text('P${c.classIndex}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant)),
                ),
              ),
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final int day;
  final bool isToday;
  final VoidCallback onTap;
  const _DayLabel(
      {required this.day, required this.isToday, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: WeekScreen._dayColW,
        height: WeekScreen._cellH,
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isToday ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(TimeUtils.dayShort(day),
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isToday ? scheme.onPrimary : scheme.onSurface)),
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final int day;
  final List<_Col> columns;
  final List<TimelineEntry> classes;
  final VoidCallback onTap;

  const _DayRow({
    required this.day,
    required this.columns,
    required this.classes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final c in columns)
          if (c.isBreak)
            _BreakBand(kind: c.breakKind!)
          else
            _ClassCell(
              entry: c.classIndex! <= classes.length
                  ? classes[c.classIndex! - 1]
                  : null,
              onTap: onTap,
            ),
      ],
    );
  }
}

class _ClassCell extends StatelessWidget {
  final TimelineEntry? entry;
  final VoidCallback onTap;
  const _ClassCell({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;

    Widget child;
    if (entry == null) {
      child = Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
      );
    } else {
      final color = Color(entry!.color);
      final bg = SubjectColors.surface(color, brightness);
      final fg = SubjectColors.onSurface(color, brightness);
      child = Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        padding: const EdgeInsets.fromLTRB(8, 7, 7, 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(entry!.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12.5,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                          color: fg)),
                ),
                if (entry!.isLab)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                        color: color, borderRadius: BorderRadius.circular(4)),
                    child: Text('LAB',
                        style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            color: SubjectColors.contrastOn(color))),
                  ),
              ],
            ),
            const Spacer(),
            Text(TimeUtils.formatMinutes(context, entry!.startMin),
                style: TextStyle(
                    fontSize: 10.5, color: fg.withValues(alpha: 0.9))),
            if (entry!.room != null && entry!.room!.isNotEmpty)
              Text(entry!.room!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 10, color: fg.withValues(alpha: 0.8))),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(3),
      child: SizedBox(
        width: WeekScreen._cellW - 6,
        height: WeekScreen._cellH - 6,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _BreakBand extends StatelessWidget {
  final EntryKind kind;
  const _BreakBand({required this.kind});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: WeekScreen._breakW,
      height: WeekScreen._cellH,
      alignment: Alignment.center,
      child: RotatedBox(
        quarterTurns: 3,
        child: Text(kind == EntryKind.lunch ? 'LUNCH' : 'TEA',
            style: TextStyle(
                fontSize: 9,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant)),
      ),
    );
  }
}
