import '../entities/recurrence_rule.dart';

class RecurrenceCalculator {
  const RecurrenceCalculator();

  DateTime? nextOccurrence(RecurrenceRule rule, DateTime after) {
    _validate(rule);
    final current = _dateOnly(after);
    final start = _dateOnly(rule.startDate);
    final candidate = current.isBefore(start)
        ? start
        : switch (rule.frequency) {
            RecurrenceFrequency.daily => current.add(
              Duration(days: rule.interval),
            ),
            RecurrenceFrequency.weekly => current.add(
              Duration(days: 7 * rule.interval),
            ),
            RecurrenceFrequency.monthly => _addMonths(
              current,
              rule.interval,
              start.day,
            ),
          };
    return _withinEnd(rule, candidate) ? candidate : null;
  }

  DateTime? firstOccurrenceOnOrAfter(RecurrenceRule rule, DateTime target) {
    _validate(rule);
    final start = _dateOnly(rule.startDate);
    final requested = _dateOnly(target);
    if (!requested.isAfter(start)) {
      return _withinEnd(rule, start) ? start : null;
    }

    final DateTime candidate;
    switch (rule.frequency) {
      case RecurrenceFrequency.daily:
        final elapsedDays = requested.difference(start).inDays;
        final steps = (elapsedDays + rule.interval - 1) ~/ rule.interval;
        candidate = start.add(Duration(days: steps * rule.interval));
      case RecurrenceFrequency.weekly:
        final intervalDays = 7 * rule.interval;
        final elapsedDays = requested.difference(start).inDays;
        final steps = (elapsedDays + intervalDays - 1) ~/ intervalDays;
        candidate = start.add(Duration(days: steps * intervalDays));
      case RecurrenceFrequency.monthly:
        final elapsedMonths =
            (requested.year - start.year) * 12 + requested.month - start.month;
        var steps = (elapsedMonths + rule.interval - 1) ~/ rule.interval;
        var monthlyCandidate = _addMonths(
          start,
          steps * rule.interval,
          start.day,
        );
        if (monthlyCandidate.isBefore(requested)) {
          steps += 1;
          monthlyCandidate = _addMonths(
            start,
            steps * rule.interval,
            start.day,
          );
        }
        candidate = monthlyCandidate;
    }

    return _withinEnd(rule, candidate) ? candidate : null;
  }

  DateTime _addMonths(DateTime date, int months, int anchorDay) {
    final monthIndex = date.year * 12 + date.month - 1 + months;
    final year = monthIndex ~/ 12;
    final month = monthIndex % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, anchorDay.clamp(1, lastDay));
  }

  bool _withinEnd(RecurrenceRule rule, DateTime candidate) {
    final endDate = rule.endDate;
    return endDate == null || !candidate.isAfter(_dateOnly(endDate));
  }

  void _validate(RecurrenceRule rule) {
    if (rule.interval < 1) {
      throw ArgumentError.value(
        rule.interval,
        'interval',
        'El intervalo debe ser mayor que cero',
      );
    }
    final endDate = rule.endDate;
    if (endDate != null &&
        _dateOnly(endDate).isBefore(_dateOnly(rule.startDate))) {
      throw ArgumentError.value(
        endDate,
        'endDate',
        'La fecha final no puede ser anterior a la fecha de inicio',
      );
    }
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
