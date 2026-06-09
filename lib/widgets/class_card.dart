import 'package:flutter/material.dart';

import '../logic/schedule_service.dart';
import '../theme.dart';
import 'time_utils.dart';

/// A color-coded card for a single scheduled class. Used in the Today list.
/// When [highlight] is true (the in-progress class) it gets a stronger accent.
class ClassCard extends StatelessWidget {
  final ScheduledClass scheduledClass;
  final bool highlight;
  final VoidCallback? onTap;

  const ClassCard({
    super.key,
    required this.scheduledClass,
    this.highlight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = Color(scheduledClass.color);
    final bg = CourseColors.surface(color, brightness);
    final fg = CourseColors.onSurface(color, brightness);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: highlight
            ? BorderSide(color: color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            scheduledClass.courseName,
                            style: textTheme.titleMedium?.copyWith(
                              color: fg,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (highlight)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Now',
                              style: textTheme.labelSmall?.copyWith(
                                color: CourseColors.contrastOn(color),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${TimeUtils.formatMinutes(context, scheduledClass.startMinutes)}'
                      ' – '
                      '${TimeUtils.formatMinutes(context, scheduledClass.endMinutes)}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: fg.withOpacity(0.9),
                      ),
                    ),
                    if (scheduledClass.room != null &&
                        scheduledClass.room!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Icon(Icons.place_outlined,
                                size: 15, color: fg.withOpacity(0.8)),
                            const SizedBox(width: 3),
                            Text(
                              scheduledClass.room!,
                              style: textTheme.bodySmall
                                  ?.copyWith(color: fg.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
