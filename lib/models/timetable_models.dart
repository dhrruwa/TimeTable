import 'dart:convert';

/// Pure data models for the timetable domain.
///
/// IMPORTANT: This file must stay free of Flutter and Isar imports. The
/// [Course.toJson]/[Course.fromJson] (and the equivalents on [ClassSlot] /
/// [Timetable]) methods are the canonical serialization format and will be
/// reused for cloud sharing in Phase 2 — do not change their shape lightly.

/// A course a student takes. Slots reference a course by [id].
class Course {
  final String id;
  final String name;
  final String? instructor;
  final String? room;

  /// Course color encoded as a 32-bit ARGB integer (e.g. 0xFF2196F3).
  final int color;

  const Course({
    required this.id,
    required this.name,
    this.instructor,
    this.room,
    required this.color,
  });

  Course copyWith({
    String? id,
    String? name,
    String? instructor,
    String? room,
    int? color,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      instructor: instructor ?? this.instructor,
      room: room ?? this.room,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'instructor': instructor,
        'room': room,
        'color': color,
      };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        name: json['name'] as String,
        instructor: json['instructor'] as String?,
        room: json['room'] as String?,
        color: (json['color'] as num).toInt(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course &&
          other.id == id &&
          other.name == name &&
          other.instructor == instructor &&
          other.room == room &&
          other.color == color;

  @override
  int get hashCode => Object.hash(id, name, instructor, room, color);
}

/// A single recurring class on the weekly grid.
///
/// Times are minutes-since-midnight in the range 0..1440. [dayOfWeek] follows
/// `DateTime.weekday` semantics: 1 = Monday .. 7 = Sunday.
class ClassSlot {
  final String id;
  final String courseId;

  /// 1 = Monday .. 7 = Sunday (matches `DateTime.weekday`).
  final int dayOfWeek;

  /// Minutes since midnight, 0..1440.
  final int startMinutes;

  /// Minutes since midnight, 0..1440. Must be > [startMinutes].
  final int endMinutes;

  const ClassSlot({
    required this.id,
    required this.courseId,
    required this.dayOfWeek,
    required this.startMinutes,
    required this.endMinutes,
  });

  /// Duration of this slot in minutes.
  int get durationMinutes => endMinutes - startMinutes;

  /// Whether [minutesSinceMidnight] falls within this slot (start inclusive,
  /// end exclusive).
  bool contains(int minutesSinceMidnight) =>
      minutesSinceMidnight >= startMinutes && minutesSinceMidnight < endMinutes;

  /// Formats a minutes-since-midnight value as a 24h `H:mm` label, e.g. 545
  /// becomes `9:05`. Pure helper so the logic layer can format without Flutter.
  static String atTime(int minutesSinceMidnight) {
    final clamped = minutesSinceMidnight % (24 * 60);
    final h = clamped ~/ 60;
    final m = clamped % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

  String get startLabel => atTime(startMinutes);
  String get endLabel => atTime(endMinutes);

  ClassSlot copyWith({
    String? id,
    String? courseId,
    int? dayOfWeek,
    int? startMinutes,
    int? endMinutes,
  }) {
    return ClassSlot(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'dayOfWeek': dayOfWeek,
        'startMinutes': startMinutes,
        'endMinutes': endMinutes,
      };

  factory ClassSlot.fromJson(Map<String, dynamic> json) => ClassSlot(
        id: json['id'] as String,
        courseId: json['courseId'] as String,
        dayOfWeek: (json['dayOfWeek'] as num).toInt(),
        startMinutes: (json['startMinutes'] as num).toInt(),
        endMinutes: (json['endMinutes'] as num).toInt(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassSlot &&
          other.id == id &&
          other.courseId == courseId &&
          other.dayOfWeek == dayOfWeek &&
          other.startMinutes == startMinutes &&
          other.endMinutes == endMinutes;

  @override
  int get hashCode =>
      Object.hash(id, courseId, dayOfWeek, startMinutes, endMinutes);
}

/// The complete timetable: the set of courses and the slots that schedule them.
class Timetable {
  final List<Course> courses;
  final List<ClassSlot> slots;

  const Timetable({
    this.courses = const [],
    this.slots = const [],
  });

  Course? courseById(String id) {
    for (final c in courses) {
      if (c.id == id) return c;
    }
    return null;
  }

  Timetable copyWith({
    List<Course>? courses,
    List<ClassSlot>? slots,
  }) {
    return Timetable(
      courses: courses ?? this.courses,
      slots: slots ?? this.slots,
    );
  }

  Map<String, dynamic> toJson() => {
        'courses': courses.map((c) => c.toJson()).toList(),
        'slots': slots.map((s) => s.toJson()).toList(),
      };

  factory Timetable.fromJson(Map<String, dynamic> json) => Timetable(
        courses: (json['courses'] as List<dynamic>? ?? [])
            .map((e) => Course.fromJson(e as Map<String, dynamic>))
            .toList(),
        slots: (json['slots'] as List<dynamic>? ?? [])
            .map((e) => ClassSlot.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  String toJsonString() => jsonEncode(toJson());

  factory Timetable.fromJsonString(String source) =>
      Timetable.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
