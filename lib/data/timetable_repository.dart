import '../models/timetable_models.dart';

/// Storage-agnostic contract for loading and mutating the timetable.
///
/// Phase 1 ships an Isar implementation. Phase 2 (cloud sharing) can provide an
/// alternative implementation behind this same interface without touching the
/// providers or UI.
abstract class TimetableRepository {
  /// Load the full timetable from storage.
  Future<Timetable> load();

  /// Insert or update a course (matched by [Course.id]).
  Future<void> upsertCourse(Course course);

  /// Delete a course AND all of its slots.
  Future<void> deleteCourse(String courseId);

  /// Insert or update a slot (matched by [ClassSlot.id]).
  Future<void> upsertSlot(ClassSlot slot);

  /// Delete a single slot.
  Future<void> deleteSlot(String slotId);

  /// Replace the entire stored timetable (used for seeding / bulk import).
  Future<void> replaceAll(Timetable timetable);
}
