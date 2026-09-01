import '../entities/atomic_task.dart';
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
    DateTime? reminderAt,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
    String? reminderSoundKey,
    bool reminderEveryOccurrence = true,
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
    _validateReminderAt(reminderAt);
    final normalizedReminderAt = reminderAt == null
        ? null
        : DateTime(
            normalizedStart.year,
            normalizedStart.month,
            normalizedStart.day,
            reminderAt.hour,
            reminderAt.minute,
          );
    return _repository.createRecurringTask(
      title: normalizedTitle,
      dueDate: dueDate,
      rule: RecurrenceRule(
        id: 0,
        frequency: frequency,
        interval: interval,
        startDate: normalizedStart,
        endDate: normalizedEnd,
        reminderTimeMinutes:
            normalizedReminderAt == null || !reminderEveryOccurrence
            ? null
            : _minutesSinceMidnight(normalizedReminderAt),
        isActive: true,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      createdAt: createdAt,
      reminderAt: normalizedReminderAt,
      reminderMode: reminderMode,
      reminderSoundKey: reminderSoundKey,
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

int _minutesSinceMidnight(DateTime value) => value.hour * 60 + value.minute;

void _validateReminderAt(DateTime? reminderAt) {
  if (reminderAt == null) {
    return;
  }
  final minutes = _minutesSinceMidnight(reminderAt);
  if (minutes < 0 || minutes > 1439) {
    throw ArgumentError.value(
      reminderAt,
      'reminderAt',
      'La hora del recordatorio debe estar entre 00:00 y 23:59',
    );
  }
}
