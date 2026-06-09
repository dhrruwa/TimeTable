import 'package:isar/isar.dart';

import '../models/timetable_models.dart';
import 'isar_entities.dart';
import 'timetable_repository.dart';

/// Isar-backed implementation of [TimetableRepository].
class IsarTimetableRepository implements TimetableRepository {
  final Isar isar;

  IsarTimetableRepository(this.isar);

  /// Opens (or reuses) the Isar instance with this app's schemas.
  static Future<Isar> open({required String directory}) async {
    final existing = Isar.getInstance();
    if (existing != null) return existing;
    return Isar.open(
      [CourseEntitySchema, ClassSlotEntitySchema],
      directory: directory,
    );
  }

  @override
  Future<Timetable> load() async {
    final courseEntities = await isar.courseEntitys.where().findAll();
    final slotEntities = await isar.classSlotEntitys.where().findAll();
    return Timetable(
      courses: courseEntities.map((e) => e.toModel()).toList(),
      slots: slotEntities.map((e) => e.toModel()).toList(),
    );
  }

  @override
  Future<void> upsertCourse(Course course) async {
    await isar.writeTxn(() async {
      await isar.courseEntitys.put(CourseEntity.fromModel(course));
    });
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await isar.writeTxn(() async {
      await isar.courseEntitys.deleteByUid(courseId);
      // Cascade: remove the course's slots too.
      final orphans =
          await isar.classSlotEntitys.filter().courseIdEqualTo(courseId).findAll();
      await isar.classSlotEntitys
          .deleteAll(orphans.map((e) => e.isarId).toList());
    });
  }

  @override
  Future<void> upsertSlot(ClassSlot slot) async {
    await isar.writeTxn(() async {
      await isar.classSlotEntitys.put(ClassSlotEntity.fromModel(slot));
    });
  }

  @override
  Future<void> deleteSlot(String slotId) async {
    await isar.writeTxn(() async {
      await isar.classSlotEntitys.deleteByUid(slotId);
    });
  }

  @override
  Future<void> replaceAll(Timetable timetable) async {
    await isar.writeTxn(() async {
      await isar.courseEntitys.clear();
      await isar.classSlotEntitys.clear();
      await isar.courseEntitys
          .putAll(timetable.courses.map(CourseEntity.fromModel).toList());
      await isar.classSlotEntitys
          .putAll(timetable.slots.map(ClassSlotEntity.fromModel).toList());
    });
  }
}
