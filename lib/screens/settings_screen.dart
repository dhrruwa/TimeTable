import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/period_models.dart';
import '../providers/providers.dart';
import '../providers/widget_providers.dart';
import '../widgets/time_utils.dart';

/// Configure the bell schedule (day start, durations, break positions) and the
/// app theme. Changes recompute every screen + the widgets instantly.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(timetableProvider).config;
    final notifier = ref.read(timetableProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);

    void update(TimetableConfig c) => notifier.setConfig(c);

    final lunchInvalid = config.lunchAfter <= config.teaAfter;

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Live preview of the computed period times — updates as you tweak.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('LIVE PREVIEW',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    )),
          ),
          _PeriodPreviewStrip(cfg: config),
          if (lunchInvalid)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      size: 18, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lunch must come after the tea break (lunch-after > tea-after).',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          _section(context, 'Timing'),
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined),
            title: const Text('Day starts at'),
            trailing: Text(TimeUtils.formatMinutes(context, config.dayStartMin),
                style: const TextStyle(fontWeight: FontWeight.w600)),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeUtils.toTimeOfDay(config.dayStartMin),
              );
              if (picked != null) {
                update(
                    config.copyWith(dayStartMin: TimeUtils.toMinutes(picked)));
              }
            },
          ),
          _stepperTile(
              context,
              'Class length',
              '${config.classMins} min',
              () => update(config.copyWith(classMins: config.classMins - 5)),
              () => update(config.copyWith(classMins: config.classMins + 5))),
          _stepperTile(
              context,
              'Lab length',
              '${config.labMins} min',
              () => update(config.copyWith(labMins: config.labMins - 10)),
              () => update(config.copyWith(labMins: config.labMins + 10))),
          const Divider(),
          _section(context, 'Breaks'),
          _stepperTile(
              context,
              'Tea break after',
              '${config.teaAfter} classes',
              () => update(config.copyWith(
                  teaAfter: (config.teaAfter - 1).clamp(1, 12))),
              () => update(config.copyWith(
                  teaAfter: (config.teaAfter + 1).clamp(1, 12)))),
          _stepperTile(
              context,
              'Tea break length',
              '${config.teaMins} min',
              () => update(
                  config.copyWith(teaMins: (config.teaMins - 5).clamp(0, 60))),
              () => update(
                  config.copyWith(teaMins: (config.teaMins + 5).clamp(0, 60)))),
          _stepperTile(
              context,
              'Lunch after',
              '${config.lunchAfter} classes',
              () => update(config.copyWith(
                  lunchAfter: (config.lunchAfter - 1).clamp(1, 12))),
              () => update(config.copyWith(
                  lunchAfter: (config.lunchAfter + 1).clamp(1, 12)))),
          _stepperTile(
              context,
              'Lunch length',
              '${config.lunchMins} min',
              () => update(config.copyWith(
                  lunchMins: (config.lunchMins - 5).clamp(0, 120))),
              () => update(config.copyWith(
                  lunchMins: (config.lunchMins + 5).clamp(0, 120)))),
          const Divider(),
          _section(context, 'Appearance'),
          for (final entry in const {
            ThemeMode.system: 'System',
            ThemeMode.light: 'Light',
            ThemeMode.dark: 'Dark',
          }.entries)
            RadioListTile<ThemeMode>(
              value: entry.key,
              groupValue: themeMode,
              onChanged: (m) => ref.read(themeModeProvider.notifier).state =
                  m ?? ThemeMode.system,
              title: Text(entry.value),
            ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(title.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                )),
      );

  Widget _stepperTile(BuildContext context, String title, String value,
      VoidCallback onMinus, VoidCallback onPlus) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: onMinus,
              icon: const Icon(Icons.remove_circle_outline)),
          SizedBox(
            width: 76,
            child: Text(value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          IconButton(
              onPressed: onPlus, icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
    );
  }
}

/// Horizontal strip of the computed period times — recomputes instantly as the
/// config changes: "P1 8:30 · P2 9:20 · ☕ · P3 9:35 · …".
class _PeriodPreviewStrip extends StatelessWidget {
  final TimetableConfig cfg;
  const _PeriodPreviewStrip({required this.cfg});

  static String _hm(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '$h:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chips = <Widget>[];
    var cursor = cfg.dayStartMin;

    Widget periodChip(String label, String time) => Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: scheme.onPrimaryContainer)),
              Text(time,
                  style: TextStyle(
                      fontSize: 10,
                      color:
                          scheme.onPrimaryContainer.withValues(alpha: 0.8))),
            ],
          ),
        );

    Widget breakChip(String emoji) => Container(
          margin: const EdgeInsets.only(right: 8),
          width: 34,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 16)),
        );

    for (var i = 1; i <= 8; i++) {
      chips.add(periodChip('P$i', _hm(cursor)));
      cursor += cfg.classMins;
      if (i == cfg.teaAfter && cfg.teaMins > 0) {
        chips.add(breakChip('☕'));
        cursor += cfg.teaMins;
      }
      if (i == cfg.lunchAfter && cfg.lunchMins > 0) {
        chips.add(breakChip('🍽'));
        cursor += cfg.lunchMins;
      }
      if (cursor >= 22 * 60) break; // don't run past ~10pm
    }

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: chips,
      ),
    );
  }
}
