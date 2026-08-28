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

/// Contrato opcional para repositorios que persisten recordatorios de tareas.
///
/// Se mantiene separado de [TaskRepository] para conservar compatibilidad con
/// repositorios de prueba o implementaciones que todavía no almacenan alarmas.
abstract interface class TaskAlarmRepository {
  Future<int> createTaskWithReminder({
    required String title,
    required DateTime? dueDate,
    required DateTime? reminderAt,
    required DateTime createdAt,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
  });

  Future<void> updateTaskWithReminder({
    required int id,
    required String title,
    required DateTime? dueDate,
    required DateTime? reminderAt,
    required DateTime updatedAt,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
  });
}
