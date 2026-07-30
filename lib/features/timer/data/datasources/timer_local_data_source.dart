import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/app_database.dart';
import '../models/progress_model.dart';

abstract interface class TimerLocalDataSource {
  Future<ProgressModel> load();

  Future<void> save(ProgressModel progress);

  Future<void> clear();
}

class DriftTimerLocalDataSource implements TimerLocalDataSource {
  DriftTimerLocalDataSource(this._database);

  final AppDatabase _database;

  static const _gemsKey = 'atomic_gems';
  static const _focusSecondsKey = 'atomic_focus_seconds';
  static const _profileNameKey = 'atomic_profile_name';

  @override
  Future<ProgressModel> load() async {
    final storedProgress = await _database.readProgress();
    if (storedProgress != null) {
      return ProgressModel(
        gems: storedProgress.gems,
        totalFocusSeconds: storedProgress.totalFocusSeconds,
        profileName: storedProgress.profileName,
      );
    }

    final legacyProgress = await _loadLegacyProgress();
    if (legacyProgress != null) {
      await save(legacyProgress);
      return legacyProgress;
    }

    return const ProgressModel(
      gems: 0,
      totalFocusSeconds: 0,
      profileName: 'NOMBRE',
    );
  }

  @override
  Future<void> save(ProgressModel progress) {
    return _database.writeProgress(
      TimerProgressCompanion.insert(
        id: const Value(1),
        gems: Value(progress.gems),
        totalFocusSeconds: Value(progress.totalFocusSeconds),
        profileName: Value(progress.profileName),
      ),
    );
  }

  @override
  Future<void> clear() async {
    await _database.deleteProgress();

    // Elimina también los datos antiguos para que no vuelvan a migrarse.
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.remove(_gemsKey),
      preferences.remove(_focusSecondsKey),
      preferences.remove(_profileNameKey),
    ]);
  }

  Future<ProgressModel?> _loadLegacyProgress() async {
    final preferences = await SharedPreferences.getInstance();
    final hasLegacyData =
        preferences.containsKey(_gemsKey) ||
        preferences.containsKey(_focusSecondsKey) ||
        preferences.containsKey(_profileNameKey);

    if (!hasLegacyData) {
      return null;
    }

    return ProgressModel(
      gems: preferences.getInt(_gemsKey) ?? 0,
      totalFocusSeconds: preferences.getInt(_focusSecondsKey) ?? 0,
      profileName: preferences.getString(_profileNameKey) ?? 'NOMBRE',
    );
  }
}
