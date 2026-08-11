import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/atomic_task.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/assign_task_focus.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/toggle_task_completion.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/watch_tasks.dart';

class TaskController extends ChangeNotifier {
  TaskController(
    this._watchTasks,
    this._createTask,
    this._updateTask,
    this._toggleTaskCompletion,
    this._deleteTask,
    this._assignTaskFocus, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final WatchTasks _watchTasks;
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final ToggleTaskCompletion _toggleTaskCompletion;
  final DeleteTask _deleteTask;
  final AssignTaskFocus _assignTaskFocus;
  final DateTime Function() _now;

  StreamSubscription<List<AtomicTask>>? _subscription;
  List<AtomicTask> _tasks = const [];
  bool _isLoading = true;
  bool _isMutating = false;
  String? _errorMessage;

  List<AtomicTask> get tasks => _tasks;
  List<AtomicTask> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList(growable: false);
  List<AtomicTask> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList(growable: false);
  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  String? get errorMessage => _errorMessage;

  void initialize() {
    if (_subscription != null) {
      return;
    }

    _subscription = _watchTasks().listen(
      (tasks) {
        _tasks = tasks;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        _errorMessage = 'No fue posible cargar las tareas.';
        notifyListeners();
      },
    );
  }

  Future<bool> create({required String title, DateTime? dueDate}) {
    return _runMutation(
      () => _createTask(title: title, dueDate: dueDate, createdAt: _now()),
      failureMessage: 'No fue posible crear la tarea.',
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

  Future<bool> toggleCompletion(AtomicTask task) {
    return _runMutation(
      () => _toggleTaskCompletion(task, _now()),
      failureMessage: 'No fue posible actualizar la tarea.',
    );
  }

  Future<bool> completeById(int id) async {
    final matchingTasks = _tasks.where((task) => task.id == id);
    if (matchingTasks.isEmpty || matchingTasks.first.isCompleted) {
      return true;
    }
    return toggleCompletion(matchingTasks.first);
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
    return _runMutation(
      () => _deleteTask(task.id),
      failureMessage: 'No fue posible eliminar la tarea.',
    );
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _runMutation(
    Future<Object?> Function() operation, {
    required String failureMessage,
  }) async {
    _isMutating = true;
    _errorMessage = null;
    notifyListeners();

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
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
