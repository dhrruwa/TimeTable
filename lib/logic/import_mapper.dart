import 'package:uuid/uuid.dart';

import '../data/sample_week.dart';
import '../models/period_models.dart';

/// Maps the JSON returned by the Gemini extraction Edge Function into this app's
/// model.
///
/// This app derives every period's clock time from a global [TimetableConfig]
/// (day start, period length, break positions). To make an imported timetable
/// show the REAL times, this mapper reads the extracted `time_slots` and derives
/// a matching config — day start, period length, and up to two breaks (tea +
/// lunch) with their durations. It assumes a uniform period length across the
/// day (true for the large majority of college timetables); if the slots can't
/// be read, it falls back to the app default and keeps periods in order.
///
/// The output is an editable [DraftTimetable] that the review screen mutates
/// before [DraftTimetable.toTimetable] builds the final, deduped+colored model.

const _uuid = Uuid();

/// Neutral colour for "Free" placeholder periods (matches the break colour).
const int _freeColor = 0xFF7C828C;

/// One editable row in the review screen. Subject is a free-text name here;
/// [DraftTimetable.toTimetable] later dedupes names into [Subject]s + colors.
class DraftPeriod {
  String subject; // may be empty -> shown as "Unknown" / needs editing
  String? teacher;
  String? room;
  bool isLab;
  bool isFree; // an empty slot kept to preserve later periods' real times

  DraftPeriod({
    required this.subject,
    this.teacher,
    this.room,
    this.isLab = false,
    this.isFree = false,
  });
}

/// The full editable import, keyed by weekday (1=Mon .. 6=Sat).
class DraftTimetable {
  String university;
  String branch;
  String semester;
  String section;
  final Map<int, List<DraftPeriod>> week;

  /// Schedule timings derived from the source image (day start, period length,
  /// breaks). Defaults to the app default when they couldn't be read.
  TimetableConfig config;

  DraftTimetable({
    this.university = '',
    this.branch = '',
    this.semester = '',
    this.section = '',
    Map<int, List<DraftPeriod>>? week,
    this.config = const TimetableConfig(),
  }) : week = week ?? {};

  /// Total class rows across the week — used by the UI to detect an empty parse.
  int get periodCount =>
      week.values.fold(0, (sum, list) => sum + list.length);

