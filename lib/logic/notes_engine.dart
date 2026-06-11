import '../models/period_models.dart';
import 'timetable_builder.dart';

/// Picks a single contextual, motivational note for the Today screen / widget.
///
/// Priority: low-attendance alert > lab-today reminder > early-start warning >
/// evening prep > generic pool (seeded by weekday so it's stable for the day).
/// Pure — no Flutter, no persistence.
class NotesEngine {
  const NotesEngine._();

  static String pick({
    required DateTime now,
    required Timetable timetable,
    Map<String, double> attendancePct = const {},
  }) {
    final weekday = now.weekday;
    final todays = TimetableBuilder.buildDay(
      timetable.periodsOn(weekday),
      timetable.subjectsById,
      timetable.config,
    );

    // 1. Low attendance (< 70%) for a subject scheduled today.
    final byId = timetable.subjectsById;
    for (final p in timetable.periodsOn(weekday)) {
      final pct = attendancePct[p.subjectId];
      if (pct != null && pct < 0.70) {
        final name = byId[p.subjectId]?.name ?? 'a subject';
        return "⚠️ $name attendance is ${(pct * 100).round()}% — don't skip today.";
      }
    }

    // 2. Lab today.
    final lab = todays.where((e) => e.isLab).toList();
    if (lab.isNotEmpty) {
      return '🥽 You have ${lab.first.title} today — come prepared!';
    }

    // 3. Early first class tomorrow.
    final tmrwWeekday = now.add(const Duration(days: 1)).weekday;
    final tmrw = TimetableBuilder.buildDay(
      timetable.periodsOn(tmrwWeekday),
      byId,
      timetable.config,
    );
    final lastEnd = todays.isEmpty ? 0 : todays.last.endMin;
    final afterClasses = now.hour * 60 + now.minute >= lastEnd;
    if (afterClasses && tmrw.isNotEmpty && tmrw.first.startMin <= 9 * 60) {
      return '🌙 Early start tomorrow — first class at '
          '${_hm(tmrw.first.startMin)}. Rest up!';
    }

    // 4. Evening prep.
    if (afterClasses && todays.isNotEmpty) {
      return '🎒 Day done. Get tomorrow sorted and rest well.';
    }

    // 5. Generic pool, stable per weekday.
    return _generic[weekday % _generic.length];
  }

  static String _hm(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final hr = h % 12 == 0 ? 12 : h % 12;
    return '$hr:${m.toString().padLeft(2, '0')} ${h < 12 ? 'AM' : 'PM'}';
  }

  static const _generic = [
    'Every class is one step closer to your degree 🎓',
    "Show up. That's already half the battle 💪",
    'Your future self will thank you for attending today 🙏',
    "One period at a time. You've got this ⚡",
    'Consistency beats intensity. Be consistent 📈',
    'Small steps every day add up to big results 🚀',
    'Focus on today — tomorrow takes care of itself 🌱',
  ];
}
