import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../../domain/services/timer_notification_service.dart';

class LocalTimerNotificationService implements TimerNotificationService {
  LocalTimerNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  // The scheduled completion reuses the running notification ID so Android
  // replaces the countdown instead of leaving it visible at 00:00.
  static const _timerNotificationId = 1001;

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void>? _initialization;
  bool _isInitialized = false;
  bool _permissionRequested = false;
  bool _permissionGranted = true;
  int _operationVersion = 0;

  @override
  Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      timezone_data.initializeTimeZones();

      final initialized = await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_timer'),
          iOS: IOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          macOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          linux: LinuxInitializationSettings(
            defaultActionName: 'Abrir temporizador',
          ),
          windows: WindowsInitializationSettings(
            appName: 'Tareas Atomicas',
            appUserModelId: 'AtomicTask.Timer',
            guid: 'F8F7309A-E99A-4F92-91DF-40764DEDD5F2',
          ),
          web: WebInitializationSettings(),
        ),
      );

      _isInitialized = initialized ?? true;
    } catch (error, stackTrace) {
      _reportError('inicializar', error, stackTrace);
    }
  }

  @override
  Future<void> showRunningTimer({
    required String timerName,
    required int remainingSeconds,
    required DateTime endsAt,
    required String completionTitle,
    required String completionBody,
  }) async {
    final operationVersion = ++_operationVersion;

    if (!_isInitialized) {
      await initialize();
    }
    if (!_isCurrent(operationVersion) ||
        !_isInitialized ||
        !await _requestPermission() ||
        !_isCurrent(operationVersion)) {
      return;
    }

    await _cancelNotifications();
    if (!_isCurrent(operationVersion)) {
      return;
    }

    await _runSafely('mostrar el tiempo restante', () {
      return _plugin.show(
        id: _timerNotificationId,
        title: '$timerName en curso',
        body: 'Tiempo restante: ${_formatDuration(remainingSeconds)}',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'active_timer',
            'Temporizador en curso',
            channelDescription: 'Muestra el tiempo restante del temporizador.',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            onlyAlertOnce: true,
            playSound: false,
            enableVibration: false,
            showWhen: true,
            when: endsAt.millisecondsSinceEpoch,
            usesChronometer: true,
            chronometerCountDown: true,
          ),
          iOS: const DarwinNotificationDetails(presentSound: false),
          macOS: const DarwinNotificationDetails(presentSound: false),
          linux: const LinuxNotificationDetails(),
          windows: const WindowsNotificationDetails(),
          web: const WebNotificationDetails(requireInteraction: true),
        ),
        payload: 'running_timer',
      );
    });

    if (_supportsScheduling && _isCurrent(operationVersion)) {
      await _scheduleCompletion(
        endsAt: endsAt,
        title: completionTitle,
        body: completionBody,
      );
    }
  }

  Future<void> _scheduleCompletion({
    required DateTime endsAt,
    required String title,
    required String body,
  }) async {
    final scheduledDate = timezone.TZDateTime.from(
      endsAt.toUtc(),
      timezone.UTC,
    );

    Future<void> schedule(AndroidScheduleMode androidScheduleMode) {
      return _plugin.zonedSchedule(
        id: _timerNotificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'timer_completion',
            'Temporizadores completados',
            channelDescription: 'Avisa cuando un temporizador ha finalizado.',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
          windows: WindowsNotificationDetails(),
        ),
        androidScheduleMode: androidScheduleMode,
        payload: 'completed_timer',
      );
    }

    try {
      await schedule(AndroidScheduleMode.exactAllowWhileIdle);
    } catch (error, stackTrace) {
      _reportError('programar la finalización exacta', error, stackTrace);

      // Some Android devices or stores do not grant exact-alarm access. An
      // inexact alarm is preferable to silently losing the completion alert.
      await _runSafely(
        'programar la finalización alternativa',
        () => schedule(AndroidScheduleMode.inexactAllowWhileIdle),
      );
    }
  }

  @override
  Future<void> cancelTimerNotifications() async {
    _operationVersion += 1;

    if (!_isInitialized) {
      return;
    }

    await _cancelNotifications();
  }

  Future<void> _cancelNotifications() async {
    await _runSafely('cancelar la notificación', () async {
      await _plugin.cancel(id: _timerNotificationId);
    });
  }

  @override
  Future<void> showTimerCompleted({
    required String title,
    required String body,
  }) async {
    final operationVersion = ++_operationVersion;

    if (!_isInitialized) {
      await initialize();
    }
    if (!_isCurrent(operationVersion) ||
        !_isInitialized ||
        !_permissionGranted) {
      return;
    }

    await _cancelNotifications();
    if (!_isCurrent(operationVersion)) {
      return;
    }

    await _runSafely('mostrar la finalizacion', () {
      return _plugin.show(
        id: _timerNotificationId,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'timer_completion',
            'Temporizadores completados',
            channelDescription: 'Avisa cuando un temporizador ha finalizado.',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
          linux: LinuxNotificationDetails(),
          windows: WindowsNotificationDetails(),
          web: WebNotificationDetails(requireInteraction: true),
        ),
        payload: 'completed_timer',
      );
    });
  }

  Future<bool> _requestPermission() async {
    if (_permissionRequested) {
      return _permissionGranted;
    }

    _permissionRequested = true;

    try {
      final bool? granted;

      if (kIsWeb) {
        granted = await _plugin
            .resolvePlatformSpecificImplementation<
              WebFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();
      } else {
        granted = switch (defaultTargetPlatform) {
          TargetPlatform.android =>
            await _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission(),
          TargetPlatform.iOS =>
            await _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true),
          TargetPlatform.macOS =>
            await _plugin
                .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true),
          _ => true,
        };
      }

      _permissionGranted = granted ?? true;
    } catch (error, stackTrace) {
      _permissionGranted = false;
      _reportError('solicitar permisos', error, stackTrace);
    }

    return _permissionGranted;
  }

  bool get _supportsScheduling {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => true,
      _ => false,
    };
  }

  bool _isCurrent(int operationVersion) {
    return operationVersion == _operationVersion;
  }

  Future<void> _runSafely(
    String operation,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error, stackTrace) {
      _reportError(operation, error, stackTrace);
    }
  }

  void _reportError(String operation, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('No fue posible $operation de notificaciones: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return [
      hours,
      minutes,
      seconds,
    ].map((value) => value.toString().padLeft(2, '0')).join(':');
  }
}
