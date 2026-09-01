import 'package:shared_preferences/shared_preferences.dart';

import 'alarm_sound.dart';

class SharedPreferencesAlarmSoundSettings implements AlarmSoundSettings {
  SharedPreferencesAlarmSoundSettings({
    Future<SharedPreferences> Function()? preferencesLoader,
  }) : _preferencesLoader = preferencesLoader ?? SharedPreferences.getInstance;

  static const selectedAlarmKey = 'atomic_selected_alarm_sound';

  final Future<SharedPreferences> Function() _preferencesLoader;
  Future<SharedPreferences>? _preferences;
  AlarmSound? _cachedSound;

  @override
  Future<AlarmSound> loadSelected() async {
    final cachedSound = _cachedSound;
    if (cachedSound != null) {
      return cachedSound;
    }

    final preferences = await _getPreferences();
    final sound = alarmSoundFromStorageKey(
      preferences.getString(selectedAlarmKey),
    );
    _cachedSound = sound;
    return sound;
  }

  @override
  Future<void> saveSelected(AlarmSound sound) async {
    final preferences = await _getPreferences();
    await preferences.setString(selectedAlarmKey, sound.storageKey);
    _cachedSound = sound;
  }

  Future<SharedPreferences> _getPreferences() {
    return _preferences ??= _preferencesLoader();
  }
}
