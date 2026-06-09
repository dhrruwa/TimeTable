import 'package:flutter/material.dart';

import '../logic/schedule_service.dart';
import '../theme.dart';
import 'time_utils.dart';

/// The hero banner on the Today screen. Shows the in-progress class, or counts
/// down to the next one, or a calm "nothing scheduled" message. All schedule
/// reasoning is done by [ScheduleService]; this widget only renders what it's
/// given.
class CurrentClassBanner extends StatelessWidget {
  final ScheduledClass? current;
  final ScheduledClass? next;
  final int? minutesUntilNext;

  const CurrentClassBanner({
    super.key,
    required this.current,
    required this.next,
    required this.minutesUntilNext,
  });

  @override
  Widget build(BuildContext context) {
    if (current != null) {
      return _BannerShell(
        scheduledClass: current!,
        eyebrow: 'In progress',
        trailing: 'Ends ${TimeUtils.formatMinutes(context, current!.endMinutes)}',
      );
    }
    if (next != null) {
      final mins = minutesUntilNext ?? 0;
      return _BannerShell(
        scheduledClass: next!,
        eyebrow: _untilLabel(mins, next!),
        trailing:
            '${TimeUtils.formatMinutes(context, next!.startMinutes)} · ${TimeUtils.dayShort(next!.dayOfWeek)}',
      );
    }
    return _EmptyBanner();
  }

  String _untilLabel(int mins, ScheduledClass next) {
    // If it's not today, the minute countdown isn't meaningful — name the day.
    if (mins >= 12 * 60) {
      return 'Next: ${TimeUtils.dayName(next.dayOfWeek)}';
    }
    if (mins <= 0) return 'Starting now';
    if (mins < 60) return 'Next class in $mins min';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m == 0 ? 'Next class in ${h}h' : 'Next class in ${h}h ${m}m';
  }
}

class _BannerShell extends StatelessWidget {
  final ScheduledClass scheduledClass;
  final String eyebrow;
  final String trailing;

  const _BannerShell({
    required this.scheduledClass,
    required this.eyebrow,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(scheduledClass.color);
    final onColor = CourseColors.contrastOn(color);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.alphaBlend(Colors.black12, color)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: textTheme.labelMedium?.copyWith(
              color: onColor.withOpacity(0.85),
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scheduledClass.courseName,
            style: textTheme.headlineSmall?.copyWith(
              color: onColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.schedule, size: 17, color: onColor.withOpacity(0.9)),
              const SizedBox(width: 5),
              Text(trailing,
                  style:
                      textTheme.bodyMedium?.copyWith(color: onColor.withOpacity(0.95))),
              if (scheduledClass.room != null &&
                  scheduledClass.room!.isNotEmpty) ...[
                const SizedBox(width: 16),
                Icon(Icons.place_outlined,
                    size: 17, color: onColor.withOpacity(0.9)),
                const SizedBox(width: 5),
                Text(scheduledClass.room!,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: onColor.withOpacity(0.95))),
              ],
            ],
          ),
          if (scheduledClass.instructor != null &&
              scheduledClass.instructor!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(scheduledClass.instructor!,
                style:
                    textTheme.bodySmall?.copyWith(color: onColor.withOpacity(0.85))),
          ],
        ],
      ),
    );
  }
}

class _EmptyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Icon(Icons.celebration_outlined, color: scheme.primary, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No more classes',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text('You’re all caught up — enjoy the break.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
