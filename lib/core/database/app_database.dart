import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class TimerProgress extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  IntColumn get gems => integer().withDefault(const Constant(0))();

  IntColumn get totalFocusSeconds => integer().withDefault(const Constant(0))();

  TextColumn get profileName => text().withDefault(const Constant('NOMBRE'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [TimerProgress])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor})
    : super(
        executor ??
            driftDatabase(
              name: 'atomic_task',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ),
      );

  @override
  int get schemaVersion => 1;

  Future<TimerProgressData?> readProgress() {
    return select(timerProgress).getSingleOrNull();
  }

  Future<void> writeProgress(TimerProgressCompanion progress) {
    return into(timerProgress).insertOnConflictUpdate(progress);
  }

  Future<void> deleteProgress() {
    return delete(timerProgress).go();
  }
}
