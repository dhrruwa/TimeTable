import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/notes_engine.dart';
import '../logic/timetable_builder.dart';
import '../logic/today_engine.dart';
import '../models/period_models.dart';
import '../providers/providers.dart';
import '../providers/widget_providers.dart';
import '../widgets/dhrruwa_footer.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import '../widgets/period_tile.dart';
import '../widgets/percent_ring.dart';
import '../widgets/time_utils.dart';
import 'settings_screen.dart';
import 'share_screen.dart';

/// Today: the live current period with a completion %, a contextual note, then
/// the full day's timeline. After the last class ends it flips to a calm
/// next-day (or next-week) preview.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider);
    final weekday = now.weekday;
    final timetable = ref.watch(timetableProvider);
    final timeline = ref.watch(timelineForDayProvider(weekday));
    final status = TodayEngine.compute(timeline, now);
    final note = NotesEngine.pick(now: now, timetable: timetable);

    // Flip to next-day mode once today's classes are over (or there are none).
    final nextDayMode = status.dayOver || status.empty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today'),
            Text(
              '${TimeUtils.dayName(weekday)}, ${now.day} ${_month(now.month)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Share & community',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ShareScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Schedule settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: nextDayMode
          ? _NextDayView(now: now, timetable: timetable)
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _Hero(status: status, context: context),
                const SizedBox(height: 14),
                NoteCard(note: note),
                const SizedBox(height: 24),
                Text("Today's schedule",
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                for (final e in timeline)
                  PeriodTile(
                    entry: e,
                    isCurrent: identical(e, status.current),
                    percent: identical(e, status.current) && e.isClass
                        ? status.completionPercent
                        : null,
                    completion: identical(e, status.current) && e.isClass
                        ? status.completion
                        : null,
                  ),
                const DhrruwaFooter(),
              ],
            ),
    );
  }

  static String _month(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' //
      ][m - 1];
}

/// Shown after the last class: previews the next day (or Monday on weekends)
/// with a restful note.
class _NextDayView extends StatelessWidget {
  final DateTime now;
  final Timetable timetable;
  const _NextDayView({required this.now, required this.timetable});

  @override
  Widget build(BuildContext context) {
    // Find the next weekday (Mon–Sat) that actually has classes.
    ({int offset, DateTime date, int weekday, List<TimelineEntry> tl})? next;
    for (var off = 1; off <= 7; off++) {
      final date =
          DateTime(now.year, now.month, now.day).add(Duration(days: off));
      final wd = date.weekday;
      if (wd < 1 || wd > 6) continue;
      final tl = TimetableBuilder.buildDay(
        timetable.periodsOn(wd),
        timetable.subjectsById,
        timetable.config,
      );
      if (tl.isNotEmpty) {
        next = (offset: off, date: date, weekday: wd, tl: tl);
        break;
      }
    }

    if (next == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: EmptyState(
          icon: Icons.celebration_outlined,
          title: 'No classes coming up',
          message: 'Nothing scheduled in the week ahead. Enjoy the break! 🎉',
        ),
      );
    }

    final n = next;
    final isTomorrow = n.offset == 1;
    final isWeekendJump = n.weekday == DateTime.monday && n.offset > 1;
    final heading = isTomorrow
        ? '🌙 Tomorrow'
        : isWeekendJump
            ? '🎒 Next week'
            : '🌙 Next';
    final dateLabel =
        '${TimeUtils.dayName(n.weekday)}, ${n.date.day} ${TodayScreen._month(n.date.month)}';
    final restNote = isWeekendJump
        ? "Enjoy your weekend! Monday's first class is at "
            "${TimeUtils.formatMinutes(context, n.tl.first.startMin)} 🎒"
        : 'Get some rest and be ready for tomorrow! 💤';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Today's classes are done ✅",
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Here is what is coming up next.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      )),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Text(heading, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            Text(dateLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
          ],
        ),
        const SizedBox(height: 10),
        for (final e in n.tl) PeriodTile(entry: e),
        const SizedBox(height: 16),
        NoteCard(note: restNote, icon: Icons.bedtime_outlined),
        const DhrruwaFooter(),
      ],
    );
  }
}

/// The hero card: in-progress period (colored, with % ring), break, or a calm
/// before/after-day state.
class _Hero extends StatelessWidget {
  final TodayStatus status;
  final BuildContext context;
  const _Hero({required this.status, required this.context});

  @override
  Widget build(BuildContext _) {
    final scheme = Theme.of(context).colorScheme;

    if (status.beforeDay) {
      return _NeutralHero(
        icon: Icons.wb_twilight,
        title: 'Day ahead',
        subtitle:
            'Starts ${TimeUtils.formatMinutes(context, status.timeline.first.startMin)}',
      );
    }

    final current = status.current!;
    final color = Color(current.color);
    const onColor = Colors.white;
    final isBreak = current.isBreak;
    final heroColor = isBreak ? scheme.surfaceContainerHighest : color;
    final fg = isBreak ? scheme.onSurface : onColor;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isBreak
            ? null
            : LinearGradient(
                colors: [color, Color.alphaBlend(Colors.black26, color)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isBreak ? heroColor : null,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (!isBreak)
            PercentRing(
              percent: status.completion,
              size: 72,
              stroke: 7,
              trackColor: Colors.white.withValues(alpha: 0.3),
              progressColor: Colors.white,
              center: Text('${status.completionPercent}%',
                  style: TextStyle(
                      color: fg, fontSize: 18, fontWeight: FontWeight.bold)),
            )
          else
            Icon(Icons.local_cafe, color: scheme.primary, size: 40),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isBreak ? 'ON BREAK' : 'IN PROGRESS',
                    style: TextStyle(
                        color: fg.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8)),
                const SizedBox(height: 4),
                Text(current.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: fg, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 15, color: fg.withValues(alpha: 0.9)),
                    const SizedBox(width: 4),
                    Text(
                      'Ends ${TimeUtils.formatMinutes(context, current.endMin)}',
                      style: TextStyle(
                          color: fg.withValues(alpha: 0.95), fontSize: 13),
                    ),
                    if (current.room != null && current.room!.isNotEmpty) ...[
                      const SizedBox(width: 14),
                      Icon(Icons.place_outlined,
                          size: 15, color: fg.withValues(alpha: 0.9)),
                      const SizedBox(width: 4),
                      Text(current.room!,
                          style: TextStyle(
                              color: fg.withValues(alpha: 0.95), fontSize: 13)),
                    ],
                  ],
                ),
                if (!isBreak &&
                    current.teacher != null &&
                    current.teacher!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(current.teacher!,
                      style: TextStyle(
                          color: fg.withValues(alpha: 0.85), fontSize: 12)),
                ],
                if (status.breakHint != null && !isBreak) ...[
                  const SizedBox(height: 8),
                  _HintPill(text: status.breakHint!, onColor: fg),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NeutralHero extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _NeutralHero(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HintPill extends StatelessWidget {
  final String text;
  final Color onColor;
  const _HintPill({required this.text, required this.onColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: onColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_cafe, size: 12, color: onColor),
          const SizedBox(width: 5),
          Text(text,
              style: TextStyle(
                  color: onColor, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
