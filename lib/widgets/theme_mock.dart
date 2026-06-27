import 'package:flutter/material.dart';

import '../theme/theme_model.dart';

/// A self-contained preview of how a [ThemeModel] skins a home-screen widget.
/// Renders directly from the model's tokens (no global [Wx] state), so many can
/// be shown side-by-side in the Theme Store without interfering with the live
/// theme. Used both for store cards (compact) and the preview screen (sizes).
class ThemeMock extends StatelessWidget {
  final ThemeModel theme;
  final double width;
  final double height;

  /// Hide the upcoming list / extra rows for tiny cards.
  final bool compact;

  /// Optional wallpaper asset — when set the mock shows the real pack artwork
  /// with the timetable content overlaid (exactly how the widget will look).
  final String? imageAsset;

  const ThemeMock({
    super.key,
    required this.theme,
    required this.width,
    required this.height,
    this.compact = false,
    this.imageAsset,
  });

  /// A representative live-progress color at [t], mirroring the ramp branches in
  /// `Wx.progressColor` so the preview matches the real widget.
  Color _ramp(double t) {
    final x = t.clamp(0.0, 1.0);
    switch (theme.progressRamp) {
      case ProgressRamp.redGreen:
        final int r, g;
        if (x <= 0.5) {
          r = 255;
          g = (510 * x).round();
        } else {
          r = (255 - 510 * (x - 0.5)).round();
          g = 255;
        }
        return Color.fromARGB(255, r.clamp(0, 255), g.clamp(0, 255), 0);
      case ProgressRamp.mono:
        return theme.accent;
      case ProgressRamp.neon:
        return Color.lerp(theme.secondary, theme.primary, x)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    const sample = 0.62;
    final onBg = theme.onBg;
    final fontFamily = theme.typography.fontFamily;
    final progress = _ramp(sample);
    final scale = (width / 170).clamp(0.7, 1.4);

    TextStyle t(double size, FontWeight w, {Color? c, double ls = 0}) => TextStyle(
          fontSize: size * scale,
          fontWeight: w,
          color: c ?? onBg,
          fontFamily: fontFamily,
          letterSpacing: ls + theme.typography.letterSpacingDelta,
          height: 1.1,
        );

    final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MON', style: t(11, FontWeight.w700, c: onBg.withValues(alpha: 0.7), ls: 1.2)),
          SizedBox(height: 8 * scale),
          // Status pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9 * scale, vertical: 3 * scale),
            decoration: BoxDecoration(
              color: theme.accent.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: theme.accent.withValues(alpha: 0.5), width: 0.5),
            ),
            child: Text(theme.labels.currentClass,
                style: t(10, FontWeight.w800, c: theme.accent, ls: 0.8)),
          ),
          SizedBox(height: 8 * scale),
          Text('Mathematics',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t(17, theme.typography.headingWeight)),
          SizedBox(height: 2 * scale),
          Text('Ends 9:15 · LH-204',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t(11.5, FontWeight.w500, c: onBg.withValues(alpha: 0.72))),
          const Spacer(),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 6 * scale,
              color: onBg.withValues(alpha: 0.22),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: sample,
                  child: DecoratedBox(decoration: BoxDecoration(color: progress)),
                ),
              ),
            ),
          ),
          if (!compact) ...[
            SizedBox(height: 10 * scale),
            Text('Next · Physics · 9:25',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t(12, FontWeight.w500, c: onBg.withValues(alpha: 0.72))),
          ],
        ],
      );

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: imageAsset == null ? theme.background.linearGradient : null,
        color: imageAsset == null ? null : Colors.black,
        borderRadius: BorderRadius.circular(theme.borderRadius),
        border: Border.all(color: theme.glass.hairline, width: 0.5),
        boxShadow: theme.glass.shadow,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageAsset != null) ...[
            Image.asset(imageAsset!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => DecoratedBox(
                    decoration:
                        BoxDecoration(gradient: theme.background.linearGradient))),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: theme.overlayStrength * 0.35),
                    Colors.black.withValues(alpha: theme.overlayStrength * 0.55),
                    Colors.black.withValues(alpha: theme.overlayStrength),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ],
          Padding(padding: EdgeInsets.all(14 * scale), child: content),
        ],
      ),
    );
  }
}
