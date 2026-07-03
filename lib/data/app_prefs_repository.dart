import 'dart:convert';

import 'package:isar_community/isar.dart';

import 'isar_entities.dart';

/// Lightweight per-device state: a stable device id (used as the creator id so
/// only the creator can edit) and whether onboarding/discovery has run.
class AppPrefs {
  final String deviceId;
  final bool onboarded;

  /// Id of the selected theme pack (see `lib/theme/theme_catalog.dart`).
  final String themeId;

  /// Community `matchKey`s the user has blocked/hidden — filtered out of
  /// discovery so objectionable/unwanted class listings disappear for them.
  final List<String> blockedKeys;

  const AppPrefs({
    required this.deviceId,
    this.onboarded = false,
    this.themeId = 'liquid_glass',
    this.blockedKeys = const [],
  });

  AppPrefs copyWith({
    String? deviceId,
    bool? onboarded,
    String? themeId,
    List<String>? blockedKeys,
  }) =>
      AppPrefs(
        deviceId: deviceId ?? this.deviceId,
        onboarded: onboarded ?? this.onboarded,
        themeId: themeId ?? this.themeId,
        blockedKeys: blockedKeys ?? this.blockedKeys,
      );
}

abstract class AppPrefsRepository {
  Future<AppPrefs?> load();
  Future<void> save(AppPrefs prefs);
}

class IsarAppPrefsRepository implements AppPrefsRepository {
  final Isar isar;
  IsarAppPrefsRepository(this.isar);

  @override
  Future<AppPrefs?> load() async {
    final e = await isar.appPrefsEntitys.get(0);
    if (e == null) return null;
    List<String> blocked = const [];
    try {
      final decoded = jsonDecode(e.blockedKeysJson);
      if (decoded is List) blocked = decoded.map((v) => v.toString()).toList();
    } catch (_) {/* keep empty on malformed */}
    return AppPrefs(
      deviceId: e.deviceId,
      onboarded: e.onboarded,
      themeId: e.themeId,
      blockedKeys: blocked,
    );
  }

  @override
  Future<void> save(AppPrefs prefs) async {
    await isar.writeTxn(() async {
      await isar.appPrefsEntitys.put(
        AppPrefsEntity()
          ..id = 0
          ..deviceId = prefs.deviceId
          ..onboarded = prefs.onboarded
          ..themeId = prefs.themeId
          ..blockedKeysJson = jsonEncode(prefs.blockedKeys),
      );
    });
  }
}
