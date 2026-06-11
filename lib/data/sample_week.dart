import '../models/period_models.dart';

/// First-launch sample timetable. Generic placeholder subjects with distinct
/// colors so the layout reads immediately; fully editable in-app afterwards.
Timetable buildSampleTimetable() {
  const subjects = <Subject>[
    Subject(id: 'sub-math', name: 'Mathematics', color: 0xFF5965C8), // indigo
    Subject(id: 'sub-ds', name: 'Data Structures', color: 0xFF3F9C8E), // teal
    Subject(
        id: 'sub-os', name: 'Operating Systems', color: 0xFFC9912E), // ochre
    Subject(id: 'sub-dbms', name: 'DBMS', color: 0xFFC25E73), // rose
    Subject(
        id: 'sub-cn', name: 'Computer Networks', color: 0xFF6E78C4), // periwinkle
    Subject(id: 'sub-ai', name: 'Elective – AI', color: 0xFF5C9E6F), // sage
    Subject(id: 'sub-phys', name: 'Physics', color: 0xFFC56B4E), // terracotta
    Subject(id: 'sub-soft', name: 'Soft Skills', color: 0xFF8E6BAE), // plum
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
  0xFF5965C8, // indigo
  0xFF3F9C8E, // teal
  0xFFC9912E, // ochre
  0xFFC25E73, // rose
  0xFF6E78C4, // periwinkle
  0xFF5C9E6F, // sage
  0xFFC56B4E, // terracotta
  0xFF8E6BAE, // plum
  0xFF3E84A8, // steel blue
  0xFF7E9A4E, // olive
  0xFFB06AA0, // mauve
  0xFFC07A45, // clay
  0xFF4AA59A, // sea
  0xFF5B86C9, // cornflower
  0xFFB85C5C, // brick
  0xFF7C6BC0, // violet
];
