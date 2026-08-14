import '../domain/entities/atomic_task.dart';

enum TaskDateGroup { overdue, noDate, today, tomorrow, future }

extension TaskDateGroupLabel on TaskDateGroup {
  String get label => switch (this) {
    TaskDateGroup.overdue => 'Atrasadas',
    TaskDateGroup.noDate => 'Sin fecha',
    TaskDateGroup.today => 'Hoy',
    TaskDateGroup.tomorrow => 'Mañana',
    TaskDateGroup.future => 'Futuras',
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
    final dueDate = task.dueDate;
    if (dueDate == null) {
      groups[TaskDateGroup.noDate]!.add(task);
      continue;
    }

    final localDueDate = dueDate.toLocal();
    final dueDay = DateTime(
      localDueDate.year,
      localDueDate.month,
      localDueDate.day,
    );
    final group = dueDay.isBefore(today)
        ? TaskDateGroup.overdue
        : dueDay == today
        ? TaskDateGroup.today
        : dueDay == tomorrow
        ? TaskDateGroup.tomorrow
        : TaskDateGroup.future;
    groups[group]!.add(task);
  }

  return Map.unmodifiable({
    for (final entry in groups.entries)
      entry.key: List<AtomicTask>.unmodifiable(entry.value),
  });
}
