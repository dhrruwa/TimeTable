import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_prefs_repository.dart';
import '../data/community_repository.dart';

/// Bound in `main()` via overrides.
final communityRepositoryProvider = Provider<CommunityRepository>(
  (ref) => throw UnimplementedError('communityRepositoryProvider override'),
);
final appPrefsRepositoryProvider = Provider<AppPrefsRepository>(
  (ref) => throw UnimplementedError('appPrefsRepositoryProvider override'),
);
final initialAppPrefsProvider = Provider<AppPrefs>(
  (ref) => throw UnimplementedError('initialAppPrefsProvider override'),
);

/// Current per-device state (deviceId + onboarding). Persists on change.
final appPrefsProvider =
    StateNotifierProvider<AppPrefsNotifier, AppPrefs>((ref) {
  return AppPrefsNotifier(
    ref.watch(appPrefsRepositoryProvider),
    ref.watch(initialAppPrefsProvider),
  );
});

class AppPrefsNotifier extends StateNotifier<AppPrefs> {
  final AppPrefsRepository _repo;
  AppPrefsNotifier(this._repo, AppPrefs initial) : super(initial);

  Future<void> markOnboarded() async {
    state = state.copyWith(onboarded: true);
    await _repo.save(state);
  }

  /// Apply and persist a theme pack selection.
  Future<void> setTheme(String themeId) async {
    if (state.themeId == themeId) return;
    state = state.copyWith(themeId: themeId);
    await _repo.save(state);
  }

  /// Whether a community class has been blocked/hidden by this user.
  bool isBlocked(String matchKey) => state.blockedKeys.contains(matchKey);

  /// Block/hide a community class so it no longer appears in discovery for this
  /// user. Persists locally and (best-effort) reports it to the backend.
  Future<void> blockKey(String matchKey) async {
    if (state.blockedKeys.contains(matchKey)) return;
    state = state.copyWith(blockedKeys: [...state.blockedKeys, matchKey]);
    await _repo.save(state);
  }
}
