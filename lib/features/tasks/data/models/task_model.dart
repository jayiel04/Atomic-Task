import '../../../../core/database/app_database.dart';
import '../../domain/entities/atomic_task.dart';

class TaskModel extends AtomicTask {
  const TaskModel({
    required super.id,
    required super.title,
    required super.isCompleted,
    required super.createdAt,
    required super.updatedAt,
    super.dueDate,
    super.focusMinutes,
  });

  factory TaskModel.fromRow(TaskRow row) {
    return TaskModel(
      id: row.id,
      title: row.title,
      isCompleted: row.isCompleted,
      dueDate: row.dueDate,
      focusMinutes: row.focusMinutes,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
