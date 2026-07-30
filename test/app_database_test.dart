import 'package:atomic_task/core/database/app_database.dart';
import 'package:atomic_task/features/timer/data/datasources/timer_local_data_source.dart';
import 'package:atomic_task/features/timer/data/models/progress_model.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists progress in the local SQLite database', () async {
    SharedPreferences.setMockInitialValues({});
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);
    final dataSource = DriftTimerLocalDataSource(database);

    await dataSource.save(
      const ProgressModel(
        gems: 7,
        totalFocusSeconds: 1234,
        profileName: 'Javier',
      ),
    );

    final progress = await dataSource.load();

    expect(progress.gems, 7);
    expect(progress.totalFocusSeconds, 1234);
    expect(progress.profileName, 'Javier');

    await dataSource.clear();
    final clearedProgress = await dataSource.load();

    expect(clearedProgress.gems, 0);
    expect(clearedProgress.totalFocusSeconds, 0);
    expect(clearedProgress.profileName, 'NOMBRE');
  });
}
