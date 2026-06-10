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

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
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
