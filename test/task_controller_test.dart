import 'package:atomic_task/features/tasks/domain/entities/atomic_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/assign_task_focus.dart';
import 'package:atomic_task/features/tasks/domain/usecases/create_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/delete_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/toggle_task_completion.dart';
import 'package:atomic_task/features/tasks/domain/usecases/update_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/watch_tasks.dart';
import 'package:atomic_task/features/tasks/presentation/controllers/task_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'task_test_support.dart';

void main() {
  test('creates, edits, completes, reopens and deletes tasks', () async {
    final repository = MemoryTaskRepository();
    addTearDown(repository.dispose);
    var now = DateTime(2026, 8, 10, 9);
    final controller = _buildController(repository, now: () => now);
    addTearDown(controller.dispose);

    controller.initialize();
    repository.emit();
    await pumpEventQueue();
    expect(controller.isLoading, isFalse);

    expect(
      await controller.create(
        title: '  Preparar informe  ',
        dueDate: DateTime(2026, 8, 12),
      ),
      isTrue,
    );
    await pumpEventQueue();
    expect(controller.pendingTasks.single.title, 'Preparar informe');
    expect(controller.pendingTasks.single.dueDate, DateTime(2026, 8, 12));

    expect(await controller.assignFocus(controller.tasks.single, 45), isTrue);
    await pumpEventQueue();
    expect(controller.tasks.single.focusMinutes, 45);

    final task = controller.pendingTasks.single;
    now = now.add(const Duration(hours: 1));
    expect(
      await controller.update(
        task: task,
        title: 'Informe final',
        dueDate: null,
      ),
      isTrue,
    );
    await pumpEventQueue();
    expect(controller.tasks.single.title, 'Informe final');
    expect(controller.tasks.single.dueDate, isNull);
    expect(controller.tasks.single.updatedAt, now);

    expect(await controller.toggleCompletion(controller.tasks.single), isTrue);
    await pumpEventQueue();
    expect(controller.completedTasks, hasLength(1));

    expect(await controller.toggleCompletion(controller.tasks.single), isTrue);
    await pumpEventQueue();
    expect(controller.pendingTasks, hasLength(1));

    expect(await controller.delete(controller.tasks.single), isTrue);
    await pumpEventQueue();
    expect(controller.tasks, isEmpty);
  });

  test('rejects an empty title and cancels its stream on dispose', () async {
    final repository = MemoryTaskRepository();
    addTearDown(repository.dispose);
    final controller = _buildController(repository);

    controller.initialize();
    repository.emit();
    await pumpEventQueue();
    expect(repository.hasListener, isTrue);

    expect(await controller.create(title: '   '), isFalse);
    expect(controller.errorMessage, 'Escribe un titulo para la tarea.');

    controller.dispose();
    await pumpEventQueue();
    expect(repository.hasListener, isFalse);
  });

  test('identifies overdue tasks using the local calendar day', () {
    final task = AtomicTask(
      id: 1,
      title: 'Ayer',
      isCompleted: false,
      dueDate: DateTime(2026, 8, 9, 23, 59),
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

    expect(task.isOverdueAt(DateTime(2026, 8, 10, 0, 1)), isTrue);
    expect(task.isOverdueAt(DateTime(2026, 8, 9, 8)), isFalse);
  });
}

TaskController _buildController(
  MemoryTaskRepository repository, {
  DateTime Function()? now,
}) {
  return TaskController(
    WatchTasks(repository),
    CreateTask(repository),
    UpdateTask(repository),
    ToggleTaskCompletion(repository),
    DeleteTask(repository),
    AssignTaskFocus(repository),
    now: now,
  );
}
