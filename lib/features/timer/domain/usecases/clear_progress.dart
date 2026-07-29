import '../repositories/timer_repository.dart';

class ClearProgress {
  const ClearProgress(this._repository);

  final TimerRepository _repository;

  Future<void> call() => _repository.clearProgress();
}
