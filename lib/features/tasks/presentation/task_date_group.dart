import '../domain/entities/atomic_task.dart';

enum TaskDateGroup { overdue, noDate, today, tomorrow, future }

extension TaskDateGroupLabel on TaskDateGroup {
  String get label => switch (this) {
    TaskDateGroup.overdue => 'Atrasadas',
    TaskDateGroup.noDate => 'Sin fecha',
    TaskDateGroup.today => 'Hoy',
    TaskDateGroup.tomorrow => 'Mañana',
    TaskDateGroup.future => 'Tareas futuras',
  };
}

Map<TaskDateGroup, List<AtomicTask>> groupPendingTasksByDate(
  Iterable<AtomicTask> tasks,
  DateTime now,
) {
  final groups = <TaskDateGroup, List<AtomicTask>>{
    for (final group in TaskDateGroup.values) group: <AtomicTask>[],
  };
  final localNow = now.toLocal();
  final today = DateTime(localNow.year, localNow.month, localNow.day);
  final tomorrow = DateTime(today.year, today.month, today.day + 1);

  for (final task in tasks) {
    if (task.isCompleted) {
      continue;
    }
    final effectiveDate = _effectiveDate(task);
    if (effectiveDate == null) {
      groups[TaskDateGroup.noDate]!.add(task);
      continue;
    }

    final localEffectiveDate = effectiveDate.toLocal();
    final effectiveDay = DateTime(
      localEffectiveDate.year,
      localEffectiveDate.month,
      localEffectiveDate.day,
    );
    final group = effectiveDay.isBefore(today)
        ? TaskDateGroup.overdue
        : effectiveDay == today
        ? TaskDateGroup.today
        : effectiveDay == tomorrow
        ? TaskDateGroup.tomorrow
        : TaskDateGroup.future;
    groups[group]!.add(task);
  }

  return Map.unmodifiable({
    for (final entry in groups.entries)
      entry.key: List<AtomicTask>.unmodifiable(entry.value),
  });
}

DateTime? _effectiveDate(AtomicTask task) {
  return task.dueDate ?? (task.isRecurring ? task.occurrenceDate : null);
}
