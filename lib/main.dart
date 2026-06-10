import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'data/period_repository.dart';
import 'data/sample_week.dart';
import 'providers/providers.dart';
import 'providers/widget_providers.dart';
import 'screens/home_screen.dart';
import 'theme.dart';
import 'widgetkit/home_widget_service.dart';
import 'widgetkit/home_widget_updater.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Home-screen widget bridge (App Group on iOS, etc.).
  await HomeWidgetService.init();

  // Open Isar and load the unified timetable; seed sample data on first launch.
  final dir = await getApplicationDocumentsDirectory();
  final isar = await IsarPeriodRepository.open(directory: dir.path);
  final repository = IsarPeriodRepository(isar);

  var timetable = await repository.load();
  if (timetable == null) {
    timetable = buildSampleTimetable();
    await repository.save(timetable);
  }

  runApp(
    ProviderScope(
      overrides: [
        periodRepositoryProvider.overrideWithValue(repository),
        initialTimetableProvider.overrideWithValue(timetable),
      ],
      child: const TimetableApp(),
    ),
  );
}

class TimetableApp extends ConsumerWidget {
  const TimetableApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Timetable',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const HomeWidgetUpdater(child: HomeScreen()),
    );
  }
}
