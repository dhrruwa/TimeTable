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
import 'theme/theme_catalog.dart';
import 'theme/wallpaper_packs.dart';
import 'widgets/weather/weather_style.dart';
import 'widgetkit/deep_link_handler.dart';
import 'widgetkit/home_widget_service.dart';
import 'widgetkit/home_widget_updater.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Home-screen widget bridge (App Group on iOS, etc.).
  await HomeWidgetService.init();

  // Load the wallpaper manifest (theme-pack background images, if generated).
  await WallpaperPacks.load();

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
    final theme = ref.watch(activeThemeProvider);
    final onboarded = ref.watch(appPrefsProvider).onboarded;

    // Keep the home-screen-widget style hub in sync so any in-app widget
    // previews render with the active pack immediately.
    Wx.active = theme;

    // The default pack still honors the user's light/dark/system choice; the
    // vivid packs are designed dark-only, so pin them to dark.
    final effectiveMode =
        theme.id == kDefaultThemeId ? themeMode : ThemeMode.dark;

    return MaterialApp(
      title: 'Timetable',
      debugShowCheckedModeBanner: false,
      navigatorKey: DeepLinkHandler.navigatorKey,
      theme: AppTheme.light(theme),
      darkTheme: AppTheme.dark(theme),
      themeMode: effectiveMode,
      home: DeepLinkHandler(
        child: _ThemeMorph(
          themeId: theme.id,
          child: onboarded
              ? const HomeWidgetUpdater(child: HomeScreen())
              : const OnboardingScreen(),
        ),
      ),
    );
  }
}

/// Plays a brief fade + scale "morph" whenever the active theme id changes,
/// without rebuilding [child] (so navigation / tab state is preserved).
class _ThemeMorph extends StatefulWidget {
  final String themeId;
  final Widget child;
  const _ThemeMorph({required this.themeId, required this.child});

  @override
  State<_ThemeMorph> createState() => _ThemeMorphState();
}

class _ThemeMorphState extends State<_ThemeMorph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: 1,
  );

  @override
  void didUpdateWidget(_ThemeMorph old) {
    super.didUpdateWidget(old);
    if (old.themeId != widget.themeId) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: curve,
      child: widget.child,
      builder: (_, child) {
        final t = curve.value; // 0 -> 1
        return Opacity(
          opacity: 0.3 + 0.7 * t,
          child: Transform.scale(scale: 0.98 + 0.02 * t, child: child),
        );
      },
    );
  }
}
