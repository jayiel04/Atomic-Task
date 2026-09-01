import 'package:atomic_task/core/database/app_database.dart';
import 'package:atomic_task/core/theme/app_theme.dart';
import 'package:atomic_task/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:atomic_task/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:atomic_task/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:atomic_task/features/tasks/domain/services/recurrence_calculator.dart';
import 'package:atomic_task/features/tasks/domain/services/recurrence_generation_policy.dart';
import 'package:atomic_task/features/tasks/domain/usecases/assign_task_focus.dart';
import 'package:atomic_task/features/tasks/domain/usecases/calculate_next_occurrence.dart';
import 'package:atomic_task/features/tasks/domain/usecases/complete_task_occurrence.dart';
import 'package:atomic_task/features/tasks/domain/usecases/create_recurring_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/create_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/delete_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/delete_task_occurrence.dart';
import 'package:atomic_task/features/tasks/domain/usecases/delete_task_series.dart';
import 'package:atomic_task/features/tasks/domain/usecases/reconcile_task_recurrences.dart';
import 'package:atomic_task/features/tasks/domain/usecases/set_task_recurrence_active.dart';
import 'package:atomic_task/features/tasks/domain/usecases/toggle_task_completion.dart';
import 'package:atomic_task/features/tasks/domain/usecases/update_recurring_occurrence.dart';
import 'package:atomic_task/features/tasks/domain/usecases/update_recurring_series.dart';
import 'package:atomic_task/features/tasks/domain/usecases/update_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/watch_tasks.dart';
import 'package:atomic_task/features/tasks/presentation/controllers/task_controller.dart';
import 'package:atomic_task/features/tasks/presentation/pages/task_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('creates and manages a recurring task and its series', (
    tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);
    final controller = _buildController(database)..initialize();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: TaskPage(
          controller: controller,
          onStartFocus: (_, _) async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('createTaskButton')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('taskTitleField')),
      'Revisar objetivos',
    );
    await tester.tap(find.byKey(const Key('taskRecurrenceSection')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('recurrenceIntervalField')),
      '2',
    );
    await tester.ensureVisible(find.byKey(const Key('saveTaskButton')));
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();

    expect(find.text('Sin fecha'), findsNothing);
    expect(find.text('Hoy'), findsOneWidget);
    expect(find.textContaining('Cada 2 días · Activa'), findsOneWidget);
    expect(find.textContaining('Próxima:'), findsOneWidget);

    await tester.tap(find.byKey(const Key('toggleTaskRecurrence-1')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pausada'), findsOneWidget);
    await tester.tap(find.byKey(const Key('toggleTaskRecurrence-1')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('editTask-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editOccurrenceOption')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('taskTitleField')),
      'Objetivos personales',
    );
    await tester.ensureVisible(find.byKey(const Key('saveTaskButton')));
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();
    expect(find.text('Objetivos personales'), findsOneWidget);

    await tester.tap(find.byKey(const Key('editTask-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editSeriesOption')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('taskRecurrenceSection')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('recurrenceIntervalField')),
      '3',
    );
    await tester.ensureVisible(find.byKey(const Key('saveTaskButton')));
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Cada 3 días · Activa'), findsOneWidget);

    await tester.tap(find.byKey(const Key('deleteTask-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteOccurrenceOption')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmDeleteTaskButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tareas futuras'));
    await tester.pumpAndSettle();
    expect(find.text('Objetivos personales'), findsOneWidget);
    expect(find.byKey(const Key('deleteTask-2')), findsOneWidget);

    await tester.tap(find.byKey(const Key('deleteTask-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('deleteSeriesOption')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmDeleteTaskButton')));
    await tester.pumpAndSettle();
    expect(find.text('No tienes tareas pendientes'), findsOneWidget);
  });

  testWidgets('places the next daily occurrence in Tomorrow', (tester) async {
    final now = DateTime.now();
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);
    final controller = _buildController(database, now: () => now);
    addTearDown(controller.dispose);
    controller.initialize();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: TaskPage(
          controller: controller,
          onStartFocus: (_, _) async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await controller.createRecurring(
      title: 'Revisión diaria',
      dueDate: null,
      frequency: RecurrenceFrequency.daily,
      interval: 1,
      startDate: now,
      endDate: null,
    );
    await tester.pumpAndSettle();

    expect(find.text('Revisión diaria'), findsOneWidget);
    expect(find.text('Sin fecha'), findsNothing);
    await tester.tap(find.byKey(const Key('taskToggle-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('completeTaskNowOption')));
    await tester.pumpAndSettle();

    expect(find.text('Mañana'), findsOneWidget);
    await tester.tap(find.text('Mañana'));
    await tester.pumpAndSettle();
    expect(find.text('Revisión diaria'), findsOneWidget);
    expect(find.byKey(const Key('taskToggle-2')), findsOneWidget);
  });

  testWidgets('recurrence form fits compact text and a visible keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);
    final controller = _buildController(database)..initialize();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(1.3),
              viewInsets: const EdgeInsets.only(bottom: 220),
            ),
            child: child!,
          );
        },
        home: TaskPage(
          controller: controller,
          onStartFocus: (_, _) async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('createTaskButton')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('taskRecurrenceSection')));
    await tester.tap(find.byKey(const Key('taskRecurrenceSection')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('recurrenceFrequencyField')), findsOneWidget);
    expect(find.byKey(const Key('recurrenceIntervalField')), findsOneWidget);
    expect(
      find.byKey(const Key('selectRecurrenceStartDateButton')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('selectRecurrenceEndDateButton')),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byKey(const Key('saveTaskButton')));
    expect(tester.takeException(), isNull);
  });
}

TaskController _buildController(
  AppDatabase database, {
  DateTime Function()? now,
}) {
  final dataSource = DriftTaskLocalDataSource(database);
  final repository = TaskRepositoryImpl(dataSource);
  const calculator = RecurrenceCalculator();
  const policy = RecurrenceGenerationPolicy(calculator);
  const calculateNextOccurrence = CalculateNextOccurrence(policy);
  final updateTask = UpdateTask(repository);
  return TaskController(
    WatchTasks(repository),
    CreateTask(repository),
    updateTask,
    ToggleTaskCompletion(repository),
    DeleteTask(repository),
    AssignTaskFocus(repository),
    createRecurringTaskUseCase: CreateRecurringTask(repository),
    updateRecurringOccurrenceUseCase: UpdateRecurringOccurrence(updateTask),
    updateRecurringSeriesUseCase: UpdateRecurringSeries(repository),
    completeTaskOccurrenceUseCase: CompleteTaskOccurrence(
      repository,
      repository,
      calculateNextOccurrence,
    ),
    setTaskRecurrenceActiveUseCase: SetTaskRecurrenceActive(repository),
    deleteTaskOccurrenceUseCase: DeleteTaskOccurrence(
      repository,
      repository,
      calculateNextOccurrence,
    ),
    deleteTaskSeriesUseCase: DeleteTaskSeries(repository),
    reconcileTaskRecurrencesUseCase: ReconcileTaskRecurrences(
      repository,
      policy,
    ),
    now: now ?? () => DateTime(2026, 8, 14, 9),
  );
}
