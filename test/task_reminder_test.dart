import 'package:atomic_task/core/database/app_database.dart';
import 'package:atomic_task/core/theme/app_theme.dart';
import 'package:atomic_task/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:atomic_task/features/tasks/domain/entities/atomic_task.dart';
import 'package:atomic_task/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:atomic_task/features/tasks/domain/services/task_reminder_service.dart';
import 'package:atomic_task/features/tasks/domain/usecases/assign_task_focus.dart';
import 'package:atomic_task/features/tasks/domain/usecases/create_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/delete_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/toggle_task_completion.dart';
import 'package:atomic_task/features/tasks/domain/usecases/update_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/watch_tasks.dart';
import 'package:atomic_task/features/tasks/presentation/controllers/task_controller.dart';
import 'package:atomic_task/features/tasks/presentation/widgets/task_form_sheet.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'task_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists, updates and clears a task reminder', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);
    final dataSource = DriftTaskLocalDataSource(database);
    final createdAt = DateTime(2026, 8, 20, 9);
    final reminderAt = DateTime(2026, 8, 20, 10);

    final id = await dataSource.createWithReminder(
      title: 'Revisar informe',
      dueDate: DateTime(2026, 8, 20),
      reminderAt: reminderAt,
      createdAt: createdAt,
    );
    var task = (await dataSource.watchAll().first).single;

    expect(task.id, id);
    expect(task.reminderAt, reminderAt);

    await dataSource.updateWithReminder(
      id: id,
      title: 'Revisar informe final',
      dueDate: task.dueDate,
      reminderAt: null,
      updatedAt: createdAt.add(const Duration(minutes: 1)),
    );
    task = (await dataSource.watchAll().first).single;

    expect(task.title, 'Revisar informe final');
    expect(task.reminderAt, isNull);
  });

  test('derives reminder dates for generated recurring occurrences', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);
    final dataSource = DriftTaskLocalDataSource(database);
    final startDate = DateTime(2026, 8, 20);
    final createdAt = DateTime(2026, 8, 20, 8);
    final rule = RecurrenceRule(
      id: 0,
      frequency: RecurrenceFrequency.daily,
      interval: 1,
      startDate: startDate,
      reminderTimeMinutes: 10 * 60,
      isActive: true,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    await dataSource.createRecurring(
      title: 'Rutina diaria',
      dueDate: startDate,
      rule: rule,
      reminderAt: DateTime(2026, 8, 20, 10),
      createdAt: createdAt,
    );
    final firstTask = (await dataSource.watchAll().first).single;

    await dataSource.ensureOccurrence(
      template: firstTask,
      occurrenceDate: DateTime(2026, 8, 21),
      createdAt: createdAt.add(const Duration(days: 1)),
    );
    final tasks = await dataSource.watchAll().first;
    final nextTask = tasks.singleWhere(
      (task) => task.occurrenceDate == DateTime(2026, 8, 21),
    );

    expect(nextTask.reminderAt, DateTime(2026, 8, 21, 10));
    expect(nextTask.recurrenceRule?.reminderTimeMinutes, 600);
  });

  test('reconciles reminders when task completion changes', () async {
    final now = DateTime(2026, 8, 20, 9);
    final reminderAt = now.add(const Duration(hours: 1));
    final repository = MemoryTaskRepository(
      initialTasks: [
        AtomicTask(
          id: 5,
          title: 'Llamar al cliente',
          isCompleted: false,
          reminderAt: reminderAt,
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );
    addTearDown(repository.dispose);
    final reminderService = _FakeTaskReminderService();
    final controller = _buildController(
      repository,
      reminderService: reminderService,
      now: () => now,
    );
    addTearDown(controller.dispose);

    controller.initialize();
    repository.emit();
    await pumpEventQueue();
    expect(reminderService.reconciled.single.single.id, 5);

    expect(await controller.toggleCompletion(controller.tasks.single), isTrue);
    await pumpEventQueue();

    expect(reminderService.cancelled.any((task) => task.id == 5), isTrue);
  });

  testWidgets('shows reminder controls and clears an existing reminder', (
    tester,
  ) async {
    final now = DateTime(2026, 8, 20, 9);
    final repository = MemoryTaskRepository();
    addTearDown(repository.dispose);
    final controller = _buildController(repository, now: () => now);
    addTearDown(controller.dispose);
    final task = AtomicTask(
      id: 1,
      title: 'Preparar reunión',
      isCompleted: false,
      reminderAt: DateTime(2026, 8, 20, 10),
      reminderMode: TaskReminderMode.alarm,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TaskFormSheet(
            controller: controller,
            task: task,
            now: () => now,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dueAlarmSection')), findsOneWidget);
    expect(find.byKey(const Key('dueAlarmSwitch')), findsOneWidget);
    expect(
      tester.widget<Switch>(find.byKey(const Key('dueAlarmSwitch'))).value,
      isTrue,
    );
    expect(find.byKey(const Key('dueAlarmModeSelector')), findsOneWidget);
    expect(find.byKey(const Key('selectDueAlarmTimeButton')), findsOneWidget);
    expect(find.byKey(const Key('clearTaskReminderButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('clearTaskReminderButton')));
    await tester.pump();
    expect(
      tester.widget<Switch>(find.byKey(const Key('dueAlarmSwitch'))).value,
      isFalse,
    );
    await tester.tap(find.byKey(const Key('dueAlarmSwitch')));
    await tester.pump();
    expect(find.byKey(const Key('addTaskReminderButton')), findsOneWidget);
  });

  testWidgets('rejects a reminder in the past', (tester) async {
    final now = DateTime(2026, 8, 20, 9);
    final repository = MemoryTaskRepository();
    addTearDown(repository.dispose);
    final controller = _buildController(repository, now: () => now);
    addTearDown(controller.dispose);
    final task = AtomicTask(
      id: 1,
      title: 'Alarma vencida',
      isCompleted: false,
      dueDate: DateTime(2026, 8, 20),
      reminderAt: DateTime(2026, 8, 20, 8),
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TaskFormSheet(
            controller: controller,
            task: task,
            now: () => now,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('saveTaskButton')));
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pump();

    expect(
      find.text('La alarma debe programarse para una fecha y hora futuras.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('saveTaskButton')), findsOneWidget);
  });

  testWidgets('due date and repeat options are mutually exclusive', (
    tester,
  ) async {
    final now = DateTime(2026, 8, 20, 9);
    final repository = MemoryTaskRepository();
    addTearDown(repository.dispose);
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

    expect(find.byKey(const Key('dueAlarmSection')), findsNothing);
    expect(find.byKey(const Key('repeatAlarmSection')), findsNothing);

    await tester.tap(find.byKey(const Key('dueDateOptionSwitch')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dueAlarmSection')), findsOneWidget);
    expect(find.byKey(const Key('repeatTaskSwitch')), findsOneWidget);
    expect(
      tester.widget<Switch>(find.byKey(const Key('repeatTaskSwitch'))).value,
      isFalse,
    );

    await tester.tap(find.byKey(const Key('dueAlarmSwitch')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dueAlarmModeSelector')), findsOneWidget);
    expect(find.text('Notificación'), findsOneWidget);

    await tester.tap(find.byKey(const Key('repeatTaskSwitch')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Switch>(find.byKey(const Key('dueDateOptionSwitch'))).value,
      isFalse,
    );
    expect(find.byKey(const Key('dueAlarmSection')), findsNothing);
    expect(find.byKey(const Key('repeatAlarmSection')), findsOneWidget);
    expect(find.byKey(const Key('repeatAlarmScopeSelector')), findsNothing);

    await tester.tap(find.byKey(const Key('repeatAlarmSwitch')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('repeatAlarmScopeSelector')), findsOneWidget);
    expect(find.text('Siempre'), findsOneWidget);
    expect(find.text('Solo la primera vez'), findsOneWidget);
  });
}

TaskController _buildController(
  MemoryTaskRepository repository, {
  TaskReminderService? reminderService,
  DateTime Function()? now,
}) {
  return TaskController(
    WatchTasks(repository),
    CreateTask(repository),
    UpdateTask(repository),
    ToggleTaskCompletion(repository),
    DeleteTask(repository),
    AssignTaskFocus(repository),
    reminderService: reminderService,
    now: now,
  );
}

class _FakeTaskReminderService implements TaskReminderService {
  int initializeCalls = 0;
  final List<AtomicTask> scheduled = [];
  final List<AtomicTask> cancelled = [];
  final List<List<AtomicTask>> reconciled = [];

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
  }

  @override
  Future<void> schedule(AtomicTask task) async {
    scheduled.add(task);
  }

  @override
  Future<void> cancel(AtomicTask task) async {
    cancelled.add(task);
  }

  @override
  Future<void> reconcile(Iterable<AtomicTask> tasks, {DateTime? now}) async {
    final snapshot = tasks.toList(growable: false);
    reconciled.add(snapshot);
    for (final task in snapshot) {
      if (task.isCompleted ||
          task.reminderAt == null ||
          !task.reminderAt!.isAfter(now ?? DateTime.now())) {
        cancelled.add(task);
      } else {
        scheduled.add(task);
      }
    }
  }
}