  /// Builds the final [Timetable]: dedupes subject names (case-insensitive),
  /// assigns palette colors, and turns each [DraftPeriod] into a [Period]. Free
  /// placeholders share one neutral "Free" subject.
  Timetable toTimetable({required int nowMs}) {
    final subjects = <Subject>[];
    final byName = <String, String>{}; // normalized name -> subjectId
    String? freeSubjectId;

    String subjectIdForFree() {
      if (freeSubjectId != null) return freeSubjectId!;
      final id = _uuid.v4();
      subjects.add(Subject(id: id, name: 'Free', color: _freeColor));
      freeSubjectId = id;
      return id;
    }

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
          subjectId: d.isFree ? subjectIdForFree() : subjectIdFor(d.subject),
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
      config: config,
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

// ─── Parsing ──────────────────────────────────────────────────────────────────

class _Slot {
  final int index;
  final int start; // minutes since midnight
  final int end;
  bool isBreak = false;
  _Slot(this.index, this.start, this.end);
  int get dur => end - start;
}

/// Parses the Edge Function's JSON map into a [DraftTimetable], deriving the
/// real schedule timings from `time_slots` when possible.
DraftTimetable mapGeminiJson(Map<String, dynamic> j) {
  final draft = DraftTimetable(
    university: _str(j['institution']),
    branch: _str(j['department']),
    semester: _str(j['semester']),
    section: _str(j['section']),
  );

  final schedule = j['schedule'];
  if (schedule is! Map) return draft;

  // ---- 1. Parse the time grid (slot_index -> start/end) -------------------
  final slotsByIndex = <int, _Slot>{};
  final rawSlots = j['time_slots'];
  if (rawSlots is List) {
    for (final s in rawSlots.whereType<Map>()) {
      final idx = _intOrNull(s['index']);
      final start = _hhmmToMin(_str(s['start']));
      final end = _hhmmToMin(_str(s['end']));
      if (idx != null && start != null && end != null && end > start) {
        slotsByIndex[idx] = _Slot(idx, start, end);
      }
    }
  }

  // ---- 2. Mark which slots are breaks (by the dominant entry type) --------
  final breakVotes = <int, int>{}; // slot_index -> #break entries
  final classVotes = <int, int>{};
  schedule.forEach((_, slots) {
    if (slots is! List) return;
    for (final row in slots.whereType<Map>()) {
      final idx = _intOrNull(row['slot_index']);
      if (idx == null) return;
      final type = _str(row['type']).toLowerCase();
      if (type == 'break') {
        breakVotes[idx] = (breakVotes[idx] ?? 0) + 1;
      } else if (type == 'lecture' || type == 'lab') {
        classVotes[idx] = (classVotes[idx] ?? 0) + 1;
      }
    }
  });
  for (final slot in slotsByIndex.values) {
    final b = breakVotes[slot.index] ?? 0;
    final c = classVotes[slot.index] ?? 0;
    if (b > 0 && b >= c) slot.isBreak = true;
  }

  // ---- 3. Derive the config from the time grid ----------------------------
  final derived = _deriveConfig(slotsByIndex.values.toList());
  if (derived != null) {
    draft.config = derived.config;
    _buildWithSlots(draft, schedule, slotsByIndex, derived.classPosByIndex);
  } else {
    // No usable time grid: keep the app default config and order by slot index.
    _buildSequential(draft, schedule);
  }

  return draft;
}

class _Derived {
  final TimetableConfig config;
  final Map<int, int> classPosByIndex; // slot_index -> 1-based class position
  _Derived(this.config, this.classPosByIndex);
}

/// Derives day start, period length and up to two breaks from the time grid.
/// Returns null if there aren't at least two readable class slots.
_Derived? _deriveConfig(List<_Slot> slots) {
  final ordered = [...slots]..sort((a, b) => a.start.compareTo(b.start));
  final classSlots = ordered.where((s) => !s.isBreak).toList();
  if (classSlots.length < 2) return null;

  final dayStart = classSlots.first.start;

  // Period length = median class-slot duration, rounded to nearest 5 min.
  final durs = classSlots.map((s) => s.dur).toList()..sort();
  final median = durs[durs.length ~/ 2];
  final classMins = (median / 5).round() * 5;
  if (classMins <= 0) return null;

  // 1-based class position for each class slot (in time order).
  final classPosByIndex = <int, int>{};
  for (var i = 0; i < classSlots.length; i++) {
    classPosByIndex[classSlots[i].index] = i + 1;
  }

  // Breaks: explicit break slots, plus gaps between consecutive class slots.
  final breaks = <List<int>>[]; // [afterClassCount, durationMin]
  var classCount = 0;
  int? prevEnd;
  for (final s in ordered) {
    if (s.isBreak) {
      breaks.add([classCount, s.dur]);
      prevEnd = s.end;
      continue;
    }
    if (prevEnd != null && s.start - prevEnd >= 5) {
      breaks.add([classCount, s.start - prevEnd]); // uncovered gap = break
    }
    classCount++;
    prevEnd = s.end;
  }

  // Map to the model's two break slots (tea then lunch).
  var teaAfter = 2, teaMins = 0, lunchAfter = 4, lunchMins = 0;
  if (breaks.length == 1) {
    final b = breaks.first;
    // A long single break is lunch; a short one is the tea break.
    if (b[1] >= 30) {
      lunchAfter = b[0];
      lunchMins = b[1];
      teaAfter = (b[0] - 1).clamp(1, 11);
    } else {
      teaAfter = b[0];
      teaMins = b[1];
      lunchAfter = b[0] + 1;
    }
  } else if (breaks.length >= 2) {
    // Keep the two largest breaks, ordered by position.
    final sorted = [...breaks]..sort((a, b) => b[1].compareTo(a[1]));
    final two = sorted.take(2).toList()
      ..sort((a, b) => a[0].compareTo(b[0]));
    teaAfter = two[0][0];
    teaMins = two[0][1];
    lunchAfter = two[1][0];
    lunchMins = two[1][1];
    if (lunchAfter <= teaAfter) lunchAfter = teaAfter + 1; // keep order valid
  }

  final config = TimetableConfig(
    dayStartMin: dayStart,
    classMins: classMins,
    labMins: classMins, // labs span multiple uniform slots, not one long block
    teaAfter: teaAfter.clamp(1, 12),
    teaMins: teaMins.clamp(0, 60),
    lunchAfter: lunchAfter.clamp(1, 12),
    lunchMins: lunchMins.clamp(0, 120),
  );
  return _Derived(config, classPosByIndex);
}

/// Builds each day's periods using the derived class positions, filling internal
/// gaps with "Free" placeholders so later periods keep their real times. Trailing
/// empty slots are dropped so a short day ends early.
void _buildWithSlots(
  DraftTimetable draft,
  Map schedule,
  Map<int, _Slot> slotsByIndex,
  Map<int, int> classPosByIndex,
) {
  schedule.forEach((dayName, slots) {
    final weekday = _weekdayFromName(dayName.toString());
    if (weekday == null || slots is! List) return;

    // class position -> entry for this day.
    final byPos = <int, DraftPeriod>{};
    var lastPos = 0;
    for (final row in slots.whereType<Map>()) {
      final idx = _intOrNull(row['slot_index']);
      if (idx == null) continue;
      final pos = classPosByIndex[idx];
      if (pos == null) continue; // break slot or unknown -> skip
      final type = _str(row['type']).toLowerCase();
      if (type == 'break') continue;
      final subject = _str(row['subject']);
      if (type == 'free' || subject.isEmpty) continue; // gap -> filled below
      byPos[pos] = DraftPeriod(
        subject: subject,
        teacher: _emptyToNull(_str(row['faculty'])),
        room: _emptyToNull(_str(row['room'])),
        isLab: type == 'lab',
      );
      if (pos > lastPos) lastPos = pos;
    }

    if (lastPos == 0) return; // no classes this day
    final drafts = <DraftPeriod>[];
    for (var pos = 1; pos <= lastPos; pos++) {
      drafts.add(byPos[pos] ?? DraftPeriod(subject: 'Free', isFree: true));
    }
    draft.week[weekday] = drafts;
  });
}

/// Fallback when the time grid is unreadable: order entries by slot index, drop
/// break/free, collapse multi-slot labs (since the default config models a lab
/// as one long block).
void _buildSequential(DraftTimetable draft, Map schedule) {
  schedule.forEach((dayName, slots) {
    final weekday = _weekdayFromName(dayName.toString());
    if (weekday == null || slots is! List) return;

    final rows = slots.whereType<Map>().toList()
      ..sort((a, b) => _intOr(a['slot_index'], 1 << 30)
          .compareTo(_intOr(b['slot_index'], 1 << 30)));

    final drafts = <DraftPeriod>[];
    for (final row in rows) {
      final type = _str(row['type']).toLowerCase();
      if (type == 'break' || type == 'free') continue;
      final subject = _str(row['subject']);
      final isLab = type == 'lab';
      final prev = drafts.isNotEmpty ? drafts.last : null;
      if (isLab &&
          prev != null &&
          prev.isLab &&
          prev.subject.toLowerCase() == subject.toLowerCase()) {
        continue; // collapse repeated lab slots into one block
      }
      drafts.add(DraftPeriod(
        subject: subject,
        teacher: _emptyToNull(_str(row['faculty'])),
        room: _emptyToNull(_str(row['room'])),
        isLab: isLab,
      ));
    }
    if (drafts.isNotEmpty) draft.week[weekday] = drafts;
  });
}

// ─── helpers ──────────────────────────────────────────────────────────────────

String? _clean(String? s) {
  if (s == null) return null;
  final t = s.trim();
  return t.isEmpty ? null : t;
}

String? _emptyToNull(String s) => s.isEmpty ? null : s;

String _str(dynamic v) => v == null ? '' : v.toString().trim();

int? _intOrNull(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString().trim() ?? '');
}

int _intOr(dynamic v, int fallback) => _intOrNull(v) ?? fallback;

/// Parses "HH:MM" (tolerant of "H:MM", stray am/pm) to minutes since midnight.
int? _hhmmToMin(String raw) {
  var s = raw.trim().toLowerCase();
  if (s.isEmpty) return null;
  var pm = false, am = false;
  if (s.endsWith('am')) {
    am = true;
    s = s.substring(0, s.length - 2).trim();
  } else if (s.endsWith('pm')) {
    pm = true;
    s = s.substring(0, s.length - 2).trim();
  }
  final parts = s.split(RegExp(r'[:.]'));
  if (parts.isEmpty) return null;
  final h = int.tryParse(parts[0].trim());
  final m = parts.length > 1 ? int.tryParse(parts[1].trim()) : 0;
  if (h == null || m == null) return null;
  var hour = h;
  if (pm && hour < 12) hour += 12;
  if (am && hour == 12) hour = 0;
  if (hour < 0 || hour > 23 || m < 0 || m > 59) return null;
  return hour * 60 + m;
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
