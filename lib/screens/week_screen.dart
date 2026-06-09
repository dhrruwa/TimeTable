import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/schedule_service.dart';
import '../models/timetable_models.dart';
import '../providers/providers.dart';
import '../theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/time_utils.dart';
import 'edit_slot_screen.dart';

/// Weekly grid: days across the top, time down the side, color-coded blocks.
/// Tapping a block opens its edit screen; long-press-drag it to reschedule.
class WeekScreen extends ConsumerWidget {
  const WeekScreen({super.key});

  static const double _hourHeight = 64;
  static const double _gutter = 52;
  static const double _headerHeight = 44;
  static const double _minColWidth = 104;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(scheduleServiceProvider);
    final showSunday = ref.watch(showSundayProvider);
    final now = ref.watch(nowProvider);

    final days = [for (var d = 1; d <= (showSunday ? 7 : 6); d++) d];

    // Time bounds: tightest window covering all slots, with sane defaults.
    final allSlots = ref.watch(timetableProvider).slots;
    var startHour = 8;
    var endHour = 18;
    if (allSlots.isNotEmpty) {
      final minStart = allSlots.map((s) => s.startMinutes).reduce((a, b) => a < b ? a : b);
      final maxEnd = allSlots.map((s) => s.endMinutes).reduce((a, b) => a > b ? a : b);
      startHour = (minStart ~/ 60).clamp(0, 23);
      endHour = ((maxEnd + 59) ~/ 60).clamp(startHour + 1, 24);
    }
    final hours = [for (var h = startHour; h <= endHour; h++) h];
    final gridHeight = (endHour - startHour) * _hourHeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Week'),
        actions: [
          Row(
            children: [
              const Text('Sun'),
              Switch(
                value: showSunday,
                onChanged: (v) =>
                    ref.read(showSundayProvider.notifier).state = v,
              ),
              const SizedBox(width: 4),
            ],
          ),
        ],
        bottom: allSlots.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(26),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.drag_indicator,
                          size: 15,
                          color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'Long-press a class to drag it to a new time',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditSlotScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Class'),
      ),
      body: allSlots.isEmpty
          ? EmptyState(
              icon: Icons.grid_view_outlined,
              title: 'Empty week',
              message: 'Add your first class to start building your timetable.',
              action: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditSlotScreen()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add class'),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final available = constraints.maxWidth - _gutter;
                final colWidth =
                    (available / days.length).clamp(_minColWidth, double.infinity);
                final totalWidth = _gutter + colWidth * days.length;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: totalWidth,
                    child: Column(
                      children: [
                        _HeaderRow(
                          days: days,
                          colWidth: colWidth,
                          today: now.weekday,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: SizedBox(
                              height: gridHeight,
                              child: _GridBody(
                                days: days,
                                hours: hours,
                                startHour: startHour,
                                colWidth: colWidth,
                                service: service,
                                onTapSlot: (slot) =>
                                    Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditSlotScreen(existing: slot),
                                  ),
                                ),
                                onMoveSlot: (slot, day, newStart) =>
                                    _moveSlot(context, ref, slot, day, newStart),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// Persists a drag-and-drop reschedule: keep the duration, change day/start.
  void _moveSlot(
    BuildContext context,
    WidgetRef ref,
    ClassSlot slot,
    int newDay,
    int newStart,
  ) {
    if (slot.dayOfWeek == newDay && slot.startMinutes == newStart) return;
    final duration = slot.endMinutes - slot.startMinutes;
    ref.read(timetableProvider.notifier).upsertSlot(
          slot.copyWith(
            dayOfWeek: newDay,
            startMinutes: newStart,
            endMinutes: newStart + duration,
          ),
        );
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1200),
          content: Text(
            'Moved to ${TimeUtils.dayName(newDay)}, '
            '${TimeUtils.formatMinutes(context, newStart)}',
          ),
        ),
      );
  }
}

class _HeaderRow extends StatelessWidget {
  final List<int> days;
  final double colWidth;
  final int today;

