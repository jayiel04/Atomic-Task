import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/atomic_task.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../../domain/entities/recurrence_series_state.dart';
import '../models/task_model.dart';
import '../models/recurrence_rule_model.dart';

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

abstract interface class TaskRecurrenceLocalDataSource {
  Future<int> createRecurring({
    required String title,
    required DateTime? dueDate,
    required RecurrenceRule rule,
    required DateTime createdAt,
  });

  Future<void> updateSeries({
    required AtomicTask task,
    required String title,
    required DateTime? dueDate,
    required RecurrenceRule rule,
    required DateTime updatedAt,
  });

  Future<void> setRecurrenceActive({
    required int ruleId,
    required bool isActive,
    required DateTime updatedAt,
  });

  Future<void> completeOccurrence({
    required AtomicTask task,
    required DateTime? nextOccurrenceDate,
    required DateTime updatedAt,
  });

  Future<void> deleteOccurrence({
    required AtomicTask task,
    required DateTime? nextOccurrenceDate,
    required DateTime updatedAt,
  });

  Future<void> deleteSeries(int ruleId);

  Future<List<RecurrenceSeriesState>> loadSeries();

  Future<void> ensureOccurrence({
    required AtomicTask template,
    required DateTime occurrenceDate,
    required DateTime createdAt,
  });
}

class DriftTaskLocalDataSource
    implements TaskLocalDataSource, TaskRecurrenceLocalDataSource {
  const DriftTaskLocalDataSource(this._database);

  final AppDatabase _database;

  @override
  Stream<List<TaskModel>> watchAll() {
    return _database.watchTasksWithRecurrence().map(
      (rows) => rows.map(TaskModel.fromDatabaseRow).toList(growable: false),
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

  @override
  Future<int> createRecurring({
    required String title,
    required DateTime? dueDate,
    required RecurrenceRule rule,
    required DateTime createdAt,
  }) {
    return _database.insertRecurringTask(
      rule: TaskRecurrenceRulesCompanion.insert(
        frequency: rule.frequency.name,
        interval: rule.interval,
        startDate: rule.startDate,
        endDate: Value(rule.endDate),
        isActive: Value(rule.isActive),
        createdAt: rule.createdAt,
        updatedAt: rule.updatedAt,
      ),
      title: title,
      dueDate: dueDate,
      occurrenceDate: rule.startDate,
      createdAt: createdAt,
    );
  }

  @override
  Future<void> updateSeries({
    required AtomicTask task,
    required String title,
    required DateTime? dueDate,
    required RecurrenceRule rule,
    required DateTime updatedAt,
  }) {
    return _database.updateRecurringSeries(
      ruleId: rule.id,
      taskId: task.id,
      title: title,
      dueDate: dueDate,
      frequency: rule.frequency.name,
      interval: rule.interval,
      startDate: rule.startDate,
      endDate: rule.endDate,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> setRecurrenceActive({
    required int ruleId,
    required bool isActive,
    required DateTime updatedAt,
  }) {
    return _database.setTaskRecurrenceActive(
      ruleId: ruleId,
      isActive: isActive,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> completeOccurrence({
    required AtomicTask task,
    required DateTime? nextOccurrenceDate,
    required DateTime updatedAt,
  }) {
    return _database.completeRecurringTaskOccurrence(
      taskId: task.id,
      nextOccurrenceDate: nextOccurrenceDate,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> deleteOccurrence({
    required AtomicTask task,
    required DateTime? nextOccurrenceDate,
    required DateTime updatedAt,
  }) {
    return _database.deleteRecurringTaskOccurrence(
      taskId: task.id,
      nextOccurrenceDate: nextOccurrenceDate,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> deleteSeries(int ruleId) {
    return _database.deleteTaskRecurrenceSeries(ruleId);
  }

  @override
  Future<List<RecurrenceSeriesState>> loadSeries() async {
    final rows = await _database.readTaskRecurrenceSeries();
    final groupedTasks = <int, List<AtomicTask>>{};
    final groupedRules = <int, RecurrenceRule>{};
    for (final row in rows) {
      final recurrenceRow = row.recurrenceRule;
      if (recurrenceRow == null) {
        continue;
      }
      groupedRules[recurrenceRow.id] = RecurrenceRuleModel.fromRow(
        recurrenceRow,
      );
      if (row.task != null) {
        groupedTasks
            .putIfAbsent(recurrenceRow.id, () => <AtomicTask>[])
            .add(TaskModel.fromDatabaseRow(row));
      }
    }
    return groupedRules.entries
        .map(
          (entry) => RecurrenceSeriesState(
            rule: entry.value,
            occurrences: List.unmodifiable(
              groupedTasks[entry.key] ?? const <AtomicTask>[],
            ),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> ensureOccurrence({
    required AtomicTask template,
    required DateTime occurrenceDate,
    required DateTime createdAt,
  }) {
    return _database.ensureTaskOccurrence(
      templateTaskId: template.id,
      occurrenceDate: occurrenceDate,
      createdAt: createdAt,
    );
  }
}
