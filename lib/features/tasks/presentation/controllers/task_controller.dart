import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/atomic_task.dart';
import '../../domain/services/task_reminder_service.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/assign_task_focus.dart';
import '../../domain/usecases/complete_task_occurrence.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/delete_task_occurrence.dart';
import '../../domain/usecases/delete_task_series.dart';
import '../../domain/usecases/create_recurring_task.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../../domain/usecases/reconcile_task_recurrences.dart';
import '../../domain/usecases/set_task_recurrence_active.dart';
import '../../domain/usecases/toggle_task_completion.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/update_recurring_occurrence.dart';
import '../../domain/usecases/update_recurring_series.dart';
import '../../domain/usecases/watch_tasks.dart';

class TaskController extends ChangeNotifier {
  TaskController(
    this._watchTasks,
    this._createTask,
    this._updateTask,
    this._toggleTaskCompletion,
    this._deleteTask,
    this._assignTaskFocus, {
    this.createRecurringTaskUseCase,
    this.updateRecurringOccurrenceUseCase,
    this.updateRecurringSeriesUseCase,
    this.completeTaskOccurrenceUseCase,
    this.setTaskRecurrenceActiveUseCase,
    this.deleteTaskOccurrenceUseCase,
    this.deleteTaskSeriesUseCase,
    this.reconcileTaskRecurrencesUseCase,
    this.reminderService,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final WatchTasks _watchTasks;
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final ToggleTaskCompletion _toggleTaskCompletion;
  final DeleteTask _deleteTask;
  final AssignTaskFocus _assignTaskFocus;
  final CreateRecurringTask? createRecurringTaskUseCase;
  final UpdateRecurringOccurrence? updateRecurringOccurrenceUseCase;
  final UpdateRecurringSeries? updateRecurringSeriesUseCase;
  final CompleteTaskOccurrence? completeTaskOccurrenceUseCase;
  final SetTaskRecurrenceActive? setTaskRecurrenceActiveUseCase;
  final DeleteTaskOccurrence? deleteTaskOccurrenceUseCase;
  final DeleteTaskSeries? deleteTaskSeriesUseCase;
  final ReconcileTaskRecurrences? reconcileTaskRecurrencesUseCase;
  final TaskReminderService? reminderService;
  final DateTime Function() _now;

  StreamSubscription<List<AtomicTask>>? _subscription;
  Future<void>? _reminderInitialization;
  List<AtomicTask> _tasks = const [];
  bool _isLoading = true;
  bool _isMutating = false;
  bool _isDisposed = false;
  String? _errorMessage;

  List<AtomicTask> get tasks => _tasks;
  List<AtomicTask> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList(growable: false);
  List<AtomicTask> get completedTasks {
    final completed = _tasks.where((task) => task.isCompleted).toList();
    completed.sort(_compareCompletedTasks);
    return List.unmodifiable(completed);
  }

  int get completedTodayCount {
    final today = _now().toLocal();
    return _tasks.where((task) {
      final completedAt = task.completedAt?.toLocal();
      return task.isCompleted &&
          completedAt != null &&
          completedAt.year == today.year &&
          completedAt.month == today.month &&
          completedAt.day == today.day;
    }).length;
  }

  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  String? get errorMessage => _errorMessage;

  void initialize() {
    if (_isDisposed || _subscription != null) {
      return;
    }

    _subscription = _watchTasks().listen(
      (tasks) {
        if (_isDisposed) {
          return;
        }
        _tasks = tasks;
        _isLoading = false;
        _errorMessage = null;
        _notifyListeners();
        unawaited(_reconcileReminders(tasks));
      },
      onError: (_) {
        if (_isDisposed) {
          return;
        }
        _isLoading = false;
        _errorMessage = 'No fue posible cargar las tareas.';
        _notifyListeners();
      },
    );
    final reconcile = reconcileTaskRecurrencesUseCase;
    if (reconcile != null) {
      unawaited(
        reconcile(_now()).catchError((Object _) {
          if (_isDisposed) {
            return;
          }
          _errorMessage = 'No fue posible recuperar las tareas recurrentes.';
          _notifyListeners();
        }),
      );
    }
  }

  Future<bool> create({
    required String title,
    DateTime? dueDate,
    DateTime? reminderAt,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
  }) {
    return _runMutation(() async {
      final createdAt = _now();
      final id = await _createTask(
        title: title,
        dueDate: dueDate,
        reminderAt: reminderAt,
        createdAt: createdAt,
        reminderMode: reminderMode,
      );
      if (reminderAt != null) {
        unawaited(
          _syncReminderSafely(
            AtomicTask(
              id: id,
              title: title.trim(),
              isCompleted: false,
              dueDate: dueDate,
              reminderAt: reminderAt,
              reminderMode: reminderMode,
              createdAt: createdAt,
              updatedAt: createdAt,
            ),
          ),
        );
      }
      return null;
    }, failureMessage: 'No fue posible crear la tarea.');
  }

  Future<bool> createRecurring({
    required String title,
    required DateTime? dueDate,
    required RecurrenceFrequency frequency,
    required int interval,
    required DateTime startDate,
    required DateTime? endDate,
    DateTime? reminderAt,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
    bool reminderEveryOccurrence = true,
  }) {
    final operation = createRecurringTaskUseCase;
    if (operation == null) {
      return Future<bool>.value(false);
    }
    return _runMutation(() async {
      final createdAt = _now();
      final id = await operation(
        title: title,
        dueDate: dueDate,
        frequency: frequency,
        interval: interval,
        startDate: startDate,
        endDate: endDate,
        reminderAt: reminderAt,
        createdAt: createdAt,
        reminderMode: reminderMode,
        reminderEveryOccurrence: reminderEveryOccurrence,
      );
      if (reminderAt != null) {
        final normalizedStart = _dateOnly(startDate);
        unawaited(
          _syncReminderSafely(
            AtomicTask(
              id: id,
              title: title.trim(),
              isCompleted: false,
              dueDate: dueDate,
              reminderAt: DateTime(
                normalizedStart.year,
                normalizedStart.month,
                normalizedStart.day,
                reminderAt.hour,
                reminderAt.minute,
              ),
              reminderMode: reminderMode,
              occurrenceDate: normalizedStart,
              recurrenceRule: RecurrenceRule(
                id: 0,
                frequency: frequency,
                interval: interval,
                startDate: normalizedStart,
                endDate: endDate == null ? null : _dateOnly(endDate),
                reminderTimeMinutes: reminderAt.hour * 60 + reminderAt.minute,
                isActive: true,
                createdAt: createdAt,
                updatedAt: createdAt,
              ),
              createdAt: createdAt,
              updatedAt: createdAt,
            ),
          ),
        );
      }
      return null;
    }, failureMessage: 'No fue posible crear la tarea recurrente.');
  }

  Future<bool> update({
    required AtomicTask task,
    required String title,
    required DateTime? dueDate,
    DateTime? reminderAt,
    bool clearReminder = false,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
  }) {
    return _runMutation(() async {
      final updatedAt = _now();
      await _updateTask(
        id: task.id,
        title: title,
        dueDate: dueDate,
        reminderAt: reminderAt,
        clearReminder: clearReminder,
        updatedAt: updatedAt,
        reminderMode: reminderMode,
      );
      if (reminderAt != null || clearReminder || task.reminderAt != null) {
        unawaited(
          _syncReminderSafely(
            _updatedTask(
              task: task,
              title: title,
              dueDate: dueDate,
              reminderAt: reminderAt,
              clearReminder: clearReminder,
              reminderMode: reminderMode,
              updatedAt: updatedAt,
            ),
          ),
        );
      }
      return null;
    }, failureMessage: 'No fue posible guardar los cambios.');
  }

  Future<bool> updateOccurrence({
    required AtomicTask task,
    required String title,
    required DateTime? dueDate,
    DateTime? reminderAt,
    bool clearReminder = false,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
  }) {
    final operation = updateRecurringOccurrenceUseCase;
    if (operation == null) {
      return update(
        task: task,
        title: title,
        dueDate: dueDate,
        reminderAt: reminderAt,
        clearReminder: clearReminder,
        reminderMode: reminderMode,
      );
    }
    return _runMutation(() async {
      final updatedAt = _now();
      await operation(
        task: task,
        title: title,
        dueDate: dueDate,
        reminderAt: reminderAt,
        clearReminder: clearReminder,
        updatedAt: updatedAt,
        reminderMode: reminderMode,
      );
      if (reminderAt != null || clearReminder || task.reminderAt != null) {
        unawaited(
          _syncReminderSafely(
            _updatedTask(
              task: task,
              title: title,
              dueDate: dueDate,
              reminderAt: reminderAt,
              clearReminder: clearReminder,
              reminderMode: reminderMode,
              updatedAt: updatedAt,
            ),
          ),
        );
      }
      return null;
    }, failureMessage: 'No fue posible guardar la ocurrencia.');
  }

  Future<bool> updateSeries({
    required AtomicTask task,
    required String title,
    required DateTime? dueDate,
    required RecurrenceFrequency frequency,
    required int interval,
    required DateTime startDate,
    required DateTime? endDate,
    DateTime? reminderAt,
    bool clearReminder = false,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
    bool reminderEveryOccurrence = true,
  }) {
    final operation = updateRecurringSeriesUseCase;
    if (operation == null) {
      return Future<bool>.value(false);
    }
    return _runMutation(
      () => operation(
        task: task,
        title: title,
        dueDate: dueDate,
        frequency: frequency,
        interval: interval,
        startDate: startDate,
        endDate: endDate,
        reminderAt: reminderAt,
        clearReminder: clearReminder,
        updatedAt: _now(),
        reminderMode: reminderMode,
        reminderEveryOccurrence: reminderEveryOccurrence,
      ),
      failureMessage: 'No fue posible guardar la serie.',
    );
  }

  Future<bool> toggleCompletion(AtomicTask task) {
    return _toggleCompletionAt(task, _now());
  }

  Future<bool> _toggleCompletionAt(AtomicTask task, DateTime completedAt) {
    final completeOccurrence = completeTaskOccurrenceUseCase;
    if (!task.isCompleted && completeOccurrence != null) {
      return _runMutation(() async {
        await _cancelReminderSafely(task);
        return completeOccurrence(task, completedAt);
      }, failureMessage: 'No fue posible completar la ocurrencia.');
    }
    if (!task.isCompleted) {
      return _runMutation(() async {
        await _cancelReminderSafely(task);
        return _toggleTaskCompletion(task, completedAt);
      }, failureMessage: 'No fue posible actualizar la tarea.');
    }
    return _runMutation(
      () => _toggleTaskCompletion(task, completedAt),
      failureMessage: 'No fue posible actualizar la tarea.',
    );
  }

  Future<bool> completeById(int id) => completeByIdAt(id, _now());

  Future<bool> completeByIdAt(int id, DateTime completedAt) async {
    final matchingTasks = _tasks.where((task) => task.id == id);
    if (matchingTasks.isEmpty) {
      return !_isLoading;
    }
    if (matchingTasks.first.isCompleted) {
      return true;
    }
    return _toggleCompletionAt(matchingTasks.first, completedAt);
  }

  Future<bool> assignFocus(AtomicTask task, int focusMinutes) {
    return _runMutation(
      () => _assignTaskFocus(
        id: task.id,
        focusMinutes: focusMinutes,
        updatedAt: _now(),
      ),
      failureMessage: 'No fue posible asociar la tarea.',
    );
  }

  Future<bool> delete(AtomicTask task) {
    final deleteOccurrence = deleteTaskOccurrenceUseCase;
    if (task.isRecurring && deleteOccurrence != null) {
      return _runMutation(() async {
        await _cancelReminderSafely(task);
        return deleteOccurrence(task, _now());
      }, failureMessage: 'No fue posible eliminar la ocurrencia.');
    }
    return _runMutation(() async {
      await _cancelReminderSafely(task);
      return _deleteTask(task.id);
    }, failureMessage: 'No fue posible eliminar la tarea.');
  }

  Future<bool> deleteSeries(AtomicTask task) {
    final operation = deleteTaskSeriesUseCase;
    if (operation == null) {
      return Future<bool>.value(false);
    }
    return _runMutation(() async {
      await _cancelReminderSafely(task);
      return operation(task);
    }, failureMessage: 'No fue posible eliminar la serie.');
  }

  Future<bool> setRecurrenceActive(AtomicTask task, {required bool isActive}) {
    final operation = setTaskRecurrenceActiveUseCase;
    if (operation == null) {
      return Future<bool>.value(false);
    }
    return _runMutation(
      () async {
        final timestamp = _now();
        await operation(task, isActive: isActive, updatedAt: timestamp);
        final reconcile = reconcileTaskRecurrencesUseCase;
        if (isActive && reconcile != null) {
          await reconcile(timestamp);
        }
        return null;
      },
      failureMessage: isActive
          ? 'No fue posible reactivar la serie.'
          : 'No fue posible pausar la serie.',
    );
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    _notifyListeners();
  }

  static int _compareCompletedTasks(AtomicTask left, AtomicTask right) {
    final leftCompletedAt = left.completedAt;
    final rightCompletedAt = right.completedAt;
    if (leftCompletedAt == null && rightCompletedAt != null) {
      return 1;
    }
    if (leftCompletedAt != null && rightCompletedAt == null) {
      return -1;
    }
    final completedComparison =
        rightCompletedAt?.compareTo(leftCompletedAt!) ?? 0;
    return completedComparison != 0
        ? completedComparison
        : right.id.compareTo(left.id);
  }

  Future<void> _reconcileReminders(Iterable<AtomicTask> tasks) async {
    final service = reminderService;
    if (_isDisposed || service == null) {
      return;
    }

    final referenceTime = _now();
    try {
      await _initializeReminderService(service);
      if (_isDisposed) {
        return;
      }
      await service.reconcile(tasks, now: referenceTime);

      // Un recordatorio puede seguir siendo futuro aunque la fecha límite de
      // la tarea ya haya pasado. Se cancela explícitamente ese caso porque el
      // servicio de plataforma recibe la política de tareas, pero no la
      // responsabilidad de decidir cuándo una tarea está vencida.
      for (final task in tasks) {
        if (task.reminderAt != null && task.isOverdueAt(referenceTime)) {
          await _runReminderAction(() => service.cancel(task));
        }
      }
    } on TaskReminderPermissionDeniedException {
      _setReminderError(
        message: 'Activa los permisos de notificaciones para usar alarmas.',
      );
    } catch (_) {
      _setReminderError();
    }
  }

  Future<void> _syncReminderSafely(AtomicTask task) async {
    final service = reminderService;
    if (_isDisposed || service == null) {
      return;
    }

    try {
      await _initializeReminderService(service);
      if (_isDisposed) {
        return;
      }
      if (task.reminderAt == null) {
        await service.cancel(task);
      } else {
        await service.schedule(task);
      }
    } on TaskReminderPermissionDeniedException {
      _setReminderError(
        message: 'Activa los permisos de notificaciones para usar alarmas.',
      );
    } catch (_) {
      _setReminderError();
    }
  }

  Future<void> _runReminderAction(Future<void> Function() action) async {
    try {
      await action();
    } on TaskReminderPermissionDeniedException {
      _setReminderError(
        message: 'Activa los permisos de notificaciones para usar alarmas.',
      );
    } catch (_) {
      _setReminderError();
    }
  }

  Future<void> _cancelReminderSafely(AtomicTask task) async {
    final service = reminderService;
    if (_isDisposed || service == null) {
      return;
    }

    try {
      await _initializeReminderService(service);
      if (!_isDisposed) {
        await service.cancel(task);
      }
    } on TaskReminderPermissionDeniedException {
      _setReminderError(
        message: 'Activa los permisos de notificaciones para usar alarmas.',
      );
    } catch (_) {
      _setReminderError();
    }
  }

  Future<void> _initializeReminderService(TaskReminderService service) {
    return _reminderInitialization ??= Future<void>.sync(service.initialize);
  }

  void _setReminderError({
    String message = 'No fue posible sincronizar el recordatorio.',
  }) {
    if (_isDisposed) {
      return;
    }
    _errorMessage = message;
    _notifyListeners();
  }

  AtomicTask _updatedTask({
    required AtomicTask task,
    required String title,
    required DateTime? dueDate,
    required DateTime? reminderAt,
    required bool clearReminder,
    required TaskReminderMode reminderMode,
    required DateTime updatedAt,
  }) {
    final effectiveReminderAt = reminderAt ??
        (clearReminder ? null : task.reminderAt);
    return AtomicTask(
      id: task.id,
      title: title.trim(),
      isCompleted: task.isCompleted,
      dueDate: dueDate,
      reminderAt: effectiveReminderAt,
      reminderMode: effectiveReminderAt == null
          ? TaskReminderMode.notification
          : reminderMode,
      focusMinutes: task.focusMinutes,
      completedAt: task.completedAt,
      occurrenceDate: task.occurrenceDate,
      recurrenceRule: task.recurrenceRule,
      createdAt: task.createdAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  Future<bool> _runMutation(
    Future<Object?> Function() operation, {
    required String failureMessage,
  }) async {
    _isMutating = true;
    _errorMessage = null;
    _notifyListeners();

    try {
      await operation();
      return true;
    } on ArgumentError {
      _errorMessage = 'Escribe un titulo para la tarea.';
      return false;
    } catch (_) {
      _errorMessage = failureMessage;
      return false;
    } finally {
      _isMutating = false;
      _notifyListeners();
    }
  }

  void _notifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
  }
}
