import '../entities/atomic_task.dart';
import '../repositories/task_recurrence_repository.dart';
import '../services/recurrence_generation_policy.dart';

class ReconcileTaskRecurrences {
  const ReconcileTaskRecurrences(this._repository, this._generationPolicy);

  final TaskRecurrenceRepository _repository;
  final RecurrenceGenerationPolicy _generationPolicy;

  Future<void> call(DateTime now) async {
    final today = DateTime(now.year, now.month, now.day);
    final series = await _repository.loadRecurrenceSeries();
    for (final state in series) {
      if (!state.rule.isActive ||
          state.occurrences.any((task) => !task.isCompleted)) {
        continue;
      }
      final datedOccurrences =
          state.occurrences
              .where((task) => task.occurrenceDate != null)
              .toList(growable: false)
            ..sort(
              (left, right) =>
                  left.occurrenceDate!.compareTo(right.occurrenceDate!),
            );
      if (datedOccurrences.isEmpty) {
        continue;
      }

      final AtomicTask template = datedOccurrences.last;
      var nextDate = _generationPolicy.nextAfter(
        state.rule,
        template.occurrenceDate!,
      );
      if (nextDate != null && nextDate.isBefore(today)) {
        nextDate = _generationPolicy.nextPendingOnOrAfter(state.rule, today);
      }
      if (nextDate != null) {
        await _repository.ensureOccurrence(
          template: template,
          occurrenceDate: nextDate,
          createdAt: now,
        );
      }
    }
  }
}
