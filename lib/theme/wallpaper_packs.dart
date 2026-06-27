import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Resolves the generated wallpaper assets for theme packs.
///
/// Wallpapers are produced by `tool/generate_wallpapers.dart` into
/// `assets/theme_packs/<pack>/<index>_<size>.png`, with `manifest.json` recording
/// how many wallpapers each pack has. When a pack has 0 wallpapers (artwork not
/// generated yet) the app gracefully falls back to the gradient look, so the
/// feature works before — and upgrades automatically after — generation.
class WallpaperPacks {
  WallpaperPacks._();

  static Map<String, int> _counts = const {};

  /// Loads the bundled manifest once at startup. Safe to call if the manifest is
  /// missing or empty (counts stay 0 → gradient fallback everywhere).
  static Future<void> load() async {
    try {
      final s = await rootBundle.loadString('assets/theme_packs/manifest.json');
      final m = jsonDecode(s) as Map<String, dynamic>;
      _counts = m.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      _counts = const {};
    }
  }

  static int count(String pack) => _counts[pack] ?? 0;

  /// Whether [pack] has generated wallpapers (else use the gradient fallback).
  static bool has(String pack) => count(pack) > 0;

  /// The wallpaper index (1..count) to show at [now]. Rotates roughly hourly so
  /// the home screen feels like a live collection without flickering on the
  /// native widget's 60-second ticks. Mirrors the Kotlin selection exactly.
  static int indexFor(String pack, DateTime now) {
    final c = count(pack);
    if (c <= 0) return 0;
    final bucket = now.day * 24 + now.hour;
    return (bucket % c) + 1;
  }

  /// Asset path for a wallpaper [size] (small|medium|large|lockscreen) of [pack]
  /// at [now], or null if the pack has no wallpapers.
  static String? asset(String pack, String size, DateTime now) {
    final i = indexFor(pack, now);
    if (i == 0) return null;
    return 'assets/theme_packs/$pack/${i}_$size.png';
  }

  /// The store preview image for [pack], or null if not generated yet.
  static String? preview(String pack) =>
      has(pack) ? 'assets/theme_packs/$pack/preview.png' : null;
}
