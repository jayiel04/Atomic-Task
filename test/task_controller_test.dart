import 'dart:async';

import 'package:atomic_task/core/audio/alarm_sound.dart';
import 'package:atomic_task/features/tasks/domain/entities/atomic_task.dart';
import 'package:atomic_task/features/tasks/domain/repositories/task_repository.dart';
import 'package:atomic_task/features/tasks/domain/services/task_reminder_service.dart';
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
    final completedAt = now;
    expect(controller.completedTasks.single.completedAt, completedAt);
    expect(controller.completedTodayCount, 1);

    now = now.add(const Duration(hours: 1));
    expect(
      await controller.update(
        task: controller.completedTasks.single,
        title: 'Informe completado',
        dueDate: null,
      ),
      isTrue,
    );
    await pumpEventQueue();
    expect(controller.completedTasks.single.completedAt, completedAt);

    expect(await controller.toggleCompletion(controller.tasks.single), isTrue);
    await pumpEventQueue();
    expect(controller.pendingTasks, hasLength(1));
    expect(controller.pendingTasks.single.completedAt, isNull);
    expect(controller.completedTodayCount, 0);

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

  test('plays task effects only after successful create and delete', () async {
    final repository = MemoryTaskRepository();
    addTearDown(repository.dispose);
    final audioService = _FakeAudioService();
    final controller = _buildController(repository, audioService: audioService)
      ..initialize();
    addTearDown(controller.dispose);
    repository.emit();
    await pumpEventQueue();

    expect(await controller.create(title: 'Nueva tarea'), isTrue);
    await pumpEventQueue();
    expect(audioService.effects, [AppAudioEffect.taskCreated]);

    expect(await controller.delete(controller.tasks.single), isTrue);
    await pumpEventQueue();
    expect(audioService.effects, [
      AppAudioEffect.taskCreated,
      AppAudioEffect.taskDeleted,
    ]);
  });

  test(
    'does not notify after a pending mutation outlives the controller',
    () async {
      final repository = _DelayedCreateTaskRepository();
      addTearDown(repository.dispose);
      final controller = _buildController(repository);

      controller.initialize();
      repository.emit();
      await pumpEventQueue();

      var notifications = 0;
      controller.addListener(() => notifications += 1);
      final creation = controller.create(title: 'Tarea pendiente');
      expect(controller.isMutating, isTrue);
      expect(notifications, 1);

      controller.dispose();
      repository.completeCreate();

      await expectLater(creation, completion(isTrue));
      expect(notifications, 1);
    },
  );

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

  test(
    'counts completions from today and orders history newest first',
    () async {
      var now = DateTime(2026, 8, 14, 15);
      final createdAt = DateTime(2026, 8, 1);
      final repository = MemoryTaskRepository(
        initialTasks: [
          AtomicTask(
            id: 1,
            title: 'Anterior',
            isCompleted: true,
            completedAt: DateTime(2026, 8, 13, 18),
            createdAt: createdAt,
            updatedAt: DateTime(2026, 8, 13, 18),
          ),
          AtomicTask(
            id: 2,
            title: 'Esta mañana',
            isCompleted: true,
            completedAt: DateTime(2026, 8, 14, 8),
            createdAt: createdAt,
            updatedAt: DateTime(2026, 8, 14, 8),
          ),
          AtomicTask(
            id: 3,
            title: 'Más reciente',
            isCompleted: true,
            completedAt: DateTime(2026, 8, 14, 12),
            createdAt: createdAt,
            updatedAt: DateTime(2026, 8, 14, 12),
          ),
          AtomicTask(
            id: 4,
            title: 'Pendiente',
            isCompleted: false,
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        ],
      );
      addTearDown(repository.dispose);
      final controller = _buildController(repository, now: () => now)
        ..initialize();
      addTearDown(controller.dispose);
      repository.emit();
      await pumpEventQueue();

      expect(controller.completedTasks.map((task) => task.id), [3, 2, 1]);
      expect(controller.completedTodayCount, 2);

      now = DateTime(2026, 8, 15, 0, 1);
      expect(controller.completedTodayCount, 0);
    },
  );

  test(
    'propagates the reminder sound key when creating and clearing',
    () async {
      final repository = _FakeAlarmTaskRepository();
      addTearDown(repository.dispose);
      final now = DateTime(2026, 8, 10, 9);
      final reminderAt = now.add(const Duration(hours: 2));
      final reminderService = _RecordingReminderService();
      final controller = TaskController(
        WatchTasks(repository),
        CreateTask(repository),
        UpdateTask(repository),
        ToggleTaskCompletion(repository),
        DeleteTask(repository),
        AssignTaskFocus(repository),
        reminderService: reminderService,
        now: () => now,
      );
      addTearDown(controller.dispose);
      controller.initialize();
      repository.emit();
      await pumpEventQueue();

      expect(
        await controller.create(
          title: 'Con sonido propio',
          reminderAt: reminderAt,
          reminderMode: TaskReminderMode.alarm,
          reminderSoundKey: 'pulso_electronico',
        ),
        isTrue,
      );
      await pumpEventQueue();
      expect(repository.createdSoundKeys.single, 'pulso_electronico');
      expect(
        reminderService.scheduled.single.reminderSoundKey,
        'pulso_electronico',
      );

      final task = controller.tasks.single;
      expect(
        await controller.update(
          task: task,
          title: 'Con sonido propio',
          dueDate: null,
          reminderAt: reminderAt,
          reminderMode: TaskReminderMode.alarm,
          reminderSoundKey: null,
        ),
        isTrue,
      );
      await pumpEventQueue();
      expect(repository.updatedSoundKeys.single, isNull);

      expect(
        await controller.update(
          task: controller.tasks.single,
          title: 'Con sonido propio',
          dueDate: null,
          clearReminder: true,
          reminderMode: TaskReminderMode.alarm,
        ),
        isTrue,
      );
      await pumpEventQueue();
      expect(reminderService.cancelled, isNotEmpty);
    },
  );
}

