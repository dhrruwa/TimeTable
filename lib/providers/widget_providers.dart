import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/period_repository.dart';
import '../data/sample_week.dart';
import '../logic/timetable_builder.dart';
import '../models/period_models.dart';

const _uuid = Uuid();

/// Bound in `main()` via overrides once Isar is open + the timetable is loaded.
final periodRepositoryProvider = Provider<PeriodRepository>(
  (ref) =>
      throw UnimplementedError('periodRepositoryProvider must be overridden'),
);
final initialTimetableProvider = Provider<Timetable>(
  (ref) =>
      throw UnimplementedError('initialTimetableProvider must be overridden'),
);

/// The single source of truth. Every mutation updates state AND persists.
final timetableProvider =
    StateNotifierProvider<TimetableNotifier, Timetable>((ref) {
  return TimetableNotifier(
    ref.watch(periodRepositoryProvider),
    ref.watch(initialTimetableProvider),
  );
});

/// The concrete, timed timeline (classes + breaks) for a weekday (1..6).
final timelineForDayProvider =
    Provider.family<List<TimelineEntry>, int>((ref, weekday) {
  final t = ref.watch(timetableProvider);
  return TimetableBuilder.buildDay(
      t.periodsOn(weekday), t.subjectsById, t.config);
});

class TimetableNotifier extends StateNotifier<Timetable> {
  final PeriodRepository _repo;
  TimetableNotifier(this._repo, Timetable initial) : super(initial);

  String newId() => _uuid.v4();

  Future<void> _commit(Timetable next) async {
    state = next;
    await _repo.save(next);
  }

  // ---- Subjects ----------------------------------------------------------

  /// Next palette color not already used by a subject.
  int nextSubjectColor() {
    final used = state.subjects.map((s) => s.color).toSet();
    for (final c in kSubjectPalette) {
      if (!used.contains(c)) return c;
    }
    return kSubjectPalette[state.subjects.length % kSubjectPalette.length];
  }

  Future<void> upsertSubject(Subject subject) {
    final subjects = [...state.subjects];
    final i = subjects.indexWhere((s) => s.id == subject.id);
    if (i >= 0) {
      subjects[i] = subject;
    } else {
      subjects.add(subject);
    }
    return _commit(state.copyWith(subjects: subjects));
  }

  /// Deletes a subject and every period that used it.
  Future<void> deleteSubject(String subjectId) {
    final week = {
      for (final entry in state.week.entries)
        entry.key: entry.value.where((p) => p.subjectId != subjectId).toList(),
    };
    return _commit(state.copyWith(
      subjects: state.subjects.where((s) => s.id != subjectId).toList(),
      week: week,
    ));
  }

  int subjectUsageCount(String subjectId) {
    var n = 0;
    for (final periods in state.week.values) {
      n += periods.where((p) => p.subjectId == subjectId).length;
    }
    return n;
  }

  // ---- Periods -----------------------------------------------------------

  Future<void> addPeriod(int weekday, Period period) {
    final week = _mutableWeek();
    (week[weekday] ??= []).add(period);
    return _commit(state.copyWith(week: week));
  }

  Future<void> updatePeriod(int weekday, Period period) {
    final week = _mutableWeek();
    final list = week[weekday] ?? [];
    final i = list.indexWhere((p) => p.id == period.id);
    if (i >= 0) list[i] = period;
    week[weekday] = list;
    return _commit(state.copyWith(week: week));
  }

  Future<void> deletePeriod(int weekday, String periodId) {
    final week = _mutableWeek();
    week[weekday] =
        (week[weekday] ?? []).where((p) => p.id != periodId).toList();
    return _commit(state.copyWith(week: week));
  }

  Future<void> setDayPeriods(int weekday, List<Period> periods) {
    final week = _mutableWeek();
    week[weekday] = periods;
    return _commit(state.copyWith(week: week));
  }

  Map<int, List<Period>> _mutableWeek() => {
        for (final e in state.week.entries) e.key: [...e.value],
      };

  // ---- Config ------------------------------------------------------------

  Future<void> setConfig(TimetableConfig config) =>
      _commit(state.copyWith(config: config));
}
