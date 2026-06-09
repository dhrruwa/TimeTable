import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/logic/schedule_service.dart';
import 'package:timetable/models/timetable_models.dart';

void main() {
  const cs = Course(id: 'c1', name: 'CS', color: 0xFF000000);
  const math = Course(id: 'c2', name: 'Math', color: 0xFF111111);

  int hm(int h, int m) => h * 60 + m;

  final timetable = Timetable(
    courses: const [cs, math],
    slots: [
      // Monday
      ClassSlot(id: 's1', courseId: 'c1', dayOfWeek: 1, startMinutes: hm(9, 0), endMinutes: hm(10, 0)),
      ClassSlot(id: 's2', courseId: 'c2', dayOfWeek: 1, startMinutes: hm(11, 0), endMinutes: hm(12, 0)),
      // Friday
      ClassSlot(id: 's3', courseId: 'c1', dayOfWeek: 5, startMinutes: hm(14, 0), endMinutes: hm(15, 0)),
    ],
  );

  final service = ScheduleService(timetable);

  // A known Monday: 2026-06-08 is a Monday.
  DateTime monday(int h, int m) => DateTime(2026, 6, 8, h, m);
  // 2026-06-12 is a Friday.
  DateTime friday(int h, int m) => DateTime(2026, 6, 12, h, m);

  test('classesOnDay returns sorted resolved classes', () {
    final mon = service.classesOnDay(1);
    expect(mon.map((c) => c.id), ['s1', 's2']);
    expect(mon.first.courseName, 'CS');
    expect(service.classesOnDay(3), isEmpty);
  });

  test('currentClass detects an in-progress class', () {
    expect(service.currentClass(now: monday(9, 30))?.id, 's1');
    expect(service.currentClass(now: monday(10, 30)), isNull); // gap
  });

  test('nextClass returns the next class later the same day', () {
    expect(service.nextClass(now: monday(9, 30))?.id, 's2');
    expect(service.nextClass(now: monday(10, 30))?.id, 's2');
  });

  test('nextClass wraps Friday -> Monday', () {
    expect(service.nextClass(now: friday(16, 0))?.id, 's1');
  });

  test('minutesUntilNext computes same-day and wrapping gaps', () {
    expect(service.minutesUntilNext(now: monday(10, 30)), 30); // until 11:00
    // Friday 16:00 -> Monday 09:00 = 3 days minus 7h.
    final wrap = service.minutesUntilNext(now: friday(16, 0));
    expect(wrap, 3 * 24 * 60 - 7 * 60);
  });

  test('widgetTimelineForDay flags current and next', () {
    final timeline = service.widgetTimelineForDay(1, now: monday(9, 30));
    expect(timeline.firstWhere((e) => e.scheduledClass.id == 's1').isCurrent, isTrue);
    expect(timeline.firstWhere((e) => e.scheduledClass.id == 's2').isNext, isTrue);
  });

  test('orphan slots (missing course) are ignored', () {
    final s = ScheduleService(Timetable(
      courses: const [cs],
      slots: const [
        ClassSlot(id: 'x', courseId: 'missing', dayOfWeek: 2, startMinutes: 60, endMinutes: 120),
      ],
    ));
    expect(s.classesOnDay(2), isEmpty);
  });
}
