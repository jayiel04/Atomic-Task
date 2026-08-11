import '../repositories/task_repository.dart';

class UpdateTask {
  const UpdateTask(this._repository);

  final TaskRepository _repository;

  Future<void> call({
    required int id,
    required String title,
    required DateTime? dueDate,
    required DateTime updatedAt,
  }) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(
        title,
        'title',
        'El titulo no puede estar vacio',
      );
    }

    return _repository.updateTask(
      id: id,
      title: normalizedTitle,
      dueDate: dueDate,
      updatedAt: updatedAt,
    );
  }
}
