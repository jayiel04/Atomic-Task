import 'package:atomic_task/core/database/app_database.dart';
import 'package:atomic_task/features/timer/data/datasources/timer_local_data_source.dart';
import 'package:atomic_task/features/timer/data/models/progress_model.dart';
import 'package:atomic_task/features/timer/data/repositories/timer_session_repository_impl.dart';
import 'package:atomic_task/features/timer/domain/entities/timer_mode.dart';
import 'package:atomic_task/features/timer/domain/entities/timer_session.dart';
import 'package:atomic_task/features/timer/domain/entities/user_progress.dart';
import 'package:atomic_task/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';

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

  test('persists, orders, updates and deletes tasks', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);
    final dataSource = DriftTaskLocalDataSource(database);
    final now = DateTime(2026, 8, 10, 9);

    final noDateId = await dataSource.create(
      title: 'Sin fecha',
      dueDate: null,
      createdAt: now,
    );
    final datedId = await dataSource.create(
      title: 'Con fecha',
      dueDate: DateTime(2026, 8, 12),
      createdAt: now.add(const Duration(minutes: 1)),
    );

    var tasks = await dataSource.watchAll().first;
    expect(tasks.map((task) => task.id), [datedId, noDateId]);
    expect(tasks.first.dueDate, DateTime(2026, 8, 12));

    await dataSource.update(
      id: datedId,
      title: 'Fecha eliminada',
      dueDate: null,
      updatedAt: now.add(const Duration(hours: 1)),
    );
    await dataSource.setCompleted(
      id: noDateId,
      isCompleted: true,
      updatedAt: now.add(const Duration(hours: 2)),
    );
    await dataSource.setFocusMinutes(
      id: datedId,
      focusMinutes: 45,
      updatedAt: now.add(const Duration(hours: 3)),
    );

    tasks = await dataSource.watchAll().first;
    expect(tasks.first.id, datedId);
    expect(tasks.first.title, 'Fecha eliminada');
    expect(tasks.first.dueDate, isNull);
    expect(tasks.first.focusMinutes, 45);
    expect(tasks.last.isCompleted, isTrue);

    await dataSource.delete(datedId);
    tasks = await dataSource.watchAll().first;
    expect(tasks, hasLength(1));
    expect(tasks.single.id, noDateId);
  });

  test('migrates version 1 without losing timer progress', () async {
    final sqliteDatabase = sqlite3.openInMemory();
    sqliteDatabase.execute('''
      CREATE TABLE timer_progress (
        id INTEGER NOT NULL PRIMARY KEY,
        gems INTEGER NOT NULL DEFAULT 0,
        total_focus_seconds INTEGER NOT NULL DEFAULT 0,
        profile_name TEXT NOT NULL DEFAULT 'NOMBRE'
      );
      INSERT INTO timer_progress
        (id, gems, total_focus_seconds, profile_name)
      VALUES (1, 9, 720, 'Javier');
      PRAGMA user_version = 1;
    ''');

    final database = AppDatabase(
      executor: NativeDatabase.opened(sqliteDatabase),
    );
    addTearDown(database.close);

    final progress = await database.readProgress();
    final tasks = await database.watchAllTasks().first;

    expect(progress?.gems, 9);
    expect(progress?.totalFocusSeconds, 720);
    expect(progress?.profileName, 'Javier');
    expect(tasks, isEmpty);
  });

  test('migrates version 2 tasks by adding focus minutes', () async {
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
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
      INSERT INTO tasks
        (title, is_completed, created_at, updated_at)
      VALUES ('Tarea existente', 0, 1786348800, 1786348800);
      PRAGMA user_version = 2;
    ''');

    final database = AppDatabase(
      executor: NativeDatabase.opened(sqliteDatabase),
    );
    addTearDown(database.close);
    final dataSource = DriftTaskLocalDataSource(database);

    var tasks = await dataSource.watchAll().first;
    expect(tasks.single.title, 'Tarea existente');
    expect(tasks.single.focusMinutes, isNull);

    await dataSource.setFocusMinutes(
      id: tasks.single.id,
      focusMinutes: 30,
      updatedAt: DateTime(2026, 8, 10),
    );
    tasks = await dataSource.watchAll().first;
    expect(tasks.single.focusMinutes, 30);
  });

  test('persists active sessions and pending summaries', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftTimerSessionRepository(database);
    final checkpoint = DateTime(2026, 8, 13, 10);

    await repository.saveActiveSession(
      ActiveTimerSession(
        sessionId: 'session-1',
        mode: TimerMode.focus,
        state: TimerSessionState.running,
        selectedSeconds: 1500,
        remainingSeconds: 900,
        elapsedSeconds: 600,
        rewardedBlocks: 3,
        chargedMinutes: 0,
        lastCheckpointAt: checkpoint,
        endsAt: checkpoint.add(const Duration(minutes: 15)),
        linkedTaskId: 4,
        linkedTaskTitle: 'Escribir informe',
      ),
    );

    final active = await repository.loadActiveSession();
    expect(active?.sessionId, 'session-1');
    expect(active?.state, TimerSessionState.running);
    expect(active?.linkedTaskTitle, 'Escribir informe');

    await repository.savePendingSummary(
      CompletionSummary(
        sessionId: 'session-1',
        mode: TimerMode.focus,
        completedSeconds: 1500,
        gemDelta: 8,
        completedAt: checkpoint,
        taskId: 4,
        taskTitle: 'Escribir informe',
        adPending: true,
      ),
    );

    final summary = await repository.loadPendingSummary();
    expect(summary?.gemDelta, 8);
    expect(summary?.adPending, isTrue);
    expect(summary?.taskTitle, 'Escribir informe');

    await repository.finalizeSession(
      summary!,
      const UserProgress(
        gems: 15,
        totalFocusSeconds: 1500,
        profileName: 'Javier',
      ),
    );
    expect(await repository.loadActiveSession(), isNull);
    expect((await database.readProgress())?.gems, 15);
    expect((await repository.loadPendingSummary())?.sessionId, 'session-1');

    await repository.clearActiveSession();
    await repository.clearPendingSummary();
    expect(await repository.loadActiveSession(), isNull);
    expect(await repository.loadPendingSummary(), isNull);
  });

  test('migrates version 3 by adding session tables', () async {
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
      INSERT INTO timer_progress
        (id, gems, total_focus_seconds, profile_name)
      VALUES (1, 6, 360, 'Javier');
      PRAGMA user_version = 3;
    ''');

    final database = AppDatabase(
      executor: NativeDatabase.opened(sqliteDatabase),
    );
    addTearDown(database.close);

    expect((await database.readProgress())?.gems, 6);
    expect(await database.readActiveTimerSession(), isNull);
    expect(await database.readPendingTimerSummary(), isNull);
  });
}
