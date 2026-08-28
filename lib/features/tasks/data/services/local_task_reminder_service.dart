import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../../domain/entities/atomic_task.dart';
import '../../domain/services/task_reminder_service.dart';

/// Implementación local de recordatorios de tareas.
///
/// `reminderAt` pertenece al modelo de dominio y se interpreta como una fecha
/// absoluta en la zona local del dispositivo.
class LocalTaskReminderService implements TaskReminderService {
  LocalTaskReminderService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  // Este rango está separado del identificador 1001 reservado por el
  // temporizador. El ID se deriva del ID persistente de la tarea, por lo que
  // reprogramar una tarea reemplaza su recordatorio en lugar de duplicarlo.
  static const int _taskReminderIdStart = 200000000;
  static const int _taskReminderIdRange = 1000000;
  static const int _taskReminderIdEnd =
      _taskReminderIdStart + _taskReminderIdRange;

  static const String _channelId = 'task_reminders';
  static const String _channelName = 'Recordatorios de tareas';
  static const String _channelDescription =
      'Avisa cuando llega el momento de realizar una tarea.';

  static const String _alarmChannelId = 'task_alarms';
  static const String _alarmChannelName = 'Alarmas de tareas';
  static const String _alarmChannelDescription =
      'Suena una alarma cuando inicia una tarea.';

  // FLAG_INSISTENT de Android: repite el sonido hasta descartar la alarma.
  static const int _insistentFlag = 32;

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void>? _initialization;
  bool _isInitialized = false;
  bool _permissionRequested = false;
  bool _permissionGranted = true;
  bool _timeZonesInitialized = false;
  int _operationVersion = 0;

