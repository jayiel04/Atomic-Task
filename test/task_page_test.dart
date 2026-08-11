import 'package:atomic_task/core/theme/app_theme.dart';
import 'package:atomic_task/features/tasks/domain/entities/atomic_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/assign_task_focus.dart';
import 'package:atomic_task/features/tasks/domain/usecases/create_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/delete_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/toggle_task_completion.dart';
import 'package:atomic_task/features/tasks/domain/usecases/update_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/watch_tasks.dart';
import 'package:atomic_task/features/tasks/presentation/controllers/task_controller.dart';
import 'package:atomic_task/features/tasks/presentation/pages/task_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'task_test_support.dart';

void main() {
  testWidgets('creates, edits, completes and deletes a task', (tester) async {
    final repository = MemoryTaskRepository();
    addTearDown(repository.dispose);
    final controller = _buildController(repository)..initialize();
    addTearDown(controller.dispose);
    repository.emit();

    await tester.pumpWidget(_TestApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Todavía no hay tareas'), findsOneWidget);
    await tester.tap(find.byKey(const Key('createTaskButton')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('taskTitleField')),
      'Preparar presentación',
    );
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();

    expect(find.text('Preparar presentación'), findsOneWidget);
    expect(find.text('Sin fecha límite'), findsOneWidget);

    await tester.tap(find.byKey(const Key('editTask-1')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('taskTitleField')),
      'Presentación final',
    );
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();
    expect(find.text('Presentación final'), findsOneWidget);

    await tester.tap(find.byKey(const Key('taskToggle-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('completeTaskNowOption')));
    await tester.pumpAndSettle();
    expect(find.text('Completadas (1)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('deleteTask-1')));
    await tester.pumpAndSettle();
    expect(find.text('Eliminar tarea'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirmDeleteTaskButton')));
    await tester.pumpAndSettle();
    expect(find.text('Todavía no hay tareas'), findsOneWidget);
  });

  testWidgets('associates a duration without completing the task immediately', (
    tester,
  ) async {
    final repository = MemoryTaskRepository(
      initialTasks: [
        AtomicTask(
          id: 4,
          title: 'Diseñar propuesta',
          isCompleted: false,
          createdAt: DateTime(2026, 8, 10),
          updatedAt: DateTime(2026, 8, 10),
        ),
      ],
    );
    addTearDown(repository.dispose);
    final controller = _buildController(repository)..initialize();
    addTearDown(controller.dispose);
    repository.emit();
    AtomicTask? startedTask;
    int? startedMinutes;

    await tester.pumpWidget(
      _TestApp(
        controller: controller,
        onStartFocus: (task, minutes) async {
          startedTask = task;
          startedMinutes = minutes;
          return true;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('taskToggle-4')));
    await tester.pumpAndSettle();
    expect(find.text('¿Cómo quieres continuar?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('associateTaskFocusOption')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('focusMinutes-45')));
    await tester.tap(find.byKey(const Key('startTaskFocusButton')));
    await tester.pumpAndSettle();

    expect(startedTask?.id, 4);
    expect(startedMinutes, 45);
    expect(repository.tasks.single.focusMinutes, 45);
    expect(repository.tasks.single.isCompleted, isFalse);
  });

  testWidgets('shows overdue text and fits on a small screen', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = MemoryTaskRepository(
      initialTasks: [
        AtomicTask(
          id: 7,
          title: 'Entregar reporte',
          isCompleted: false,
          dueDate: DateTime(2020, 1, 1),
          createdAt: DateTime(2019, 12, 1),
          updatedAt: DateTime(2019, 12, 1),
        ),
      ],
    );
    addTearDown(repository.dispose);
    final controller = _buildController(repository)..initialize();
    addTearDown(controller.dispose);
    repository.emit();

    await tester.pumpWidget(_TestApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.textContaining('Vencida'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

TaskController _buildController(MemoryTaskRepository repository) {
  return TaskController(
    WatchTasks(repository),
    CreateTask(repository),
    UpdateTask(repository),
    ToggleTaskCompletion(repository),
    DeleteTask(repository),
    AssignTaskFocus(repository),
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.controller, this.onStartFocus});

  final TaskController controller;
  final Future<bool> Function(AtomicTask task, int minutes)? onStartFocus;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      home: TaskPage(
        controller: controller,
        onStartFocus: onStartFocus ?? (_, _) async => true,
      ),
    );
  }
}
