import '../../../../core/constants/timer_constants.dart';
import '../repositories/task_repository.dart';

class AssignTaskFocus {
  const AssignTaskFocus(this._repository);

  final TaskRepository _repository;

  Future<void> call({
    required int id,
    required int focusMinutes,
    required DateTime updatedAt,
  }) {
    if (focusMinutes < 1 || focusMinutes > TimerConstants.maximumMinutes) {
      throw ArgumentError.value(
        focusMinutes,
        'focusMinutes',
        'El tiempo debe estar entre 1 y ${TimerConstants.maximumMinutes}',
      );
    }

    return _repository.setTaskFocusMinutes(
      id: id,
      focusMinutes: focusMinutes,
      updatedAt: updatedAt,
    );
  }
}
