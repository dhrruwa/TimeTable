import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/today_engine.dart';
import '../providers/providers.dart';
import '../providers/widget_providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/period_tile.dart';
import '../widgets/percent_ring.dart';
import '../widgets/time_utils.dart';
import 'settings_screen.dart';

/// Today: the live current period with a completion %, then the full day's
/// timeline (periods + breaks), color-coded by subject.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(nowProvider);
    final weekday = now.weekday;
    final timeline = ref.watch(timelineForDayProvider(weekday));
    final status = TodayEngine.compute(timeline, now);

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
            icon: const Icon(Icons.tune),
            tooltip: 'Schedule settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Hero(status: status, context: context),
          const SizedBox(height: 24),
          Text("Today's schedule",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          if (timeline.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: EmptyState(
                icon: Icons.beach_access_outlined,
                title: 'Nothing today',
                message: 'No classes scheduled. Enjoy the day off!',
              ),
            )
          else
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
        ],
      ),
    );
  }

  static String _month(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' //
      ][m - 1];
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

    // Empty / before / done states use a neutral surface.
    if (status.empty || status.dayOver || status.beforeDay) {
      final (icon, title, sub) = status.empty
          ? (Icons.weekend_outlined, 'No classes today', 'Enjoy the day off')
          : status.dayOver
              ? (
                  Icons.check_circle_outline,
                  'All classes done',
                  'See you tomorrow'
                )
              : (
                  Icons.wb_twilight,
                  'Day ahead',
                  'Starts ${TimeUtils.formatMinutes(context, status.timeline.first.startMin)}'
                );
      return _NeutralHero(icon: icon, title: title, subtitle: sub);
    }

    final current = status.current!;
    final color = Color(current.color);
    final onColor = Colors.white;
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
        borderRadius: BorderRadius.circular(22),
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
        borderRadius: BorderRadius.circular(22),
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
