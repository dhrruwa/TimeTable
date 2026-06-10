import 'package:flutter/material.dart';

import '../percent_ring.dart';

export '../percent_ring.dart';

/// Shared styling for the home-screen widgets. They're self-contained (no
/// Theme) so they render identically on the home screen. Background color is
/// driven by the CURRENT subject's color; break/done states use a neutral
/// slate. White type hierarchy + thin dividers throughout.
class Wx {
  Wx._();

  static const radius = 22.0;

  static const Color text = Colors.white;
  static Color get text70 => Colors.white.withValues(alpha: 0.74);
  static Color get text55 => Colors.white.withValues(alpha: 0.55);
  static Color get divider => Colors.white.withValues(alpha: 0.22);

  /// Vertical gradient from a subject [color] (slightly brightened top → color).
  static LinearGradient subjectGradient(int color) {
    final c = Color(color);
    final hsl = HSLColor.fromColor(c);
    final top = hsl.withLightness((hsl.lightness + 0.08).clamp(0, 1)).toColor();
    final bottom =
        hsl.withLightness((hsl.lightness - 0.12).clamp(0, 1)).toColor();
    return LinearGradient(
      colors: [top, bottom],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  /// Neutral dark slate gradient for breaks, the day-over state, and the large
  /// full-day card.
  static const neutralGradient = LinearGradient(
    colors: [Color(0xFF2B3340), Color(0xFF1C2129)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// 12-hour "8:30" (compact).
  static String hm(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final hr = h % 12 == 0 ? 12 : h % 12;
    return '$hr:${m.toString().padLeft(2, '0')}';
  }

  static String ampm(int minutes) => (minutes ~/ 60) < 12 ? 'AM' : 'PM';

  static String range(int startMin, int endMin) =>
      '${hm(startMin)} – ${hm(endMin)}';
}

/// The rounded gradient card all three widget sizes sit on.
class WeatherCard extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final Gradient gradient;
  final bool elevated;
  final Widget child;

  const WeatherCard({
    super.key,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    required this.gradient,
    this.elevated = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(Wx.radius),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      padding: padding,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Wx.text,
          fontFamily: 'SF Pro Text',
          fontFamilyFallback: ['.SF UI Text', 'Roboto'],
          height: 1.1,
        ),
        child: child,
      ),
    );
  }
}

class WxDivider extends StatelessWidget {
  const WxDivider({super.key});
  @override
  Widget build(BuildContext context) => Container(height: 1, color: Wx.divider);
}

/// A small colored dot (a subject's color) used in list rows.
class SubjectDot extends StatelessWidget {
  final int color;
  final double size;
  const SubjectDot(this.color, {super.key, this.size = 9});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: Color(color), shape: BoxShape.circle),
      );
}

/// Convenience for a white-on-color percent ring inside the widgets.
class WhiteRing extends StatelessWidget {
  final double percent;
  final double size;
  final double stroke;
  final Widget center;
  const WhiteRing({
    super.key,
    required this.percent,
    required this.size,
    required this.stroke,
    required this.center,
  });
  @override
  Widget build(BuildContext context) => PercentRing(
        percent: percent,
        size: size,
        stroke: stroke,
        trackColor: Colors.white.withValues(alpha: 0.28),
        progressColor: Colors.white,
        center: center,
      );
}
