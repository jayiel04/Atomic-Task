import '../entities/atomic_task.dart';
import '../repositories/task_recurrence_repository.dart';
import '../repositories/task_repository.dart';
import 'calculate_next_occurrence.dart';

class DeleteTaskOccurrence {
  const DeleteTaskOccurrence(
    this._taskRepository,
    this._recurrenceRepository,
    this._calculateNextOccurrence,
  );

  final TaskRepository _taskRepository;
  final TaskRecurrenceRepository _recurrenceRepository;
  final CalculateNextOccurrence _calculateNextOccurrence;

  Future<void> call(AtomicTask task, DateTime updatedAt) {
    final rule = task.recurrenceRule;
    if (rule == null) {
      return _taskRepository.deleteTask(task.id);
    }
    final nextOccurrenceDate = task.isCompleted
        ? null
        : _calculateNextOccurrence(rule, task.occurrenceDate ?? rule.startDate);
    return _recurrenceRepository.deleteRecurringOccurrence(
      task: task,
      nextOccurrenceDate: nextOccurrenceDate,
      updatedAt: updatedAt,
    );
  }
}
