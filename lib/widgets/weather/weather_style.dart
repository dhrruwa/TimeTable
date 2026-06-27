import 'package:flutter/material.dart';

import '../percent_ring.dart';

export '../percent_ring.dart';

/// Shared styling for the home-screen widgets — a premium, self-contained dark
/// look (no Theme dependency so it renders identically on the home screen).
/// Cards are a glossy dark gradient with a hairline border + top highlight;
/// in-progress classes sweep the red→green ramp. White type hierarchy, hairline
/// dividers, pill chips, and rounded gradient progress bars throughout.
class Wx {
  Wx._();

  // ── radii ────────────────────────────────────────────────────────────────
  static const radius = 26.0; // outer card
  static const radiusInner = 14.0; // card-in-card highlights
  static const radiusChip = 999.0; // pills
  static const radiusBar = 999.0; // progress bars

  // ── text colors ──────────────────────────────────────────────────────────
  static const Color text = Colors.white;
  static Color get text70 => Colors.white.withValues(alpha: 0.72);
  static Color get text55 => Colors.white.withValues(alpha: 0.52);
  static Color get divider => Colors.white.withValues(alpha: 0.16);
  static Color get dividerStrong => Colors.white.withValues(alpha: 0.24);

  // ── type scale (color inherited from DefaultTextStyle = white) ────────────
  static const TextStyle titleLg =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.08, letterSpacing: -0.3);
  static const TextStyle titleMd =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2);
  static const TextStyle bodySm = TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500);
  static TextStyle get caption => TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: text70);
  static TextStyle get overline => TextStyle(
      fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: text70);
  static const TextStyle pctLg =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.3);
  static const TextStyle pctSm = TextStyle(fontSize: 12, fontWeight: FontWeight.w700);

  // ── card decoration helpers ───────────────────────────────────────────────
  /// Hairline border that gives cards a crisp premium edge.
  static Border get hairlineBorder =>
      Border.all(color: Colors.white.withValues(alpha: 0.10), width: 0.5);

  /// A soft top-down sheen overlaid on the card's top ~40%.
  static LinearGradient get topHighlight => LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.10), Colors.white.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.4],
      );

  /// Vertical 3-stop gradient from a subject [color]: glossy top, base mid,
  /// deepened bottom (keeps white text readable).
  static LinearGradient subjectGradient(int color) {
    final hsl = HSLColor.fromColor(Color(color));
    final top = hsl
        .withLightness((hsl.lightness + 0.10).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + 0.04).clamp(0.0, 1.0))
        .toColor();
    final mid = hsl.toColor();
    final bottom = hsl.withLightness((hsl.lightness - 0.16).clamp(0.0, 1.0)).toColor();
    return LinearGradient(
      colors: [top, mid, bottom],
      stops: const [0.0, 0.55, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  /// Neutral dark slate gradient (breaks, day-over, the large full-day card).
  static const neutralGradient = LinearGradient(
    colors: [Color(0xFF323B4A), Color(0xFF232A35), Color(0xFF161B22)],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Live class-progress color, following the exact ramp:
  ///
  ///   #FF0000 → #FF5500 → #FFAA00 → #FFFF00 → #AAFF00 → #55FF00 → #00FF00
  ///
  /// i.e. RED (just started) → ORANGE → YELLOW (halfway) → GREEN (about to end).
  /// Continuous piecewise-linear RGB. MUST stay identical to the Kotlin
  /// `WidgetRenderer.progressColor` so both platforms match — do not change.
  static Color progressColor(double t) {
    final x = t.isNaN ? 0.0 : t.clamp(0.0, 1.0);
    final int r, g;
    if (x <= 0.5) {
      r = 255;
      g = (510 * x).round(); // 0 → 255 over the first half
    } else {
      r = (255 - 510 * (x - 0.5)).round(); // 255 → 0 over the second half
      g = 255;
    }
    return Color.fromARGB(255, r.clamp(0, 255), g.clamp(0, 255), 0);
  }

  /// Card gradient for an in-progress class — a darkened 3-stop sheen of the
  /// live [progressColor], deepened so white type stays readable on the lighter
  /// (yellow/green) parts of the ramp while the hue still reads clearly.
  static LinearGradient progressGradient(double t) {
    final hsl = HSLColor.fromColor(progressColor(t));
    Color at(double f) =>
        hsl.withLightness((hsl.lightness * f).clamp(0.0, 1.0)).withSaturation(1).toColor();
    return LinearGradient(
      colors: [at(0.66), at(0.52), at(0.40)],
      stops: const [0.0, 0.55, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

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
        border: Wx.hairlineBorder,
        // Two-layer shadow only when elevated. The iOS PNG renders with
        // elevated:false so the OS draws its own widget shadow (no baked halo).
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.30),
                  blurRadius: 22,
                  offset: const Offset(0, 14),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Top sheen overlay (non-interactive, above gradient / below content).
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(decoration: BoxDecoration(gradient: Wx.topHighlight)),
            ),
          ),
          Padding(
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
          ),
        ],
      ),
    );
  }
}

