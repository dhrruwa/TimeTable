import 'package:isar/isar.dart';

import '../models/period_models.dart';
import 'isar_entities.dart';

/// Storage-agnostic contract for the unified timetable. Phase 2 (cloud) can
/// provide an alternative implementation behind this interface.
abstract class PeriodRepository {
  Future<Timetable?> load();
  Future<void> save(Timetable timetable);
}

/// Isar-backed implementation: stores the timetable as one JSON document.
class IsarPeriodRepository implements PeriodRepository {
  final Isar isar;
  IsarPeriodRepository(this.isar);

  static Future<Isar> open({required String directory}) async {
    final existing = Isar.getInstance();
    if (existing != null) return existing;
    return Isar.open([TimetableDocEntitySchema], directory: directory);
  }

  @override
  Future<Timetable?> load() async {
    final doc = await isar.timetableDocEntitys.get(0);
    if (doc == null) return null;
    return Timetable.fromJsonString(doc.json);
  }

  @override
  Future<void> save(Timetable timetable) async {
    await isar.writeTxn(() async {
      await isar.timetableDocEntitys.put(
        TimetableDocEntity.of(timetable.toJsonString())..id = 0,
      );
    });
  }
}
