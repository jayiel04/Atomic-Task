import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/timer/data/datasources/timer_local_data_source.dart';
import 'features/timer/data/repositories/timer_repository_impl.dart';
import 'features/timer/data/services/local_timer_notification_service.dart';
import 'features/timer/domain/services/timer_notification_service.dart';
import 'features/timer/domain/usecases/clear_progress.dart';
import 'features/timer/domain/usecases/load_progress.dart';
import 'features/timer/domain/usecases/save_progress.dart';
import 'features/timer/presentation/controllers/timer_controller.dart';
import 'features/timer/presentation/pages/timer_page.dart';

class AtomicTimerBootstrap extends StatefulWidget {
  const AtomicTimerBootstrap({this.notificationService, super.key});

  final TimerNotificationService? notificationService;

  @override
  State<AtomicTimerBootstrap> createState() => _AtomicTimerBootstrapState();
}

class _AtomicTimerBootstrapState extends State<AtomicTimerBootstrap> {
  late final TimerController _controller;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();

    final localDataSource = SharedPreferencesTimerLocalDataSource();
    final repository = TimerRepositoryImpl(localDataSource);
    final notificationService =
        widget.notificationService ?? LocalTimerNotificationService();

    _controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: notificationService,
    )..initialize();

    _lifecycleListener = AppLifecycleListener(
      onResume: _controller.syncWithClock,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tareas Atómicas',
      theme: AppTheme.light,
      home: TimerPage(controller: _controller),
    );
  }
}
