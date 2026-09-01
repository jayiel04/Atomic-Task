import 'package:atomic_task/core/audio/alarm_sound.dart';
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
import 'package:atomic_task/features/tasks/presentation/task_date_formatter.dart';
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

  test(
    'propagates the reminder sound to the next recurring occurrence',
    () async {
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
        reminderMode: TaskReminderMode.alarm,
        reminderSoundKey: 'amanecer_suave',
      );
      final firstTask = (await dataSource.watchAll().first).single;
      expect(firstTask.reminderSoundKey, 'amanecer_suave');

      await dataSource.ensureOccurrence(
        template: firstTask,
        occurrenceDate: DateTime(2026, 8, 21),
        createdAt: createdAt.add(const Duration(days: 1)),
      );
      final nextTask = (await dataSource.watchAll().first).singleWhere(
        (task) => task.occurrenceDate == DateTime(2026, 8, 21),
      );

      expect(nextTask.reminderAt, DateTime(2026, 8, 21, 10));
      expect(nextTask.reminderMode, TaskReminderMode.alarm);
      expect(nextTask.reminderSoundKey, 'amanecer_suave');
    },
  );

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

  testWidgets('shows the alarm editor and clears an existing alarm', (
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

    // El ícono vive dentro de la vista de fecha límite y es la única vía para
    // configurar la alarma.
    expect(find.byKey(const Key('dueAlarmSection')), findsNothing);
    expect(find.byKey(const Key('dueAlarmSwitch')), findsNothing);
    expect(find.byKey(const Key('dueAlarmIcon')), findsNothing);

    await tester.tap(find.byKey(const Key('taskDueDateSection')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dueAlarmIcon')), findsOneWidget);

    await tester.tap(find.byKey(const Key('dueAlarmIcon')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dueAlarmToggleItem')), findsOneWidget);
    expect(find.byKey(const Key('dueAlarmTimeItem')), findsOneWidget);
    expect(find.byKey(const Key('dueAlarmModeAlarmItem')), findsOneWidget);
    expect(
      find.byKey(const Key('dueAlarmModeNotificationItem')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('dueAlarmSoundItem')), findsOneWidget);
    expect(find.byKey(const Key('dueAlarmSaveButton')), findsOneWidget);
    expect(find.byKey(const Key('dueAlarmCancelButton')), findsOneWidget);

    // Cancelar cierra la tarjeta sin aplicar cambios.
    await tester.ensureVisible(find.byKey(const Key('dueAlarmCancelButton')));
    await tester.tap(find.byKey(const Key('dueAlarmCancelButton')));
    await tester.pumpAndSettle();
    final iconBefore = tester.widget<Icon>(
      find
          .descendant(
            of: find.byKey(const Key('dueAlarmIcon')),
            matching: find.byType(Icon),
          )
          .first,
    );
    expect(iconBefore.icon, Icons.alarm_on_rounded);

    // Quitar la alarma desde la tarjeta y guardar limpia hora, modo y sonido.
    await tester.tap(find.byKey(const Key('dueAlarmIcon')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dueAlarmToggleItem')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('dueAlarmSaveButton')));
    await tester.tap(find.byKey(const Key('dueAlarmSaveButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dueAlarmIcon')), findsOneWidget);
    final alarmIcon = tester.widget<Icon>(
      find
          .descendant(
            of: find.byKey(const Key('dueAlarmIcon')),
            matching: find.byType(Icon),
          )
          .first,
    );
    expect(alarmIcon.icon, Icons.alarm_add_rounded);
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

  testWidgets('alarm editor blocks applying a past hour', (tester) async {
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

    await tester.tap(find.byKey(const Key('taskDueDateSection')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('dueAlarmIcon')));
    await tester.tap(find.byKey(const Key('dueAlarmIcon')));
    await tester.pumpAndSettle();

    // Guardar con la hora vencida muestra el mensaje y mantiene la tarjeta
    // abierta sin aplicar cambios.
    await tester.ensureVisible(find.byKey(const Key('dueAlarmSaveButton')));
    await tester.tap(find.byKey(const Key('dueAlarmSaveButton')));
    await tester.pumpAndSettle();
    expect(
      find.text('La alarma debe programarse para una fecha y hora futuras.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('dueAlarmSaveButton')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('dueAlarmCancelButton')));
    await tester.tap(find.byKey(const Key('dueAlarmCancelButton')));
    await tester.pumpAndSettle();
    final icon = tester.widget<Icon>(
      find
          .descendant(
            of: find.byKey(const Key('dueAlarmIcon')),
            matching: find.byType(Icon),
          )
          .first,
    );
    expect(icon.icon, Icons.alarm_on_rounded);
  });

  testWidgets('due date picker does not allow days before today', (
    tester,
  ) async {
    final now = DateTime(2026, 8, 20, 9);
    final repository = MemoryTaskRepository();
    addTearDown(repository.dispose);
    final controller = _buildController(repository, now: () => now);
    addTearDown(controller.dispose);
    final task = AtomicTask(
      id: 1,
      title: 'Tarea vencida',
      isCompleted: false,
      dueDate: DateTime(2026, 8, 10),
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
    expect(find.text('10/08/2026'), findsOneWidget);

    // La configuración vive en la vista de fecha límite; el calendario
    // arranca en hoy (20/08) y los días anteriores están deshabilitados:
    // elegir el 19 no cambia la selección y confirmar devuelve la fecha
    // inicial.
    await tester.tap(find.byKey(const Key('taskDueDateSection')));
    await tester.pumpAndSettle();
    expect(find.text('10/08/2026'), findsOneWidget);
    await tester.tap(find.byKey(const Key('selectTaskDueDateButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('19'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aceptar'));
    await tester.pumpAndSettle();

    expect(find.text('20/08/2026'), findsOneWidget);
    expect(find.text('19/08/2026'), findsNothing);
    expect(find.text('10/08/2026'), findsNothing);
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

    // El ícono de alarma solo aparece dentro de las vistas de configuración.
    expect(find.byKey(const Key('dueAlarmIcon')), findsNothing);
    expect(find.byKey(const Key('repeatAlarmIcon')), findsNothing);

    await tester.tap(find.byKey(const Key('taskDueDateSection')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dueAlarmIcon')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('dueAlarmIcon')));
    await tester.tap(find.byKey(const Key('dueAlarmIcon')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dueAlarmToggleItem')), findsOneWidget);
    expect(find.byKey(const Key('dueAlarmSoundItem')), findsOneWidget);
    expect(find.text('Predeterminada'), findsOneWidget);
    expect(find.byKey(const Key('dueAlarmScopeAlwaysItem')), findsNothing);
    expect(find.byKey(const Key('dueAlarmScopeFirstItem')), findsNothing);

    // Cierra el editor antes de cambiar de opción.
    await tester.ensureVisible(find.byKey(const Key('dueAlarmCancelButton')));
    await tester.tap(find.byKey(const Key('dueAlarmCancelButton')));
    await tester.pumpAndSettle();

    // Volver conservando mantiene la fecha límite configurada.
    await tester.tap(find.byKey(const Key('formBackButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('formKeepChangesButton')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(TaskDateFormatter.format(DateTime(2026, 8, 20))),
      findsOneWidget,
    );

    // Configurar la tarea cíclica limpia la fecha límite (exclusividad).
    await tester.tap(find.byKey(const Key('taskRecurrenceSection')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('repeatAlarmIcon')), findsOneWidget);

    await tester.tap(find.byKey(const Key('formBackButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('formKeepChangesButton')));
    await tester.pumpAndSettle();
    expect(find.text('Limita cuándo debe completarse'), findsOneWidget);

    await tester.tap(find.byKey(const Key('taskRecurrenceSection')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('repeatAlarmIcon')));
    await tester.tap(find.byKey(const Key('repeatAlarmIcon')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('repeatAlarmToggleItem')), findsOneWidget);
    expect(find.byKey(const Key('repeatAlarmScopeAlwaysItem')), findsOneWidget);
    expect(find.byKey(const Key('repeatAlarmScopeFirstItem')), findsOneWidget);
  });

  testWidgets('alarm editor offers sounds with the default option for '
      'recurrences', (tester) async {
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

    await tester.tap(find.byKey(const Key('taskRecurrenceSection')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('repeatAlarmIcon')));
    await tester.tap(find.byKey(const Key('repeatAlarmIcon')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('repeatAlarmToggleItem')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('repeatAlarmSoundDefaultOption')),
      findsOneWidget,
    );
    for (final sound in AlarmSound.values) {
      expect(
        find.byKey(Key('repeatAlarmSoundOption_${sound.storageKey}')),
        findsOneWidget,
      );
    }

    await tester.ensureVisible(find.text('Pulso Electrónico'));
    await tester.tap(find.text('Pulso Electrónico'));
    await tester.pumpAndSettle();

    // Guardar aplica el borrador y cierra la tarjeta; se reabre para
    // verificar la selección.
    await tester.ensureVisible(find.byKey(const Key('repeatAlarmSaveButton')));
    await tester.tap(find.byKey(const Key('repeatAlarmSaveButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('repeatAlarmIcon')));
    await tester.pumpAndSettle();

    final chip = tester.widget<ChoiceChip>(
      find.byKey(const Key('repeatAlarmSoundOption_pulso_electronico')),
    );
    expect(chip.selected, isTrue);
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