  @override
  Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (!_timeZonesInitialized) {
        timezone_data.initializeTimeZones();
        _timeZonesInitialized = true;
      }

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
          linux: LinuxInitializationSettings(defaultActionName: 'Abrir tareas'),
          windows: WindowsInitializationSettings(
            appName: 'Tareas Atomicas',
            appUserModelId: 'AtomicTask.Timer',
            guid: 'F8F7309A-E99A-4F92-91DF-40764DEDD5F2',
          ),
          web: WebInitializationSettings(),
        ),
      );

      // Algunas versiones del plugin devuelven null cuando la inicialización
      // terminó correctamente sin informar un booleano.
      _isInitialized = initialized ?? true;
    } catch (error, stackTrace) {
      _reportError('inicializar', error, stackTrace);
    }
  }

  @override
  Future<void> schedule(AtomicTask task) async {
    final operationVersion = ++_operationVersion;

    if (!_supportsScheduling) {
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }
    if (!_isCurrent(operationVersion) || !_isInitialized) {
      return;
    }

    final reminderAt = task.reminderAt;
    if (reminderAt == null ||
        !_isSchedulable(task, reminderAt, DateTime.now())) {
      await _cancelNotification(_notificationIdForTask(task));
      return;
    }

    // No cancelamos el ID antes de pedir permiso: si el usuario lo deniega,
    // una programación válida existente no se pierde innecesariamente. El
    // plugin reemplaza una programación anterior cuando conserva el mismo ID.
    if (!_isCurrent(operationVersion)) {
      return;
    }
    if (!await _requestPermission()) {
      throw const TaskReminderPermissionDeniedException();
    }
    if (!_isCurrent(operationVersion)) {
      return;
    }

    await _scheduleTask(
      task: task,
      reminderAt: reminderAt,
      operationVersion: operationVersion,
    );
  }

  @override
  Future<void> cancel(AtomicTask task) async {
    final operationVersion = ++_operationVersion;

    if (!_supportsScheduling) {
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }
    if (!_isCurrent(operationVersion) || !_isInitialized) {
      return;
    }

    await _cancelNotification(_notificationIdForTask(task));
  }

  @override
  Future<void> reconcile(Iterable<AtomicTask> tasks, {DateTime? now}) async {
    final operationVersion = ++_operationVersion;

    if (!_supportsScheduling) {
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }
    if (!_isCurrent(operationVersion) || !_isInitialized) {
      return;
    }

    final referenceTime = now ?? DateTime.now();
    final candidates = <_TaskReminderCandidate>[];
    final desiredIds = <int>{};
    final knownObsoleteIds = <int>{};

    for (final task in tasks) {
      final reminderAt = task.reminderAt;
      final notificationId = _notificationIdForTask(task);

      if (_isSchedulable(task, reminderAt, referenceTime)) {
        desiredIds.add(notificationId);
        candidates.add(
          _TaskReminderCandidate(
            task: task,
            reminderAt: reminderAt!,
            notificationId: notificationId,
          ),
        );
      } else {
        // También cancelamos los IDs de las tareas recibidas que ya no son
        // válidas, aunque el plugin no los reporte como pendientes todavía.
        knownObsoleteIds.add(notificationId);
      }
    }

    await _cancelObsoleteNotifications(
      desiredIds: desiredIds,
      knownObsoleteIds: knownObsoleteIds,
      operationVersion: operationVersion,
    );
    if (!_isCurrent(operationVersion) || candidates.isEmpty) {
      return;
    }

    if (!_isCurrent(operationVersion)) {
      return;
    }
    if (!await _requestPermission()) {
      throw const TaskReminderPermissionDeniedException();
    }
    if (!_isCurrent(operationVersion)) {
      return;
    }

    for (final candidate in candidates) {
      if (!_isCurrent(operationVersion)) {
        return;
      }

      await _scheduleTask(
        task: candidate.task,
        reminderAt: candidate.reminderAt,
        operationVersion: operationVersion,
        notificationId: candidate.notificationId,
      );
    }
  }

  Future<void> _scheduleTask({
    required AtomicTask task,
    required DateTime reminderAt,
    required int operationVersion,
    int? notificationId,
  }) async {
    if (!_isCurrent(operationVersion)) {
      return;
    }

    final id = notificationId ?? _notificationIdForTask(task);
    final scheduledDate = timezone.TZDateTime.from(reminderAt, timezone.local);
    final notificationDetails = _notificationDetailsFor(task);

    Future<void> schedule(AndroidScheduleMode androidScheduleMode) {
      return _plugin.zonedSchedule(
        id: id,
        title: task.title,
        body: 'Es hora de realizar esta tarea.',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: androidScheduleMode,
        payload: 'task_reminder:$id',
      );
    }

    try {
      await schedule(AndroidScheduleMode.exactAllowWhileIdle);
    } catch (error, stackTrace) {
      _reportError('programar el recordatorio exacto', error, stackTrace);

      // El acceso a alarmas exactas puede no estar concedido en Android. La
      // alternativa inexacta conserva el recordatorio sin perder la tarea.
      await _runSafely(
        'programar el recordatorio alternativo',
        () => schedule(AndroidScheduleMode.inexactAllowWhileIdle),
      );
    }
  }

  NotificationDetails _notificationDetailsFor(AtomicTask task) {
    final isAlarm = task.reminderMode == TaskReminderMode.alarm;

    final androidDetails = isAlarm
        ? AndroidNotificationDetails(
            _alarmChannelId,
            _alarmChannelName,
            channelDescription: _alarmChannelDescription,
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.alarm,
            fullScreenIntent: true,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound('task_alarm'),
            audioAttributesUsage: AudioAttributesUsage.alarm,
            enableVibration: true,
            additionalFlags: Int32List.fromList(<int>[_insistentFlag]),
          )
        : AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          );

    return NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
      windows: const WindowsNotificationDetails(),
    );
  }

  Future<void> _cancelObsoleteNotifications({
    required Set<int> desiredIds,
    required Set<int> knownObsoleteIds,
    required int operationVersion,
  }) async {
    final idsToCancel = <int>{
      ...knownObsoleteIds.where(_isTaskReminderNotificationId),
    };

    try {
      final pending = await _plugin.pendingNotificationRequests();
      idsToCancel.addAll(
        pending
            .map((request) => request.id)
            .where(_isTaskReminderNotificationId)
            .where((id) => !desiredIds.contains(id)),
      );
    } catch (error, stackTrace) {
      _reportError('consultar recordatorios pendientes', error, stackTrace);
    }

    for (final id in idsToCancel) {
      if (!_isCurrent(operationVersion)) {
        return;
      }
      await _cancelNotification(id);
    }
  }

  Future<bool> _requestPermission() async {
    if (_permissionRequested) {
      return _permissionGranted;
    }

    // Se marca antes de llamar al plugin para que una excepción tampoco
    // provoque solicitudes repetidas en cada sincronización.
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

      // null significa que la plataforma no expuso un resultado explícito;
      // el plugin de temporizador trata ese caso como permitido igualmente.
      _permissionGranted = granted ?? true;
    } catch (error, stackTrace) {
      _permissionGranted = false;
      _reportError('solicitar permisos', error, stackTrace);
    }

    return _permissionGranted;
  }

  Future<void> _cancelNotification(int id) {
    return _runSafely('cancelar el recordatorio', () => _plugin.cancel(id: id));
  }

  bool _isSchedulable(AtomicTask task, DateTime? reminderAt, DateTime now) {
    if (task.isCompleted || reminderAt == null || !reminderAt.isAfter(now)) {
      return false;
    }

    final recurrenceRule = task.recurrenceRule;
    return recurrenceRule == null || recurrenceRule.isActive;
  }

  int _notificationIdForTask(AtomicTask task) {
    return _notificationIdForTaskId(task.id);
  }

  int _notificationIdForTaskId(int taskId) {
    final remainder = taskId.remainder(_taskReminderIdRange);
    final normalized = remainder < 0
        ? remainder + _taskReminderIdRange
        : remainder;
    return _taskReminderIdStart + normalized;
  }

  bool _isTaskReminderNotificationId(int id) {
    return id >= _taskReminderIdStart && id < _taskReminderIdEnd;
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
      debugPrint('No fue posible $operation de recordatorios: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

class _TaskReminderCandidate {
  const _TaskReminderCandidate({
    required this.task,
    required this.reminderAt,
    required this.notificationId,
  });

  final AtomicTask task;
  final DateTime reminderAt;
  final int notificationId;
}
