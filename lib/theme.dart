import 'package:flutter/material.dart';

/// Material 3 themes for light and dark mode. The app's accent is a calm
/// indigo; per-class color comes from each course, applied at the widget level.
class AppTheme {
  static const _seed = Color(0xFF4F46E5);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}

/// Color helpers for rendering per-course colors legibly on either theme.
class CourseColors {
  /// A soft, theme-aware tint of [color] for block/card backgrounds.
  static Color surface(Color color, Brightness brightness) {
    return Color.alphaBlend(
      color.withOpacity(brightness == Brightness.dark ? 0.22 : 0.14),
      brightness == Brightness.dark
          ? const Color(0xFF1C1B1F)
          : Colors.white,
    );
  }

  /// A foreground color that reads well on [surface] of the same [color].
  static Color onSurface(Color color, Brightness brightness) {
    final hsl = HSLColor.fromColor(color);
    return brightness == Brightness.dark
        ? hsl.withLightness((hsl.lightness + 0.35).clamp(0.0, 1.0)).toColor()
        : hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
  }

  /// Black or white text that contrasts with a solid [color] fill.
  static Color contrastOn(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
