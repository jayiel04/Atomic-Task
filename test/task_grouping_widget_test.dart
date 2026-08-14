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
  testWidgets('shows non-empty groups in order and keeps them independent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final repository = MemoryTaskRepository(
      initialTasks: [
        _task(
          1,
          'Tarea atrasada',
          dueDate: today.subtract(const Duration(days: 1)),
        ),
        _task(2, 'Tarea sin fecha'),
        _task(3, 'Tarea de hoy', dueDate: today),
        _task(
          4,
          'Tarea de mañana',
          dueDate: today.add(const Duration(days: 1)),
        ),
        _task(5, 'Tarea futura', dueDate: today.add(const Duration(days: 2))),
      ],
    );
    addTearDown(repository.dispose);
    final controller = _buildController(repository, now: () => now)
      ..initialize();
    addTearDown(controller.dispose);
    repository.emit();

    await tester.pumpWidget(_TestApp(controller: controller));
    await tester.pumpAndSettle();

    final labels = ['Atrasadas', 'Sin fecha', 'Hoy', 'Mañana', 'Futuras'];
    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }
    final positions = labels
        .map((label) => tester.getTopLeft(find.text(label)).dy)
        .toList();
    expect(positions, orderedEquals([...positions]..sort()));

    expect(find.text('Tarea de hoy'), findsOneWidget);
    expect(find.text('Tarea atrasada'), findsNothing);
    expect(find.text('Tarea sin fecha'), findsNothing);

    await tester.tap(find.text('Atrasadas'));
    await tester.pumpAndSettle();
    expect(find.text('Tarea atrasada'), findsOneWidget);
    expect(find.text('Tarea de hoy'), findsOneWidget);

    await tester.tap(find.text('Sin fecha'));
    await tester.pumpAndSettle();
    expect(find.text('Tarea atrasada'), findsOneWidget);
    expect(find.text('Tarea sin fecha'), findsOneWidget);
    expect(find.text('Tarea de hoy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'hides empty groups and removes one when its last task completes',
    (tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final repository = MemoryTaskRepository(
        initialTasks: [_task(1, 'Única de hoy', dueDate: today)],
      );
      addTearDown(repository.dispose);
      final controller = _buildController(repository, now: () => now)
        ..initialize();
      addTearDown(controller.dispose);
      repository.emit();

      await tester.pumpWidget(_TestApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('Hoy'), findsOneWidget);
      expect(find.text('Atrasadas'), findsNothing);
      expect(find.text('Sin fecha'), findsNothing);
      expect(find.text('Mañana'), findsNothing);
      expect(find.text('Futuras'), findsNothing);

      await tester.tap(find.byKey(const Key('taskToggle-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('completeTaskNowOption')));
      await tester.pumpAndSettle();

      expect(find.text('Hoy'), findsNothing);
      expect(find.text('No tienes tareas pendientes'), findsOneWidget);
      expect(find.text('0 pendientes · 1 completada hoy'), findsOneWidget);
    },
  );
}

TaskController _buildController(
  MemoryTaskRepository repository, {
  required DateTime Function() now,
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

AtomicTask _task(int id, String title, {DateTime? dueDate}) {
  final createdAt = DateTime(2026, 8, 1);
  return AtomicTask(
    id: id,
    title: title,
    isCompleted: false,
    dueDate: dueDate,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      home: TaskPage(
        controller: controller,
        onStartFocus: (_, _) async => true,
      ),
    );
  }
}
