import 'package:flutter/material.dart';

/// UI-side helpers for converting between minutes-since-midnight and Flutter's
/// [TimeOfDay], plus day-name formatting. The pure model has its own `atTime`;
/// these add locale-aware display and native picker integration.
class TimeUtils {
  static TimeOfDay toTimeOfDay(int minutes) =>
      TimeOfDay(hour: (minutes ~/ 60) % 24, minute: minutes % 60);

  static int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  /// Locale-aware time label (respects 24h vs AM/PM device setting).
  static String formatMinutes(BuildContext context, int minutes) =>
      toTimeOfDay(minutes).format(context);

  static const List<String> _dayFull = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _dayShort = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// [dayOfWeek] is 1=Mon..7=Sun.
  static String dayName(int dayOfWeek) => _dayFull[(dayOfWeek - 1) % 7];
  static String dayShort(int dayOfWeek) => _dayShort[(dayOfWeek - 1) % 7];

  /// Human "1h 20m" / "45m" duration label.
  static String durationLabel(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