  const _HeaderRow({
    required this.days,
    required this.colWidth,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: WeekScreen._headerHeight,
      child: Row(
        children: [
          const SizedBox(width: WeekScreen._gutter),
          for (final d in days)
            SizedBox(
              width: colWidth,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: d == today
                        ? scheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    TimeUtils.dayShort(d),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: d == today
                              ? scheme.onPrimary
                              : scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GridBody extends StatefulWidget {
  final List<int> days;
  final List<int> hours;
  final int startHour;
  final double colWidth;
  final ScheduleService service;
  final void Function(ClassSlot slot) onTapSlot;
  final void Function(ClassSlot slot, int newDay, int newStart) onMoveSlot;

  const _GridBody({
    required this.days,
    required this.hours,
    required this.startHour,
    required this.colWidth,
    required this.service,
    required this.onTapSlot,
    required this.onMoveSlot,
  });

  @override
  State<_GridBody> createState() => _GridBodyState();
}

class _GridBodyState extends State<_GridBody> {
  // Key on the Stack so we can convert drag coordinates into grid cells.
  final GlobalKey _stackKey = GlobalKey();

  // Live preview of where a dragged block would land.
  ({int day, int start, int duration})? _preview;

  static const int _snapMinutes = 5;

  double get _minuteHeight => WeekScreen._hourHeight / 60;

  /// Resolve a global drop point to a snapped (day, start) cell.
  ({int day, int start})? _cellAt(Offset globalOffset, int duration) {
    final ctx = _stackKey.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox;
    final local = box.globalToLocal(globalOffset);
    final dayIndex = (((local.dx - WeekScreen._gutter) / widget.colWidth))
        .floor()
        .clamp(0, widget.days.length - 1);
    final rawStart = widget.startHour * 60 + (local.dy / _minuteHeight).round();
    final snapped = ((rawStart / _snapMinutes).round() * _snapMinutes)
        .clamp(0, 24 * 60 - duration);
    return (day: widget.days[dayIndex], start: snapped);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    return DragTarget<ClassSlot>(
      onMove: (details) {
        final duration = details.data.endMinutes - details.data.startMinutes;
        final cell = _cellAt(details.offset, duration);
        if (cell == null) return;
        if (_preview?.day != cell.day || _preview?.start != cell.start) {
          setState(() => _preview =
              (day: cell.day, start: cell.start, duration: duration));
        }
      },
      onLeave: (_) {
        if (_preview != null) setState(() => _preview = null);
      },
      onAcceptWithDetails: (details) {
        final slot = details.data;
        final duration = slot.endMinutes - slot.startMinutes;
        final cell = _cellAt(details.offset, duration);
        setState(() => _preview = null);
        if (cell != null) widget.onMoveSlot(slot, cell.day, cell.start);
      },
      builder: (context, candidate, rejected) {
        return Stack(
          key: _stackKey,
          children: [
            // Hour gridlines + labels.
            for (final h in widget.hours)
              Positioned(
                top: (h - widget.startHour) * WeekScreen._hourHeight,
                left: 0,
                right: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: WeekScreen._gutter,
                      child: Transform.translate(
                        offset: const Offset(0, -7),
                        child: Text(
                          _hourLabel(context, h),
                          textAlign: TextAlign.right,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: scheme.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

            // Drop preview while dragging.
            if (_preview != null) _buildPreview(scheme),

            // Class blocks per day (draggable).
            for (var i = 0; i < widget.days.length; i++)
              for (final c in widget.service.classesOnDay(widget.days[i]))
                Positioned(
                  left: WeekScreen._gutter + i * widget.colWidth + 3,
                  width: widget.colWidth - 6,
                  top: (c.startMinutes - widget.startHour * 60) * _minuteHeight,
                  height:
                      (c.endMinutes - c.startMinutes) * _minuteHeight - 3,
                  child: _DraggableBlock(
                    scheduledClass: c,
                    brightness: brightness,
                    width: widget.colWidth - 6,
                    height:
                        (c.endMinutes - c.startMinutes) * _minuteHeight - 3,
                    onTap: () => widget.onTapSlot(c.slot),
                  ),
                ),
          ],
        );
      },
    );
  }

  Widget _buildPreview(ColorScheme scheme) {
    final p = _preview!;
    final dayIndex = widget.days.indexOf(p.day);
    if (dayIndex < 0) return const SizedBox.shrink();
    return Positioned(
      left: WeekScreen._gutter + dayIndex * widget.colWidth + 3,
      width: widget.colWidth - 6,
      top: (p.start - widget.startHour * 60) * _minuteHeight,
      height: p.duration * _minuteHeight - 3,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.primary, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          TimeUtils.formatMinutes(context, p.start),
          style: TextStyle(
            color: scheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _hourLabel(BuildContext context, int hour) {
    return TimeUtils.formatMinutes(context, (hour % 24) * 60);
  }
}

/// A class block that can be long-press-dragged to a new day/time.
class _DraggableBlock extends StatelessWidget {
  final ScheduledClass scheduledClass;
  final Brightness brightness;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _DraggableBlock({
    required this.scheduledClass,
    required this.brightness,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final block = _Block(
      scheduledClass: scheduledClass,
      brightness: brightness,
      onTap: onTap,
    );
    return LongPressDraggable<ClassSlot>(
      data: scheduledClass.slot,
      onDragStarted: HapticFeedback.mediumImpact,
      feedback: Material(
        color: Colors.transparent,
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        child: Opacity(
          opacity: 0.95,
          child: SizedBox(
            width: width,
            height: height < 24 ? 24 : height,
            child: _Block(
              scheduledClass: scheduledClass,
              brightness: brightness,
              onTap: () {},
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: block),
      child: block,
    );
  }
}

class _Block extends StatelessWidget {
  final ScheduledClass scheduledClass;
  final Brightness brightness;
  final VoidCallback onTap;

  const _Block({
    required this.scheduledClass,
    required this.brightness,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(scheduledClass.color);
    final bg = CourseColors.surface(color, brightness);
    final fg = CourseColors.onSurface(color, brightness);
    final compact =
        (scheduledClass.endMinutes - scheduledClass.startMinutes) < 50;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scheduledClass.courseName,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
              ),
              if (!compact) ...[
                const SizedBox(height: 2),
                Text(
                  TimeUtils.formatMinutes(context, scheduledClass.startMinutes),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: fg.withOpacity(0.85),
                      ),
                ),
                if (scheduledClass.room != null &&
                    scheduledClass.room!.isNotEmpty)
                  Text(
                    scheduledClass.room!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: fg.withOpacity(0.85),
                        ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
