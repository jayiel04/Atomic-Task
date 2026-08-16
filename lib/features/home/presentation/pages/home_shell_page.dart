import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../tasks/domain/entities/atomic_task.dart';
import '../../../tasks/presentation/controllers/task_controller.dart';
import '../../../tasks/presentation/pages/task_page.dart';
import '../../../timer/domain/entities/timer_mode.dart';
import '../../../timer/domain/entities/timer_session.dart';
import '../../../timer/presentation/controllers/timer_controller.dart';
import '../../../timer/presentation/pages/timer_page.dart';
import '../../../timer/presentation/widgets/focus_completion_summary_sheet.dart';
import '../../../timer/presentation/widgets/required_profile_name_dialog.dart';
import '../home_destination.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_bottom_navigation.dart';
import '../widgets/home_sidebar.dart';
import '../widgets/progress_detail_sheet.dart';
import 'settings_view.dart';
import 'statistics_view.dart';

enum _ProgressDetailKind { focusTime, gems }

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({
    required this.timerController,
    required this.taskController,
    super.key,
  });

  final TimerController timerController;
  final TaskController taskController;

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  HomeDestination _selectedDestination = HomeDestination.tasks;
  bool _nameRequestScheduled = false;
  bool _restoredTabApplied = false;
  String? _lastSummaryId;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TimerController get _timerController => widget.timerController;
  TaskController get _taskController => widget.taskController;

  @override
  void initState() {
    super.initState();
    _timerController.addListener(_handleTimerChanged);
    _taskController.addListener(_handleTaskChanged);
    _handleTimerChanged();
  }

  @override
  void didUpdateWidget(covariant HomeShellPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timerController != widget.timerController) {
      oldWidget.timerController.removeListener(_handleTimerChanged);
      widget.timerController.addListener(_handleTimerChanged);
      _restoredTabApplied = false;
      _handleTimerChanged();
    }
    if (oldWidget.taskController != widget.taskController) {
      oldWidget.taskController.removeListener(_handleTaskChanged);
      widget.taskController.addListener(_handleTaskChanged);
    }
  }

  @override
  void dispose() {
    _timerController.removeListener(_handleTimerChanged);
    _taskController.removeListener(_handleTaskChanged);
    super.dispose();
  }

  void _handleTaskChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleTimerChanged() {
    if (!_timerController.isInitialized) {
      return;
    }

    if (!_restoredTabApplied && _timerController.hasRestorableSession) {
      _restoredTabApplied = true;
      _selectedDestination = HomeDestination.focus;
    }

    if (!_nameRequestScheduled &&
        _timerController.progress.profileName == 'NOMBRE') {
      _nameRequestScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showNameDialog();
        }
      });
    }

    final summary = _timerController.pendingCompletionSummary;
    if (summary != null && summary.sessionId != _lastSummaryId) {
      _lastSummaryId = summary.sessionId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_showCompletionSummary(summary));
        }
      });
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showNameDialog() async {
    await showRequiredProfileNameDialog(
      context,
      onSubmitted: _timerController.updateProfileName,
    );
  }

  Future<void> _showCompletionSummary(CompletionSummary summary) async {
    if (summary.mode == TimerMode.focus) {
      await showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        constraints: const BoxConstraints(maxWidth: 480),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (sheetContext) => FocusCompletionSummarySheet(
          gemsGenerated: summary.gemDelta,
          completedSeconds: summary.completedSeconds,
          completedTaskTitle:
              summary.taskId != null && !summary.taskCompletionPending
              ? summary.taskTitle
              : null,
          awaySecondsAfterCompletion: summary.completedWhileAppWasAway
              ? summary.awaySecondsAfterCompletion
              : null,
          onClose: () => Navigator.pop(sheetContext),
        ),
      );
      if (mounted) {
        _timerController.consumePendingCompletionSummary();
      }
      return;
    }

    final taskLine = summary.taskTitle == null
        ? ''
        : '\nTarea: ${summary.taskTitle}';
    final minutes = summary.completedSeconds ~/ 60;
    final durationLabel =
        '$minutes min '
        '${summary.mode == TimerMode.focus ? 'de concentración' : 'de descanso'}';
    final gemLabel = summary.gemDelta >= 0
        ? '+${summary.gemDelta} '
              '${summary.gemDelta == 1 ? 'gema' : 'gemas'}'
        : '−${summary.gemDelta.abs()} '
              '${summary.gemDelta.abs() == 1 ? 'gema' : 'gemas'}';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryDark,
          content: Text(
            '${summary.mode == TimerMode.focus ? 'Sesión completada' : 'Descanso completado'}\n'
            '$durationLabel · $gemLabel$taskLine',
          ),
        ),
      );
    _timerController.consumePendingCompletionSummary();
  }

  Future<bool> _prepareFocusForTask(AtomicTask task, int minutes) async {
    return _timerController.prepareFocusForTask(
      taskId: task.id,
      taskTitle: task.title,
      minutes: minutes,
    );
  }

  void _selectDestination(HomeDestination destination) {
    setState(() {
      _selectedDestination = destination;
    });
  }

  Future<void> _showProgressDetail(_ProgressDetailKind kind) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      constraints: const BoxConstraints(maxWidth: 480),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return AnimatedBuilder(
          animation: _timerController,
          builder: (context, _) {
            final progress = _timerController.progress;

            return switch (kind) {
              _ProgressDetailKind.focusTime => ProgressDetailSheet(
                key: const Key('focusTimeDetailSheet'),
                icon: Icons.schedule_rounded,
                title: 'Tiempo de concentración',
                value: TimeFormatter.totalFocusDetailed(
                  progress.totalFocusSeconds,
                ),
                description:
                    'Se acumula mientras una sesión de concentración está en '
                    'curso. Las pausas y los descansos no cuentan.',
                accentColor: AppColors.focusAccent,
                accentSurface: AppColors.focusAccentSoft,
              ),
              _ProgressDetailKind.gems => ProgressDetailSheet(
                key: const Key('gemsDetailSheet'),
                icon: Icons.diamond_rounded,
                title: 'Gemas disponibles',
                value: progress.gems.toString(),
                description:
                    'Ganas 1 gema por cada 3 minutos completos de '
                    'concentración. Cada minuto completo de descanso consume '
                    '1 gema.',
                accentColor: AppColors.primaryDark,
                accentSurface: AppColors.primarySoft,
              ),
            };
          },
        );
      },
    );
  }

  Future<void> _confirmResetProgress() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Restablecer progreso'),
          content: const Text(
            'Se borrarán las gemas, el tiempo acumulado y el nombre guardado.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              key: const Key('confirmResetProgressButton'),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Restablecer'),
            ),
          ],
        );
      },
    );

    if (accepted != true || !mounted) {
      return;
    }

    _nameRequestScheduled = false;
    _scaffoldKey.currentState?.closeDrawer();
    await _timerController.resetProgress();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _timerController.progress;
    final showsPrimaryNavigation =
        _selectedDestination == HomeDestination.tasks ||
        _selectedDestination == HomeDestination.focus;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      drawer: HomeSidebar(
        selectedDestination: _selectedDestination,
        onDestinationSelected: _selectDestination,
        onResetProgress: _confirmResetProgress,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: !showsPrimaryNavigation,
          child: Column(
            children: [
              HomeAppBar(
                title: _selectedDestination.title,
                showUserSummary: showsPrimaryNavigation,
                profileName: progress.profileName,
                totalFocusSeconds: progress.totalFocusSeconds,
                gems: progress.gems,
                onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                onProfilePressed: () =>
                    _selectDestination(HomeDestination.settings),
                onFocusTimePressed: () {
                  unawaited(_showProgressDetail(_ProgressDetailKind.focusTime));
                },
                onGemsPressed: () {
                  unawaited(_showProgressDetail(_ProgressDetailKind.gems));
                },
              ),
              Expanded(
                child: IndexedStack(
                  index: _selectedDestination.index,
                  children: [
                    TasksView(
                      controller: _taskController,
                      onStartFocus: _prepareFocusForTask,
                      onFocusPrepared: () =>
                          _selectDestination(HomeDestination.focus),
                      showCreateAction: true,
                    ),
                    FocusView(controller: _timerController, compactReset: true),
                    SettingsView(
                      profileName: progress.profileName,
                      onProfileNameChanged: _timerController.updateProfileName,
                    ),
                    StatisticsView(
                      totalFocusSeconds: progress.totalFocusSeconds,
                      gems: progress.gems,
                      controller: _taskController,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: showsPrimaryNavigation
          ? HomeBottomNavigation(
              selectedDestination: _selectedDestination,
              onSelected: _selectDestination,
            )
          : null,
    );
  }
}
