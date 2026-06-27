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
  final String? backgroundImage;

  const TimetableWidgetMedium({
    super.key,
    required this.status,
    required this.weekday,
    required this.date,
    this.width = 360,
    this.height = 170,
    this.elevated = true,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    final rows = status.currentPlusNext(4);
    final current = status.currentIsClass ? status.current : null;

    return WeatherCard(
      width: width,
      height: height,
      elevated: elevated,
      imageAsset: backgroundImage,
      overlayStrength: Wx.active.overlayStrength,
      // In-progress class → live red→yellow→green sweep; otherwise neutral.
      gradient: current != null
          ? Wx.progressGradient(status.completion)
          : Wx.neutralGradient,
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: width * 0.36, child: _summary()),
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 14),
            color: Wx.dividerStrong,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (rows.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text('No upcoming classes',
                          style: Wx.caption.copyWith(fontSize: 13)),
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
    String? pill;
    if (s.empty) {
      big = 'No classes';
      sub = 'Enjoy the day off';
    } else if (s.beforeDay) {
      big = 'Day ahead';
      sub = 'Starts ${Wx.hm(s.timeline.first.startMin)}';
      pill = Wx.active.labels.upNext;
    } else if (s.dayOver) {
      big = 'Done';
      sub = 'All finished';
      pill = 'DONE';
    } else if (s.currentIsBreak) {
      big = s.current!.title;
      sub = 'Ends ${Wx.hm(s.current!.endMin)}';
      pill = Wx.active.labels.onBreak;
    } else if (s.currentIsClass) {
      big = s.current!.title;
      sub = '${s.completionPercent}% complete';
      pill = Wx.active.labels.currentClass;
    } else {
      big = 'Free now';
      sub = s.upcomingClasses.isNotEmpty
          ? 'Next ${Wx.hm(s.upcomingClasses.first.startMin)}'
          : 'No more classes';
      if (s.upcomingClasses.isNotEmpty) pill = Wx.active.labels.upNext;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(weekday.toUpperCase(), style: Wx.overline),
        const SizedBox(height: 2),
        Text(date, style: Wx.caption.copyWith(color: Wx.text55)),
        const SizedBox(height: 10),
        if (pill != null) ...[
          StatusPill(pill),
          const SizedBox(height: 6),
        ],
        Text(big,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Wx.titleLg.copyWith(fontSize: 19, height: 1.1)),
        const SizedBox(height: 6),
        Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: Wx.caption),
        if (s.currentIsClass) ...[
          const SizedBox(height: 8),
          ProgressBarRx(value: s.completion, height: 6),
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
              borderRadius: BorderRadius.circular(Wx.radiusChip)),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Wx.hm(entry.startMin), style: Wx.titleMd.copyWith(fontSize: 13)),
              Text(Wx.ampm(entry.startMin),
                  style: Wx.caption.copyWith(fontSize: 8.5, color: Wx.text55)),
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
                        style: Wx.titleMd.copyWith(fontSize: 13)),
                  ),
                  if (entry.isLab) const LabTag('LAB'),
                ],
              ),
              if (subtitle.isNotEmpty)
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Wx.caption.copyWith(fontSize: 10.5)),
            ],
          ),
        ),
        if (percent != null)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: PercentPill(percent!),
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
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Wx.radiusInner),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 0.5),
      ),
      child: row,
    );
  }
}
