import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Soft, rounded Material 3 theme — calm solid colors (no neon), generous
/// curves, airy surfaces, and pill-shaped buttons. Per-subject color is applied
/// at the widget level from each subject.
class AppTheme {
  // A calm, slightly muted indigo — solid, not neon.
  static const _seed = Color(0xFF5965C8);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    final pill = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(26),
    );
    ButtonStyle pillStyle(Color? bg, Color? fg) => ButtonStyle(
          shape: WidgetStatePropertyAll(pill),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 22, vertical: 14)),
          minimumSize: const WidgetStatePropertyAll(Size(0, 50)),
          textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          backgroundColor: bg == null ? null : WidgetStatePropertyAll(bg),
          foregroundColor: fg == null ? null : WidgetStatePropertyAll(fg),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      // Smooth, premium navigation transitions on both platforms.
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(style: pillStyle(null, null)),
      elevatedButtonTheme: ElevatedButtonThemeData(style: pillStyle(null, null)),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: pillStyle(null, null).copyWith(
          side: WidgetStatePropertyAll(
              BorderSide(color: scheme.outlineVariant)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(pill),
          textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: scheme.surface,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: scheme.secondaryContainer,
        indicatorShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
    );
  }
}

/// Shared card decoration — a soft surface with rounded corners (curved, not a
/// hard box).
BoxDecoration cardDecoration(ColorScheme scheme, {Color? accent}) =>
    BoxDecoration(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: (accent ?? scheme.outlineVariant).withValues(alpha: 0.4),
      ),
    );

/// Uppercase section-header text style.
TextStyle sectionHeaderStyle(ColorScheme scheme) => TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: scheme.onSurfaceVariant,
    );

/// Color helpers for rendering per-course colors legibly on either theme.
class SubjectColors {
  /// A soft, theme-aware tint of [color] for block/card backgrounds.
  static Color surface(Color color, Brightness brightness) {
    return Color.alphaBlend(
      color.withValues(alpha: brightness == Brightness.dark ? 0.24 : 0.13),
      brightness == Brightness.dark ? const Color(0xFF1A1A1E) : Colors.white,
    );
  }

  /// A foreground color that reads well on [surface] of the same [color].
  static Color onSurface(Color color, Brightness brightness) {
    final hsl = HSLColor.fromColor(color);
    return brightness == Brightness.dark
        ? hsl.withLightness((hsl.lightness + 0.35).clamp(0.0, 1.0)).toColor()
        : hsl.withLightness((hsl.lightness - 0.22).clamp(0.0, 1.0)).toColor();
  }

  /// Black or white text that contrasts with a solid [color] fill.
  static Color contrastOn(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
