import 'package:atomic_task/features/tasks/domain/entities/atomic_task.dart';
import 'package:atomic_task/features/tasks/presentation/task_date_group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groups pending tasks by the local calendar day', () {
    final now = DateTime(2026, 8, 14, 23, 59);
    final tasks = [
      _task(1, 'Atrasada', dueDate: DateTime(2026, 8, 13, 23, 59)),
      _task(2, 'Sin fecha'),
      _task(3, 'Hoy temprano', dueDate: DateTime(2026, 8, 14)),
      _task(4, 'Hoy tarde', dueDate: DateTime(2026, 8, 14, 23, 59, 59)),
      _task(5, 'Mañana', dueDate: DateTime(2026, 8, 15, 18)),
      _task(6, 'Futura', dueDate: DateTime(2026, 8, 16)),
      _task(7, 'Completada', dueDate: DateTime(2026, 8, 14), isCompleted: true),
    ];

    final groups = groupPendingTasksByDate(tasks, now);

    expect(groups.keys, TaskDateGroup.values);
    expect(groups[TaskDateGroup.overdue]!.map((task) => task.id), [1]);
    expect(groups[TaskDateGroup.noDate]!.map((task) => task.id), [2]);
    expect(groups[TaskDateGroup.today]!.map((task) => task.id), [3, 4]);
    expect(groups[TaskDateGroup.tomorrow]!.map((task) => task.id), [5]);
    expect(groups[TaskDateGroup.future]!.map((task) => task.id), [6]);
  });

  test('keeps the source order inside every group', () {
    final tasks = [
      _task(3, 'Tercera', dueDate: DateTime(2026, 8, 20)),
      _task(1, 'Primera', dueDate: DateTime(2026, 8, 20)),
      _task(2, 'Segunda', dueDate: DateTime(2026, 8, 20)),
    ];

    final groups = groupPendingTasksByDate(tasks, DateTime(2026, 8, 14));

    expect(groups[TaskDateGroup.future]!.map((task) => task.id), [3, 1, 2]);
  });

  test('provides labels in the required order', () {
    expect(TaskDateGroup.values.map((group) => group.label), [
      'Atrasadas',
      'Sin fecha',
      'Hoy',
      'Mañana',
      'Futuras',
    ]);
  });
}

AtomicTask _task(
  int id,
  String title, {
  DateTime? dueDate,
  bool isCompleted = false,
}) {
  final createdAt = DateTime(2026, 8, 1);
  return AtomicTask(
    id: id,
    title: title,
    isCompleted: isCompleted,
    dueDate: dueDate,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
