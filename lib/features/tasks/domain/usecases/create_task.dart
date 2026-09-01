import '../entities/atomic_task.dart';
import '../repositories/task_repository.dart';

class CreateTask {
  const CreateTask(this._repository);

  final TaskRepository _repository;

  Future<int> call({
    required String title,
    required DateTime? dueDate,
    required DateTime createdAt,
    DateTime? reminderAt,
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
    if (reminderAt != null) {
      if (repository case final TaskAlarmRepository alarmRepository) {
        return alarmRepository.createTaskWithReminder(
          title: normalizedTitle,
          dueDate: dueDate,
          reminderAt: reminderAt,
          createdAt: createdAt,
          reminderMode: reminderMode,
          reminderSoundKey: reminderSoundKey,
        );
      }
      throw UnsupportedError(
        'El repositorio configurado no admite recordatorios',
      );
    }
    return repository.createTask(
      title: normalizedTitle,
      dueDate: dueDate,
      createdAt: createdAt,
    );
  }
}
