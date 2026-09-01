enum AlarmSound {
  amanecerCosmico(
    storageKey: 'amanecer_cosmico',
    label: 'Amanecer Cósmico',
    assetPath: 'audio/alarmas/Amanecer Cósmico.mp3',
    androidResourceName: 'alarm_amanecer_cosmico',
  ),
  amanecerSuave(
    storageKey: 'amanecer_suave',
    label: 'Amanecer Suave',
    assetPath: 'audio/alarmas/Amanecer Suave.mp3',
    androidResourceName: 'alarm_amanecer_suave',
  ),
  despertarRitmico(
    storageKey: 'despertar_ritmico',
    label: 'Despertar Rítmico',
    assetPath: 'audio/alarmas/Despertar Rítmico.mp3',
    androidResourceName: 'alarm_despertar_ritmico',
  ),
  pulsoElectronico(
    storageKey: 'pulso_electronico',
    label: 'Pulso Electrónico',
    assetPath: 'audio/alarmas/Pulso Electrónico.mp3',
    androidResourceName: 'alarm_pulso_electronico',
  ),
  secuenciaDigital(
    storageKey: 'secuencia_digital',
    label: 'Secuencia Digital',
    assetPath: 'audio/alarmas/Secuencia Digital.mp3',
    androidResourceName: 'alarm_secuencia_digital',
  );

  const AlarmSound({
    required this.storageKey,
    required this.label,
    required this.assetPath,
    required this.androidResourceName,
  });

  final String storageKey;
  final String label;
  final String assetPath;
  final String androidResourceName;

  static const defaultSound = AlarmSound.secuenciaDigital;
}

AlarmSound alarmSoundFromStorageKey(String? storageKey) {
  for (final sound in AlarmSound.values) {
    if (sound.storageKey == storageKey) {
      return sound;
    }
  }
  return AlarmSound.defaultSound;
}

enum AppAudioEffect {
  taskCreated(assetPath: 'audio/efectos/ui_click_sfx.wav'),
  taskDeleted(assetPath: 'audio/efectos/eliminar_archivo_sfx.wav');

  const AppAudioEffect({required this.assetPath});

  final String assetPath;
}

abstract interface class AlarmSoundSettings {
  Future<AlarmSound> loadSelected();

  Future<void> saveSelected(AlarmSound sound);
}

abstract interface class AppAudioService {
  Future<void> playEffect(AppAudioEffect effect);

  Future<void> previewAlarm(AlarmSound sound, {void Function()? onCompleted});

  Future<void> stop();

  Future<void> dispose();
}
