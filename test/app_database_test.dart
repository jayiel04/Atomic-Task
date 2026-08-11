import 'package:atomic_task/core/database/app_database.dart';
import 'package:atomic_task/features/timer/data/datasources/timer_local_data_source.dart';
import 'package:atomic_task/features/timer/data/models/progress_model.dart';
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
}
