import 'package:flutter/material.dart';

import '../../logic/today_engine.dart';
import '../../models/period_models.dart';
import 'weather_style.dart';

/// MEDIUM (wide): colored summary of the current class on the left, a list of
/// 4 classes (time · subject · room · teacher) on the right, current highlighted.
class TimetableWidgetMedium extends StatelessWidget {
  final TodayStatus status;
  final String weekday;
  final String date;
  final double width;
  final double height;
  final bool elevated;

  const TimetableWidgetMedium({
    super.key,
    required this.status,
    required this.weekday,
    required this.date,
    this.width = 360,
    this.height = 170,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final rows = status.currentPlusNext(4);
    final current = status.currentIsClass ? status.current : null;
    final accent = current?.color;

    return WeatherCard(
      width: width,
      height: height,
      elevated: elevated,
      gradient:
          accent != null ? Wx.subjectGradient(accent) : Wx.neutralGradient,
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: width * 0.36, child: _summary()),
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: Wx.divider,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (rows.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text('No upcoming classes',
                          style: TextStyle(color: Wx.text70, fontSize: 13)),
                    ),
                  )
                else
                  for (final e in rows)
                    _Row(
                      entry: e,
                      highlighted: identical(e, current),
                      percent: identical(e, current)
                          ? status.completionPercent
                          : null,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary() {
    final s = status;
    final String big;
    final String sub;
    if (s.empty) {
      big = 'No classes';
      sub = 'Enjoy the day off';
    } else if (s.beforeDay) {
      big = 'Day ahead';
      sub = 'Starts ${Wx.hm(s.timeline.first.startMin)}';
    } else if (s.dayOver) {
      big = 'Done';
      sub = 'All finished';
    } else if (s.currentIsBreak) {
      big = s.current!.title;
      sub = 'Ends ${Wx.hm(s.current!.endMin)}';
    } else if (s.currentIsClass) {
      big = s.current!.title;
      sub = '${s.completionPercent}% complete';
    } else {
      big = 'Free now';
      sub = s.upcomingClasses.isNotEmpty
          ? 'Next ${Wx.hm(s.upcomingClasses.first.startMin)}'
          : 'No more classes';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(weekday.toUpperCase(),
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: Wx.text70)),
        const SizedBox(height: 2),
        Text(date, style: TextStyle(fontSize: 11, color: Wx.text55)),
        const SizedBox(height: 10),
        Text(big,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 19, fontWeight: FontWeight.w700, height: 1.1)),
        const SizedBox(height: 6),
        Text(sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: Wx.text70)),
        if (s.currentIsClass) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: s.completion,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final TimelineEntry entry;
  final bool highlighted;
  final int? percent;
  const _Row({required this.entry, required this.highlighted, this.percent});

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (entry.teacher != null && entry.teacher!.isNotEmpty) entry.teacher!,
      if (entry.room != null && entry.room!.isNotEmpty) entry.room!,
    ].join(' · ');

    final row = Row(
      children: [
        Container(
          width: 3,
          height: 26,
          decoration: BoxDecoration(
              color: Color(entry.color),
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Wx.hm(entry.startMin),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Text(Wx.ampm(entry.startMin),
                  style: TextStyle(fontSize: 8.5, color: Wx.text55)),
            ],
          ),
        ),
        const SizedBox(width: 6),
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
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  if (entry.isLab) const _Tag('LAB'),
                ],
              ),
              if (subtitle.isNotEmpty)
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10.5, color: Wx.text70)),
            ],
          ),
        ),
        if (percent != null)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text('$percent%',
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w700)),
          ),
      ],
    );

    if (!highlighted) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4), child: row);
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.fromLTRB(6, 5, 8, 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: row,
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(left: 5),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      );
}
