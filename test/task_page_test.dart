import 'package:atomic_task/core/theme/app_colors.dart';
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
import 'package:atomic_task/features/tasks/presentation/task_date_formatter.dart';
import 'package:atomic_task/features/tasks/presentation/widgets/task_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'task_test_support.dart';

void main() {
  testWidgets('creates, edits and removes a completed task from the view', (
    tester,
  ) async {
    final repository = MemoryTaskRepository();
    addTearDown(repository.dispose);
    final now = DateTime(2026, 8, 14, 10);
    final controller = _buildController(repository, now: () => now)
      ..initialize();
    addTearDown(controller.dispose);
    repository.emit();

    await tester.pumpWidget(_TestApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('No tienes tareas pendientes'), findsOneWidget);
    await tester.tap(find.byKey(const Key('createTaskButton')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('taskTitleField')),
      'Preparar presentación',
    );
    await tester.ensureVisible(find.byKey(const Key('saveTaskButton')));
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sin fecha'));
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
    expect(find.text('Presentación final'), findsNothing);
    expect(find.byKey(const Key('taskToggle-1')), findsNothing);
    expect(find.text('0 pendientes · 1 completada hoy'), findsOneWidget);
    expect(find.text('No tienes tareas pendientes'), findsOneWidget);
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

    await tester.tap(find.text('Sin fecha'));
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

    await tester.tap(find.text('Atrasadas'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Vencida'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'shows due-date shortcuts after enabling the option and a red clear icon',
    (tester) async {
      final repository = MemoryTaskRepository();
      addTearDown(repository.dispose);
      final now = DateTime(2026, 1, 31, 10);
      final controller = _buildController(repository, now: () => now)
        ..initialize();
      addTearDown(controller.dispose);
      repository.emit();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: TaskFormSheet(controller: controller, now: () => now),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dueDateShortcutOptions')), findsNothing);

      await tester.tap(find.byKey(const Key('taskDueDateSection')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('formBackButton')), findsOneWidget);

      final shortcuts = <Key, DateTime>{
        const Key('dueDateTodayOption'): DateTime(2026, 1, 31),
        const Key('dueDateTomorrowOption'): DateTime(2026, 2, 1),
      };
      expect(find.byKey(const Key('dueDateShortcutOptions')), findsOneWidget);
      expect(find.text('Hoy'), findsOneWidget);
      expect(find.text('Mañana'), findsOneWidget);

      for (final entry in shortcuts.entries) {
        await tester.tap(find.byKey(entry.key));
        await tester.pump();
        expect(
          tester.widget<ChoiceChip>(find.byKey(entry.key)).selected,
          isTrue,
        );
        expect(
          find.text(TaskDateFormatter.format(entry.value)),
          findsOneWidget,
        );
        for (final otherKey in shortcuts.keys.where(
          (key) => key != entry.key,
        )) {
          expect(
            tester.widget<ChoiceChip>(find.byKey(otherKey)).selected,
            isFalse,
          );
        }
      }

      final clearFinder = find.byKey(const Key('clearTaskDueDateButton'));
      final clearIcon = tester.widget<Icon>(
        find.descendant(of: clearFinder, matching: find.byType(Icon)).first,
      );
      expect(clearIcon.icon, Icons.close_rounded);
      expect(clearIcon.color, AppColors.destructive);
      expect(tester.getSize(clearFinder).height, greaterThanOrEqualTo(48));
      expect(
        tester.widget<IconButton>(clearFinder).tooltip,
        'Quitar fecha límite',
      );

      await tester.tap(clearFinder);
      await tester.pump();
      // Quitar la fecha regresa a la vista principal con la opción apagada.
      expect(find.byKey(const Key('formBackButton')), findsNothing);
      expect(find.text('Limita cuándo debe completarse'), findsOneWidget);
      expect(find.byKey(const Key('dueDateShortcutOptions')), findsNothing);
      expect(find.byKey(const Key('dueAlarmSection')), findsNothing);
      for (final key in shortcuts.keys) {
        expect(find.byKey(key), findsNothing);
      }

      await tester.tap(find.byKey(const Key('taskRecurrenceSection')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('selectRecurrenceEndDateButton')),
      );
      await tester.tap(find.byKey(const Key('selectRecurrenceEndDateButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aceptar'));
      await tester.pumpAndSettle();
      final recurrenceClear = find.byKey(
        const Key('clearRecurrenceEndDateButton'),
      );
      expect(
        tester
            .widget<Icon>(
              find
                  .descendant(of: recurrenceClear, matching: find.byType(Icon))
                  .first,
            )
            .icon,
        Icons.event_busy_rounded,
      );
      // Descartar desde la flecha atrás desactiva la opción cíclica.
      await tester.tap(find.byKey(const Key('formBackButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('formDiscardButton')));
      await tester.pumpAndSettle();
      expect(find.text('Crear ocurrencias automáticamente'), findsOneWidget);

      await tester.tap(find.byKey(const Key('taskDueDateSection')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('dueDateTomorrowOption')));
      await tester.enterText(
        find.byKey(const Key('taskTitleField')),
        'Cerrar el mes',
      );
      await tester.ensureVisible(find.byKey(const Key('saveTaskButton')));
      await tester.tap(find.byKey(const Key('saveTaskButton')));
      await tester.pumpAndSettle();

      expect(repository.tasks.single.dueDate, DateTime(2026, 2, 1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('defaults a new due date to today and persists it', (
    tester,
  ) async {
    final repository = MemoryTaskRepository();
    addTearDown(repository.dispose);
    final now = DateTime(2026, 8, 20, 9);
    final controller = _buildController(repository, now: () => now);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TaskFormSheet(controller: controller, now: () => now),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('taskDueDateSection')));
    await tester.pumpAndSettle();

    expect(find.text('Tarea con fecha límite'), findsOneWidget);
    expect(find.byKey(const Key('formBackButton')), findsOneWidget);
    expect(
      find.text(TaskDateFormatter.format(DateTime(2026, 8, 20))),
      findsOneWidget,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const Key('dueDateTodayOption')))
          .selected,
      isTrue,
    );

    await tester.enterText(
      find.byKey(const Key('taskTitleField')),
      'Tarea para hoy',
    );
    await tester.ensureVisible(find.byKey(const Key('saveTaskButton')));
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();

    expect(repository.tasks.single.dueDate, DateTime(2026, 8, 20));
  });

  testWidgets('clearing a due date disables the option and saves without one', (
    tester,
  ) async {
    final repository = MemoryTaskRepository();
    addTearDown(repository.dispose);
    final now = DateTime(2026, 8, 20, 9);
    final controller = _buildController(repository, now: () => now);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TaskFormSheet(controller: controller, now: () => now),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('taskDueDateSection')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('clearTaskDueDateButton')));
    await tester.pumpAndSettle();

    expect(find.text('Limita cuándo debe completarse'), findsOneWidget);
    expect(find.byKey(const Key('dueDateShortcutOptions')), findsNothing);

    await tester.enterText(
      find.byKey(const Key('taskTitleField')),
      'Tarea sin fecha',
    );
    await tester.ensureVisible(find.byKey(const Key('saveTaskButton')));
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();

    expect(repository.tasks.single.dueDate, isNull);
  });

  testWidgets('does not show due-date shortcuts while editing', (tester) async {
    final task = AtomicTask(
      id: 9,
      title: 'Tarea existente',
      isCompleted: false,
      dueDate: DateTime(2026, 2, 1),
      createdAt: DateTime(2026, 1, 20),
      updatedAt: DateTime(2026, 1, 20),
    );
    final repository = MemoryTaskRepository(initialTasks: [task]);
    addTearDown(repository.dispose);
    final controller = _buildController(repository)..initialize();
    addTearDown(controller.dispose);
    repository.emit();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TaskFormSheet(controller: controller, task: task),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dueDateShortcutOptions')), findsNothing);
    expect(find.byKey(const Key('dueDateTomorrowOption')), findsNothing);
    expect(find.byKey(const Key('dueDateOneWeekOption')), findsNothing);
    expect(find.byKey(const Key('dueDateOneMonthOption')), findsNothing);
    expect(find.text(TaskDateFormatter.format(task.dueDate!)), findsOneWidget);

    await tester.enterText(find.byKey(const Key('taskTitleField')), 'Editada');
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();
    expect(repository.tasks.single.dueDate, task.dueDate);
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
