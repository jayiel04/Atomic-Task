import '../entities/atomic_task.dart';
import '../repositories/task_recurrence_repository.dart';

class DeleteTaskSeries {
  const DeleteTaskSeries(this._repository);

  final TaskRecurrenceRepository _repository;

  Future<void> call(AtomicTask task) {
    final rule = task.recurrenceRule;
    if (rule == null) {
      throw ArgumentError.value(task.id, 'task', 'La tarea no es recurrente');
    }
    return _repository.deleteRecurrenceSeries(rule.id);
  }
}
