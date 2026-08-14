import '../entities/atomic_task.dart';
import '../repositories/task_recurrence_repository.dart';

class SetTaskRecurrenceActive {
  const SetTaskRecurrenceActive(this._repository);

  final TaskRecurrenceRepository _repository;

  Future<void> call(
    AtomicTask task, {
    required bool isActive,
    required DateTime updatedAt,
  }) {
    final rule = task.recurrenceRule;
    if (rule == null) {
      throw ArgumentError.value(task.id, 'task', 'La tarea no es recurrente');
    }
    return _repository.setRecurrenceActive(
      ruleId: rule.id,
      isActive: isActive,
      updatedAt: updatedAt,
    );
  }
}
