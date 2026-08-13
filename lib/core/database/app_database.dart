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

@DataClassName('ActiveTimerSessionRow')
class ActiveTimerSessions extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  TextColumn get sessionId => text()();

  TextColumn get mode => text()();

  TextColumn get state => text()();

  IntColumn get selectedSeconds => integer()();

  IntColumn get remainingSeconds => integer()();

  IntColumn get elapsedSeconds => integer()();

  IntColumn get rewardedBlocks => integer()();

  IntColumn get chargedMinutes => integer()();

  DateTimeColumn get lastCheckpointAt => dateTime()();

  DateTimeColumn get endsAt => dateTime().nullable()();

  IntColumn get linkedTaskId => integer().nullable()();

  TextColumn get linkedTaskTitle => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PendingTimerSummaryRow')
class PendingTimerSummaries extends Table {
  TextColumn get sessionId => text()();

  TextColumn get mode => text()();

  IntColumn get completedSeconds => integer()();

  IntColumn get gemDelta => integer()();

  DateTimeColumn get completedAt => dateTime()();

  IntColumn get taskId => integer().nullable()();

  TextColumn get taskTitle => text().nullable()();

  BoolColumn get inAppPending => boolean().withDefault(const Constant(true))();

  BoolColumn get notificationPending =>
      boolean().withDefault(const Constant(true))();

  BoolColumn get adPending => boolean().withDefault(const Constant(false))();

  BoolColumn get taskCompletionPending =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {sessionId};
}

@DriftDatabase(
  tables: [TimerProgress, Tasks, ActiveTimerSessions, PendingTimerSummaries],
)
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
  int get schemaVersion => 4;

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
      if (from < 4) {
        await migrator.createTable(activeTimerSessions);
        await migrator.createTable(pendingTimerSummaries);
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

  Future<ActiveTimerSessionRow?> readActiveTimerSession() {
    return select(activeTimerSessions).getSingleOrNull();
  }

  Future<void> writeActiveTimerSession(ActiveTimerSessionsCompanion session) {
    return into(activeTimerSessions).insertOnConflictUpdate(session);
  }

  Future<void> deleteActiveTimerSession() {
    return delete(activeTimerSessions).go();
  }

  Future<PendingTimerSummaryRow?> readPendingTimerSummary() {
    return select(pendingTimerSummaries).getSingleOrNull();
  }

  Future<void> writePendingTimerSummary(
    PendingTimerSummariesCompanion summary,
  ) {
    return into(pendingTimerSummaries).insertOnConflictUpdate(summary);
  }

  Future<void> deletePendingTimerSummary() {
    return delete(pendingTimerSummaries).go();
  }

  Future<void> finalizeTimerSession({
    required TimerProgressCompanion progress,
    required PendingTimerSummariesCompanion summary,
  }) {
    return transaction(() async {
      await into(timerProgress).insertOnConflictUpdate(progress);
      await delete(activeTimerSessions).go();
      await into(pendingTimerSummaries).insertOnConflictUpdate(summary);
    });
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
