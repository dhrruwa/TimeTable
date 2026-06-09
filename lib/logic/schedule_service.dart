import '../models/timetable_models.dart';

/// A [ClassSlot] paired with its resolved [Course]. This is what the UI renders;
/// it never has to look a course up by id itself.
class ScheduledClass {
  final ClassSlot slot;
  final Course course;

  const ScheduledClass({required this.slot, required this.course});

  // Convenience pass-throughs so widgets stay terse.
  String get id => slot.id;
  String get courseName => course.name;
  String? get instructor => course.instructor;
  String? get room => course.room;
  int get color => course.color;
  int get dayOfWeek => slot.dayOfWeek;
  int get startMinutes => slot.startMinutes;
  int get endMinutes => slot.endMinutes;
  String get startLabel => slot.startLabel;
  String get endLabel => slot.endLabel;
  String get timeRangeLabel => '${slot.startLabel} – ${slot.endLabel}';

  bool isInProgressAt(int minutesSinceMidnight) =>
      slot.contains(minutesSinceMidnight);
}

/// One entry in a day's timeline, used by the (future) home-screen widget and
/// the Today screen. Carries flags for the currently-running and next-up class
/// so the UI never recomputes that logic itself.
class WidgetTimelineEntry {
  final ScheduledClass scheduledClass;
  final bool isCurrent;
  final bool isNext;

  const WidgetTimelineEntry({
    required this.scheduledClass,
    required this.isCurrent,
    required this.isNext,
  });
}

/// THE single source of truth for "what's on now / what's next".
///
/// Pure Dart: no Flutter, no Isar, no persistence. Construct it with a
/// [Timetable] snapshot and ask it questions. All schedule reasoning lives
/// here so the UI never reimplements it.
class ScheduleService {
  final Timetable timetable;

  /// Resolved-and-sorted classes keyed by day of week (1..7). Built once.
  final Map<int, List<ScheduledClass>> _byDay;

  ScheduleService(this.timetable) : _byDay = _index(timetable);

  static Map<int, List<ScheduledClass>> _index(Timetable timetable) {
    final byId = {for (final c in timetable.courses) c.id: c};
    final map = <int, List<ScheduledClass>>{};
    for (final slot in timetable.slots) {
      final course = byId[slot.courseId];
      if (course == null) continue; // orphan slot — ignore defensively.
      (map[slot.dayOfWeek] ??= []).add(
        ScheduledClass(slot: slot, course: course),
      );
    }
    for (final list in map.values) {
      list.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    }
    return map;
  }

  static int _minutesOf(DateTime t) => t.hour * 60 + t.minute;

  /// All classes on [dayOfWeek] (1=Mon..7=Sun), sorted by start time.
  List<ScheduledClass> classesOnDay(int dayOfWeek) =>
      List.unmodifiable(_byDay[dayOfWeek] ?? const []);

  /// All classes scheduled for today, sorted by start time.
  List<ScheduledClass> classesToday({DateTime? now}) =>
      classesOnDay((now ?? DateTime.now()).weekday);

  /// The class currently in progress, or null if nothing is running right now.
  ScheduledClass? currentClass({DateTime? now}) {
    final at = now ?? DateTime.now();
    final mins = _minutesOf(at);
    for (final c in classesOnDay(at.weekday)) {
      if (c.isInProgressAt(mins)) return c;
    }
    return null;
  }

  /// The next class that will start, scanning forward from [now] and wrapping
  /// around the week (e.g. Friday afternoon -> Monday morning). Returns null
  /// only when there are no classes at all.
  ScheduledClass? nextClass({DateTime? now}) {
    final at = now ?? DateTime.now();
    final nowMins = _minutesOf(at);

    // Rest of today.
    for (final c in classesOnDay(at.weekday)) {
      if (c.startMinutes > nowMins) return c;
    }
    // Following days, wrapping all the way around the week.
    for (var offset = 1; offset <= 7; offset++) {
      final day = ((at.weekday - 1 + offset) % 7) + 1;
      final classes = classesOnDay(day);
      if (classes.isNotEmpty) return classes.first;
    }
    return null;
  }

  /// Whole minutes until [nextClass] starts, accounting for day wrap. Null when
  /// there is no next class. 0 means it starts this minute.
  int? minutesUntilNext({DateTime? now}) {
    final at = now ?? DateTime.now();
    final next = nextClass(now: at);
    if (next == null) return null;
    final nowMins = _minutesOf(at);

    var dayDelta = (next.dayOfWeek - at.weekday) % 7;
    // Same weekday but earlier/equal time means it's a week away.
    if (dayDelta == 0 && next.startMinutes <= nowMins) dayDelta = 7;

    return dayDelta * 24 * 60 + next.startMinutes - nowMins;
  }

  /// An ordered timeline for [dayOfWeek] annotated with current/next flags.
  /// Designed to feed the Phase-3 home-screen widget, but also drives Today.
  List<WidgetTimelineEntry> widgetTimelineForDay(int dayOfWeek, {DateTime? now}) {
    final at = now ?? DateTime.now();
    final isToday = at.weekday == dayOfWeek;
    final current = isToday ? currentClass(now: at) : null;
    final next = nextClass(now: at);

    return [
      for (final c in classesOnDay(dayOfWeek))
        WidgetTimelineEntry(
          scheduledClass: c,
          isCurrent: current != null && c.id == current.id,
          isNext: next != null && c.id == next.id && current?.id != c.id,
        ),
    ];
  }
}
