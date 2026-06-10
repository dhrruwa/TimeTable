import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// App theme mode. Defaults to following the system; toggled from the UI.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Whether the weekly grid includes Saturday's later activities expanded.
final showSundayProvider = StateProvider<bool>((ref) => false);
