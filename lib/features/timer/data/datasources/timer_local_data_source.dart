import 'package:shared_preferences/shared_preferences.dart';

import '../models/progress_model.dart';

abstract interface class TimerLocalDataSource {
  Future<ProgressModel> load();

  Future<void> save(ProgressModel progress);

  Future<void> clear();
}

class SharedPreferencesTimerLocalDataSource implements TimerLocalDataSource {
  static const _gemsKey = 'atomic_gems';
  static const _focusSecondsKey = 'atomic_focus_seconds';
  static const _profileNameKey = 'atomic_profile_name';

  @override
  Future<ProgressModel> load() async {
    final preferences = await SharedPreferences.getInstance();

    return ProgressModel(
      gems: preferences.getInt(_gemsKey) ?? 0,
      totalFocusSeconds: preferences.getInt(_focusSecondsKey) ?? 0,
      profileName: preferences.getString(_profileNameKey) ?? 'NOMBRE',
    );
  }

  @override
  Future<void> save(ProgressModel progress) async {
    final preferences = await SharedPreferences.getInstance();

    await Future.wait([
      preferences.setInt(_gemsKey, progress.gems),
      preferences.setInt(
        _focusSecondsKey,
        progress.totalFocusSeconds,
      ),
      preferences.setString(
        _profileNameKey,
        progress.profileName,
      ),
    ]);
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();

    await Future.wait([
      preferences.remove(_gemsKey),
      preferences.remove(_focusSecondsKey),
      preferences.remove(_profileNameKey),
    ]);
  }
}
