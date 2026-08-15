import 'package:atomic_task/core/database/app_database.dart';
import 'package:atomic_task/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:atomic_task/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:atomic_task/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:atomic_task/features/tasks/domain/services/recurrence_calculator.dart';
import 'package:atomic_task/features/tasks/domain/services/recurrence_generation_policy.dart';
import 'package:atomic_task/features/tasks/domain/usecases/reconcile_task_recurrences.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('persists a rule and completes an occurrence transactionally', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);
    final dataSource = DriftTaskLocalDataSource(database);
    final createdAt = DateTime(2026, 8, 14, 9);
    final rule = _rule(startDate: DateTime(2026, 8, 14), createdAt: createdAt);

    await dataSource.createRecurring(
      title: 'Revisar objetivos',
      dueDate: null,
      rule: rule,
      createdAt: createdAt,
    );
    var tasks = await dataSource.watchAll().first;
    expect(tasks, hasLength(1));
    expect(tasks.single.recurrenceRule?.frequency, RecurrenceFrequency.daily);
    expect(tasks.single.occurrenceDate, DateTime(2026, 8, 14));

    final first = tasks.single;
    final completedAt = createdAt.add(const Duration(hours: 1));
    await dataSource.completeOccurrence(
      task: first,
      nextOccurrenceDate: DateTime(2026, 8, 15),
      updatedAt: completedAt,
    );
    await dataSource.completeOccurrence(
      task: first,
      nextOccurrenceDate: DateTime(2026, 8, 15),
      updatedAt: completedAt,
    );

    tasks = await dataSource.watchAll().first;
    expect(tasks, hasLength(2));
    expect(tasks.where((task) => task.isCompleted), hasLength(1));
    expect(
      tasks.singleWhere((task) => task.isCompleted).completedAt,
      completedAt,
    );
    expect(tasks.where((task) => !task.isCompleted), hasLength(1));
    expect(
      tasks.singleWhere((task) => !task.isCompleted).occurrenceDate,
      DateTime(2026, 8, 15),
    );
  });

  test(
    'reconciliation creates only one pending occurrence after missed dates',
    () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);
      final dataSource = DriftTaskLocalDataSource(database);
      final repository = TaskRepositoryImpl(dataSource);
      final createdAt = DateTime(2026, 8, 1, 9);

      await dataSource.createRecurring(
        title: 'Registrar hábitos',
        dueDate: null,
        rule: _rule(startDate: DateTime(2026, 8, 1), createdAt: createdAt),
        createdAt: createdAt,
      );
      final first = (await dataSource.watchAll().first).single;
      await dataSource.setCompleted(
        id: first.id,
        isCompleted: true,
        updatedAt: createdAt,
      );

      const calculator = RecurrenceCalculator();
      const policy = RecurrenceGenerationPolicy(calculator);
      final reconcile = ReconcileTaskRecurrences(repository, policy);
      await reconcile(DateTime(2026, 8, 14, 12));
      await reconcile(DateTime(2026, 8, 14, 12));

      final tasks = await dataSource.watchAll().first;
      expect(tasks, hasLength(2));
      final pending = tasks.singleWhere((task) => !task.isCompleted);
      expect(pending.occurrenceDate, DateTime(2026, 8, 14));
    },
  );

  test('migrates version 4 additively and preserves existing tasks', () async {
    final sqliteDatabase = sqlite3.openInMemory();
    sqliteDatabase.execute('''
      CREATE TABLE timer_progress (
        id INTEGER NOT NULL PRIMARY KEY,
        gems INTEGER NOT NULL DEFAULT 0,
        total_focus_seconds INTEGER NOT NULL DEFAULT 0,
        profile_name TEXT NOT NULL DEFAULT 'NOMBRE'
      );
      CREATE TABLE tasks (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        due_date INTEGER NULL,
        focus_minutes INTEGER NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
      CREATE TABLE pending_timer_summaries (
        session_id TEXT NOT NULL PRIMARY KEY,
        mode TEXT NOT NULL,
        completed_seconds INTEGER NOT NULL,
        gem_delta INTEGER NOT NULL,
        completed_at INTEGER NOT NULL,
        task_id INTEGER NULL,
        task_title TEXT NULL,
        in_app_pending INTEGER NOT NULL DEFAULT 1,
        notification_pending INTEGER NOT NULL DEFAULT 1,
        ad_pending INTEGER NOT NULL DEFAULT 0,
        task_completion_pending INTEGER NOT NULL DEFAULT 0
      );
      INSERT INTO tasks
        (title, is_completed, created_at, updated_at)
      VALUES ('Tarea v4', 0, 1786348800, 1786348800);
      PRAGMA user_version = 4;
    ''');
    final database = AppDatabase(
      executor: NativeDatabase.opened(sqliteDatabase),
    );
    addTearDown(database.close);
    final dataSource = DriftTaskLocalDataSource(database);

    var tasks = await dataSource.watchAll().first;
    expect(tasks.single.title, 'Tarea v4');
    expect(tasks.single.recurrenceRule, isNull);

    await dataSource.createRecurring(
      title: 'Nueva serie',
      dueDate: null,
      rule: _rule(
        startDate: DateTime(2026, 8, 14),
        createdAt: DateTime(2026, 8, 14),
      ),
      createdAt: DateTime(2026, 8, 14),
    );
    tasks = await dataSource.watchAll().first;
    expect(tasks, hasLength(2));
    expect(tasks.where((task) => task.isRecurring), hasLength(1));
  });
}

RecurrenceRule _rule({
  required DateTime startDate,
  required DateTime createdAt,
}) {
  return RecurrenceRule(
    id: 0,
    frequency: RecurrenceFrequency.daily,
    interval: 1,
    startDate: startDate,
    isActive: true,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
