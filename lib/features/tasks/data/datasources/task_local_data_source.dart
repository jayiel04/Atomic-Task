import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/task_model.dart';

abstract interface class TaskLocalDataSource {
  Stream<List<TaskModel>> watchAll();

  Future<int> create({
    required String title,
    required DateTime? dueDate,
    required DateTime createdAt,
  });

  Future<void> update({
    required int id,
    required String title,
    required DateTime? dueDate,
    required DateTime updatedAt,
  });

  Future<void> setCompleted({
    required int id,
    required bool isCompleted,
    required DateTime updatedAt,
  });

  Future<void> setFocusMinutes({
    required int id,
    required int focusMinutes,
    required DateTime updatedAt,
  });

  Future<void> delete(int id);
}

class DriftTaskLocalDataSource implements TaskLocalDataSource {
  const DriftTaskLocalDataSource(this._database);

  final AppDatabase _database;

  @override
  Stream<List<TaskModel>> watchAll() {
    return _database.watchAllTasks().map(
      (rows) => rows.map(TaskModel.fromRow).toList(growable: false),
    );
  }

  @override
  Future<int> create({
    required String title,
    required DateTime? dueDate,
    required DateTime createdAt,
  }) {
    return _database.insertTask(
      TasksCompanion.insert(
        title: title,
        dueDate: Value(dueDate),
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
    );
  }

  @override
  Future<void> update({
    required int id,
    required String title,
    required DateTime? dueDate,
    required DateTime updatedAt,
  }) async {
    await _database.updateTask(
      id: id,
      title: title,
      dueDate: dueDate,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> setCompleted({
    required int id,
    required bool isCompleted,
    required DateTime updatedAt,
  }) async {
    await _database.setTaskCompleted(
      id: id,
      isCompleted: isCompleted,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> setFocusMinutes({
    required int id,
    required int focusMinutes,
    required DateTime updatedAt,
  }) async {
    await _database.setTaskFocusMinutes(
      id: id,
      focusMinutes: focusMinutes,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> delete(int id) async {
    await _database.deleteTask(id);
  }
}
