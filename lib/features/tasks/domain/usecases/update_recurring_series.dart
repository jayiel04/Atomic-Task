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
    return _repository.updateRecurringSeries(
      task: task,
      title: normalizedTitle,
      dueDate: dueDate,
      rule: currentRule.copyWith(
        frequency: frequency,
        interval: interval,
        startDate: DateTime(startDate.year, startDate.month, startDate.day),
        endDate: endDate == null
            ? null
            : DateTime(endDate.year, endDate.month, endDate.day),
        clearEndDate: endDate == null,
        updatedAt: updatedAt,
      ),
      updatedAt: updatedAt,
    );
  }
}
