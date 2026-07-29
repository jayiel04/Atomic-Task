import '../../domain/entities/user_progress.dart';
import '../../domain/repositories/timer_repository.dart';
import '../datasources/timer_local_data_source.dart';
import '../models/progress_model.dart';

class TimerRepositoryImpl implements TimerRepository {
  const TimerRepositoryImpl(this._localDataSource);

  final TimerLocalDataSource _localDataSource;

  @override
  Future<UserProgress> loadProgress() {
    return _localDataSource.load();
  }

  @override
  Future<void> saveProgress(UserProgress progress) {
    return _localDataSource.save(ProgressModel.fromEntity(progress));
  }

  @override
  Future<void> clearProgress() {
    return _localDataSource.clear();
  }
}
