import '../entities/atomic_task.dart';
import '../repositories/task_repository.dart';

class ToggleTaskCompletion {
  const ToggleTaskCompletion(this._repository);

  final TaskRepository _repository;

  Future<void> call(AtomicTask task, DateTime updatedAt) {
    return _repository.setTaskCompleted(
      id: task.id,
      isCompleted: !task.isCompleted,
      updatedAt: updatedAt,
    );
  }
}
