import '../models/period_models.dart';

/// Turns a day's ordered [Period]s into a concrete timed timeline, resolving
/// each period's [Subject] so every [TimelineEntry] carries its title + color.
///
/// Pure Dart. Times are computed sequentially from [TimetableConfig.dayStartMin]:
/// regular = [TimetableConfig.classMins], lab = [TimetableConfig.labMins] (one
/// block), with tea/lunch breaks inserted after the configured class counts.
class TimetableBuilder {
  const TimetableBuilder._();

  /// Neutral color used for break rows.
  static const int breakColor = 0xFF7C828C;

  static List<TimelineEntry> buildDay(
    List<Period> periods,
    Map<String, Subject> subjectsById,
    TimetableConfig config,
  ) {
    final entries = <TimelineEntry>[];
    var cursor = config.dayStartMin;
    var classCount = 0;

    for (final p in periods) {
      final subject = subjectsById[p.subjectId];
      if (subject == null) continue; // orphan period — skip defensively.
      final duration = p.isLab ? config.labMins : config.classMins;
      entries.add(TimelineEntry(
        kind: p.isLab ? EntryKind.lab : EntryKind.regular,
        title: subject.name,
        color: subject.color,
        room: p.room,
        teacher: p.teacher,
        startMin: cursor,
        endMin: cursor + duration,
      ));
      cursor += duration;
      classCount++;

      if (classCount == config.teaAfter && config.teaMins > 0) {
        entries.add(TimelineEntry(
          kind: EntryKind.tea,
          title: 'Tea Break',
          color: breakColor,
          startMin: cursor,
          endMin: cursor + config.teaMins,
        ));
        cursor += config.teaMins;
      } else if (classCount == config.lunchAfter && config.lunchMins > 0) {
        entries.add(TimelineEntry(
          kind: EntryKind.lunch,
          title: 'Lunch Break',
          color: breakColor,
          startMin: cursor,
          endMin: cursor + config.lunchMins,
        ));
        cursor += config.lunchMins;
      }
    }

    return entries;
  }
}
