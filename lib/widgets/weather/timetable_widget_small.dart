import 'package:flutter/material.dart';

import '../../logic/today_engine.dart';
import '../../models/period_models.dart';
import 'weather_style.dart';

/// SMALL (square): current subject (colored card) + completion ring, then the
/// next 2 classes.
class TimetableWidgetSmall extends StatelessWidget {
  final TodayStatus status;
  final String weekday;
  final String date;
  final double size;
  final bool elevated;

  const TimetableWidgetSmall({
    super.key,
    required this.status,
    required this.weekday,
    required this.date,
    this.size = 170,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final h = _Head.from(status);
    final next = status.upcomingClasses.take(2).toList();

    return WeatherCard(
      width: size,
      height: size,
      elevated: elevated,
      gradient: h.liveProgress != null
          ? Wx.progressGradient(h.liveProgress!)
          : (h.accentColor != null
              ? Wx.subjectGradient(h.accentColor!)
              : Wx.neutralGradient),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(weekday.toUpperCase(), style: Wx.overline.copyWith(color: Wx.text)),
              const Spacer(),
              Text(date, style: Wx.caption),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (h.showRing)
                WhiteRing(
                  percent: h.ring,
                  size: 46,
                  stroke: 4.5,
                  strokeColor:
                      h.liveProgress != null ? Wx.progressColor(h.ring) : null,
                  center: Text('${(h.ring * 100).round()}%', style: Wx.pctSm),
                )
              else
                Icon(h.icon, size: 30, color: Wx.text),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(h.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Wx.titleMd.copyWith(fontSize: 14.5, height: 1.15)),
                    const SizedBox(height: 2),
                    Text(h.sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Wx.caption.copyWith(fontSize: 10.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const WxDivider(),
          const SizedBox(height: 8),
          if (next.isEmpty)
            Text('No more classes', style: Wx.caption.copyWith(color: Wx.text55))
          else
            for (final e in next)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SubjectDot(e.color, size: 8, glow: true),
                    const SizedBox(width: 7),
                    SizedBox(
                      width: 34,
                      child: Text(Wx.hm(e.startMin), style: Wx.caption),
                    ),
                    Expanded(
                      child: Text(e.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Wx.bodySm),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _Head {
  final String title;
  final String sub;
  final double ring;
  final bool showRing;
  final IconData icon;
  final int? accentColor;

  /// When non-null, a class is in progress and the card uses the live
  /// red→yellow→green [Wx.progressGradient] driven by this 0..1 fraction.
  final double? liveProgress;

  const _Head(this.title, this.sub, this.ring, this.showRing, this.icon,
      this.accentColor,
      {this.liveProgress});

  factory _Head.from(TodayStatus s) {
    if (s.empty) {
      return const _Head(
          'No classes', 'Enjoy the day', 0, false, Icons.weekend, null);
    }
    if (s.beforeDay) {
      return _Head('Classes start', Wx.hm(s.timeline.first.startMin), 0, false,
          Icons.schedule, null);
    }
    if (s.dayOver) {
      return const _Head(
          'All done', 'See you tomorrow', 1, false, Icons.check_circle, null);
    }
    final c = s.current;
    if (s.currentIsBreak && c != null) {
      final frac = c.durationMin == 0
          ? 0.0
          : ((s.nowMinutes - c.startMin) / c.durationMin).clamp(0.0, 1.0);
      return _Head(
          c.title,
          'ends ${Wx.hm(c.endMin)}',
          frac,
          false,
          c.kind == EntryKind.lunch ? Icons.restaurant : Icons.local_cafe,
          null);
    }
    if (s.currentIsClass && c != null) {
      return _Head(c.title, '${s.completionPercent}% complete', s.completion,
          true, Icons.school, c.color,
          liveProgress: s.completion);
    }
    if (s.upcomingClasses.isNotEmpty) {
      final n = s.upcomingClasses.first;
      return _Head('Up next', '${n.title} · ${Wx.hm(n.startMin)}', 0, false,
          Icons.hourglass_empty, null);
    }
    return const _Head(
        'All done', 'See you tomorrow', 1, false, Icons.check_circle, null);
  }
}
