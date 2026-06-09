import '../models/timetable_models.dart';

/// First-launch seed data so the UI has something to show immediately.
/// Generated with fixed ids (no uuid needed) since it only runs once on an
/// empty database.
Timetable buildSampleTimetable() {
  const cs = Course(
    id: 'seed-cs101',
    name: 'Intro to Computer Science',
    instructor: 'Dr. Alan Mehta',
    room: 'Sci-204',
    color: 0xFF3F51B5, // indigo
  );
  const calc = Course(
    id: 'seed-math',
    name: 'Calculus II',
    instructor: 'Prof. Lena Ortiz',
    room: 'Math-110',
    color: 0xFF009688, // teal
  );
  const eng = Course(
    id: 'seed-eng',
    name: 'Academic Writing',
    instructor: 'Dr. Priya Nair',
    room: 'Hum-3B',
    color: 0xFFE91E63, // pink
  );
  const phys = Course(
    id: 'seed-phys',
    name: 'Physics Lab',
    instructor: 'Mr. Dev Kapoor',
    room: 'Lab-7',
    color: 0xFFFF9800, // orange
  );

  int hm(int h, int m) => h * 60 + m;

  final slots = <ClassSlot>[
    // Monday
    ClassSlot(id: 's1', courseId: cs.id, dayOfWeek: 1, startMinutes: hm(9, 0), endMinutes: hm(10, 15)),
    ClassSlot(id: 's2', courseId: calc.id, dayOfWeek: 1, startMinutes: hm(11, 0), endMinutes: hm(12, 15)),
    ClassSlot(id: 's3', courseId: eng.id, dayOfWeek: 1, startMinutes: hm(14, 0), endMinutes: hm(15, 0)),
    // Tuesday
    ClassSlot(id: 's4', courseId: phys.id, dayOfWeek: 2, startMinutes: hm(10, 0), endMinutes: hm(12, 0)),
    ClassSlot(id: 's5', courseId: calc.id, dayOfWeek: 2, startMinutes: hm(13, 0), endMinutes: hm(14, 15)),
    // Wednesday
    ClassSlot(id: 's6', courseId: cs.id, dayOfWeek: 3, startMinutes: hm(9, 0), endMinutes: hm(10, 15)),
    ClassSlot(id: 's7', courseId: eng.id, dayOfWeek: 3, startMinutes: hm(11, 0), endMinutes: hm(12, 0)),
    // Thursday
    ClassSlot(id: 's8', courseId: calc.id, dayOfWeek: 4, startMinutes: hm(9, 30), endMinutes: hm(10, 45)),
    ClassSlot(id: 's9', courseId: phys.id, dayOfWeek: 4, startMinutes: hm(14, 0), endMinutes: hm(16, 0)),
    // Friday
    ClassSlot(id: 's10', courseId: cs.id, dayOfWeek: 5, startMinutes: hm(10, 0), endMinutes: hm(11, 15)),
    ClassSlot(id: 's11', courseId: eng.id, dayOfWeek: 5, startMinutes: hm(12, 0), endMinutes: hm(13, 0)),
  ];

  return Timetable(courses: [cs, calc, eng, phys], slots: slots);
}
