import 'dart:async';

import 'package:flutter/material.dart';

import 'core/audio/alarm_sound.dart';
import 'core/audio/local_app_audio_service.dart';
import 'core/audio/shared_preferences_alarm_sound_settings.dart';
import 'core/database/app_database.dart';
import 'core/theme/app_theme.dart';
import 'features/tasks/data/datasources/task_local_data_source.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/data/services/local_task_reminder_service.dart';
import 'features/tasks/domain/services/task_reminder_service.dart';
import 'features/tasks/domain/usecases/assign_task_focus.dart';
import 'features/tasks/domain/services/recurrence_calculator.dart';
import 'features/tasks/domain/services/recurrence_generation_policy.dart';
import 'features/tasks/domain/usecases/complete_task_occurrence.dart';
import 'features/tasks/domain/usecases/calculate_next_occurrence.dart';
import 'features/tasks/domain/usecases/create_task.dart';
import 'features/tasks/domain/usecases/create_recurring_task.dart';
import 'features/tasks/domain/usecases/delete_task.dart';
import 'features/tasks/domain/usecases/delete_task_occurrence.dart';
import 'features/tasks/domain/usecases/delete_task_series.dart';
import 'features/tasks/domain/usecases/reconcile_task_recurrences.dart';
import 'features/tasks/domain/usecases/set_task_recurrence_active.dart';
import 'features/tasks/domain/usecases/toggle_task_completion.dart';
import 'features/tasks/domain/usecases/update_task.dart';
import 'features/tasks/domain/usecases/update_recurring_occurrence.dart';
import 'features/tasks/domain/usecases/update_recurring_series.dart';
import 'features/tasks/domain/usecases/watch_tasks.dart';
import 'features/tasks/presentation/controllers/task_controller.dart';
import 'features/alarm/presentation/controllers/alarm_controller.dart';
import 'features/timer/data/datasources/timer_local_data_source.dart';
import 'features/timer/data/repositories/timer_repository_impl.dart';
import 'features/timer/data/repositories/timer_session_repository_impl.dart';
import 'features/timer/data/services/admob_focus_completion_ad_service.dart';
import 'features/timer/data/services/local_timer_notification_service.dart';
import 'features/timer/domain/services/focus_completion_ad_service.dart';
import 'features/timer/domain/services/timer_notification_service.dart';
import 'features/timer/domain/repositories/timer_session_repository.dart';
import 'features/timer/domain/usecases/clear_progress.dart';
import 'features/timer/domain/usecases/load_progress.dart';
import 'features/timer/domain/usecases/save_progress.dart';
import 'features/timer/presentation/controllers/timer_controller.dart';
import 'features/home/presentation/pages/home_shell_page.dart';

class AtomicTimerBootstrap extends StatefulWidget {
  const AtomicTimerBootstrap({
    this.notificationService,
    this.focusCompletionAdService,
    this.localDataSource,
    this.taskLocalDataSource,
    this.sessionRepository,
    this.taskReminderService,
    this.alarmSoundSettings,
    this.audioService,
    super.key,
  });

  final TimerNotificationService? notificationService;
  final FocusCompletionAdService? focusCompletionAdService;
  final TimerLocalDataSource? localDataSource;
  final TaskLocalDataSource? taskLocalDataSource;
  final TimerSessionRepository? sessionRepository;
  final TaskReminderService? taskReminderService;
  final AlarmSoundSettings? alarmSoundSettings;
  final AppAudioService? audioService;

  @override
  State<AtomicTimerBootstrap> createState() => _AtomicTimerBootstrapState();
}

class _AtomicTimerBootstrapState extends State<AtomicTimerBootstrap> {
  late final TimerController _controller;
  late final TaskController _taskController;
  late final AlarmController _alarmController;
  late final AppLifecycleListener _lifecycleListener;
  AppDatabase? _database;

