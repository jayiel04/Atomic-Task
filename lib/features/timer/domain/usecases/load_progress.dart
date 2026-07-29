import '../entities/user_progress.dart';
import '../repositories/timer_repository.dart';

class LoadProgress {
  const LoadProgress(this._repository);

  final TimerRepository _repository;

  Future<UserProgress> call() => _repository.loadProgress();
}
