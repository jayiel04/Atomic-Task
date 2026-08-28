import '../entities/atomic_task.dart';
import 'update_task.dart';

class UpdateRecurringOccurrence {
  const UpdateRecurringOccurrence(this._updateTask);

  final UpdateTask _updateTask;

  Future<void> call({
    required AtomicTask task,
    required String title,
    required DateTime? dueDate,
    required DateTime updatedAt,
    DateTime? reminderAt,
    bool clearReminder = false,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
  }) {
    return _updateTask(
      id: task.id,
      title: title,
      dueDate: dueDate,
      updatedAt: updatedAt,
      reminderAt: reminderAt,
      clearReminder: clearReminder,
      reminderMode: reminderMode,
    );
  }
}
