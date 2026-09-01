import 'package:atomic_task/core/audio/alarm_sound.dart';
import 'package:atomic_task/features/tasks/data/services/local_task_reminder_service.dart';
import 'package:atomic_task/features/tasks/domain/entities/atomic_task.dart';
import 'package:atomic_task/features/timer/data/services/local_timer_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <MethodCall>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final channel = const MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    calls.clear();
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'initialize' => true,
        'requestNotificationsPermission' => true,
        'requestExactAlarmsPermission' => true,
        'pendingNotificationRequests' => <Map<String, Object?>>[],
        _ => null,
      };
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'maps normal tasks to chime and alarm tasks to selected sound',
    () async {
      final settings = _FakeAlarmSoundSettings(AlarmSound.pulsoElectronico);
      final service = LocalTaskReminderService(
        plugin: FlutterLocalNotificationsPlugin(),
        alarmSoundSettings: settings,
      );

      await service.schedule(_task(1, TaskReminderMode.notification));
      await service.schedule(_task(2, TaskReminderMode.alarm));

      final scheduled = calls
          .where((call) => call.method == 'zonedSchedule')
          .toList();
      expect(scheduled, hasLength(2));
      final normalDetails = _platformSpecifics(scheduled[0]);
      final alarmDetails = _platformSpecifics(scheduled[1]);
      expect(normalDetails['channelId'], 'task_reminders_v3');
      expect(normalDetails['sound'], 'notification_chime_sfx');
      expect(alarmDetails['channelId'], 'task_alarms_v3_pulso_electronico');
      expect(alarmDetails['sound'], 'alarm_pulso_electronico');
    },
  );

  test('uses the selected sound for immediate timer completion', () async {
    final service = LocalTimerNotificationService(
      plugin: FlutterLocalNotificationsPlugin(),
      alarmSoundSettings: _FakeAlarmSoundSettings(AlarmSound.amanecerSuave),
    );

    await service.initialize();
    await service.showTimerCompleted(
      title: 'Temporizador terminado',
      body: 'La sesión ha finalizado.',
    );

    final shown = calls.where((call) => call.method == 'show').toList();
    expect(shown, hasLength(1));
    final details = _platformSpecifics(shown.single);
    expect(details['channelId'], 'timer_completion_v3_amanecer_suave');
    expect(details['sound'], 'alarm_amanecer_suave');
  });

  test(
    'replacing a task schedule cancels before applying the new channel',
    () async {
      final settings = _FakeAlarmSoundSettings(AlarmSound.amanecerCosmico);
      final service = LocalTaskReminderService(
        plugin: FlutterLocalNotificationsPlugin(),
        alarmSoundSettings: settings,
      );
      final task = _task(3, TaskReminderMode.alarm);

      await service.schedule(task);
      settings.selected = AlarmSound.secuenciaDigital;
      await service.schedule(task);

      final scheduled = calls
          .where((call) => call.method == 'zonedSchedule')
          .toList();
      expect(scheduled, hasLength(2));
      expect(
        _platformSpecifics(scheduled[0])['channelId'],
        'task_alarms_v3_amanecer_cosmico',
      );
      expect(
        _platformSpecifics(scheduled[1])['channelId'],
        'task_alarms_v3_secuencia_digital',
      );
      expect(calls.where((call) => call.method == 'cancel'), hasLength(2));
    },
  );

  test(
    'tasks with their own sound use it and null falls back to the global one',
    () async {
      final settings = _FakeAlarmSoundSettings(AlarmSound.secuenciaDigital);
      final service = LocalTaskReminderService(
        plugin: FlutterLocalNotificationsPlugin(),
        alarmSoundSettings: settings,
      );

      await service.schedule(
        _task(4, TaskReminderMode.alarm, soundKey: 'pulso_electronico'),
      );
      await service.schedule(_task(5, TaskReminderMode.alarm));

      final scheduled = calls
          .where((call) => call.method == 'zonedSchedule')
          .toList();
      expect(scheduled, hasLength(2));
      final ownDetails = _platformSpecifics(scheduled[0]);
      final defaultDetails = _platformSpecifics(scheduled[1]);
      expect(ownDetails['channelId'], 'task_alarms_v3_pulso_electronico');
      expect(ownDetails['sound'], 'alarm_pulso_electronico');
      expect(defaultDetails['channelId'], 'task_alarms_v3_secuencia_digital');
      expect(defaultDetails['sound'], 'alarm_secuencia_digital');
    },
  );

  test('an unknown task sound key falls back to the global sound', () async {
    final settings = _FakeAlarmSoundSettings(AlarmSound.despertarRitmico);
    final service = LocalTaskReminderService(
      plugin: FlutterLocalNotificationsPlugin(),
      alarmSoundSettings: settings,
    );

    await service.schedule(
      _task(6, TaskReminderMode.alarm, soundKey: 'sonido_desconocido'),
    );

    final scheduled = calls
        .where((call) => call.method == 'zonedSchedule')
        .toList();
    expect(scheduled, hasLength(1));
    expect(
      _platformSpecifics(scheduled.single)['channelId'],
      'task_alarms_v3_despertar_ritmico',
    );
  });

  test(
    'changing the global sound keeps own-sound tasks and updates default ones',
    () async {
      final settings = _FakeAlarmSoundSettings(AlarmSound.amanecerCosmico);
      final service = LocalTaskReminderService(
        plugin: FlutterLocalNotificationsPlugin(),
        alarmSoundSettings: settings,
      );
      final ownSoundTask = _task(
        7,
        TaskReminderMode.alarm,
        soundKey: 'pulso_electronico',
      );
      final defaultTask = _task(8, TaskReminderMode.alarm);
      final now = DateTime.now();

      await service.reconcile([ownSoundTask, defaultTask], now: now);
      calls.clear();
      settings.selected = AlarmSound.amanecerSuave;
      await service.reconcile([ownSoundTask, defaultTask], now: now);

      final scheduled = calls
          .where((call) => call.method == 'zonedSchedule')
          .toList();
      expect(scheduled, hasLength(2));
      final ownDetails = _platformSpecifics(
        scheduled.firstWhere(
          (call) =>
              _platformSpecifics(call)['channelId'] ==
              'task_alarms_v3_pulso_electronico',
        ),
      );
      expect(ownDetails['sound'], 'alarm_pulso_electronico');
      final defaultDetails = _platformSpecifics(
        scheduled.firstWhere(
          (call) =>
              _platformSpecifics(call)['channelId'] ==
              'task_alarms_v3_amanecer_suave',
        ),
      );
      expect(defaultDetails['sound'], 'alarm_amanecer_suave');
    },
  );

  test('notification mode always uses the fixed chime', () async {
    final service = LocalTaskReminderService(
      plugin: FlutterLocalNotificationsPlugin(),
      alarmSoundSettings: _FakeAlarmSoundSettings(AlarmSound.amanecerCosmico),
    );

    await service.schedule(
      _task(9, TaskReminderMode.notification, soundKey: 'pulso_electronico'),
    );

    final scheduled = calls
        .where((call) => call.method == 'zonedSchedule')
        .toList();
    expect(scheduled, hasLength(1));
    final details = _platformSpecifics(scheduled.single);
    expect(details['channelId'], 'task_reminders_v3');
    expect(details['sound'], 'notification_chime_sfx');
  });
}

Map<Object?, Object?> _platformSpecifics(MethodCall call) {
  final arguments = call.arguments as Map<Object?, Object?>;
  return arguments['platformSpecifics'] as Map<Object?, Object?>;
}

AtomicTask _task(int id, TaskReminderMode mode, {String? soundKey}) {
  final now = DateTime.now();
  return AtomicTask(
    id: id,
    title: 'Tarea $id',
    isCompleted: false,
    reminderAt: now.add(const Duration(hours: 1)),
    reminderMode: mode,
    reminderSoundKey: soundKey,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeAlarmSoundSettings implements AlarmSoundSettings {
  _FakeAlarmSoundSettings(this.selected);

  AlarmSound selected;

  @override
  Future<AlarmSound> loadSelected() async => selected;

  @override
  Future<void> saveSelected(AlarmSound sound) async {
    selected = sound;
  }
}
