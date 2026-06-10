import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A circular completion ring with a configurable track/progress color and a
/// centered child (usually the percentage text).
class PercentRing extends StatelessWidget {
  final double percent; // 0..1
  final double size;
  final double stroke;
  final Color trackColor;
  final Color progressColor;
  final Widget? center;

  const PercentRing({
    super.key,
    required this.percent,
    this.size = 56,
    this.stroke = 6,
    required this.trackColor,
    required this.progressColor,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          percent: percent.clamp(0, 1),
          stroke: stroke,
          track: trackColor,
          progress: progressColor,
        ),
        child: Center(child: center),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final double stroke;
  final Color track;
  final Color progress;

  _RingPainter({
    required this.percent,
    required this.stroke,
    required this.track,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = (Offset.zero & size).center;
    final radius = (size.shortestSide - stroke) / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = track;
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = progress;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percent != percent ||
      old.track != track ||
      old.progress != progress ||
      old.stroke != stroke;
}
