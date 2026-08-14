import '../entities/recurrence_rule.dart';
import 'recurrence_calculator.dart';

class RecurrenceGenerationPolicy {
  const RecurrenceGenerationPolicy(this._calculator);

  final RecurrenceCalculator _calculator;

  DateTime? nextAfter(RecurrenceRule rule, DateTime occurrenceDate) {
    if (!rule.isActive) {
      return null;
    }
    return _calculator.nextOccurrence(rule, occurrenceDate);
  }

  DateTime? nextPendingOnOrAfter(RecurrenceRule rule, DateTime date) {
    if (!rule.isActive) {
      return null;
    }
    return _calculator.firstOccurrenceOnOrAfter(rule, date);
  }
}
