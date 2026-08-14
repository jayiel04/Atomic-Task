import 'atomic_task.dart';
import 'recurrence_rule.dart';

class RecurrenceSeriesState {
  const RecurrenceSeriesState({required this.rule, required this.occurrences});

  final RecurrenceRule rule;
  final List<AtomicTask> occurrences;
}
