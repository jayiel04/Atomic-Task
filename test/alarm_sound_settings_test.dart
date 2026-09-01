import 'package:atomic_task/core/audio/alarm_sound.dart';
import 'package:atomic_task/core/audio/shared_preferences_alarm_sound_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('persists the alarm and falls back for unknown values', () async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesAlarmSoundSettings.selectedAlarmKey: 'unknown_sound',
    });
    final settings = SharedPreferencesAlarmSoundSettings();

    expect(await settings.loadSelected(), AlarmSound.defaultSound);

    await settings.saveSelected(AlarmSound.amanecerCosmico);

    final reloaded = SharedPreferencesAlarmSoundSettings();
    expect(await reloaded.loadSelected(), AlarmSound.amanecerCosmico);
  });
}
