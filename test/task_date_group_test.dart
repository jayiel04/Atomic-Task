import 'package:atomic_task/features/tasks/domain/entities/atomic_task.dart';
import 'package:atomic_task/features/tasks/domain/entities/recurrence_rule.dart';
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

  test('uses occurrence dates for recurring tasks without due dates', () {
    final now = DateTime(2026, 8, 14, 23, 59);
    final tasks = [
      _task(
        1,
        'Recurrente atrasada',
        occurrenceDate: DateTime(2026, 8, 13, 20),
        recurring: true,
      ),
      _task(
        2,
        'Recurrente de hoy',
        occurrenceDate: DateTime(2026, 8, 14, 1),
        recurring: true,
      ),
      _task(
        3,
        'Recurrente de mañana',
        occurrenceDate: DateTime(2026, 8, 15, 22),
        recurring: true,
      ),
      _task(
        4,
        'Recurrente futura',
        occurrenceDate: DateTime(2026, 8, 20),
        recurring: true,
      ),
      _task(5, 'Normal sin fecha'),
      _task(6, 'Recurrente anómala', recurring: true),
      _task(
        7,
        'Recurrente completada',
        occurrenceDate: DateTime(2026, 8, 15),
        recurring: true,
        isCompleted: true,
      ),
    ];

    final groups = groupPendingTasksByDate(tasks, now);

    expect(groups[TaskDateGroup.overdue]!.map((task) => task.id), [1]);
    expect(groups[TaskDateGroup.today]!.map((task) => task.id), [2]);
    expect(groups[TaskDateGroup.tomorrow]!.map((task) => task.id), [3]);
    expect(groups[TaskDateGroup.future]!.map((task) => task.id), [4]);
    expect(groups[TaskDateGroup.noDate]!.map((task) => task.id), [5, 6]);
  });

  test('keeps an explicit due date ahead of the recurrence date', () {
    final task = _task(
      1,
      'Recurrente con fecha límite',
      dueDate: DateTime(2026, 8, 15),
      occurrenceDate: DateTime(2026, 8, 20),
      recurring: true,
    );

    final groups = groupPendingTasksByDate([task], DateTime(2026, 8, 14));

    expect(groups[TaskDateGroup.tomorrow], [task]);
    expect(groups[TaskDateGroup.future], isEmpty);
  });

  test('provides labels in the required order', () {
    expect(TaskDateGroup.values.map((group) => group.label), [
      'Atrasadas',
      'Sin fecha',
      'Hoy',
      'Mañana',
      'Tareas futuras',
    ]);
  });
}

AtomicTask _task(
  int id,
  String title, {
  DateTime? dueDate,
  DateTime? occurrenceDate,
  bool recurring = false,
  bool isCompleted = false,
}) {
  final createdAt = DateTime(2026, 8, 1);
  return AtomicTask(
    id: id,
    title: title,
    isCompleted: isCompleted,
    dueDate: dueDate,
    occurrenceDate: occurrenceDate,
    recurrenceRule: recurring
        ? RecurrenceRule(
            id: 1,
            frequency: RecurrenceFrequency.daily,
            interval: 1,
            startDate: occurrenceDate ?? createdAt,
            isActive: true,
            createdAt: createdAt,
            updatedAt: createdAt,
          )
        : null,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
