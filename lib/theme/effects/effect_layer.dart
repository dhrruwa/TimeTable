import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme_model.dart';

/// Returns the in-app animated overlay for [effect], or an empty box for
/// [ThemeEffect.none]. Overlays are decorative and non-interactive — callers
/// wrap them in [IgnorePointer] and stack them above content. Widgets (home /
/// lock screen) never animate, so this is in-app only.
Widget effectFor(ThemeEffect effect, ThemeModel theme) {
  switch (effect) {
    case ThemeEffect.sakura:
      return _ParticleOverlay(color: theme.accent, kind: _Particle.petal);
    case ThemeEffect.starfield:
      return _ParticleOverlay(color: theme.onBg, kind: _Particle.star);
    case ThemeEffect.scanlines:
      return _ScanlineOverlay(color: theme.accent);
    case ThemeEffect.neonGrid:
      return _NeonGridOverlay(color: theme.accent);
    case ThemeEffect.none:
    case ThemeEffect.nowPlaying:
    case ThemeEffect.pixel:
      return const SizedBox.shrink();
  }
}

enum _Particle { petal, star }

/// Drifting particles — falling petals (sakura) or twinkling stars (space).
class _ParticleOverlay extends StatefulWidget {
  final Color color;
  final _Particle kind;
  const _ParticleOverlay({required this.color, required this.kind});

  @override
  State<_ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<_ParticleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  late final List<_Seed> _seeds = List.generate(28, (i) {
    final r = math.Random(i * 7 + 13);
    return _Seed(r.nextDouble(), r.nextDouble(), 0.4 + r.nextDouble(), r.nextDouble());
  });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          painter: _ParticlePainter(_c.value, _seeds, widget.color, widget.kind),
          size: Size.infinite,
        ),
      );
}

class _Seed {
  final double x, phase, speed, size;
  _Seed(this.x, this.phase, this.speed, this.size);
}

class _ParticlePainter extends CustomPainter {
  final double t;
  final List<_Seed> seeds;
  final Color color;
  final _Particle kind;
  _ParticlePainter(this.t, this.seeds, this.color, this.kind);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in seeds) {
      if (kind == _Particle.star) {
        // Twinkle in place.
        final tw = (math.sin((t + s.phase) * math.pi * 2) + 1) / 2;
        paint.color = color.withValues(alpha: 0.15 + 0.5 * tw * s.size);
        final x = s.x * size.width;
        final y = s.phase * size.height;
        canvas.drawCircle(Offset(x, y), 0.8 + 1.6 * s.size, paint);
      } else {
        // Fall + sway.
        final prog = (t * s.speed + s.phase) % 1.0;
        final y = prog * (size.height + 40) - 20;
        final sway = math.sin((prog + s.phase) * math.pi * 4) * 14;
        final x = s.x * size.width + sway;
        paint.color = color.withValues(alpha: 0.10 + 0.18 * s.size);
        canvas.drawCircle(Offset(x, y), 2.5 + 3 * s.size, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

/// A bright scan line sweeping vertically over faint static lines.
class _ScanlineOverlay extends StatefulWidget {
  final Color color;
  const _ScanlineOverlay({required this.color});

  @override
  State<_ScanlineOverlay> createState() => _ScanlineOverlayState();
}

class _ScanlineOverlayState extends State<_ScanlineOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          painter: _ScanlinePainter(_c.value, widget.color),
          size: Size.infinite,
        ),
      );
}

class _ScanlinePainter extends CustomPainter {
  final double t;
  final Color color;
  _ScanlinePainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // Faint static scan lines.
    final faint = Paint()..color = color.withValues(alpha: 0.035);
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), faint);
    }
    // Sweeping bright band.
    final y = t * size.height;
    canvas.drawRect(
      Rect.fromLTWH(0, y - 24, size.width, 48),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0),
            color.withValues(alpha: 0.14),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, y - 24, size.width, 48)),
    );
  }

  @override
  bool shouldRepaint(_ScanlinePainter old) => old.t != t;
}

/// A subtle perspective neon grid that scrolls toward the viewer.
class _NeonGridOverlay extends StatefulWidget {
  final Color color;
  const _NeonGridOverlay({required this.color});

  @override
  State<_NeonGridOverlay> createState() => _NeonGridOverlayState();
}

class _NeonGridOverlayState extends State<_NeonGridOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          painter: _NeonGridPainter(_c.value, widget.color),
          size: Size.infinite,
        ),
      );
}

class _NeonGridPainter extends CustomPainter {
  final double t;
  final Color color;
  _NeonGridPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.10)
      ..strokeWidth = 1;
    const rows = 14;
    final hStart = size.height * 0.45;
    for (int i = 0; i < rows; i++) {
      final p = ((i + t) % rows) / rows; // 0..1 toward viewer
      final y = hStart + (size.height - hStart) * (p * p);
      canvas.drawLine(Offset(0, y), Offset(size.width, y),
          paint..color = color.withValues(alpha: 0.04 + 0.10 * p));
    }
    // Vertical perspective lines converging near the horizon center.
    const cols = 10;
    final cx = size.width / 2;
    for (int i = 0; i <= cols; i++) {
      final fx = i / cols;
      final bottomX = fx * size.width;
      final topX = cx + (bottomX - cx) * 0.12;
      canvas.drawLine(Offset(topX, hStart), Offset(bottomX, size.height),
          paint..color = color.withValues(alpha: 0.06));
    }
  }

  @override
  bool shouldRepaint(_NeonGridPainter old) => old.t != t;
}
