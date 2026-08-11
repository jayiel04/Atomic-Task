import '../repositories/task_repository.dart';

class CreateTask {
  const CreateTask(this._repository);

  final TaskRepository _repository;

  Future<int> call({
    required String title,
    required DateTime? dueDate,
    required DateTime createdAt,
  }) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(
        title,
        'title',
        'El titulo no puede estar vacio',
      );
    }

    return _repository.createTask(
      title: normalizedTitle,
      dueDate: dueDate,
      createdAt: createdAt,
    );
  }
}
