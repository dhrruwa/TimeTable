import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/timetable_import_service.dart';
import '../theme/theme_catalog.dart';
import '../theme/theme_model.dart';
import 'community_providers.dart';

/// Ticks once a minute (and immediately on subscribe) so "now / next / %" UI
/// stays current without the user refreshing.
final clockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now());
});

/// The current wall-clock time, defaulting to now before the first tick.
final nowProvider = Provider<DateTime>(
  (ref) => ref.watch(clockProvider).value ?? DateTime.now(),
);

/// Ticks every second — used only by the live countdown on the Today hero, so
/// the cost is bounded to when that screen is visible.
final secondClockProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});

/// App theme mode. Defaults to following the system; toggled from the UI.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// The active [ThemeModel] every render target reads from. The in-app theme
/// picker was removed, so the app always uses the default look.
final activeThemeProvider =
    Provider<ThemeModel>((ref) => themeById(kDefaultThemeId));

/// Whether the weekly grid includes Saturday's later activities expanded.
final showSundayProvider = StateProvider<bool>((ref) => false);

/// Backend proxy for AI timetable import. Disposed with the provider container.
final timetableImportServiceProvider = Provider<TimetableImportService>((ref) {
  final service = TimetableImportService();
  ref.onDispose(service.dispose);
  return service;
});
