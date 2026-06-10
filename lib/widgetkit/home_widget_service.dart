import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';

import '../logic/timetable_builder.dart';
import '../logic/today_engine.dart';
import '../models/period_models.dart';
import '../widgets/weather/timetable_widget_large.dart';
import '../widgets/weather/timetable_widget_medium.dart';
import '../widgets/weather/timetable_widget_small.dart';

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

  /// Renders all three sizes for [timetable] at the current moment and refreshes
  /// the home-screen widgets.
  static Future<void> refresh(Timetable timetable, {DateTime? now}) async {
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

    try {
      await HomeWidget.renderFlutterWidget(
        _wrap(TimetableWidgetSmall(
          status: status,
          weekday: weekdayShort,
          date: date,
          size: 170,
          elevated: false,
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
        )),
        key: _largeKey,
        logicalSize: const Size(360, 376),
      );

      await HomeWidget.saveWidgetData<String>('tt_day', weekdayFull);
      await HomeWidget.saveWidgetData<String>('tt_status', status.statusLine);

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
