import 'package:flutter/material.dart';

/// How a theme paints its background. Widgets that can only render a flat fill
/// (native Android via a single color) fall back to [gradientStops.first].
enum BgKind { solid, gradient, image }

/// Progress-bar color ramp. The *name* of this enum is the single token carried
/// to native Android (Kotlin `WidgetRenderer.progressColor`) so the Dart and
/// Kotlin ramps stay in lockstep — never duplicate the math, branch on the name.
enum ProgressRamp { redGreen, mono, neon }

/// Optional in-app animated overlay a pack can opt into. Defaults to [none] so
/// every pack ships as a static token pack and effects are purely additive.
enum ThemeEffect { none, sakura, scanlines, neonGrid, nowPlaying, starfield, pixel }

/// Visual treatment of cards/surfaces.
enum CardStyle { glass, flat, neon, pixel }

/// Background specification — flattened to a top/bottom color pair for the
/// native widget, used in full (3-stop gradient / asset image) in-app and in the
/// Flutter-rendered widget PNGs.
@immutable
class BgSpec {
  final BgKind kind;
  final Color solid;
  final List<Color> gradientStops; // top -> bottom, 2-3 stops
  final double gradientAngle; // degrees, matches Android <gradient android:angle>
  final String? assetImage; // in-app only; widgets fall back to gradient/solid

  const BgSpec.solid(this.solid)
      : kind = BgKind.solid,
        gradientStops = const [],
        gradientAngle = 270,
        assetImage = null;

  const BgSpec.gradient(this.gradientStops, {this.gradientAngle = 270})
      : kind = BgKind.gradient,
        solid = const Color(0xFF000000),
        assetImage = null;

  const BgSpec.image(this.assetImage, this.gradientStops)
      : kind = BgKind.image,
        solid = const Color(0xFF000000),
        gradientAngle = 270;

  /// Top color for the native widget's flat/gradient fill.
  Color get top => kind == BgKind.solid
      ? solid
      : (gradientStops.isNotEmpty ? gradientStops.first : solid);

  /// Bottom color for the native widget's gradient fill.
  Color get bottom => kind == BgKind.solid
      ? solid
      : (gradientStops.isNotEmpty ? gradientStops.last : solid);

  /// In-app / PNG gradient. Solid backgrounds become a flat 2-stop gradient.
  LinearGradient get linearGradient => LinearGradient(
        colors: kind == BgKind.solid ? [solid, solid] : gradientStops,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
}

/// Frosted-glass / shadow treatment. `blur` is in-app only (BackdropFilter);
/// widget PNGs and native Android ignore it.
@immutable
class GlassSpec {
  final bool blur;
  final double blurSigma;
  final double cardOpacity; // card fill alpha over the background
  final Color hairline; // replaces Wx.hairlineBorder color
  final double topSheen; // replaces Wx.topHighlight peak alpha (0 disables)
  final List<BoxShadow> shadow;

  const GlassSpec({
    this.blur = false,
    this.blurSigma = 0,
    this.cardOpacity = 1,
    required this.hairline,
    this.topSheen = 0.10,
    this.shadow = const [],
  });
}

/// Typography overrides. `null` fontFamily keeps the SF Pro / Roboto default.
@immutable
class ThemeTypography {
  final String? fontFamily;
  final List<String> fontFallback;
  final double titleScale; // multiplies widget title sizes
  final double letterSpacingDelta;
  final FontWeight headingWeight;

  const ThemeTypography({
    this.fontFamily,
    this.fontFallback = const ['SF Pro Text', '.SF UI Text', 'Roboto'],
    this.titleScale = 1.0,
    this.letterSpacingDelta = 0,
    this.headingWeight = FontWeight.w700,
  });
}

/// Per-theme label renames. Defaults equal the strings the app currently
/// hardcodes, so an unset pack is visually unchanged.
@immutable
class ThemeLabels {
  final String currentClass; // "IN PROGRESS" -> "MISSION" / "ACTIVE QUEST" / ...
  final String upNext; // "UP NEXT"
  final String onBreak; // "ON BREAK"
  final String attendance; // "Attendance" -> "Power Level" / "XP" / "Fuel"
  final String dayOver; // "Classes are over"
  final String emptyDay; // "No classes today"

  const ThemeLabels({
    this.currentClass = 'IN PROGRESS',
    this.upNext = 'UP NEXT',
    this.onBreak = 'ON BREAK',
    this.attendance = 'Attendance',
    this.dayOver = 'Classes are over',
    this.emptyDay = 'No classes today',
  });
}

/// A complete theme pack — pure data. Adding a new theme is exactly one
/// `ThemeModel` literal in `lib/theme/packs/`; no widget logic changes.
@immutable
class ThemeModel {
  final String id; // stable persistence key, e.g. 'liquid_glass'
  final String name;
  final String description;
  final Brightness brightness;

  /// Folder under assets/theme_packs/ holding this pack's wallpapers. When the
  /// pack has generated images (see manifest.json), the widget uses a full-bleed
  /// wallpaper + a readability scrim instead of [background]; otherwise it falls
  /// back to the [background] gradient. The background image *is* the theme.
  final String assetPack;

  /// Strength (0..1) of the bottom-weighted dark scrim drawn over the wallpaper
  /// so overlaid timetable text stays readable on any photo.
  final double overlayStrength;

  final Color primary; // Material seed + accents
  final Color secondary;
  final Color accent; // progress / highlight / pill accents
  final Color onBg; // default text color on the themed background

  final BgSpec background;
  final ThemeTypography typography;
  final GlassSpec glass;
  final CardStyle cardStyle;
  final ProgressRamp progressRamp;
  final double borderRadius;
  final ThemeEffect effect;
  final ThemeLabels labels;

  const ThemeModel({
    required this.id,
    required this.name,
    required this.description,
    this.brightness = Brightness.dark,
    required this.assetPack,
    this.overlayStrength = 0.55,
    required this.primary,
    required this.secondary,
    required this.accent,
    this.onBg = Colors.white,
    required this.background,
    this.typography = const ThemeTypography(),
    required this.glass,
    this.cardStyle = CardStyle.glass,
    this.progressRamp = ProgressRamp.redGreen,
    this.borderRadius = 26,
    this.effect = ThemeEffect.none,
    this.labels = const ThemeLabels(),
  });
}
