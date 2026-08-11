import '../../domain/entities/atomic_task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._localDataSource);

  final TaskLocalDataSource _localDataSource;

  @override
  Stream<List<AtomicTask>> watchTasks() => _localDataSource.watchAll();

  @override
  Future<int> createTask({
    required String title,
    required DateTime? dueDate,
    required DateTime createdAt,
  }) {
    return _localDataSource.create(
      title: title,
      dueDate: dueDate,
      createdAt: createdAt,
    );
  }

  @override
  Future<void> updateTask({
    required int id,
    required String title,
    required DateTime? dueDate,
    required DateTime updatedAt,
  }) {
    return _localDataSource.update(
      id: id,
      title: title,
      dueDate: dueDate,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> setTaskCompleted({
    required int id,
    required bool isCompleted,
    required DateTime updatedAt,
  }) {
    return _localDataSource.setCompleted(
      id: id,
      isCompleted: isCompleted,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> setTaskFocusMinutes({
    required int id,
    required int focusMinutes,
    required DateTime updatedAt,
  }) {
    return _localDataSource.setFocusMinutes(
      id: id,
      focusMinutes: focusMinutes,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> deleteTask(int id) => _localDataSource.delete(id);
}