class WxDivider extends StatelessWidget {
  final double inset;
  const WxDivider({super.key, this.inset = 0});
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, margin: EdgeInsets.only(left: inset), color: Wx.divider);
}

/// A small colored dot (a subject's color) used in list rows, with an optional
/// soft glow.
class SubjectDot extends StatelessWidget {
  final int color;
  final double size;
  final bool glow;
  const SubjectDot(this.color, {super.key, this.size = 9, this.glow = false});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Color(color),
          shape: BoxShape.circle,
          boxShadow: glow
              ? [BoxShadow(color: Color(color).withValues(alpha: 0.5), blurRadius: 4)]
              : null,
        ),
      );
}

/// A translucent capsule for short labels ("IN PROGRESS", "UP NEXT", break).
class StatusPill extends StatelessWidget {
  final String label;
  const StatusPill(this.label, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(Wx.radiusChip),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14), width: 0.5),
        ),
        child: Text(label, style: Wx.overline.copyWith(color: Wx.text)),
      );
}

/// A capsule showing a percentage ("62%").
class PercentPill extends StatelessWidget {
  final int percent;
  final bool large;
  const PercentPill(this.percent, {super.key, this.large = false});
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: large ? 10 : 8, vertical: large ? 4 : 2.5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(Wx.radiusChip),
        ),
        child: Text('$percent%', style: large ? Wx.pctLg : Wx.pctSm),
      );
}

/// A rounded progress bar with a gradient fill (replaces LinearProgressIndicator).
class ProgressBarRx extends StatelessWidget {
  final double value; // 0..1
  final double height;
  final Gradient? fillGradient;
  const ProgressBarRx({super.key, required this.value, this.height = 6, this.fillGradient});

  @override
  Widget build(BuildContext context) {
    final fill = fillGradient ??
        LinearGradient(colors: [Colors.white, Colors.white.withValues(alpha: 0.85)]);
    return ClipRRect(
      borderRadius: BorderRadius.circular(Wx.radiusBar),
      child: Container(
        height: height,
        color: Colors.white.withValues(alpha: 0.22),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: DecoratedBox(decoration: BoxDecoration(gradient: fill)),
          ),
        ),
      ),
    );
  }
}

/// A small "LAB" (or similar) pill tag.
class LabTag extends StatelessWidget {
  final String text;
  const LabTag(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(left: 5),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(Wx.radiusChip),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 8.5, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
      );
}

/// Convenience for a percent ring inside the widgets. Defaults to a white
/// stroke; pass [stroke]Color to carry the live progress color.
class WhiteRing extends StatelessWidget {
  final double percent;
  final double size;
  final double stroke;
  final Widget center;
  final Color? strokeColor;
  const WhiteRing({
    super.key,
    required this.percent,
    required this.size,
    required this.stroke,
    required this.center,
    this.strokeColor,
  });
  @override
  Widget build(BuildContext context) => PercentRing(
        percent: percent,
        size: size,
        stroke: stroke,
        trackColor: Colors.white.withValues(alpha: 0.22),
        progressColor: strokeColor ?? Colors.white,
        center: center,
      );
}