class _DelayedCreateTaskRepository extends MemoryTaskRepository {
  final _createCompletion = Completer<int>();

  void completeCreate() => _createCompletion.complete(1);

  @override
  Future<int> createTask({
    required String title,
    required DateTime? dueDate,
    required DateTime createdAt,
  }) {
    return _createCompletion.future;
  }
}

TaskController _buildController(
  MemoryTaskRepository repository, {
  DateTime Function()? now,
  AppAudioService? audioService,
}) {
  return TaskController(
    WatchTasks(repository),
    CreateTask(repository),
    UpdateTask(repository),
    ToggleTaskCompletion(repository),
    DeleteTask(repository),
    AssignTaskFocus(repository),
    audioService: audioService,
    now: now,
  );
}

class _FakeAudioService implements AppAudioService {
  final List<AppAudioEffect> effects = [];

  @override
  Future<void> playEffect(AppAudioEffect effect) async {
    effects.add(effect);
  }

  @override
  Future<void> previewAlarm(
    AlarmSound sound, {
    void Function()? onCompleted,
  }) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

class _FakeAlarmTaskRepository extends MemoryTaskRepository
    implements TaskAlarmRepository {
  final List<String?> createdSoundKeys = [];
  final List<String?> updatedSoundKeys = [];

  @override
  Future<int> createTaskWithReminder({
    required String title,
    required DateTime? dueDate,
    required DateTime? reminderAt,
    required DateTime createdAt,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
    String? reminderSoundKey,
  }) async {
    createdSoundKeys.add(reminderSoundKey);
    final id = await createTask(
      title: title,
      dueDate: dueDate,
      createdAt: createdAt,
    );
    return id;
  }

  @override
  Future<void> updateTaskWithReminder({
    required int id,
    required String title,
    required DateTime? dueDate,
    required DateTime? reminderAt,
    required DateTime updatedAt,
    TaskReminderMode reminderMode = TaskReminderMode.notification,
    String? reminderSoundKey,
  }) async {
    updatedSoundKeys.add(reminderAt == null ? null : reminderSoundKey);
    await updateTask(
      id: id,
      title: title,
      dueDate: dueDate,
      updatedAt: updatedAt,
    );
  }
}

class _RecordingReminderService implements TaskReminderService {
  final List<AtomicTask> scheduled = [];
  final List<AtomicTask> cancelled = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> schedule(AtomicTask task) async {
    scheduled.add(task);
  }

  @override
  Future<void> cancel(AtomicTask task) async {
    cancelled.add(task);
  }

  @override
  Future<void> reconcile(Iterable<AtomicTask> tasks, {DateTime? now}) async {}
}
