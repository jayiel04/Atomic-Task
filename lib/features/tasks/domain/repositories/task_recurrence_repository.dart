import '../entities/atomic_task.dart';
import '../entities/recurrence_rule.dart';
import '../entities/recurrence_series_state.dart';

abstract interface class TaskRecurrenceRepository {
  Future<int> createRecurringTask({
    required String title,
    required DateTime? dueDate,
    required RecurrenceRule rule,
    required DateTime createdAt,
  });

  Future<void> updateRecurringSeries({
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

  Future<void> completeRecurringOccurrence({
    required AtomicTask task,
    required DateTime? nextOccurrenceDate,
    required DateTime updatedAt,
  });

  Future<void> deleteRecurringOccurrence({
    required AtomicTask task,
    required DateTime? nextOccurrenceDate,
    required DateTime updatedAt,
  });

  Future<void> deleteRecurrenceSeries(int ruleId);

  Future<List<RecurrenceSeriesState>> loadRecurrenceSeries();

  Future<void> ensureOccurrence({
    required AtomicTask template,
    required DateTime occurrenceDate,
    required DateTime createdAt,
  });
}
