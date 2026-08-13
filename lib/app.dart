import 'dart:async';

import 'package:flutter/material.dart';

import 'core/database/app_database.dart';
import 'core/theme/app_theme.dart';
import 'features/tasks/data/datasources/task_local_data_source.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/usecases/assign_task_focus.dart';
import 'features/tasks/domain/usecases/create_task.dart';
import 'features/tasks/domain/usecases/delete_task.dart';
import 'features/tasks/domain/usecases/toggle_task_completion.dart';
import 'features/tasks/domain/usecases/update_task.dart';
import 'features/tasks/domain/usecases/watch_tasks.dart';
import 'features/tasks/presentation/controllers/task_controller.dart';
import 'features/timer/data/datasources/timer_local_data_source.dart';
import 'features/timer/data/repositories/timer_repository_impl.dart';
import 'features/timer/data/repositories/timer_session_repository_impl.dart';
import 'features/timer/data/services/admob_focus_completion_ad_service.dart';
import 'features/timer/data/services/local_timer_notification_service.dart';
import 'features/timer/domain/services/focus_completion_ad_service.dart';
import 'features/timer/domain/services/timer_notification_service.dart';
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
    super.key,
  });

  final TimerNotificationService? notificationService;
  final FocusCompletionAdService? focusCompletionAdService;
  final TimerLocalDataSource? localDataSource;
  final TaskLocalDataSource? taskLocalDataSource;

  @override
  State<AtomicTimerBootstrap> createState() => _AtomicTimerBootstrapState();
}

class _AtomicTimerBootstrapState extends State<AtomicTimerBootstrap> {
  late final TimerController _controller;
  late final TaskController _taskController;
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
    final sessionRepository = database == null
        ? null
        : DriftTimerSessionRepository(database);
    final notificationService =
        widget.notificationService ?? LocalTimerNotificationService();
    final focusCompletionAdService =
        widget.focusCompletionAdService ?? AdMobFocusCompletionAdService();

    final taskLocalDataSource =
        widget.taskLocalDataSource ?? DriftTaskLocalDataSource(database!);
    final taskRepository = TaskRepositoryImpl(taskLocalDataSource);
    _taskController = TaskController(
      WatchTasks(taskRepository),
      CreateTask(taskRepository),
      UpdateTask(taskRepository),
      ToggleTaskCompletion(taskRepository),
      DeleteTask(taskRepository),
      AssignTaskFocus(taskRepository),
    )..initialize();

    _controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: notificationService,
      focusCompletionAdService: focusCompletionAdService,
      sessionRepository: sessionRepository,
      onLinkedTaskFocusCompletedAsync: _taskController.completeById,
    )..initialize();

    _lifecycleListener = AppLifecycleListener(
      onResume: _controller.handleAppResumed,
      onPause: _controller.persistSession,
      onDetach: _controller.persistSession,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _controller.dispose();
    _taskController.dispose();
    final database = _database;
    if (database != null) {
      unawaited(database.close());
    }
    super.dispose();
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
          );
        },
      ),
    );
  }
}
