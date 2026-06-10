import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/logic/timetable_builder.dart';
import 'package:timetable/logic/today_engine.dart';
import 'package:timetable/models/period_models.dart';

void main() {
  const subjects = [
    Subject(id: 'm', name: 'Math', color: 0xFF000001),
    Subject(id: 'p', name: 'Physics', color: 0xFF000002),
    Subject(id: 'c', name: 'CS', color: 0xFF000003),
  ];
  final byId = {for (final s in subjects) s.id: s};

  const config = TimetableConfig(
    dayStartMin: 8 * 60 + 30, // 8:30
    classMins: 50,
    labMins: 120,
    teaAfter: 2,
    teaMins: 15,
    lunchAfter: 4,
    lunchMins: 45,
  );

  final periods = const [
    Period(id: '1', subjectId: 'm'),
    Period(id: '2', subjectId: 'c'),
    Period(id: '3', subjectId: 'p', isLab: true), // 120-min block
    Period(id: '4', subjectId: 'm'),
    Period(id: '5', subjectId: 'c'),
  ];

  final timeline = TimetableBuilder.buildDay(periods, byId, config);

  test('sequential times, lab is one 2-hour block, breaks inserted', () {
    // 8:30 Math, 9:20 CS, 9:35? no -> tea after 2 classes at 10:10? recompute:
    // Math 510-560, CS 560-610, TEA 610-625, Lab 625-745 (120), Math 745-795,
    // (lunch is configured after 4 classes) -> after Math(#4): Lunch 795-840,
    // CS 840-890.
    expect(timeline.map((e) => e.title).toList(),
        ['Math', 'CS', 'Tea Break', 'Physics', 'Math', 'Lunch Break', 'CS']);
    final lab = timeline.firstWhere((e) => e.isLab);
    expect(lab.durationMin, 120);
    expect(lab.startMin, 625);
    expect(lab.color, 0xFF000002);
  });

  test('completion % scales over a class and a lab', () {
    // 25 min into the first 50-min Math (8:55) => 50%.
    var s = TodayEngine.compute(timeline, DateTime(2026, 1, 1, 8, 55));
    expect(s.currentIsClass, isTrue);
    expect(s.completionPercent, 50);

    // 60 min into the 120-min lab (lab starts 10:25 -> 11:25) => 50%.
    s = TodayEngine.compute(timeline, DateTime(2026, 1, 1, 11, 25));
    expect(s.current!.isLab, isTrue);
    expect(s.completionPercent, 50);
  });

  test('break active + break-next hint', () {
    // During tea (10:10-10:25).
    var s = TodayEngine.compute(timeline, DateTime(2026, 1, 1, 10, 15));
    expect(s.currentIsBreak, isTrue);
    // Just before tea, the hint surfaces.
    s = TodayEngine.compute(timeline, DateTime(2026, 1, 1, 10, 5));
    expect(s.breakHint, isNotNull);
  });

  test('day-over state', () {
    final s = TodayEngine.compute(timeline, DateTime(2026, 1, 1, 18, 0));
    expect(s.dayOver, isTrue);
    expect(s.current, isNull);
  });

  test('orphan period (missing subject) is skipped', () {
    final t = TimetableBuilder.buildDay(
      const [Period(id: 'x', subjectId: 'missing')],
      byId,
      config,
    );
    expect(t, isEmpty);
  });
}
