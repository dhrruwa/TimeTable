import '../models/period_models.dart';

/// First-launch sample timetable. Generic placeholder subjects with distinct
/// colors so the layout reads immediately; fully editable in-app afterwards.
Timetable buildSampleTimetable() {
  const subjects = <Subject>[
    Subject(id: 'sub-math', name: 'Mathematics', color: 0xFF4F46E5), // indigo
    Subject(id: 'sub-ds', name: 'Data Structures', color: 0xFF0EA5A4), // teal
    Subject(
        id: 'sub-os', name: 'Operating Systems', color: 0xFFF59E0B), // amber
    Subject(id: 'sub-dbms', name: 'DBMS', color: 0xFFEC4899), // pink
    Subject(
        id: 'sub-cn', name: 'Computer Networks', color: 0xFF6366F1), // violet
    Subject(id: 'sub-ai', name: 'Elective – AI', color: 0xFF10B981), // green
    Subject(id: 'sub-phys', name: 'Physics', color: 0xFFEF4444), // red
    Subject(id: 'sub-soft', name: 'Soft Skills', color: 0xFF8B5CF6), // purple
  ];

  int n = 0;
  Period p(String subjectId, String room, String teacher, {bool lab = false}) =>
      Period(
        id: 'p${n++}',
        subjectId: subjectId,
        room: room,
        teacher: teacher,
        isLab: lab,
      );

  final week = <int, List<Period>>{
    1: [
      p('sub-math', 'R-204', 'Prof. Rao'),
      p('sub-ds', 'R-204', 'Prof. Nair'),
      p('sub-os', 'R-210', 'Dr. Iyer'),
      p('sub-dbms', 'R-210', 'Prof. Rao'),
      p('sub-cn', 'R-215', 'Dr. Das'),
      p('sub-ai', 'R-215', 'Prof. Menon'),
    ],
    2: [
      p('sub-math', 'R-204', 'Prof. Rao'),
      p('sub-cn', 'R-215', 'Dr. Das'),
      p('sub-phys', 'Lab-1', 'Dr. Kapoor', lab: true),
      p('sub-dbms', 'R-210', 'Prof. Rao'),
      p('sub-os', 'R-210', 'Dr. Iyer'),
    ],
    3: [
      p('sub-os', 'R-210', 'Dr. Iyer'),
      p('sub-ds', 'Lab-3', 'Prof. Nair', lab: true),
      p('sub-math', 'R-204', 'Prof. Rao'),
      p('sub-cn', 'R-215', 'Dr. Das'),
      p('sub-ai', 'R-215', 'Prof. Menon'),
    ],
    4: [
      p('sub-dbms', 'R-210', 'Prof. Rao'),
      p('sub-math', 'R-204', 'Prof. Rao'),
      p('sub-ds', 'R-204', 'Prof. Nair'),
      p('sub-os', 'R-210', 'Dr. Iyer'),
      p('sub-cn', 'R-215', 'Dr. Das'),
      p('sub-soft', 'R-301', 'Ms. Pillai'),
    ],
    5: [
      p('sub-ds', 'R-204', 'Prof. Nair'),
      p('sub-math', 'R-204', 'Prof. Rao'),
      p('sub-cn', 'Lab-2', 'Dr. Das', lab: true),
      p('sub-dbms', 'R-210', 'Prof. Rao'),
      p('sub-os', 'R-210', 'Dr. Iyer'),
    ],
    6: [
      p('sub-soft', 'Seminar Hall', 'Dept.'),
      p('sub-ai', 'R-215', 'Prof. Menon'),
    ],
  };

  return Timetable(
    subjects: subjects,
    week: week,
    config: const TimetableConfig(),
  );
}

/// A curated palette for new subjects (assigned the next unused color).
const List<int> kSubjectPalette = [
  0xFF4F46E5,
  0xFF0EA5A4,
  0xFFF59E0B,
  0xFFEC4899,
  0xFF6366F1,
  0xFF10B981,
  0xFFEF4444,
  0xFF8B5CF6,
  0xFF0891B2,
  0xFF65A30D,
  0xFFD946EF,
  0xFFF97316,
  0xFF14B8A6,
  0xFF3B82F6,
  0xFFE11D48,
  0xFF7C3AED,
];
