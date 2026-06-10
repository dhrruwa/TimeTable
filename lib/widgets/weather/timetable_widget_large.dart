import 'package:flutter/material.dart';

import '../../logic/today_engine.dart';
import '../../models/period_models.dart';
import 'weather_style.dart';

/// LARGE (big square): the FULL day on a neutral card — every class + break in
/// order, each striped in its subject color, with the current class highlighted
/// in its color and its live completion %.
class TimetableWidgetLarge extends StatelessWidget {
  final TodayStatus status;
  final String weekday;
  final String date;
  final double width;
  final double? height;
  final bool elevated;
  final bool dense;

  const TimetableWidgetLarge({
    super.key,
    required this.status,
    required this.weekday,
    required this.date,
    this.width = 360,
    this.height,
    this.elevated = true,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final entries = status.timeline;
    final vPad = dense ? 5.0 : 8.0;

    return WeatherCard(
      width: width,
      height: height,
      elevated: elevated,
      gradient: Wx.neutralGradient,
      padding: EdgeInsets.fromLTRB(18, dense ? 12 : 16, 18, dense ? 10 : 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          SizedBox(height: dense ? 8 : 12),
          const WxDivider(),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text('No classes scheduled',
                    style: TextStyle(color: Wx.text70, fontSize: 14)),
              ),
            )
          else
            for (var i = 0; i < entries.length; i++) ...[
              if (entries[i].isBreak)
                _BreakRow(entry: entries[i], vPad: vPad)
              else
                _ClassRow(
                  entry: entries[i],
                  highlighted: identical(entries[i], status.current),
                  vPad: vPad,
                  percent: identical(entries[i], status.current)
                      ? status.completionPercent
                      : null,
                  completion: identical(entries[i], status.current)
                      ? status.completion
                      : null,
                ),
              if (i != entries.length - 1) const WxDivider(),
            ],
        ],
      ),
    );
  }

  Widget _header() {
    final s = status;
    String title;
    String sub;
    int? accent;
    if (s.empty) {
      title = 'No classes';
      sub = '';
    } else if (s.beforeDay) {
      title = 'Day ahead';
      sub = 'Starts ${Wx.hm(s.timeline.first.startMin)}';
    } else if (s.dayOver) {
      title = 'All classes done';
      sub = 'See you tomorrow';
    } else if (s.currentIsBreak) {
      title = s.current!.title;
      sub = 'Ends ${Wx.hm(s.current!.endMin)}';
    } else if (s.currentIsClass) {
      title = s.current!.title;
      sub = '${s.completionPercent}% complete';
      accent = s.current!.color;
    } else {
      title = 'Free now';
      sub = s.upcomingClasses.isNotEmpty
          ? 'Next ${Wx.hm(s.upcomingClasses.first.startMin)}'
          : 'All classes done';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(weekday,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(date, style: TextStyle(fontSize: 12, color: Wx.text70)),
          ],
        ),
        const Spacer(),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (accent != null) ...[
                    SubjectDot(accent, size: 8),
                    const SizedBox(width: 5),
                  ],
                  Flexible(
                    child: Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(sub, style: TextStyle(fontSize: 12, color: Wx.text70)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClassRow extends StatelessWidget {
  final TimelineEntry entry;
  final bool highlighted;
  final double vPad;
  final int? percent;
  final double? completion;

  const _ClassRow({
    required this.entry,
    required this.highlighted,
    required this.vPad,
    this.percent,
    this.completion,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(entry.color);
    final subtitle = [
      if (entry.teacher != null && entry.teacher!.isNotEmpty) entry.teacher!,
      if (entry.room != null && entry.room!.isNotEmpty) entry.room!,
    ].join(' · ');

    final content = Row(
      children: [
        Container(
          width: 4,
          height: 34,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Wx.hm(entry.startMin),
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w600)),
              Text(Wx.hm(entry.endMin),
                  style: TextStyle(fontSize: 11, color: Wx.text55)),
            ],
          ),
        ),
        const SizedBox(width: 10),
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
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                  if (entry.isLab) const _Tag('LAB'),
                ],
              ),
              if (subtitle.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Wx.text70)),
                ),
            ],
          ),
        ),
        if (percent != null)
          Text('$percent%',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );

    if (!highlighted) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: vPad),
        child: content,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          content,
          if (completion != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: completion,
                minHeight: 4,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BreakRow extends StatelessWidget {
  final TimelineEntry entry;
  final double vPad;
  const _BreakRow({required this.entry, required this.vPad});

  @override
  Widget build(BuildContext context) {
    final icon =
        entry.kind == EntryKind.lunch ? Icons.restaurant : Icons.local_cafe;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vPad),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: Wx.text70),
          const SizedBox(width: 6),
          Text('${entry.title}  ·  ${Wx.range(entry.startMin, entry.endMin)}',
              style: TextStyle(
                  fontSize: 11.5,
                  color: Wx.text70,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
      );
}
