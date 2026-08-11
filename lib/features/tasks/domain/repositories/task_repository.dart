import '../entities/atomic_task.dart';

abstract interface class TaskRepository {
  Stream<List<AtomicTask>> watchTasks();

  Future<int> createTask({
    required String title,
    required DateTime? dueDate,
    required DateTime createdAt,
  });

  Future<void> updateTask({
    required int id,
    required String title,
    required DateTime? dueDate,
    required DateTime updatedAt,
  });

  Future<void> setTaskCompleted({
    required int id,
    required bool isCompleted,
    required DateTime updatedAt,
  });

  Future<void> setTaskFocusMinutes({
    required int id,
    required int focusMinutes,
    required DateTime updatedAt,
  });

  Future<void> deleteTask(int id);
}
