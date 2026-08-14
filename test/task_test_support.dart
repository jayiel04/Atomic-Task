import 'dart:async';

import 'package:atomic_task/features/tasks/domain/entities/atomic_task.dart';
import 'package:atomic_task/features/tasks/domain/repositories/task_repository.dart';

class MemoryTaskRepository implements TaskRepository {
  MemoryTaskRepository({List<AtomicTask> initialTasks = const []})
    : tasks = List.of(initialTasks);

  final StreamController<List<AtomicTask>> _controller =
      StreamController<List<AtomicTask>>.broadcast();
  final List<AtomicTask> tasks;
  int _nextId = 1;

  bool get hasListener => _controller.hasListener;

  @override
  Stream<List<AtomicTask>> watchTasks() => _controller.stream;

  void emit() {
    tasks.sort(_compareTasks);
    _controller.add(List.unmodifiable(tasks));
  }

  @override
  Future<int> createTask({
    required String title,
    required DateTime? dueDate,
    required DateTime createdAt,
  }) async {
    final id = _nextId++;
    tasks.add(
      AtomicTask(
        id: id,
        title: title,
        isCompleted: false,
        dueDate: dueDate,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    );
    emit();
    return id;
  }

  @override
  Future<void> updateTask({
    required int id,
    required String title,
    required DateTime? dueDate,
    required DateTime updatedAt,
  }) async {
    final index = tasks.indexWhere((task) => task.id == id);
    final current = tasks[index];
    tasks[index] = AtomicTask(
      id: current.id,
      title: title,
      isCompleted: current.isCompleted,
      dueDate: dueDate,
      focusMinutes: current.focusMinutes,
      completedAt: current.completedAt,
      occurrenceDate: current.occurrenceDate,
      recurrenceRule: current.recurrenceRule,
      createdAt: current.createdAt,
      updatedAt: updatedAt,
    );
    emit();
  }

  @override
  Future<void> setTaskCompleted({
    required int id,
    required bool isCompleted,
    required DateTime updatedAt,
  }) async {
    final index = tasks.indexWhere((task) => task.id == id);
    final current = tasks[index];
    tasks[index] = AtomicTask(
      id: current.id,
      title: current.title,
      isCompleted: isCompleted,
      dueDate: current.dueDate,
      focusMinutes: current.focusMinutes,
      completedAt: isCompleted ? updatedAt : null,
      occurrenceDate: current.occurrenceDate,
      recurrenceRule: current.recurrenceRule,
      createdAt: current.createdAt,
      updatedAt: updatedAt,
    );
    emit();
  }

  @override
  Future<void> setTaskFocusMinutes({
    required int id,
    required int focusMinutes,
    required DateTime updatedAt,
  }) async {
    final index = tasks.indexWhere((task) => task.id == id);
    final current = tasks[index];
    tasks[index] = AtomicTask(
      id: current.id,
      title: current.title,
      isCompleted: current.isCompleted,
      dueDate: current.dueDate,
      focusMinutes: focusMinutes,
      completedAt: current.completedAt,
      occurrenceDate: current.occurrenceDate,
      recurrenceRule: current.recurrenceRule,
      createdAt: current.createdAt,
      updatedAt: updatedAt,
    );
    emit();
  }

  @override
  Future<void> deleteTask(int id) async {
    tasks.removeWhere((task) => task.id == id);
    emit();
  }

  Future<void> dispose() => _controller.close();

  static int _compareTasks(AtomicTask left, AtomicTask right) {
    if (left.isCompleted != right.isCompleted) {
      return left.isCompleted ? 1 : -1;
    }
    if (left.dueDate == null && right.dueDate != null) {
      return 1;
    }
    if (left.dueDate != null && right.dueDate == null) {
      return -1;
    }
    final dueDateComparison = left.dueDate?.compareTo(right.dueDate!) ?? 0;
    return dueDateComparison != 0
        ? dueDateComparison
        : left.createdAt.compareTo(right.createdAt);
  }
}
