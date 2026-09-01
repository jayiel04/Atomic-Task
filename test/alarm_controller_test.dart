import 'package:atomic_task/core/audio/alarm_sound.dart';
import 'package:atomic_task/core/theme/app_colors.dart';
import 'package:atomic_task/features/alarm/presentation/controllers/alarm_controller.dart';
import 'package:atomic_task/features/alarm/presentation/pages/alarm_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'uses the digital sequence by default and persists a selection',
    () async {
      final settings = _FakeAlarmSoundSettings();
      final audio = _FakeAudioService();
      var changedCalls = 0;
      final controller = AlarmController(
        settings: settings,
        audioService: audio,
        onSoundChanged: () async => changedCalls += 1,
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      expect(controller.selectedSound, AlarmSound.secuenciaDigital);

      await controller.selectSound(AlarmSound.pulsoElectronico);

      expect(controller.selectedSound, AlarmSound.pulsoElectronico);
      expect(settings.selectedSound, AlarmSound.pulsoElectronico);
      expect(changedCalls, 1);
    },
  );

  testWidgets('shows all alarms and previews the selected option', (
    tester,
  ) async {
    final settings = _FakeAlarmSoundSettings();
    final audio = _FakeAudioService();
    final controller = AlarmController(settings: settings, audioService: audio);
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AlarmView(controller: controller)),
      ),
    );

    expect(find.byKey(const Key('alarmView')), findsOneWidget);
    expect(find.byKey(const Key('selectedAlarmLabel')), findsOneWidget);
    expect(
      find.byKey(const Key('alarmOption-amanecer_cosmico')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('alarmOption-amanecer_suave')), findsOneWidget);
    expect(
      find.byKey(const Key('alarmOption-despertar_ritmico')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('alarmOption-pulso_electronico')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('alarmOption-secuencia_digital')),
      findsOneWidget,
    );

    expect(controller.previewingSound, isNull);
    expect(
      find.byIcon(Icons.play_circle_outline_rounded),
      findsNWidgets(AlarmSound.values.length),
    );

    await tester.tap(find.byKey(const Key('previewAlarm-secuencia_digital')));
    await tester.pump();
    expect(audio.previewed, [AlarmSound.secuenciaDigital]);
    expect(controller.previewingSound, AlarmSound.secuenciaDigital);
    expect(
      find.byIcon(Icons.pause_circle_outline_rounded),
      findsOneWidget,
    );
    expect(
      find.byIcon(Icons.play_circle_outline_rounded),
      findsNWidgets(AlarmSound.values.length - 1),
    );
    expect(
      find.ancestor(
        of: find.byKey(const Key('alarmOption-secuencia_digital')),
        matching: find.byWidgetPredicate(
          (widget) => widget is Material && widget.color == AppColors.primary,
        ),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('previewAlarm-secuencia_digital')));
    await tester.pump();
    expect(audio.stopCalls, 1);
    expect(controller.previewingSound, isNull);
    expect(
      find.byIcon(Icons.play_circle_outline_rounded),
      findsNWidgets(AlarmSound.values.length),
    );

    await tester.tap(find.byKey(const Key('alarmOption-amanecer_suave')));
    await tester.pump();
    expect(controller.selectedSound, AlarmSound.amanecerSuave);
  });

  test('tracks the previewing sound and toggles it off on repeat', () async {
    final settings = _FakeAlarmSoundSettings();
    final audio = _FakeAudioService();
    final controller = AlarmController(settings: settings, audioService: audio);
    addTearDown(controller.dispose);
    await controller.initialize();

    await controller.previewAlarm(AlarmSound.amanecerCosmico);
    expect(controller.previewingSound, AlarmSound.amanecerCosmico);

    await controller.previewAlarm(AlarmSound.secuenciaDigital);
    expect(controller.previewingSound, AlarmSound.secuenciaDigital);
    expect(audio.previewed, [
      AlarmSound.amanecerCosmico,
      AlarmSound.secuenciaDigital,
    ]);

    await controller.previewAlarm(AlarmSound.secuenciaDigital);
    expect(controller.previewingSound, isNull);
    expect(audio.stopCalls, 1);
  });

  test('clears the previewing state when playback completes', () async {
    final settings = _FakeAlarmSoundSettings();
    final audio = _FakeAudioService();
    final controller = AlarmController(settings: settings, audioService: audio);
    addTearDown(controller.dispose);
    await controller.initialize();

    await controller.previewAlarm(AlarmSound.pulsoElectronico);
    expect(controller.previewingSound, AlarmSound.pulsoElectronico);

    audio.completePreview();
    expect(controller.previewingSound, isNull);
  });

  test('clears the previewing state when playback fails', () async {
    final settings = _FakeAlarmSoundSettings();
    final audio = _FakeAudioService()..throwOnPreview = true;
    final controller = AlarmController(settings: settings, audioService: audio);
    addTearDown(controller.dispose);
    await controller.initialize();

    await controller.previewAlarm(AlarmSound.despertarRitmico);

    expect(controller.previewingSound, isNull);
    expect(controller.errorMessage, 'No fue posible reproducir la alarma.');
  });
}

class _FakeAlarmSoundSettings implements AlarmSoundSettings {
  AlarmSound selectedSound = AlarmSound.defaultSound;

  @override
  Future<AlarmSound> loadSelected() async => selectedSound;

  @override
  Future<void> saveSelected(AlarmSound sound) async {
    selectedSound = sound;
  }
}

class _FakeAudioService implements AppAudioService {
  final List<AlarmSound> previewed = [];
  var stopCalls = 0;
  var throwOnPreview = false;
  void Function()? onPreviewCompleted;

  @override
  Future<void> playEffect(AppAudioEffect effect) async {}

  @override
  Future<void> previewAlarm(
    AlarmSound sound, {
    void Function()? onCompleted,
  }) async {
    if (throwOnPreview) {
      throw StateError('test preview error');
    }
    onPreviewCompleted = onCompleted;
    previewed.add(sound);
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
    onPreviewCompleted = null;
  }

  void completePreview() {
    final onCompleted = onPreviewCompleted;
    onPreviewCompleted = null;
    onCompleted?.call();
  }

  @override
  Future<void> dispose() async {}
}
