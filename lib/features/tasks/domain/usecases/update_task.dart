import '../entities/atomic_task.dart';
import '../repositories/task_repository.dart';

class UpdateTask {
  const UpdateTask(this._repository);

  final TaskRepository _repository;

  Future<void> call({
    required int id,
    required String title,
    required DateTime? dueDate,
    required DateTime updatedAt,
    DateTime? reminderAt,
    bool clearReminder = false,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
    String? reminderSoundKey,
  }) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(
        title,
        'title',
        'El titulo no puede estar vacio',
      );
    }

    final repository = _repository;
    if (reminderAt != null || clearReminder) {
      if (repository case final TaskAlarmRepository alarmRepository) {
        return alarmRepository.updateTaskWithReminder(
          id: id,
          title: normalizedTitle,
          dueDate: dueDate,
          reminderAt: reminderAt,
          updatedAt: updatedAt,
          reminderMode: reminderMode,
          reminderSoundKey: reminderSoundKey,
        );
      }
      throw UnsupportedError(
        'El repositorio configurado no admite recordatorios',
      );
    }
    return repository.updateTask(
      id: id,
      title: normalizedTitle,
      dueDate: dueDate,
      updatedAt: updatedAt,
    );
  }
}
