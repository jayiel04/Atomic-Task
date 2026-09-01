import '../entities/atomic_task.dart';
import '../entities/recurrence_rule.dart';
import '../repositories/task_recurrence_repository.dart';
import 'create_recurring_task.dart';

class UpdateRecurringSeries {
  const UpdateRecurringSeries(this._repository);

  final TaskRecurrenceRepository _repository;

  Future<void> call({
    required AtomicTask task,
    required String title,
    required DateTime? dueDate,
    required RecurrenceFrequency frequency,
    required int interval,
    required DateTime startDate,
    required DateTime? endDate,
    required DateTime updatedAt,
    DateTime? reminderAt,
    bool clearReminder = false,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
    String? reminderSoundKey,
    bool reminderEveryOccurrence = true,
  }) {
    final currentRule = task.recurrenceRule;
    if (currentRule == null) {
      throw ArgumentError.value(task.id, 'task', 'La tarea no es recurrente');
    }
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(
        title,
        'title',
        'El titulo no puede estar vacio',
      );
    }
    validateRecurrence(
      interval: interval,
      startDate: startDate,
      endDate: endDate,
    );
    if (reminderAt != null &&
        (reminderAt.hour < 0 ||
            reminderAt.hour > 23 ||
            reminderAt.minute < 0 ||
            reminderAt.minute > 59)) {
      throw ArgumentError.value(
        reminderAt,
        'reminderAt',
        'La hora del recordatorio debe estar entre 00:00 y 23:59',
      );
    }
    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final normalizedReminderAt = reminderAt == null
        ? null
        : DateTime(
            normalizedStart.year,
            normalizedStart.month,
            normalizedStart.day,
            reminderAt.hour,
            reminderAt.minute,
          );
    return _repository.updateRecurringSeries(
      task: task,
      title: normalizedTitle,
      dueDate: dueDate,
      rule: currentRule.copyWith(
        frequency: frequency,
        interval: interval,
        startDate: normalizedStart,
        endDate: endDate == null
            ? null
            : DateTime(endDate.year, endDate.month, endDate.day),
        clearEndDate: endDate == null,
        reminderTimeMinutes:
            normalizedReminderAt == null || !reminderEveryOccurrence
            ? null
            : normalizedReminderAt.hour * 60 + normalizedReminderAt.minute,
        clearReminderTime:
            normalizedReminderAt == null ||
            (clearReminder && !reminderEveryOccurrence),
        updatedAt: updatedAt,
      ),
      updatedAt: updatedAt,
      reminderAt: normalizedReminderAt,
      reminderMode: reminderMode,
      reminderSoundKey: reminderSoundKey,
    );
  }
}
