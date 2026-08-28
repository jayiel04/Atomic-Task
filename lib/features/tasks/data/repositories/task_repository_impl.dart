import '../../domain/entities/atomic_task.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../../domain/entities/recurrence_series_state.dart';
import '../../domain/repositories/task_recurrence_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';

class TaskRepositoryImpl
    implements TaskRepository, TaskAlarmRepository, TaskRecurrenceRepository {
  const TaskRepositoryImpl(this._localDataSource);

  final TaskLocalDataSource _localDataSource;

  TaskRecurrenceLocalDataSource get _recurrenceDataSource {
    final source = _localDataSource;
    if (source case final TaskRecurrenceLocalDataSource recurrenceSource) {
      return recurrenceSource;
    }
    throw UnsupportedError(
      'La fuente de datos configurada no admite recurrencias',
    );
  }

  TaskAlarmLocalDataSource get _alarmDataSource {
    final source = _localDataSource;
    if (source case final TaskAlarmLocalDataSource alarmSource) {
      return alarmSource;
    }
    throw UnsupportedError(
      'La fuente de datos configurada no admite recordatorios',
    );
  }

  @override
  Stream<List<AtomicTask>> watchTasks() => _localDataSource.watchAll();

  @override
  Future<int> createTask({
    required String title,
    required DateTime? dueDate,
    required DateTime createdAt,
  }) {
    return _localDataSource.create(
      title: title,
      dueDate: dueDate,
      createdAt: createdAt,
    );
  }

  @override
  Future<void> updateTask({
    required int id,
    required String title,
    required DateTime? dueDate,
    required DateTime updatedAt,
  }) {
    return _localDataSource.update(
      id: id,
      title: title,
      dueDate: dueDate,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<int> createTaskWithReminder({
    required String title,
    required DateTime? dueDate,
    required DateTime? reminderAt,
    required DateTime createdAt,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
  }) {
    return _alarmDataSource.createWithReminder(
      title: title,
      dueDate: dueDate,
      reminderAt: reminderAt,
      createdAt: createdAt,
      reminderMode: reminderMode,
    );
  }

  @override
  Future<void> updateTaskWithReminder({
    required int id,
    required String title,
    required DateTime? dueDate,
    required DateTime? reminderAt,
    required DateTime updatedAt,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
  }) {
    return _alarmDataSource.updateWithReminder(
      id: id,
      title: title,
      dueDate: dueDate,
      reminderAt: reminderAt,
      updatedAt: updatedAt,
      reminderMode: reminderMode,
    );
  }

  @override
  Future<void> setTaskCompleted({
    required int id,
    required bool isCompleted,
    required DateTime updatedAt,
  }) {
    return _localDataSource.setCompleted(
      id: id,
      isCompleted: isCompleted,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> setTaskFocusMinutes({
    required int id,
    required int focusMinutes,
    required DateTime updatedAt,
  }) {
    return _localDataSource.setFocusMinutes(
      id: id,
      focusMinutes: focusMinutes,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> deleteTask(int id) => _localDataSource.delete(id);

  @override
  Future<int> createRecurringTask({
    required String title,
    required DateTime? dueDate,
    required RecurrenceRule rule,
    required DateTime createdAt,
    DateTime? reminderAt,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
  }) {
    return _recurrenceDataSource.createRecurring(
      title: title,
      dueDate: dueDate,
      rule: rule,
      createdAt: createdAt,
      reminderAt: reminderAt,
      reminderMode: reminderMode,
    );
  }

  @override
  Future<void> updateRecurringSeries({
    required AtomicTask task,
    required String title,
    required DateTime? dueDate,
    required RecurrenceRule rule,
    required DateTime updatedAt,
    DateTime? reminderAt,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
  }) {
    return _recurrenceDataSource.updateSeries(
      task: task,
      title: title,
      dueDate: dueDate,
      rule: rule,
      updatedAt: updatedAt,
      reminderAt: reminderAt,
      reminderMode: reminderMode,
    );
  }

  @override
  Future<void> setRecurrenceActive({
    required int ruleId,
    required bool isActive,
    required DateTime updatedAt,
  }) {
    return _recurrenceDataSource.setRecurrenceActive(
      ruleId: ruleId,
      isActive: isActive,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> completeRecurringOccurrence({
    required AtomicTask task,
    required DateTime? nextOccurrenceDate,
    required DateTime updatedAt,
  }) {
    return _recurrenceDataSource.completeOccurrence(
      task: task,
      nextOccurrenceDate: nextOccurrenceDate,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> deleteRecurringOccurrence({
    required AtomicTask task,
    required DateTime? nextOccurrenceDate,
    required DateTime updatedAt,
  }) {
    return _recurrenceDataSource.deleteOccurrence(
      task: task,
      nextOccurrenceDate: nextOccurrenceDate,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> deleteRecurrenceSeries(int ruleId) {
    return _recurrenceDataSource.deleteSeries(ruleId);
  }

  @override
  Future<List<RecurrenceSeriesState>> loadRecurrenceSeries() {
    return _recurrenceDataSource.loadSeries();
  }

  @override
  Future<void> ensureOccurrence({
    required AtomicTask template,
    required DateTime occurrenceDate,
    required DateTime createdAt,
  }) {
    return _recurrenceDataSource.ensureOccurrence(
      template: template,
      occurrenceDate: occurrenceDate,
      createdAt: createdAt,
    );
  }
}
