import 'recurrence_rule.dart';

class AtomicTask {
  const AtomicTask({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.focusMinutes,
    this.completedAt,
    this.occurrenceDate,
    this.recurrenceRule,
  });

  final int id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final int? focusMinutes;
  final DateTime? completedAt;
  final DateTime? occurrenceDate;
  final RecurrenceRule? recurrenceRule;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isRecurring => recurrenceRule != null;

  bool isOverdueAt(DateTime now) {
    final deadline = dueDate;
    if (isCompleted || deadline == null) {
      return false;
    }

    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
    return deadlineDay.isBefore(today);
  }
}
