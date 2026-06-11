import 'package:isar/isar.dart';

import '../models/period_models.dart';
import 'isar_entities.dart';
import 'sample_week.dart';

/// Seeds a few community timetables on first launch so discovery + search have
/// something to find (a real backend would already be populated by other users).
Future<void> seedCommunityIfEmpty(Isar isar) async {
  final existing = await isar.communityTimetableEntitys.count();
  if (existing > 0) return;

  final nowMs = DateTime.now().millisecondsSinceEpoch;
  const day = 86400000;

  final samples = <(_Meta, int)>[
    (
      _Meta('REVA University', 'CSE', '4', 'A', 'Aditya', true, nowMs - 2 * day),
      43
    ),
    (
      _Meta('REVA University', 'CSE', '4', 'B', 'Sneha', false, nowMs - 5 * day),
      31
    ),
    (
      _Meta('REVA University', 'ECE', '4', 'A', 'Rahul', false, nowMs - 9 * day),
      27
    ),
    (
      _Meta('VTU', 'ISE', '6', 'A', 'Megha', true, nowMs - 1 * day),
      54
    ),
  ];

  await isar.writeTxn(() async {
    for (final (m, users) in samples) {
      final meta = TimetableMeta(
        university: m.university,
        branch: m.branch,
        semester: m.semester,
        section: m.section,
        creatorName: m.creator,
        creatorId: 'seed-${m.matchKey}',
        verified: m.verified,
        updatedAtMs: m.updatedAtMs,
      );
      final timetable = buildSampleTimetable().copyWith(meta: meta);
      await isar.communityTimetableEntitys.put(
        CommunityTimetableEntity()
          ..matchKey = meta.matchKey
          ..university = meta.university
          ..branch = meta.branch
          ..semester = meta.semester
          ..section = meta.section
          ..creatorName = meta.creatorName
          ..creatorId = meta.creatorId
          ..verified = meta.verified
          ..updatedAtMs = meta.updatedAtMs
          ..userCount = users
          ..json = timetable.toJsonString(),
      );
    }
  });
}

class _Meta {
  final String university, branch, semester, section, creator;
  final bool verified;
  final int updatedAtMs;
  const _Meta(this.university, this.branch, this.semester, this.section,
      this.creator, this.verified, this.updatedAtMs);
  String get matchKey =>
      '${university.toLowerCase()}|${branch.toLowerCase()}|$semester|${section.toLowerCase()}';
}
