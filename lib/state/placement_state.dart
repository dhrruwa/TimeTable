import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/period_models.dart';

/// Drives the "Duplicate & Place" / "Move" interaction on the Week grid.
///
/// Our timetable uses a DENSE ordered period list per day, so the only open
/// slot in a day is the next position (`periods.length`). Valid targets are
/// therefore each day's next-open block, validated so a lab never lands on a
/// slot whose second half would cross a break.
typedef Target = ({int day, int pos});
typedef PlacedRef = ({int day, String id});

class PlacementState {
  final bool active;
  final bool isMove; // true => remove the source after placing
  final int? sourceDay; // 1..6
  final int? sourcePeriodPos; // 0-based index in the source day's list
  final Period? snapshot; // copy of the period being placed
  final Subject? subject;
  final List<Target> validTargets;
  final List<PlacedRef> placed; // undo stack (day + placed period id)

  const PlacementState({
    required this.active,
    this.isMove = false,
    this.sourceDay,
    this.sourcePeriodPos,
    this.snapshot,
    this.subject,
    this.validTargets = const [],
    this.placed = const [],
  });

  static const PlacementState inactive = PlacementState(active: false);

  PlacementState copyWith({
    bool? active,
    bool? isMove,
    int? sourceDay,
    int? sourcePeriodPos,
    Period? snapshot,
    Subject? subject,
    List<Target>? validTargets,
    List<PlacedRef>? placed,
  }) =>
      PlacementState(
        active: active ?? this.active,
        isMove: isMove ?? this.isMove,
        sourceDay: sourceDay ?? this.sourceDay,
        sourcePeriodPos: sourcePeriodPos ?? this.sourcePeriodPos,
        snapshot: snapshot ?? this.snapshot,
        subject: subject ?? this.subject,
        validTargets: validTargets ?? this.validTargets,
        placed: placed ?? this.placed,
      );

  bool isTarget(int day, int pos) =>
      validTargets.any((t) => t.day == day && t.pos == pos);
}

final placementProvider =
    StateProvider<PlacementState>((ref) => PlacementState.inactive);

/// Maximum class blocks allowed per day (validation rule).
int maxBlocksPerDay(TimetableConfig cfg) =>
    (cfg.teaAfter > cfg.lunchAfter ? cfg.teaAfter : cfg.lunchAfter) + 3;

/// Computes the valid drop targets: each day's next-open block, skipping the
/// source slot and lab-illegal positions.
List<Target> computeValidTargets(
  Timetable t,
  int sourceDay,
  int sourcePeriodPos,
  bool isLab,
) {
  final maxBlocks = maxBlocksPerDay(t.config);
  final targets = <Target>[];
  for (var d = 1; d <= 6; d++) {
    final periods = t.periodsOn(d);
    final pos = periods.length; // the only open slot in a dense list
    final block = pos + 1; // 1-based block position

    if (d == sourceDay && pos == sourcePeriodPos) continue; // source itself
    if (block > maxBlocks) continue; // day is full

    if (isLab) {
      // A lab's 2nd half must not fall on a break boundary, and must fit.
      final crossesBreak =
          block == t.config.teaAfter || block == t.config.lunchAfter;
      if (crossesBreak) continue;
      if (block + 1 > maxBlocks) continue;
    }

    targets.add((day: d, pos: pos));
  }
  return targets;
}
