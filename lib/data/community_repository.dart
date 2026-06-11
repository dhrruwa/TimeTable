import 'package:isar/isar.dart';

import '../models/period_models.dart';
import 'isar_entities.dart';

/// A community timetable plus how many students use it.
class CommunityEntry {
  final Timetable timetable;
  final int userCount;
  const CommunityEntry({required this.timetable, required this.userCount});
  TimetableMeta get meta => timetable.meta;
}

/// Centralized community timetable store. This contract is what a real free
/// backend (Firebase/Supabase free tier) would implement; the local mock below
/// provides the same behaviour on-device so the whole UX works for free now.
///
/// Lookups are by [TimetableMeta.matchKey] (university|branch|semester|section)
/// — the same indexed shape that scales to thousands of colleges on a server.
abstract class CommunityRepository {
  /// Exact match for a class (university/branch/semester/section).
  Future<CommunityEntry?> findMatch(TimetableMeta meta);

  /// Fuzzy search, e.g. for browsing a university's timetables.
  Future<List<CommunityEntry>> search({
    String? university,
    String? branch,
    String? semester,
    String? section,
  });

  /// Publish (create/update) a timetable to the community DB. Returns the entry.
  Future<CommunityEntry> publish(Timetable timetable);

  /// Join an existing community timetable — increments its user count.
  Future<CommunityEntry?> join(String matchKey);

  /// Send a change suggestion / incorrect report to the timetable's owner.
  Future<void> suggestChange(String matchKey, String note);
  Future<void> report(String matchKey, String reason);
}

class IsarCommunityRepository implements CommunityRepository {
  final Isar isar;
  IsarCommunityRepository(this.isar);

  CommunityEntry _toEntry(CommunityTimetableEntity e) => CommunityEntry(
        timetable: Timetable.fromJsonString(e.json),
        userCount: e.userCount,
      );

  @override
  Future<CommunityEntry?> findMatch(TimetableMeta meta) async {
    if (!meta.isComplete) return null;
    final e = await isar.communityTimetableEntitys
        .filter()
        .matchKeyEqualTo(meta.matchKey)
        .findFirst();
    return e == null ? null : _toEntry(e);
  }

  @override
  Future<List<CommunityEntry>> search({
    String? university,
    String? branch,
    String? semester,
    String? section,
  }) async {
    // Mock scale is small — load and filter in Dart (a server would index these).
    final all = await isar.communityTimetableEntitys.where().findAll();
    bool match(String? q, String v) =>
        q == null || q.isEmpty || v.toLowerCase().contains(q.toLowerCase());
    final filtered = all.where((e) =>
        match(university, e.university) &&
        match(branch, e.branch) &&
        match(semester, e.semester) &&
        match(section, e.section));
    final list = filtered.map(_toEntry).toList();
    list.sort((a, b) => b.userCount.compareTo(a.userCount));
    return list;
  }

  @override
  Future<CommunityEntry> publish(Timetable timetable) async {
    final key = timetable.meta.matchKey;
    late CommunityTimetableEntity entity;
    await isar.writeTxn(() async {
      final existing = await isar.communityTimetableEntitys
          .filter()
          .matchKeyEqualTo(key)
          .findFirst();
      entity = existing ?? CommunityTimetableEntity()
        ..matchKey = key
        ..university = timetable.meta.university
        ..branch = timetable.meta.branch
        ..semester = timetable.meta.semester
        ..section = timetable.meta.section
        ..creatorName = timetable.meta.creatorName
        ..creatorId = timetable.meta.creatorId
        ..verified = timetable.meta.verified
        ..updatedAtMs = timetable.meta.updatedAtMs
        ..json = timetable.toJsonString();
      // Keep existing user count; new entries start at 1 (the creator).
      entity.userCount = existing?.userCount ?? 1;
      await isar.communityTimetableEntitys.put(entity);
    });
    return _toEntry(entity);
  }

  @override
  Future<CommunityEntry?> join(String matchKey) async {
    CommunityTimetableEntity? entity;
    await isar.writeTxn(() async {
      entity = await isar.communityTimetableEntitys
          .filter()
          .matchKeyEqualTo(matchKey)
          .findFirst();
      if (entity != null) {
        entity!.userCount += 1;
        await isar.communityTimetableEntitys.put(entity!);
      }
    });
    return entity == null ? null : _toEntry(entity!);
  }

  @override
  Future<void> suggestChange(String matchKey, String note) async {
    // Mock: a real backend would queue this for the owner. No-op locally.
  }

  @override
  Future<void> report(String matchKey, String reason) async {
    // Mock: a real backend would flag this for moderation. No-op locally.
  }
}
