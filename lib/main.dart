import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'data/app_prefs_repository.dart';
import 'data/community_repository.dart';
import 'data/period_repository.dart';
import 'data/sample_community.dart';
import 'data/sample_week.dart';
import 'providers/community_providers.dart';
import 'providers/providers.dart';
import 'providers/widget_providers.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme.dart';
import 'widgetkit/deep_link_handler.dart';
import 'widgetkit/home_widget_service.dart';
import 'widgetkit/home_widget_updater.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Home-screen widget bridge (App Group on iOS, etc.).
  await HomeWidgetService.init();

  // Open Isar (timetable + community + prefs collections).
  final dir = await getApplicationDocumentsDirectory();
  final isar = await IsarPeriodRepository.open(directory: dir.path);
  final repository = IsarPeriodRepository(isar);
  final community = IsarCommunityRepository(isar);
  final prefsRepo = IsarAppPrefsRepository(isar);

  // Seed the community DB so discovery has something to find on first run.
  await seedCommunityIfEmpty(isar);

  // Device identity (stable creator id) + onboarding state.
  var prefs = await prefsRepo.load();
  if (prefs == null) {
    prefs = AppPrefs(deviceId: const Uuid().v4(), onboarded: false);
    await prefsRepo.save(prefs);
  }

  // Load the timetable; seed a starter one on first launch.
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
        communityRepositoryProvider.overrideWithValue(community),
        appPrefsRepositoryProvider.overrideWithValue(prefsRepo),
        initialAppPrefsProvider.overrideWithValue(prefs),
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
    final onboarded = ref.watch(appPrefsProvider).onboarded;
    return MaterialApp(
      title: 'Timetable',
      debugShowCheckedModeBanner: false,
      navigatorKey: DeepLinkHandler.navigatorKey,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: DeepLinkHandler(
        child: onboarded
            ? const HomeWidgetUpdater(child: HomeScreen())
            : const OnboardingScreen(),
      ),
    );
  }
}