  @override
  void initState() {
    super.initState();

    final database =
        widget.localDataSource == null || widget.taskLocalDataSource == null
        ? AppDatabase()
        : null;
    _database = database;
    final localDataSource =
        widget.localDataSource ?? DriftTimerLocalDataSource(database!);
    final repository = TimerRepositoryImpl(localDataSource);
    final sessionRepository =
        widget.sessionRepository ??
        (database == null ? null : DriftTimerSessionRepository(database));
    final alarmSoundSettings =
        widget.alarmSoundSettings ?? SharedPreferencesAlarmSoundSettings();
    final audioService = widget.audioService ?? LocalAppAudioService();
    final notificationService =
        widget.notificationService ??
        LocalTimerNotificationService(alarmSoundSettings: alarmSoundSettings);
    final focusCompletionAdService =
        widget.focusCompletionAdService ?? AdMobFocusCompletionAdService();

    final taskLocalDataSource =
        widget.taskLocalDataSource ?? DriftTaskLocalDataSource(database!);
    final taskRepository = TaskRepositoryImpl(taskLocalDataSource);
    final taskReminderService =
        widget.taskReminderService ??
        (database == null
            ? null
            : LocalTaskReminderService(alarmSoundSettings: alarmSoundSettings));
    final supportsRecurrence =
        taskLocalDataSource is TaskRecurrenceLocalDataSource;
    const recurrenceCalculator = RecurrenceCalculator();
    const recurrencePolicy = RecurrenceGenerationPolicy(recurrenceCalculator);
    const calculateNextOccurrence = CalculateNextOccurrence(recurrencePolicy);
    final updateTask = UpdateTask(taskRepository);
    _taskController = TaskController(
      WatchTasks(taskRepository),
      CreateTask(taskRepository),
      updateTask,
      ToggleTaskCompletion(taskRepository),
      DeleteTask(taskRepository),
      AssignTaskFocus(taskRepository),
      createRecurringTaskUseCase: supportsRecurrence
          ? CreateRecurringTask(taskRepository)
          : null,
      updateRecurringOccurrenceUseCase: supportsRecurrence
          ? UpdateRecurringOccurrence(updateTask)
          : null,
      updateRecurringSeriesUseCase: supportsRecurrence
          ? UpdateRecurringSeries(taskRepository)
          : null,
      completeTaskOccurrenceUseCase: supportsRecurrence
          ? CompleteTaskOccurrence(
              taskRepository,
              taskRepository,
              calculateNextOccurrence,
            )
          : null,
      setTaskRecurrenceActiveUseCase: supportsRecurrence
          ? SetTaskRecurrenceActive(taskRepository)
          : null,
      deleteTaskOccurrenceUseCase: supportsRecurrence
          ? DeleteTaskOccurrence(
              taskRepository,
              taskRepository,
              calculateNextOccurrence,
            )
          : null,
      deleteTaskSeriesUseCase: supportsRecurrence
          ? DeleteTaskSeries(taskRepository)
          : null,
      reconcileTaskRecurrencesUseCase: supportsRecurrence
          ? ReconcileTaskRecurrences(taskRepository, recurrencePolicy)
          : null,
      reminderService: taskReminderService,
      audioService: audioService,
    )..initialize();

    _controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: notificationService,
      focusCompletionAdService: focusCompletionAdService,
      sessionRepository: sessionRepository,
      onLinkedTaskFocusCompletedAtAsync: _taskController.completeByIdAt,
    )..initialize();

    _alarmController = AlarmController(
      settings: alarmSoundSettings,
      audioService: audioService,
      onSoundChanged: () async {
        await Future.wait([
          _taskController.reconcileReminderSchedules(),
          _controller.refreshNotificationSound(),
        ]);
      },
    )..initialize();

    _lifecycleListener = AppLifecycleListener(
      onResume: _controller.handleAppResumed,
      onPause: _controller.handleAppPaused,
      onDetach: _controller.handleAppPaused,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _controller.dispose();
    _taskController.dispose();
    _alarmController.dispose();
    final database = _database;
    if (database != null) {
      unawaited(_flushControllerAndCloseDatabase(database));
    }
    super.dispose();
  }

  Future<void> _flushControllerAndCloseDatabase(AppDatabase database) async {
    await _controller.flushPersistence();
    await database.close();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tareas Atómicas',
      theme: AppTheme.light,
      home: Builder(
        builder: (context) {
          return HomeShellPage(
            timerController: _controller,
            taskController: _taskController,
            alarmController: _alarmController,
          );
        },
      ),
    );
  }
}
