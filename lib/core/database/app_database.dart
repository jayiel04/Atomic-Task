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

@DataClassName('TaskRecurrenceRuleRow')
class TaskRecurrenceRules extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get frequency => text()();

  IntColumn get interval => integer()();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endDate => dateTime().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('TaskRow')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get dueDate => dateTime().nullable()();

  IntColumn get focusMinutes => integer().nullable()();

  DateTimeColumn get completedAt => dateTime().nullable()();

  IntColumn get recurrenceRuleId => integer().nullable().references(
    TaskRecurrenceRules,
    #id,
    onDelete: KeyAction.setNull,
  )();

  DateTimeColumn get occurrenceDate => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {recurrenceRuleId, occurrenceDate},
  ];
}

class TaskWithRecurrenceRow {
  const TaskWithRecurrenceRow({required this.task, this.recurrenceRule});

  final TaskRow? task;
  final TaskRecurrenceRuleRow? recurrenceRule;
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
  tables: [
    TimerProgress,
    TaskRecurrenceRules,
    Tasks,
    ActiveTimerSessions,
    PendingTimerSummaries,
  ],
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
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 5) {
        await migrator.createTable(taskRecurrenceRules);
      }
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
      if (from >= 2 && from < 5) {
        await migrator.addColumn(tasks, tasks.recurrenceRuleId);
        await migrator.addColumn(tasks, tasks.occurrenceDate);
        await customStatement(
          'CREATE UNIQUE INDEX tasks_recurrence_occurrence_unique '
          'ON tasks (recurrence_rule_id, occurrence_date)',
        );
      }
      if (from >= 2 && from < 6) {
        await migrator.addColumn(tasks, tasks.completedAt);
        await customStatement(
          'UPDATE tasks SET completed_at = updated_at '
          'WHERE is_completed = 1 AND completed_at IS NULL',
        );
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

  Stream<List<TaskWithRecurrenceRow>> watchTasksWithRecurrence() {
    final query =
        select(tasks).join([
          leftOuterJoin(
            taskRecurrenceRules,
            taskRecurrenceRules.id.equalsExp(tasks.recurrenceRuleId),
          ),
        ])..orderBy([
          OrderingTerm(expression: tasks.isCompleted),
          OrderingTerm(expression: tasks.dueDate.isNull()),
          OrderingTerm(expression: tasks.dueDate),
          OrderingTerm(expression: tasks.createdAt),
        ]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => TaskWithRecurrenceRow(
              task: row.readTable(tasks),
              recurrenceRule: row.readTableOrNull(taskRecurrenceRules),
            ),
          )
          .toList(growable: false),
    );
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
        completedAt: Value(isCompleted ? updatedAt : null),
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

  Future<int> insertRecurringTask({
    required TaskRecurrenceRulesCompanion rule,
    required String title,
    required DateTime? dueDate,
    required DateTime occurrenceDate,
    required DateTime createdAt,
  }) {
    return transaction(() async {
      final ruleId = await into(taskRecurrenceRules).insert(rule);
      return into(tasks).insert(
        TasksCompanion.insert(
          title: title,
          dueDate: Value(dueDate),
          recurrenceRuleId: Value(ruleId),
          occurrenceDate: Value(occurrenceDate),
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
    });
  }

  Future<void> updateRecurringSeries({
    required int ruleId,
    required int taskId,
    required String title,
    required DateTime? dueDate,
    required String frequency,
    required int interval,
    required DateTime startDate,
    required DateTime? endDate,
    required DateTime updatedAt,
  }) {
    return transaction(() async {
      await (update(
        taskRecurrenceRules,
      )..where((rule) => rule.id.equals(ruleId))).write(
        TaskRecurrenceRulesCompanion(
          frequency: Value(frequency),
          interval: Value(interval),
          startDate: Value(startDate),
          endDate: Value(endDate),
          updatedAt: Value(updatedAt),
        ),
      );
      await (update(tasks)..where(
            (task) =>
                task.recurrenceRuleId.equals(ruleId) &
                task.isCompleted.equals(false),
          ))
          .write(
            TasksCompanion(
              title: Value(title),
              dueDate: Value(dueDate),
              updatedAt: Value(updatedAt),
            ),
          );
      await (update(tasks)..where((task) => task.id.equals(taskId))).write(
        TasksCompanion(
          title: Value(title),
          dueDate: Value(dueDate),
          updatedAt: Value(updatedAt),
        ),
      );
    });
  }

  Future<void> setTaskRecurrenceActive({
    required int ruleId,
    required bool isActive,
    required DateTime updatedAt,
  }) async {
    await (update(
      taskRecurrenceRules,
    )..where((rule) => rule.id.equals(ruleId))).write(
      TaskRecurrenceRulesCompanion(
        isActive: Value(isActive),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> completeRecurringTaskOccurrence({
    required int taskId,
    required DateTime? nextOccurrenceDate,
    required DateTime updatedAt,
  }) {
    return transaction(() async {
      final current = await (select(
        tasks,
      )..where((task) => task.id.equals(taskId))).getSingleOrNull();
      if (current == null) {
        return;
      }
      await (update(tasks)..where((task) => task.id.equals(taskId))).write(
        TasksCompanion(
          isCompleted: const Value(true),
          completedAt: Value(updatedAt),
          updatedAt: Value(updatedAt),
        ),
      );
      if (nextOccurrenceDate != null) {
        await _insertNextOccurrence(
          template: current,
          occurrenceDate: nextOccurrenceDate,
          createdAt: updatedAt,
        );
      }
    });
  }

  Future<void> deleteRecurringTaskOccurrence({
    required int taskId,
    required DateTime? nextOccurrenceDate,
    required DateTime updatedAt,
  }) {
    return transaction(() async {
      final current = await (select(
        tasks,
      )..where((task) => task.id.equals(taskId))).getSingleOrNull();
      if (current == null) {
        return;
      }
      if (nextOccurrenceDate != null) {
        await _insertNextOccurrence(
          template: current,
          occurrenceDate: nextOccurrenceDate,
          createdAt: updatedAt,
        );
      }
      await (delete(tasks)..where((task) => task.id.equals(taskId))).go();
    });
  }

  Future<void> deleteTaskRecurrenceSeries(int ruleId) {
    return transaction(() async {
      await (delete(
        tasks,
      )..where((task) => task.recurrenceRuleId.equals(ruleId))).go();
      await (delete(
        taskRecurrenceRules,
      )..where((rule) => rule.id.equals(ruleId))).go();
    });
  }

  Future<List<TaskWithRecurrenceRow>> readTaskRecurrenceSeries() async {
    final query = select(taskRecurrenceRules).join([
      leftOuterJoin(
        tasks,
        tasks.recurrenceRuleId.equalsExp(taskRecurrenceRules.id),
      ),
    ]);
    final rows = await query.get();
    return rows
        .map(
          (row) => TaskWithRecurrenceRow(
            task: row.readTableOrNull(tasks),
            recurrenceRule: row.readTable(taskRecurrenceRules),
          ),
        )
        .toList(growable: false);
  }

  Future<void> ensureTaskOccurrence({
    required int templateTaskId,
    required DateTime occurrenceDate,
    required DateTime createdAt,
  }) {
    return transaction(() async {
      final template = await (select(
        tasks,
      )..where((task) => task.id.equals(templateTaskId))).getSingleOrNull();
      if (template != null) {
        await _insertNextOccurrence(
          template: template,
          occurrenceDate: occurrenceDate,
          createdAt: createdAt,
        );
      }
    });
  }

  Future<void> _insertNextOccurrence({
    required TaskRow template,
    required DateTime occurrenceDate,
    required DateTime createdAt,
  }) async {
    await into(tasks).insert(
      TasksCompanion.insert(
        title: template.title,
        dueDate: Value(template.dueDate),
        focusMinutes: Value(template.focusMinutes),
        recurrenceRuleId: Value(template.recurrenceRuleId),
        occurrenceDate: Value(occurrenceDate),
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }
}
