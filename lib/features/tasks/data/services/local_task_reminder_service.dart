// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../../../../core/audio/alarm_sound.dart';
import '../../domain/entities/atomic_task.dart';
import '../../domain/services/recurrence_calculator.dart';
import '../../domain/services/recurrence_generation_policy.dart';
import '../../domain/services/task_reminder_service.dart';

/// Implementación local de recordatorios de tareas.
///
/// `reminderAt` pertenece al modelo de dominio y se interpreta como una fecha
/// absoluta en la zona local del dispositivo.
class LocalTaskReminderService implements TaskReminderService {
  // Ventana de ocurrencias recurrentes que se programan por adelantado. Con
  // esto la alarma de la siguiente ocurrencia suena aunque la app esté
  // cerrada; al reabrir, `reconcile` cancela las que ya no aplican.
  static const int _recurrenceAheadDays = 60;
  static const int _maxAheadOccurrences = 10;

  LocalTaskReminderService({
    FlutterLocalNotificationsPlugin? plugin,
    RecurrenceGenerationPolicy? recurrencePolicy,
    AlarmSoundSettings? alarmSoundSettings,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _recurrencePolicy =
           recurrencePolicy ??
           const RecurrenceGenerationPolicy(RecurrenceCalculator()),
       _alarmSoundSettings = alarmSoundSettings;

  // Este rango está separado del identificador 1001 reservado por el
  // temporizador. El ID se deriva del ID persistente de la tarea, por lo que
  // reprogramar una tarea reemplaza su recordatorio en lugar de duplicarlo.
  static const int _taskReminderIdStart = 200000000;
  static const int _taskReminderIdRange = 1000000;
  static const int _taskReminderIdEnd =
      _taskReminderIdStart + _taskReminderIdRange;

  static const String _channelId = 'task_reminders_v3';
  static const String _channelName = 'Recordatorios de tareas';
  static const String _channelDescription =
      'Avisa cuando llega el momento de realizar una tarea.';

  static const String _alarmChannelIdPrefix = 'task_alarms_v3_';

  // FLAG_INSISTENT de Android: repite el sonido hasta descartar la alarma.
  static const int _insistentFlag = 32;

  final FlutterLocalNotificationsPlugin _plugin;
  final RecurrenceGenerationPolicy _recurrencePolicy;
  final AlarmSoundSettings? _alarmSoundSettings;

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
    await _ensureExactAlarmPermission();

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

    await _cancelNotification(
      _schedulingId(task, task.reminderAt ?? DateTime.now()),
    );
    await _cancelRecurringAhead(task, operationVersion);
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
        if (_isRecurring(task) && reminderAt != null) {
          for (final occurrence in _upcomingOccurrenceReminders(
            task,
            reminderAt,
          )) {
            desiredIds.add(_occurrenceNotificationId(task.id, occurrence));
          }
        }
        candidates.add(
          _TaskReminderCandidate(
            task: task,
            reminderAt: reminderAt!,
            notificationId: _schedulingId(task, reminderAt),
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
    await _ensureExactAlarmPermission();

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

    final id = notificationId ?? _schedulingId(task, reminderAt);
    await _zonedScheduleNotification(
      id: id,
      task: task,
      reminderAt: reminderAt,
      operationVersion: operationVersion,
    );

    // Para tareas recurrentes programamos por adelantado las próximas
    // ocurrencias, de modo que suenen aunque la app permanezca cerrada.
    await _scheduleRecurringAhead(task, reminderAt, operationVersion);
  }

  Future<void> _zonedScheduleNotification({
    required int id,
    required AtomicTask task,
    required DateTime reminderAt,
    required int operationVersion,
  }) async {
    if (!_isCurrent(operationVersion)) {
      return;
    }

    // Android conserva el canal asociado a una notificación. Cancelar justo
    // antes de reprogramar permite aplicar un canal nuevo cuando cambió el
    // sonido elegido, sin perder la protección de no cancelar antes de pedir
    // permisos.
    await _cancelNotification(id);
    final scheduledDate = timezone.TZDateTime.from(reminderAt, timezone.local);
    final notificationDetails = await _notificationDetailsFor(task);

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

  bool _isRecurring(AtomicTask task) =>
      task.recurrenceRule != null && task.occurrenceDate != null;

  // ID que se usa para programar/cancelar el recordatorio de una tarea. En las
  // recurrentes se deriva de la fecha de la ocurrencia para que la ocurrencia
  // actual y las programadas por adelantado compartan un ID estable y no se
  // dupliquen ni se cancelen entre sí.
  int _schedulingId(AtomicTask task, DateTime reminderAt) {
    if (_isRecurring(task) && task.reminderAt != null) {
      return _occurrenceNotificationId(task.id, reminderAt);
    }
    return _notificationIdForTask(task);
  }

  // Recordatorios (ocurrencia actual + siguientes) que deben quedar activos
  // para una tarea recurrente, dentro de la ventana programada por adelantado.
  Iterable<DateTime> _upcomingOccurrenceReminders(
    AtomicTask task,
    DateTime currentReminderAt,
  ) {
    final rule = task.recurrenceRule;
    final occurrenceDate = task.occurrenceDate;
    if (rule == null || !rule.isActive || occurrenceDate == null) {
      return const <DateTime>[];
    }

    final minutes = currentReminderAt.hour * 60 + currentReminderAt.minute;
    final horizon = currentReminderAt.add(
      const Duration(days: _recurrenceAheadDays),
    );

    final reminders = <DateTime>[currentReminderAt];
    var cursor = occurrenceDate;
    var generated = 0;
    while (generated < _maxAheadOccurrences) {
      final next = _recurrencePolicy.nextAfter(rule, cursor);
      if (next == null) {
        break;
      }
      cursor = next;
      final reminder = DateTime(
        next.year,
        next.month,
        next.day,
        minutes ~/ 60,
        minutes % 60,
      );
      if (reminder.isAfter(horizon)) {
        break;
      }
      reminders.add(reminder);
      generated++;
    }
    return reminders;
  }

  Future<void> _scheduleRecurringAhead(
    AtomicTask task,
    DateTime currentReminderAt,
    int operationVersion,
  ) async {
    if (!_isRecurring(task) || !_isCurrent(operationVersion)) {
      return;
    }

    for (final reminder in _upcomingOccurrenceReminders(
      task,
      currentReminderAt,
    )) {
      if (!_isCurrent(operationVersion)) {
        return;
      }
      // La ocurrencia actual ya fue programada por `_scheduleTask`.
      if (reminder == currentReminderAt) {
        continue;
      }
      await _zonedScheduleNotification(
        id: _occurrenceNotificationId(task.id, reminder),
        task: task,
        reminderAt: reminder,
        operationVersion: operationVersion,
      );
    }
  }

  Future<void> _cancelRecurringAhead(
    AtomicTask task,
    int operationVersion,
  ) async {
    final currentReminder = task.reminderAt;
    if (!_isRecurring(task) ||
        currentReminder == null ||
        !_isCurrent(operationVersion)) {
      return;
    }

    for (final reminder in _upcomingOccurrenceReminders(
      task,
      currentReminder,
    )) {
      if (!_isCurrent(operationVersion)) {
        return;
      }
      await _cancelNotification(_occurrenceNotificationId(task.id, reminder));
    }
  }

  int _occurrenceNotificationId(int taskId, DateTime occurrenceDate) {
    // Identificador determinístico para cada (tarea, ocurrencia) que permanece
    // dentro del rango reservado de recordatorios de tareas.
    final minutes = occurrenceDate.millisecondsSinceEpoch ~/ 60000;
    final combined = ((taskId * 2654435761) ^ minutes) & 0x7fffffff;
    final remainder = combined % _taskReminderIdRange;
    return _taskReminderIdStart + remainder;
  }

  Future<NotificationDetails> _notificationDetailsFor(AtomicTask task) async {
    final isAlarm = task.reminderMode == TaskReminderMode.alarm;
    final alarmSound = isAlarm ? await _resolveAlarmSound(task) : null;

    final androidDetails = isAlarm
        ? AndroidNotificationDetails(
            '$_alarmChannelIdPrefix${alarmSound!.storageKey}',
            'Alarmas de tareas · ${alarmSound.label}',
            channelDescription: 'Suena una alarma cuando inicia una tarea.',
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.alarm,
            fullScreenIntent: true,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(
              alarmSound.androidResourceName,
            ),
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
            sound: const RawResourceAndroidNotificationSound(
              'notification_chime_sfx',
            ),
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

  // El sonido propio de la tarea tiene prioridad; sin sonido propio (o con
  // una clave desconocida para el catálogo actual) se usa el sonido global.
  Future<AlarmSound> _resolveAlarmSound(AtomicTask task) async {
    final ownKey = task.reminderSoundKey;
    if (ownKey != null) {
      for (final sound in AlarmSound.values) {
        if (sound.storageKey == ownKey) {
          return sound;
        }
      }
    }
    return _loadSelectedAlarm();
  }

  Future<AlarmSound> _loadSelectedAlarm() async {
    try {
      return await (_alarmSoundSettings?.loadSelected() ??
          Future<AlarmSound>.value(AlarmSound.defaultSound));
    } catch (error, stackTrace) {
      _reportError('cargar el sonido de alarma', error, stackTrace);
      return AlarmSound.defaultSound;
    }
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

  // En Android 12+ las alarmas exactas requieren `SCHEDULE_EXACT_ALARM` (se
  // concede al instalar). En Android 14+ el usuario puede revocarlas;
  // `requestExactAlarmsPermission` abre ajustes cuando faltan. Cualquier fallo
  // aquí no debe bloquear el recordatorio: el scheduling usa el modo inexacto
  // como respaldo.
  Future<void> _ensureExactAlarmPermission() async {
    if (kIsWeb) {
      return;
    }
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      return;
    }

    try {
      final granted = await android.requestExactAlarmsPermission().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      if (granted == false) {
        throw const TaskReminderExactAlarmDeniedException();
      }
    } catch (error, stackTrace) {
      _reportError('verificar permiso de alarma exacta', error, stackTrace);
    }
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
