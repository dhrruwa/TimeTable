import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../logic/timetable_builder.dart';
import '../../logic/today_engine.dart';
import '../../models/period_models.dart';
import '../../providers/providers.dart';
import '../../providers/widget_providers.dart';
import 'timetable_widget_medium.dart';
import 'timetable_widget_small.dart';
import 'weather_style.dart';

/// A live, in-app preview of the home-screen widgets.
///
/// Why this exists: the real OS home-screen widget is refresh-throttled (Android
/// ~15–30 min, iOS ~15 min), so the red→yellow→green color can't visibly move
/// second-by-second out there. Inside the app we own the frame loop, so this
/// preview shows the exact same widget designs updating live — either against
/// the real "now" (per-second) or via a fast Demo sweep that runs a synthetic
/// class so you can watch the full red→yellow→green transition in seconds.
class LiveWidgetPreview extends ConsumerStatefulWidget {
  const LiveWidgetPreview({super.key});

  @override
  ConsumerState<LiveWidgetPreview> createState() => _LiveWidgetPreviewState();
}

class _LiveWidgetPreviewState extends ConsumerState<LiveWidgetPreview>
    with SingleTickerProviderStateMixin {
  bool _demo = true;
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8), // one full red→green pass
  )..repeat();

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _demo
                      ? 'Demo sweep — a synthetic class runs in fast-forward so '
                          'you can see the full red → yellow → green transition.'
                      : 'Live — reflects your real schedule right now, updating '
                          'every second while a class is in progress.',
                  style: TextStyle(
                      fontSize: 11.5, color: scheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Text('Demo',
                      style: TextStyle(
                          fontSize: 10, color: scheme.onSurfaceVariant)),
                  Switch(
                    value: _demo,
                    onChanged: (v) => setState(() => _demo = v),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // A continuous swatch of the exact color ramp, for reference.
        _Ramp(),
        const SizedBox(height: 12),
        if (_demo)
          AnimatedBuilder(
            animation: _sweep,
            builder: (_, __) => _previewRow(_demoStatus(_sweep.value)),
          )
        else
          _LivePreview(child: _previewRow),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Lays out the small + large widget cards (full-card sweep + per-row sweep).
  Widget _previewRow(TodayStatus status) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TimetableWidgetSmall(
            status: status,
            weekday: 'MON',
            date: 'Preview',
            size: 150,
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 300,
            child: TimetableWidgetMedium(
              status: status,
              weekday: 'Mon',
              date: 'Preview',
              width: 300,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a synthetic "class in progress at [t] (0..1)" status for the demo.
  TodayStatus _demoStatus(double t) {
    const current = TimelineEntry(
      kind: EntryKind.regular,
      title: 'Mathematics',
      color: 0xFF5965C8,
      room: 'LH-204',
      teacher: 'Prof. Rao',
      startMin: 9 * 60,
      endMin: 10 * 60,
    );
    const next1 = TimelineEntry(
      kind: EntryKind.lab,
      title: 'Physics Lab',
      color: 0xFF2BB7A3,
      room: 'Lab-2',
      startMin: 10 * 60,
      endMin: 12 * 60,
    );
    const next2 = TimelineEntry(
      kind: EntryKind.regular,
      title: 'Computer Science',
      color: 0xFFE08A3C,
      room: 'LH-101',
      startMin: 12 * 60,
      endMin: 13 * 60,
    );
    return TodayStatus(
      timeline: const [current, next1, next2],
      current: current,
      completion: t.clamp(0.0, 1.0),
      upcomingClasses: const [next1, next2],
      nextBreak: null,
      breakHint: null,
      beforeDay: false,
      dayOver: false,
      empty: false,
      nowMinutes: 9 * 60 + (t * 60).round(),
    );
  }
}

/// Watches the per-second clock + the real timetable and feeds today's status
/// to [child]. This is the same data path the real home-screen widget uses.
class _LivePreview extends ConsumerWidget {
  final Widget Function(TodayStatus) child;
  const _LivePreview({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(secondClockProvider).value ?? DateTime.now();
    final timetable = ref.watch(timetableProvider);
    final timeline = TimetableBuilder.buildDay(
      timetable.periodsOn(now.weekday),
      timetable.subjectsById,
      timetable.config,
    );
    return child(TodayEngine.compute(timeline, now));
  }
}

/// A thin bar showing the continuous red→yellow→green color ramp.
class _Ramp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 10,
          child: Row(
            children: [
              for (var i = 0; i < 60; i++)
                Expanded(
                  child: ColoredBox(color: Wx.progressColor(i / 59)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
