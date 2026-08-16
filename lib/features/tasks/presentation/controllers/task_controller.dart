import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/atomic_task.dart';
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
  final DateTime Function() _now;

  StreamSubscription<List<AtomicTask>>? _subscription;
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

  Future<bool> create({required String title, DateTime? dueDate}) {
    return _runMutation(
      () => _createTask(title: title, dueDate: dueDate, createdAt: _now()),
      failureMessage: 'No fue posible crear la tarea.',
    );
  }

  Future<bool> createRecurring({
    required String title,
    required DateTime? dueDate,
    required RecurrenceFrequency frequency,
    required int interval,
    required DateTime startDate,
    required DateTime? endDate,
  }) {
    final operation = createRecurringTaskUseCase;
    if (operation == null) {
      return Future<bool>.value(false);
    }
    return _runMutation(
      () => operation(
        title: title,
        dueDate: dueDate,
        frequency: frequency,
        interval: interval,
        startDate: startDate,
        endDate: endDate,
        createdAt: _now(),
      ),
      failureMessage: 'No fue posible crear la tarea recurrente.',
    );
  }

  Future<bool> update({
    required AtomicTask task,
    required String title,
    required DateTime? dueDate,
  }) {
    return _runMutation(
      () => _updateTask(
        id: task.id,
        title: title,
        dueDate: dueDate,
        updatedAt: _now(),
      ),
      failureMessage: 'No fue posible guardar los cambios.',
    );
  }

  Future<bool> updateOccurrence({
    required AtomicTask task,
    required String title,
    required DateTime? dueDate,
  }) {
    final operation = updateRecurringOccurrenceUseCase;
    if (operation == null) {
      return update(task: task, title: title, dueDate: dueDate);
    }
    return _runMutation(
      () => operation(
        task: task,
        title: title,
        dueDate: dueDate,
        updatedAt: _now(),
      ),
      failureMessage: 'No fue posible guardar la ocurrencia.',
    );
  }

  Future<bool> updateSeries({
    required AtomicTask task,
    required String title,
    required DateTime? dueDate,
    required RecurrenceFrequency frequency,
    required int interval,
    required DateTime startDate,
    required DateTime? endDate,
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
        updatedAt: _now(),
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
      return _runMutation(
        () => completeOccurrence(task, completedAt),
        failureMessage: 'No fue posible completar la ocurrencia.',
      );
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
      return _runMutation(
        () => deleteOccurrence(task, _now()),
        failureMessage: 'No fue posible eliminar la ocurrencia.',
      );
    }
    return _runMutation(
      () => _deleteTask(task.id),
      failureMessage: 'No fue posible eliminar la tarea.',
    );
  }

  Future<bool> deleteSeries(AtomicTask task) {
    final operation = deleteTaskSeriesUseCase;
    if (operation == null) {
      return Future<bool>.value(false);
    }
    return _runMutation(
      () => operation(task),
      failureMessage: 'No fue posible eliminar la serie.',
    );
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
