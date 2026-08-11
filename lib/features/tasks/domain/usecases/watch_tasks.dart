import '../entities/atomic_task.dart';
import '../repositories/task_repository.dart';

class WatchTasks {
  const WatchTasks(this._repository);

  final TaskRepository _repository;

  Stream<List<AtomicTask>> call() => _repository.watchTasks();
}
