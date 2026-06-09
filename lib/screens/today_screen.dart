import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../widgets/class_card.dart';
import '../widgets/current_class_banner.dart';
import '../widgets/empty_state.dart';
import '../widgets/time_utils.dart';
import 'edit_slot_screen.dart';

/// Default landing tab: the live "now / next" banner plus today's classes.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(scheduleServiceProvider);
    final now = ref.watch(nowProvider);

    final current = service.currentClass(now: now);
    final next = service.nextClass(now: now);
    final minutesUntil = service.minutesUntilNext(now: now);
    final todays = service.classesToday(now: now);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today'),
            Text(
              TimeUtils.dayName(now.weekday),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: const [_ThemeToggleButton()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {}, // clock-driven; pull is just a reassurance gesture
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            CurrentClassBanner(
              current: current,
              next: next,
              minutesUntilNext: minutesUntil,
            ),
            const SizedBox(height: 24),
            Text(
              "Today's schedule",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (todays.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: EmptyState(
                  icon: Icons.free_breakfast_outlined,
                  title: 'Nothing today',
                  message: 'No classes scheduled for today. Enjoy the day off!',
                ),
              )
            else
              for (final c in todays)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ClassCard(
                    scheduledClass: c,
                    highlight: current != null && c.id == current.id,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditSlotScreen(existing: c.slot),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// Cycles theme mode: system → light → dark → system. Gives users explicit
/// dark-mode control on top of the default system-following behavior.
class _ThemeToggleButton extends ConsumerWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final (icon, tooltip, next) = switch (mode) {
      ThemeMode.system => (Icons.brightness_auto, 'Theme: system', ThemeMode.light),
      ThemeMode.light => (Icons.light_mode, 'Theme: light', ThemeMode.dark),
      ThemeMode.dark => (Icons.dark_mode, 'Theme: dark', ThemeMode.system),
    };
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () => ref.read(themeModeProvider.notifier).state = next,
    );
  }
}
