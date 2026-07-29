import '../../domain/entities/user_progress.dart';

class ProgressModel extends UserProgress {
  const ProgressModel({
    required super.gems,
    required super.totalFocusSeconds,
    required super.profileName,
  });

  factory ProgressModel.fromEntity(UserProgress progress) {
    return ProgressModel(
      gems: progress.gems,
      totalFocusSeconds: progress.totalFocusSeconds,
      profileName: progress.profileName,
    );
  }
}
