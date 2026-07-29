import '../entities/user_progress.dart';

abstract interface class TimerRepository {
  Future<UserProgress> loadProgress();

  Future<void> saveProgress(UserProgress progress);

  Future<void> clearProgress();
}
