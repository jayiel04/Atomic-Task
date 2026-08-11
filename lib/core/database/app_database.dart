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

@DataClassName('TaskRow')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get dueDate => dateTime().nullable()();

  IntColumn get focusMinutes => integer().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [TimerProgress, Tasks])
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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(tasks);
      }
      if (from == 2) {
        await migrator.addColumn(tasks, tasks.focusMinutes);
      }
    },
  );

  Future<TimerProgressData?> readProgress() {
    return select(timerProgress).getSingleOrNull();
  }

  Future<void> writeProgress(TimerProgressCompanion progress) {
    return into(timerProgress).insertOnConflictUpdate(progress);
  }

  Future<void> deleteProgress() {
    return delete(timerProgress).go();
  }

  Stream<List<TaskRow>> watchAllTasks() {
    final query = select(tasks)
      ..orderBy([
        (task) => OrderingTerm(expression: task.isCompleted),
        (task) => OrderingTerm(expression: task.dueDate.isNull()),
        (task) => OrderingTerm(expression: task.dueDate),
        (task) => OrderingTerm(expression: task.createdAt),
      ]);

    return query.watch();
  }

  Future<int> insertTask(TasksCompanion task) {
    return into(tasks).insert(task);
  }

  Future<int> updateTask({
    required int id,
    required String title,
    required DateTime? dueDate,
    required DateTime updatedAt,
  }) {
    return (update(tasks)..where((task) => task.id.equals(id))).write(
      TasksCompanion(
        title: Value(title),
        dueDate: Value(dueDate),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<int> setTaskCompleted({
    required int id,
    required bool isCompleted,
    required DateTime updatedAt,
  }) {
    return (update(tasks)..where((task) => task.id.equals(id))).write(
      TasksCompanion(
        isCompleted: Value(isCompleted),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<int> setTaskFocusMinutes({
    required int id,
    required int focusMinutes,
    required DateTime updatedAt,
  }) {
    return (update(tasks)..where((task) => task.id.equals(id))).write(
      TasksCompanion(
        focusMinutes: Value(focusMinutes),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<int> deleteTask(int id) {
    return (delete(tasks)..where((task) => task.id.equals(id))).go();
  }
}
