import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/timetable_repository.dart';
import '../logic/schedule_service.dart';
import '../models/timetable_models.dart';

const _uuid = Uuid();

/// Bound in `main()` via a ProviderScope override once Isar is open.
final repositoryProvider = Provider<TimetableRepository>(
  (ref) => throw UnimplementedError('repositoryProvider must be overridden'),
);

/// Bound in `main()` via override with the timetable loaded from storage, so
/// the UI starts fully populated with no async/loading flicker.
final initialTimetableProvider = Provider<Timetable>(
  (ref) => throw UnimplementedError('initialTimetableProvider must be overridden'),
);

/// Holds the live timetable and persists every mutation through the repository.
final timetableProvider =
    StateNotifierProvider<TimetableNotifier, Timetable>((ref) {
  return TimetableNotifier(
    ref.watch(repositoryProvider),
    ref.watch(initialTimetableProvider),
  );
});

/// Rebuilds [ScheduleService] whenever the timetable changes. This is the only
/// place the UI gets schedule answers from.
final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  final timetable = ref.watch(timetableProvider);
  return ScheduleService(timetable);
});

/// Ticks once a minute (and immediately on subscribe) so "now / next" UI stays
/// current without the user refreshing.
final clockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(
    const Duration(minutes: 1),
    (_) => DateTime.now(),
  );
});

/// Convenience: the current wall-clock time, defaulting to now before the first
/// tick arrives.
final nowProvider = Provider<DateTime>((ref) {
  return ref.watch(clockProvider).value ?? DateTime.now();
});

/// App theme mode. Defaults to following the system; toggled from the UI.
final themeModeProvider =
    StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Whether the weekly grid includes Sunday (off by default per spec).
final showSundayProvider = StateProvider<bool>((ref) => false);

/// Mutates the timetable and writes through to persistence. State is updated
/// optimistically so the UI is instant; the repository call follows.
class TimetableNotifier extends StateNotifier<Timetable> {
  final TimetableRepository _repo;

  TimetableNotifier(this._repo, Timetable initial) : super(initial);

  String newId() => _uuid.v4();

  Future<void> upsertCourse(Course course) async {
    final courses = [...state.courses];
    final i = courses.indexWhere((c) => c.id == course.id);
    if (i >= 0) {
      courses[i] = course;
    } else {
      courses.add(course);
    }
    state = state.copyWith(courses: courses);
    await _repo.upsertCourse(course);
  }

  /// Deletes a course and all slots referencing it.
  Future<void> deleteCourse(String courseId) async {
    state = state.copyWith(
      courses: state.courses.where((c) => c.id != courseId).toList(),
      slots: state.slots.where((s) => s.courseId != courseId).toList(),
    );
    await _repo.deleteCourse(courseId);
  }

  Future<void> upsertSlot(ClassSlot slot) async {
    final slots = [...state.slots];
    final i = slots.indexWhere((s) => s.id == slot.id);
    if (i >= 0) {
      slots[i] = slot;
    } else {
      slots.add(slot);
    }
    state = state.copyWith(slots: slots);
    await _repo.upsertSlot(slot);
  }

  Future<void> deleteSlot(String slotId) async {
    state = state.copyWith(
      slots: state.slots.where((s) => s.id != slotId).toList(),
    );
    await _repo.deleteSlot(slotId);
  }

  /// Number of slots that reference [courseId] — used to confirm deletes.
  int slotCountForCourse(String courseId) =>
      state.slots.where((s) => s.courseId == courseId).length;
}
