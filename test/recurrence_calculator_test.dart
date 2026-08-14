import 'package:atomic_task/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:atomic_task/features/tasks/domain/services/recurrence_calculator.dart';
import 'package:atomic_task/features/tasks/domain/services/recurrence_generation_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calculator = RecurrenceCalculator();
  const policy = RecurrenceGenerationPolicy(calculator);

  test('calculates daily and weekly intervals', () {
    final daily = _rule(
      frequency: RecurrenceFrequency.daily,
      interval: 2,
      startDate: DateTime(2026, 8, 14),
    );
    final weekly = _rule(
      frequency: RecurrenceFrequency.weekly,
      interval: 3,
      startDate: DateTime(2026, 8, 14),
    );

    expect(
      calculator.nextOccurrence(daily, DateTime(2026, 8, 14)),
      DateTime(2026, 8, 16),
    );
    expect(
      calculator.nextOccurrence(weekly, DateTime(2026, 8, 14)),
      DateTime(2026, 9, 4),
    );
  });

  test('anchors monthly recurrence and uses the last available day', () {
    final rule = _rule(
      frequency: RecurrenceFrequency.monthly,
      startDate: DateTime(2026, 1, 31),
    );

    final february = calculator.nextOccurrence(rule, rule.startDate);
    final march = calculator.nextOccurrence(rule, february!);

    expect(february, DateTime(2026, 2, 28));
    expect(march, DateTime(2026, 3, 31));
  });

  test('respects end dates and paused rules', () {
    final ended = _rule(
      frequency: RecurrenceFrequency.daily,
      startDate: DateTime(2026, 8, 14),
      endDate: DateTime(2026, 8, 14),
    );
    final paused = _rule(
      frequency: RecurrenceFrequency.daily,
      startDate: DateTime(2026, 8, 14),
      isActive: false,
    );

    expect(calculator.nextOccurrence(ended, ended.startDate), isNull);
    expect(policy.nextAfter(paused, paused.startDate), isNull);
  });

  test('skips missed dates and returns only the next pending occurrence', () {
    final rule = _rule(
      frequency: RecurrenceFrequency.daily,
      interval: 2,
      startDate: DateTime(2026, 8, 1),
    );

    expect(
      policy.nextPendingOnOrAfter(rule, DateTime(2026, 8, 14)),
      DateTime(2026, 8, 15),
    );
  });
}

RecurrenceRule _rule({
  required RecurrenceFrequency frequency,
  required DateTime startDate,
  int interval = 1,
  DateTime? endDate,
  bool isActive = true,
}) {
  return RecurrenceRule(
    id: 1,
    frequency: frequency,
    interval: interval,
    startDate: startDate,
    endDate: endDate,
    isActive: isActive,
    createdAt: startDate,
    updatedAt: startDate,
  );
}
