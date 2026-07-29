import '../entities/user_progress.dart';
import '../repositories/timer_repository.dart';

class SaveProgress {
  const SaveProgress(this._repository);

  final TimerRepository _repository;

  Future<void> call(UserProgress progress) {
    return _repository.saveProgress(progress);
  }
}
