import 'package:uuid/uuid.dart';

import '../data/sample_week.dart';
import '../models/period_models.dart';

/// Maps the JSON returned by the Gemini extraction Edge Function into this app's
/// model.
///
/// Important: this app does NOT store per-period clock times — times are derived
/// by [TimetableBuilder] from the global [TimetableConfig]. So the extracted
/// `time_slots` (and per-slot start/end) are intentionally discarded; we keep
/// only the ORDER of classes per day. Breaks are injected by the builder, so
/// `break`/`free` slots are dropped, and a multi-slot lab is collapsed into the
/// single lab block this app models.
///
/// The output is an editable [DraftTimetable] that the review screen mutates
/// before [DraftTimetable.toTimetable] builds the final, deduped+colored model.

const _uuid = Uuid();

/// One editable row in the review screen. Subject is a free-text name here;
/// [DraftTimetable.toTimetable] later dedupes names into [Subject]s + colors.
class DraftPeriod {
  String subject; // may be empty -> shown as "Unknown" / needs editing
  String? teacher;
  String? room;
  bool isLab;

  DraftPeriod({
    required this.subject,
    this.teacher,
    this.room,
    this.isLab = false,
  });
}

/// The full editable import, keyed by weekday (1=Mon .. 6=Sat).
class DraftTimetable {
  String university;
  String branch;
  String semester;
  String section;
  final Map<int, List<DraftPeriod>> week;

  DraftTimetable({
    this.university = '',
    this.branch = '',
    this.semester = '',
    this.section = '',
    Map<int, List<DraftPeriod>>? week,
  }) : week = week ?? {};

  /// Total class rows across the week — used by the UI to detect an empty parse.
  int get periodCount =>
      week.values.fold(0, (sum, list) => sum + list.length);

  /// Builds the final [Timetable]: dedupes subject names (case-insensitive),
  /// assigns palette colors, and turns each [DraftPeriod] into a [Period].
  Timetable toTimetable({required int nowMs}) {
    final subjects = <Subject>[];
    final byName = <String, String>{}; // normalized name -> subjectId

    String subjectIdFor(String rawName) {
      final name = rawName.trim().isEmpty ? 'Unknown' : rawName.trim();
      final key = name.toLowerCase();
      final existing = byName[key];
      if (existing != null) return existing;
      final id = _uuid.v4();
      final color = kSubjectPalette[subjects.length % kSubjectPalette.length];
      subjects.add(Subject(id: id, name: name, color: color));
      byName[key] = id;
      return id;
    }

    final builtWeek = <int, List<Period>>{};
    for (final entry in week.entries) {
      final periods = <Period>[];
      for (final d in entry.value) {
        periods.add(Period(
          id: _uuid.v4(),
          subjectId: subjectIdFor(d.subject),
          room: _clean(d.room),
          teacher: _clean(d.teacher),
          isLab: d.isLab,
        ));
      }
      if (periods.isNotEmpty) builtWeek[entry.key] = periods;
    }

    return Timetable(
      subjects: subjects,
      week: builtWeek,
      config: const TimetableConfig(),
      meta: TimetableMeta(
        university: university.trim(),
        branch: branch.trim(),
        semester: semester.trim(),
        section: section.trim(),
        updatedAtMs: nowMs,
      ),
    );
  }
}

/// Parses the Edge Function's JSON map into a [DraftTimetable].
///
/// Tolerant by design: unknown days are skipped, malformed rows are ignored,
/// and the model's quirks (multi-slot labs, break/free filler) are normalized.
DraftTimetable mapGeminiJson(Map<String, dynamic> j) {
  final draft = DraftTimetable(
    university: _str(j['institution']),
    branch: _str(j['department']),
    semester: _str(j['semester']),
    section: _str(j['section']),
  );

  final schedule = j['schedule'];
  if (schedule is! Map) return draft;

  schedule.forEach((dayName, slots) {
    final weekday = _weekdayFromName(dayName.toString());
    if (weekday == null || slots is! List) return;

    // Order by slot_index so the day reads top-to-bottom as on the timetable.
    final rows = slots.whereType<Map>().toList()
      ..sort((a, b) => _int(a['slot_index']).compareTo(_int(b['slot_index'])));

    final drafts = <DraftPeriod>[];
    for (final row in rows) {
      final type = _str(row['type']).toLowerCase();
      // Breaks are injected by TimetableConfig; free = no class. Drop both.
      if (type == 'break' || type == 'free') continue;

      final subject = _str(row['subject']);
      final isLab = type == 'lab';
      final teacher = _str(row['faculty']);
      final room = _str(row['room']);

      // Collapse a multi-slot lab: Gemini repeats the same lab across the slots
      // it covers, but this app models a lab as ONE block. Merge consecutive
      // labs of the same subject into the previous row.
      final prev = drafts.isNotEmpty ? drafts.last : null;
      if (isLab &&
          prev != null &&
          prev.isLab &&
          _sameSubject(prev.subject, subject)) {
        continue;
      }

      drafts.add(DraftPeriod(
        subject: subject,
        teacher: teacher.isEmpty ? null : teacher,
        room: room.isEmpty ? null : room,
        isLab: isLab,
      ));
    }

    if (drafts.isNotEmpty) draft.week[weekday] = drafts;
  });

  return draft;
}

bool _sameSubject(String a, String b) =>
    a.trim().toLowerCase() == b.trim().toLowerCase();

String? _clean(String? s) {
  if (s == null) return null;
  final t = s.trim();
  return t.isEmpty ? null : t;
}

String _str(dynamic v) => v == null ? '' : v.toString().trim();

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? 1 << 30; // unknown -> sort last
}

/// Maps a day name (full or abbreviated, any case) to 1=Mon .. 6=Sat.
/// Sunday is not modeled by this app's week grid, so it returns null.
int? _weekdayFromName(String raw) {
  final s = raw.trim().toLowerCase();
  if (s.startsWith('mon')) return 1;
  if (s.startsWith('tue')) return 2;
  if (s.startsWith('wed')) return 3;
  if (s.startsWith('thu')) return 4;
  if (s.startsWith('fri')) return 5;
  if (s.startsWith('sat')) return 6;
  return null; // sun / unknown
}
