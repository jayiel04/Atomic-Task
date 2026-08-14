import '../entities/recurrence_rule.dart';
import '../services/recurrence_generation_policy.dart';

class CalculateNextOccurrence {
  const CalculateNextOccurrence(this._generationPolicy);

  final RecurrenceGenerationPolicy _generationPolicy;

  DateTime? call(RecurrenceRule rule, DateTime occurrenceDate) {
    return _generationPolicy.nextAfter(rule, occurrenceDate);
  }
}
