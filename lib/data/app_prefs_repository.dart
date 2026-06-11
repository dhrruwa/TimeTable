import 'package:isar/isar.dart';

import 'isar_entities.dart';

/// Lightweight per-device state: a stable device id (used as the creator id so
/// only the creator can edit) and whether onboarding/discovery has run.
class AppPrefs {
  final String deviceId;
  final bool onboarded;
  const AppPrefs({required this.deviceId, this.onboarded = false});

  AppPrefs copyWith({String? deviceId, bool? onboarded}) => AppPrefs(
        deviceId: deviceId ?? this.deviceId,
        onboarded: onboarded ?? this.onboarded,
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
    return AppPrefs(deviceId: e.deviceId, onboarded: e.onboarded);
  }

  @override
  Future<void> save(AppPrefs prefs) async {
    await isar.writeTxn(() async {
      await isar.appPrefsEntitys.put(
        AppPrefsEntity()
          ..id = 0
          ..deviceId = prefs.deviceId
          ..onboarded = prefs.onboarded,
      );
    });
  }
}
