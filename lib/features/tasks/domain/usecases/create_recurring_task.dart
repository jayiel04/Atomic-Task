import '../entities/recurrence_rule.dart';
import '../repositories/task_recurrence_repository.dart';

class CreateRecurringTask {
  const CreateRecurringTask(this._repository);

  final TaskRecurrenceRepository _repository;

  Future<int> call({
    required String title,
    required DateTime? dueDate,
    required RecurrenceFrequency frequency,
    required int interval,
    required DateTime startDate,
    required DateTime? endDate,
    required DateTime createdAt,
  }) {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(
        title,
        'title',
        'El titulo no puede estar vacio',
      );
    }
    _validateDates(interval: interval, startDate: startDate, endDate: endDate);
    final normalizedStart = _dateOnly(startDate);
    final normalizedEnd = endDate == null ? null : _dateOnly(endDate);
    return _repository.createRecurringTask(
      title: normalizedTitle,
      dueDate: dueDate,
      rule: RecurrenceRule(
        id: 0,
        frequency: frequency,
        interval: interval,
        startDate: normalizedStart,
        endDate: normalizedEnd,
        isActive: true,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      createdAt: createdAt,
    );
  }
}

void validateRecurrence({
  required int interval,
  required DateTime startDate,
  required DateTime? endDate,
}) =>
    _validateDates(interval: interval, startDate: startDate, endDate: endDate);

void _validateDates({
  required int interval,
  required DateTime startDate,
  required DateTime? endDate,
}) {
  if (interval < 1) {
    throw ArgumentError.value(
      interval,
      'interval',
      'El intervalo debe ser mayor que cero',
    );
  }
  if (endDate != null && _dateOnly(endDate).isBefore(_dateOnly(startDate))) {
    throw ArgumentError.value(
      endDate,
      'endDate',
      'La fecha final no puede ser anterior a la fecha de inicio',
    );
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
