import '../../../../core/database/app_database.dart';
import '../../domain/entities/atomic_task.dart';
import 'recurrence_rule_model.dart';

class TaskModel extends AtomicTask {
  const TaskModel({
    required super.id,
    required super.title,
    required super.isCompleted,
    required super.createdAt,
    required super.updatedAt,
    super.dueDate,
    super.reminderAt,
    super.reminderMode,
    super.focusMinutes,
    super.completedAt,
    super.occurrenceDate,
    super.recurrenceRule,
  });

  factory TaskModel.fromRow(TaskRow row) {
    return TaskModel(
      id: row.id,
      title: row.title,
      isCompleted: row.isCompleted,
      dueDate: row.dueDate,
      reminderAt: row.reminderAt,
      reminderMode: _reminderModeFromName(row.reminderMode),
      focusMinutes: row.focusMinutes,
      completedAt: row.completedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  factory TaskModel.fromDatabaseRow(TaskWithRecurrenceRow row) {
    final task = row.task;
    if (task == null) {
      throw StateError('La fila de tarea no puede ser nula');
    }
    final recurrenceRow = row.recurrenceRule;
    return TaskModel(
      id: task.id,
      title: task.title,
      isCompleted: task.isCompleted,
      dueDate: task.dueDate,
      reminderAt: task.reminderAt,
      reminderMode: _reminderModeFromName(task.reminderMode),
      focusMinutes: task.focusMinutes,
      completedAt: task.completedAt,
      occurrenceDate: task.occurrenceDate,
      recurrenceRule: recurrenceRow == null
          ? null
          : RecurrenceRuleModel.fromRow(recurrenceRow),
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  static TaskReminderMode _reminderModeFromName(String? name) {
    return TaskReminderMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => TaskReminderMode.notification,
    );
  }
}
