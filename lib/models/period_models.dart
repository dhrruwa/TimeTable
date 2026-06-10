import 'dart:convert';

/// Canonical, editable timetable model (pure Dart — no Flutter/Isar).
///
/// One shared source of truth for the whole app: Today, the Week grid, and the
/// home-screen widgets all read from a [Timetable]. The `toJson`/`fromJson`
/// methods are the persistence + (future) cloud-share format.

enum EntryKind { regular, lab, tea, lunch }

/// A subject the student takes. The COLOR lives here, so every period of the
/// same subject is shown in the same color everywhere.
class Subject {
  final String id;
  final String name;
  final int color; // ARGB, e.g. 0xFF4F46E5

  const Subject({required this.id, required this.name, required this.color});

  Subject copyWith({String? id, String? name, int? color}) => Subject(
      id: id ?? this.id, name: name ?? this.name, color: color ?? this.color);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'color': color};

  factory Subject.fromJson(Map<String, dynamic> j) => Subject(
        id: j['id'] as String,
        name: j['name'] as String,
        color: (j['color'] as num).toInt(),
      );
}

/// One editable class slot in a day's ordered list. Times are NOT stored — they
/// are computed sequentially by `TimetableBuilder`. Room/teacher can vary per
/// period (e.g. a lab in a different room).
class Period {
  final String id;
  final String subjectId;
  final String? room;
  final String? teacher;
  final bool isLab;

  const Period({
    required this.id,
    required this.subjectId,
    this.room,
    this.teacher,
    this.isLab = false,
  });

  Period copyWith({
    String? id,
    String? subjectId,
    String? room,
    String? teacher,
    bool? isLab,
  }) =>
      Period(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        room: room ?? this.room,
        teacher: teacher ?? this.teacher,
        isLab: isLab ?? this.isLab,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectId': subjectId,
        'room': room,
        'teacher': teacher,
        'isLab': isLab,
      };

  factory Period.fromJson(Map<String, dynamic> j) => Period(
        id: j['id'] as String,
        subjectId: j['subjectId'] as String,
        room: j['room'] as String?,
        teacher: j['teacher'] as String?,
        isLab: (j['isLab'] as bool?) ?? false,
      );
}

/// Rules for turning ordered [Period]s into a timed day. Configurable.
class TimetableConfig {
  final int dayStartMin; // 8:30 = 510
  final int classMins; // 50
  final int labMins; // 120 (one block)
  final int teaAfter; // insert tea after N class blocks
  final int teaMins;
  final int lunchAfter; // insert lunch after N class blocks
  final int lunchMins;

  const TimetableConfig({
    this.dayStartMin = 8 * 60 + 30,
    this.classMins = 50,
    this.labMins = 120,
    this.teaAfter = 2,
    this.teaMins = 15,
    this.lunchAfter = 4,
    this.lunchMins = 45,
  });

  TimetableConfig copyWith({
    int? dayStartMin,
    int? classMins,
    int? labMins,
    int? teaAfter,
    int? teaMins,
    int? lunchAfter,
    int? lunchMins,
  }) =>
      TimetableConfig(
        dayStartMin: dayStartMin ?? this.dayStartMin,
        classMins: classMins ?? this.classMins,
        labMins: labMins ?? this.labMins,
        teaAfter: teaAfter ?? this.teaAfter,
        teaMins: teaMins ?? this.teaMins,
        lunchAfter: lunchAfter ?? this.lunchAfter,
        lunchMins: lunchMins ?? this.lunchMins,
      );

  Map<String, dynamic> toJson() => {
        'dayStartMin': dayStartMin,
        'classMins': classMins,
        'labMins': labMins,
        'teaAfter': teaAfter,
        'teaMins': teaMins,
        'lunchAfter': lunchAfter,
        'lunchMins': lunchMins,
      };

  factory TimetableConfig.fromJson(Map<String, dynamic> j) => TimetableConfig(
        dayStartMin: (j['dayStartMin'] as num?)?.toInt() ?? 8 * 60 + 30,
        classMins: (j['classMins'] as num?)?.toInt() ?? 50,
        labMins: (j['labMins'] as num?)?.toInt() ?? 120,
        teaAfter: (j['teaAfter'] as num?)?.toInt() ?? 2,
        teaMins: (j['teaMins'] as num?)?.toInt() ?? 15,
        lunchAfter: (j['lunchAfter'] as num?)?.toInt() ?? 4,
        lunchMins: (j['lunchMins'] as num?)?.toInt() ?? 45,
      );
}

/// The whole editable timetable.
class Timetable {
  final List<Subject> subjects;
  final Map<int, List<Period>> week; // 1=Mon .. 6=Sat
  final TimetableConfig config;

  const Timetable({
    this.subjects = const [],
    this.week = const {},
    this.config = const TimetableConfig(),
  });

  Subject? subjectById(String id) {
    for (final s in subjects) {
      if (s.id == id) return s;
    }
    return null;
  }

  Map<String, Subject> get subjectsById => {for (final s in subjects) s.id: s};

  List<Period> periodsOn(int weekday) => week[weekday] ?? const [];

  Timetable copyWith({
    List<Subject>? subjects,
    Map<int, List<Period>>? week,
    TimetableConfig? config,
  }) =>
      Timetable(
        subjects: subjects ?? this.subjects,
        week: week ?? this.week,
        config: config ?? this.config,
      );

  Map<String, dynamic> toJson() => {
        'subjects': subjects.map((s) => s.toJson()).toList(),
        'week': week.map(
          (day, periods) =>
              MapEntry('$day', periods.map((p) => p.toJson()).toList()),
        ),
        'config': config.toJson(),
      };

  factory Timetable.fromJson(Map<String, dynamic> j) {
    final week = <int, List<Period>>{};
    final rawWeek = (j['week'] as Map<String, dynamic>? ?? {});
    rawWeek.forEach((day, periods) {
      week[int.parse(day)] = (periods as List<dynamic>)
          .map((e) => Period.fromJson(e as Map<String, dynamic>))
          .toList();
    });
    return Timetable(
      subjects: (j['subjects'] as List<dynamic>? ?? [])
          .map((e) => Subject.fromJson(e as Map<String, dynamic>))
          .toList(),
      week: week,
      config: TimetableConfig.fromJson(
          (j['config'] as Map<String, dynamic>?) ?? const {}),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory Timetable.fromJsonString(String s) =>
      Timetable.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

/// A fully-resolved slot on a day's timeline: a class/lab/break with concrete
/// times AND the subject color stamped on, so the UI never looks it up.
class TimelineEntry {
  final EntryKind kind;
  final String title;
  final int color; // subject color, or a neutral break color
  final String? room;
  final String? teacher;
  final int startMin;
  final int endMin;

  const TimelineEntry({
    required this.kind,
    required this.title,
    required this.color,
    this.room,
    this.teacher,
    required this.startMin,
    required this.endMin,
  });

  int get durationMin => endMin - startMin;
  bool get isLab => kind == EntryKind.lab;
  bool get isBreak => kind == EntryKind.tea || kind == EntryKind.lunch;
  bool get isClass => kind == EntryKind.regular || kind == EntryKind.lab;

  bool contains(int minutesSinceMidnight) =>
      minutesSinceMidnight >= startMin && minutesSinceMidnight < endMin;
}
