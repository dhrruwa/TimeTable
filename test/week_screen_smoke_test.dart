import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/data/app_prefs_repository.dart';
import 'package:timetable/data/period_repository.dart';
import 'package:timetable/data/sample_week.dart';
import 'package:timetable/models/period_models.dart';
import 'package:timetable/providers/community_providers.dart';
import 'package:timetable/providers/widget_providers.dart';
import 'package:timetable/screens/week_screen.dart';

class _FakePeriodRepo implements PeriodRepository {
  @override
  Future<Timetable?> load() async => null;
  @override
  Future<void> save(Timetable timetable) async {}
}

class _FakePrefsRepo implements AppPrefsRepository {
  @override
  Future<AppPrefs?> load() async => null;
  @override
  Future<void> save(AppPrefs prefs) async {}
}

void main() {
  testWidgets('WeekScreen lays out without infinite-constraint errors',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          periodRepositoryProvider.overrideWithValue(_FakePeriodRepo()),
          initialTimetableProvider.overrideWithValue(buildSampleTimetable()),
          appPrefsRepositoryProvider.overrideWithValue(_FakePrefsRepo()),
          initialAppPrefsProvider.overrideWithValue(
              const AppPrefs(deviceId: 'test-device', onboarded: true)),
        ],
        child: const MaterialApp(home: WeekScreen()),
      ),
    );
    await tester.pump();

    // This is the regression guard: the old InteractiveViewer(constrained:false)
    // + stretched, unbounded Row threw "BoxConstraints forces an infinite size".
    expect(tester.takeException(), isNull);

    // The grid actually rendered some classes.
    expect(find.text('Physics'), findsWidgets);
  });
}
