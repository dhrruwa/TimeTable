import '../models/period_models.dart';

/// High-level "where are we in the day right now" status, derived purely from a
/// day's [TimelineEntry] list and the current time. No Flutter, no persistence.
///
/// This is the single source of truth for the widgets: current class, live
/// completion %, the next classes, the upcoming-break hint, and the
/// before/over states.
class TodayStatus {
  final List<TimelineEntry> timeline;

  /// The slot happening right now — may be a class, a lab, or a break.
  final TimelineEntry? current;

  /// Completion fraction (0..1) of the current CLASS. 0 when a break is active
  /// or nothing is running.
  final double completion;

  /// Class entries that start strictly after now, in order.
  final List<TimelineEntry> upcomingClasses;

  /// The next break (tea/lunch) that hasn't started yet, if any.
  final TimelineEntry? nextBreak;

  /// A short human hint like "Tea break next" when a break is imminent.
  final String? breakHint;

  /// Before the first class of the day.
  final bool beforeDay;

  /// After the last entry of the day.
  final bool dayOver;

  /// No classes scheduled at all for this day.
  final bool empty;

  final int nowMinutes;

  const TodayStatus({
    required this.timeline,
    required this.current,
    required this.completion,
    required this.upcomingClasses,
    required this.nextBreak,
    required this.breakHint,
    required this.beforeDay,
    required this.dayOver,
    required this.empty,
    required this.nowMinutes,
  });

  bool get currentIsClass => current != null && current!.isClass;
  bool get currentIsBreak => current != null && current!.isBreak;

  /// Live completion as a whole-number percent (0..100).
  int get completionPercent => (completion * 100).round();

  /// The current class plus the next classes, capped to [count]. Used by the
  /// small/medium widgets. When a break or gap is active, this is just the
  /// upcoming classes.
  List<TimelineEntry> currentPlusNext(int count) {
    final list = <TimelineEntry>[
      if (currentIsClass) current!,
      ...upcomingClasses,
    ];
    return list.length <= count ? list : list.sublist(0, count);
  }

  /// A one-line status string mirroring Weather's "Sunny / H:30 L:13" line.
  String get statusLine {
    if (empty) return 'No classes today';
    if (beforeDay) {
      final first = timeline.first;
      return 'Starts ${_fmt(first.startMin)}';
    }
    if (dayOver) return 'All classes done';
    if (currentIsBreak)
      return '${current!.title} · ends ${_fmt(current!.endMin)}';
    if (currentIsClass) return '$completionPercent% complete';
    // In a gap between entries.
    if (upcomingClasses.isNotEmpty) {
      return 'Next ${_fmt(upcomingClasses.first.startMin)}';
    }
    return 'All classes done';
  }

  static String _fmt(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final hr = h % 12 == 0 ? 12 : h % 12;
    return '$hr:${m.toString().padLeft(2, '0')}';
  }
}

class TodayEngine {
  const TodayEngine._();

  static TodayStatus compute(List<TimelineEntry> timeline, DateTime now) {
    final m = now.hour * 60 + now.minute;

    if (timeline.isEmpty) {
      return TodayStatus(
        timeline: timeline,
        current: null,
        completion: 0,
        upcomingClasses: const [],
        nextBreak: null,
        breakHint: null,
        beforeDay: false,
        dayOver: false,
        empty: true,
        nowMinutes: m,
      );
    }

    TimelineEntry? current;
    for (final e in timeline) {
      if (e.contains(m)) {
        current = e;
        break;
      }
    }

    final upcomingClasses = [
      for (final e in timeline)
        if (e.isClass && e.startMin > m) e,
    ];

    TimelineEntry? nextBreak;
    for (final e in timeline) {
      if (e.isBreak && e.startMin > m) {
        nextBreak = e;
        break;
      }
    }

    double completion = 0;
    if (current != null && current.isClass && current.durationMin > 0) {
      completion =
          ((m - current.startMin) / current.durationMin).clamp(0.0, 1.0);
    }

    final beforeDay = m < timeline.first.startMin;
    final dayOver = m >= timeline.last.endMin;

    // Surface the break ahead of time: show the hint when the very next thing
    // after the current class (or after now, in a gap) is a break — or when a
    // break starts within the next 20 minutes.
    String? breakHint;
    if (!dayOver && nextBreak != null) {
      final startsSoon = nextBreak.startMin - m <= 20;
      final isImmediatelyNext = !upcomingClasses.any(
        (c) => c.startMin < nextBreak!.startMin,
      );
      if (startsSoon || isImmediatelyNext) {
        final label = nextBreak.kind == EntryKind.lunch ? 'Lunch' : 'Tea';
        breakHint = '$label break next';
      }
    }

    return TodayStatus(
      timeline: timeline,
      current: current,
      completion: completion,
      upcomingClasses: upcomingClasses,
      nextBreak: nextBreak,
      breakHint: breakHint,
      beforeDay: beforeDay,
      dayOver: dayOver,
      empty: false,
      nowMinutes: m,
    );
  }
}
