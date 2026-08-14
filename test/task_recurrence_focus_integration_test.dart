import 'package:atomic_task/core/database/app_database.dart';
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
import 'package:atomic_task/features/timer/domain/entities/user_progress.dart';
import 'package:atomic_task/features/timer/domain/repositories/timer_repository.dart';
import 'package:atomic_task/features/timer/domain/services/focus_completion_ad_service.dart';
import 'package:atomic_task/features/timer/domain/services/timer_notification_service.dart';
import 'package:atomic_task/features/timer/domain/usecases/clear_progress.dart';
import 'package:atomic_task/features/timer/domain/usecases/load_progress.dart';
import 'package:atomic_task/features/timer/domain/usecases/save_progress.dart';
import 'package:atomic_task/features/timer/presentation/controllers/timer_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('focus completion creates the next recurring occurrence', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);
    var now = DateTime(2026, 8, 14, 9);
    final taskController = _buildTaskController(database, now: () => now)
      ..initialize();
    addTearDown(taskController.dispose);

    expect(
      await taskController.createRecurring(
        title: 'Práctica diaria',
        dueDate: null,
        frequency: RecurrenceFrequency.daily,
        interval: 1,
        startDate: DateTime(2026, 8, 14),
        endDate: null,
      ),
      isTrue,
    );
    await pumpEventQueue();
    var task = taskController.pendingTasks.single;
    expect(await taskController.assignFocus(task, 1), isTrue);
    await pumpEventQueue();
    task = taskController.pendingTasks.single;

    final timerRepository = _MemoryTimerRepository();
    final timerController = TimerController(
      loadProgress: LoadProgress(timerRepository),
      saveProgress: SaveProgress(timerRepository),
      clearProgress: ClearProgress(timerRepository),
      notificationService: _NoopNotificationService(),
      focusCompletionAdService: _NoopAdService(),
      onLinkedTaskFocusCompletedAtAsync: taskController.completeByIdAt,
      now: () => now,
    );
    addTearDown(timerController.dispose);
    await timerController.initialize();

    expect(
      timerController.prepareFocusForTask(
        taskId: task.id,
        taskTitle: task.title,
        minutes: 1,
      ),
      isTrue,
    );
    timerController.startOrPause();
    now = now.add(const Duration(minutes: 1));
    timerController.syncWithClock();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await pumpEventQueue();

    expect(taskController.completedTasks, hasLength(1));
    expect(taskController.completedTasks.single.completedAt, now);
    expect(taskController.pendingTasks, hasLength(1));
    expect(
      taskController.pendingTasks.single.occurrenceDate,
      DateTime(2026, 8, 15),
    );
    expect(taskController.pendingTasks.single.focusMinutes, 1);
  });

  test(
    'reactivating a completed paused series creates its next task',
    () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);
      final now = DateTime(2026, 8, 14, 9);
      final controller = _buildTaskController(database, now: () => now)
        ..initialize();
      addTearDown(controller.dispose);

      await controller.createRecurring(
        title: 'Serie pausada',
        dueDate: null,
        frequency: RecurrenceFrequency.daily,
        interval: 1,
        startDate: DateTime(2026, 8, 14),
        endDate: null,
      );
      await pumpEventQueue();
      await controller.setRecurrenceActive(
        controller.pendingTasks.single,
        isActive: false,
      );
      await pumpEventQueue();
      await controller.toggleCompletion(controller.pendingTasks.single);
      await pumpEventQueue();
      expect(controller.pendingTasks, isEmpty);

      await controller.setRecurrenceActive(
        controller.completedTasks.single,
        isActive: true,
      );
      await pumpEventQueue();

      expect(controller.pendingTasks, hasLength(1));
      expect(
        controller.pendingTasks.single.occurrenceDate,
        DateTime(2026, 8, 15),
      );
    },
  );
}

TaskController _buildTaskController(
  AppDatabase database, {
  required DateTime Function() now,
}) {
  final repository = TaskRepositoryImpl(DriftTaskLocalDataSource(database));
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
    now: now,
  );
}

class _MemoryTimerRepository implements TimerRepository {
  UserProgress progress = const UserProgress(
    gems: 0,
    totalFocusSeconds: 0,
    profileName: 'Javier',
  );

  @override
  Future<UserProgress> loadProgress() async => progress;

  @override
  Future<void> saveProgress(UserProgress progress) async {
    this.progress = progress;
  }

  @override
  Future<void> clearProgress() async {
    progress = UserProgress.empty;
  }
}

class _NoopNotificationService implements TimerNotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> cancelTimerNotifications() async {}

  @override
  Future<void> showRunningTimer({
    required String timerName,
    required int remainingSeconds,
    required DateTime endsAt,
    required String completionTitle,
    required String completionBody,
  }) async {}

  @override
  Future<void> showTimerCompleted({
    required String title,
    required String body,
  }) async {}
}

class _NoopAdService implements FocusCompletionAdService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> showAfterFocusCompletion() async {}

  @override
  Future<FocusCompletionAdResult> showAfterFocusCompletionResult() async =>
      FocusCompletionAdResult.shown;

  @override
  Future<void> dispose() async {}
}
