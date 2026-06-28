import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../logic/notes_engine.dart';
import '../logic/timetable_builder.dart';
import '../logic/today_engine.dart';
import '../models/period_models.dart';
import '../theme/theme_catalog.dart';
import '../theme/theme_model.dart';
import '../theme/wallpaper_packs.dart';
import '../widgets/weather/timetable_widget_large.dart';
import '../widgets/weather/timetable_widget_medium.dart';
import '../widgets/weather/timetable_widget_small.dart';
import '../widgets/weather/weather_style.dart';

/// Bridges the Flutter widget designs onto the real OS home-screen widgets by
/// rendering them to PNGs with `home_widget`'s `renderFlutterWidget`.
class HomeWidgetService {
  HomeWidgetService._();

  static const iOSAppGroupId = 'group.com.example.timetable';
  static const _androidProviders = [
    'com.example.timetable.TimetableWidgetSmall',
    'com.example.timetable.TimetableWidgetMedium',
    'com.example.timetable.TimetableWidgetLarge',
  ];
  static const iOSWidgetKind = 'TimetableWidget';

  static const _smallKey = 'tt_small';
  static const _mediumKey = 'tt_medium';
  static const _largeKey = 'tt_large';

  static const _short = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _full = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday' //
  ];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' //
  ];

  static Future<void> init() async {
    if (Platform.isIOS) {
      await HomeWidget.setAppGroupId(iOSAppGroupId);
    }
  }

  /// `#AARRGGBB` for native (`Color.parseColor`) consumption.
  static String _hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

  /// Renders all three sizes for [timetable] at the current moment and refreshes
  /// the home-screen widgets. [theme] re-skins both the Flutter-rendered PNGs
  /// (iOS + initial Android) and the native Android widget (via theme_* tokens).
  static Future<void> refresh(Timetable timetable,
      {DateTime? now, ThemeModel? theme}) async {
    final tm = theme ?? themeById(kDefaultThemeId);
    // The widget trees rasterize off-screen reading Wx.active — set it first so
    // the PNGs bake in the active pack's colors/fonts/labels.
    Wx.active = tm;
    final at = now ?? DateTime.now();
    final weekday = at.weekday;
    final timeline = TimetableBuilder.buildDay(
      timetable.periodsOn(weekday),
      timetable.subjectsById,
      timetable.config,
    );
    final status = TodayEngine.compute(timeline, at);

    final weekdayShort = _short[(weekday - 1) % 7].toUpperCase();
    final weekdayFull = _full[(weekday - 1) % 7];
    final date = '${at.day} ${_months[at.month - 1]}';

    // Resolve this pack's wallpaper per size (null → gradient fallback). The
    // background image *is* the theme when present.
    final pack = tm.assetPack;
    final wpSmall = WallpaperPacks.asset(pack, 'small', at);
    final wpMedium = WallpaperPacks.asset(pack, 'medium', at);
    final wpLarge = WallpaperPacks.asset(pack, 'large', at);

    // Structured data for the NATIVE self-updating Android widget: every day's
    // precomputed timeline. The native widget computes the *current* period from
    // this + the system clock, so it stays live in the background without the
    // Flutter engine (which can only render while the app is foregrounded).
    final timelines = <String, dynamic>{};
    for (var d = 1; d <= 6; d++) {
      final tl = TimetableBuilder.buildDay(
        timetable.periodsOn(d),
        timetable.subjectsById,
        timetable.config,
      );
      timelines['$d'] = [
        for (final e in tl)
          {
            's': e.startMin,
            'e': e.endMin,
            't': e.title,
            'c': e.color,
            'k': e.kind.name,
            'room': e.room ?? '',
            'teacher': e.teacher ?? '',
          }
      ];
    }
    await HomeWidget.saveWidgetData<String>(
        'tt_timelines', jsonEncode(timelines));

    // Theme tokens for the NATIVE Android widget. It applies these at runtime on
    // its 60s self-update tick, so the recolor survives with the app closed. The
    // ramp name must match a branch in both Wx.progressColor (Dart) and
    // WidgetRenderer.progressColor (Kotlin).
    await HomeWidget.saveWidgetData<String>('theme_bg_top', _hex(tm.background.top));
    await HomeWidget.saveWidgetData<String>(
        'theme_bg_bottom', _hex(tm.background.bottom));
    await HomeWidget.saveWidgetData<String>(
        'theme_bg_angle', tm.background.gradientAngle.toInt().toString());
    await HomeWidget.saveWidgetData<String>('theme_text_primary', _hex(tm.onBg));
    await HomeWidget.saveWidgetData<String>(
        'theme_text_secondary', _hex(tm.onBg.withValues(alpha: 0.72)));
    await HomeWidget.saveWidgetData<String>('theme_accent', _hex(tm.accent));
    await HomeWidget.saveWidgetData<String>('theme_primary', _hex(tm.primary));
    await HomeWidget.saveWidgetData<String>('theme_secondary', _hex(tm.secondary));
    await HomeWidget.saveWidgetData<String>('theme_hairline', _hex(tm.glass.hairline));
    await HomeWidget.saveWidgetData<String>(
        'theme_radius', tm.borderRadius.toStringAsFixed(0));
    await HomeWidget.saveWidgetData<String>('theme_progress_ramp', tm.progressRamp.name);
    // Native Android wallpaper selection: folder + count (Kotlin picks the same
    // rotating index and loads the bundled asset PNG behind the widget).
    await HomeWidget.saveWidgetData<String>('theme_asset_pack', tm.assetPack);
    await HomeWidget.saveWidgetData<String>(
        'theme_pack_count', WallpaperPacks.count(tm.assetPack).toString());
    await HomeWidget.saveWidgetData<String>(
        'theme_label_current', tm.labels.currentClass);
    await HomeWidget.saveWidgetData<String>('theme_label_upnext', tm.labels.upNext);
    await HomeWidget.saveWidgetData<String>('theme_label_break', tm.labels.onBreak);

    try {
      await HomeWidget.renderFlutterWidget(
        _wrap(TimetableWidgetSmall(
          status: status,
          weekday: weekdayShort,
          date: date,
          size: 170,
          elevated: false,
          backgroundImage: wpSmall,
        )),
        key: _smallKey,
        logicalSize: const Size(170, 170),
      );
      await HomeWidget.renderFlutterWidget(
        _wrap(TimetableWidgetMedium(
          status: status,
          weekday: _short[(weekday - 1) % 7],
          date: date,
          width: 360,
          height: 170,
          elevated: false,
          backgroundImage: wpMedium,
        )),
        key: _mediumKey,
        logicalSize: const Size(360, 170),
      );
      await HomeWidget.renderFlutterWidget(
        _wrap(TimetableWidgetLarge(
          status: status,
          weekday: weekdayFull,
          date: date,
          width: 360,
          height: 376,
          elevated: false,
          dense: true,
          backgroundImage: wpLarge,
        )),
        key: _largeKey,
        logicalSize: const Size(360, 376),
      );

      await HomeWidget.saveWidgetData<String>('tt_day', weekdayFull);
      await HomeWidget.saveWidgetData<String>('tt_status', status.statusLine);

      // Feature 4 — next-day preview + motivational note for the widget.
      final isNextDay = status.dayOver || status.empty;
      var nextDayLabel = '';
      var nextDayPreview = '';
      if (isNextDay) {
        for (var off = 1; off <= 7; off++) {
          final d =
              DateTime(at.year, at.month, at.day).add(Duration(days: off));
          final wd = d.weekday;
          if (wd < 1 || wd > 6) continue;
          final tl = TimetableBuilder.buildDay(
            timetable.periodsOn(wd),
            timetable.subjectsById,
            timetable.config,
          );
          if (tl.isEmpty) continue;
          final dl = '${_short[(wd - 1) % 7]}, ${d.day} ${_months[d.month - 1]}';
          nextDayLabel = off == 1 ? 'Tomorrow — $dl' : 'Next — $dl';
          final parts = <String>[];
          var p = 0;
          for (final e in tl) {
            if (e.isBreak) {
              parts.add(e.kind == EntryKind.lunch ? 'Lunch' : 'Tea');
            } else {
              p++;
              parts.add('P$p ${e.title}');
            }
          }
          nextDayPreview = parts.join(' · ');
          break;
        }
      }
      await HomeWidget.saveWidgetData<bool>('is_next_day_mode', isNextDay);
      await HomeWidget.saveWidgetData<String>('next_day_label', nextDayLabel);
      await HomeWidget.saveWidgetData<String>('next_day_preview', nextDayPreview);
      await HomeWidget.saveWidgetData<String>(
          'motivational_note', NotesEngine.pick(now: at, timetable: timetable));
      await HomeWidget.saveWidgetData<String>('attendance_warning', '');

      // Refresh each Android size widget + the iOS widget.
      for (final name in _androidProviders) {
        await HomeWidget.updateWidget(qualifiedAndroidName: name);
      }
      await HomeWidget.updateWidget(iOSName: iOSWidgetKind);
    } catch (_) {
      // Rendering needs an attached engine view; foreground refreshes keep the
      // widget current.
    }
  }

  static Widget _wrap(Widget child) => MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(textDirection: TextDirection.ltr, child: child),
      );
}
