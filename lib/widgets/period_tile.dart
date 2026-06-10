import 'package:flutter/material.dart';

import '../models/period_models.dart';
import '../theme.dart';
import 'time_utils.dart';

/// A single row on the Today schedule: a colored class/lab card, or a slim
/// centered break row. The current period is tinted in its subject color and
/// shows a live completion bar + %.
class PeriodTile extends StatelessWidget {
  final TimelineEntry entry;
  final bool isCurrent;
  final int? percent;
  final double? completion;
  final VoidCallback? onTap;

  const PeriodTile({
    super.key,
    required this.entry,
    this.isCurrent = false,
    this.percent,
    this.completion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (entry.isBreak) return _breakRow(context);

    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;
    final color = Color(entry.color);
    final bg = isCurrent
        ? SubjectColors.surface(color, brightness)
        : scheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final subtitle = [
      if (entry.teacher != null && entry.teacher!.isNotEmpty) entry.teacher!,
      if (entry.room != null && entry.room!.isNotEmpty) entry.room!,
    ].join('  ·  ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isCurrent ? Border.all(color: color, width: 1.5) : null,
            ),
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 5,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 56,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(TimeUtils.formatMinutes(context, entry.startMin),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(TimeUtils.formatMinutes(context, entry.endMin),
                          style: TextStyle(
                              fontSize: 11, color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(entry.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                          ),
                          if (entry.isLab) _Tag('LAB', color),
                        ],
                      ),
                      if (subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant)),
                        ),
                      if (isCurrent && completion != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: completion,
                            minHeight: 5,
                            backgroundColor: color.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isCurrent && percent != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('$percent%',
                        style: TextStyle(
                            color: color,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _breakRow(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon =
        entry.kind == EntryKind.lunch ? Icons.restaurant : Icons.local_cafe;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            '${entry.title}  ·  ${TimeUtils.formatMinutes(context, entry.startMin)}'
            ' – ${TimeUtils.formatMinutes(context, entry.endMin)}',
            style: TextStyle(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: color)),
      );
}
