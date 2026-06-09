import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'data/isar_timetable_repository.dart';
import 'data/sample_data.dart';
import 'data/timetable_repository.dart';
import 'providers/providers.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open Isar in the app's documents directory.
  final dir = await getApplicationDocumentsDirectory();
  final isar = await IsarTimetableRepository.open(directory: dir.path);
  final TimetableRepository repository = IsarTimetableRepository(isar);

  // Load persisted timetable; seed sample data on first launch (empty db).
  var timetable = await repository.load();
  if (timetable.courses.isEmpty && timetable.slots.isEmpty) {
    timetable = buildSampleTimetable();
    await repository.replaceAll(timetable);
  }

  runApp(
    ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repository),
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
      home: const HomeScreen(),
    );
  }
}
