import '../entities/atomic_task.dart';
import '../repositories/task_recurrence_repository.dart';
import '../repositories/task_repository.dart';
import 'calculate_next_occurrence.dart';

class CompleteTaskOccurrence {
  const CompleteTaskOccurrence(
    this._taskRepository,
    this._recurrenceRepository,
    this._calculateNextOccurrence,
  );

  final TaskRepository _taskRepository;
  final TaskRecurrenceRepository _recurrenceRepository;
  final CalculateNextOccurrence _calculateNextOccurrence;

  Future<void> call(AtomicTask task, DateTime updatedAt) {
    if (task.isCompleted) {
      return Future<void>.value();
    }
    final rule = task.recurrenceRule;
    if (rule == null) {
      return _taskRepository.setTaskCompleted(
        id: task.id,
        isCompleted: true,
        updatedAt: updatedAt,
      );
    }
    final occurrenceDate = task.occurrenceDate ?? rule.startDate;
    return _recurrenceRepository.completeRecurringOccurrence(
      task: task,
      nextOccurrenceDate: _calculateNextOccurrence(rule, occurrenceDate),
      updatedAt: updatedAt,
    );
  }
}
