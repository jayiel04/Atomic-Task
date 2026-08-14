import '../domain/entities/recurrence_rule.dart';
import 'task_date_formatter.dart';

abstract final class TaskRecurrenceFormatter {
  static String frequency(RecurrenceRule rule) {
    final unit = switch (rule.frequency) {
      RecurrenceFrequency.daily => rule.interval == 1 ? 'día' : 'días',
      RecurrenceFrequency.weekly => rule.interval == 1 ? 'semana' : 'semanas',
      RecurrenceFrequency.monthly => rule.interval == 1 ? 'mes' : 'meses',
    };
    return rule.interval == 1 ? 'Cada $unit' : 'Cada ${rule.interval} $unit';
  }

  static String occurrence(DateTime date, {required bool completed}) {
    final prefix = completed ? 'Ocurrencia' : 'Próxima';
    return '$prefix: ${TaskDateFormatter.format(date)}';
  }
}
