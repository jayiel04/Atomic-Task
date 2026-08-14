import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../tasks/domain/entities/atomic_task.dart';
import '../../../tasks/presentation/controllers/task_controller.dart';
import '../../../tasks/presentation/pages/task_page.dart';
import '../../../timer/domain/entities/user_progress.dart';
import '../../../timer/domain/entities/timer_mode.dart';
import '../../../timer/domain/entities/timer_session.dart';
import '../../../timer/presentation/controllers/timer_controller.dart';
import '../../../timer/presentation/pages/timer_page.dart';
import '../home_destination.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_bottom_navigation.dart';
import '../widgets/home_sidebar.dart';
import 'settings_view.dart';
import 'statistics_view.dart';

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
          _showCompletionSummary(summary);
        }
      });
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showNameDialog() async {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('¡Bienvenido!'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Cómo te llamas? Usaremos tu nombre para personalizar '
                    'tu experiencia.',
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    key: const Key('firstLaunchNameField'),
                    controller: nameController,
                    autofocus: true,
                    maxLength: UserProgress.maxProfileNameLength,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Tu nombre',
                      hintText: 'Escribe tu nombre',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu nombre para continuar';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) =>
                        _saveName(dialogContext, formKey, nameController.text),
                  ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                key: const Key('saveFirstLaunchName'),
                onPressed: () =>
                    _saveName(dialogContext, formKey, nameController.text),
                child: const Text('Continuar'),
              ),
            ],
          ),
        );
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 300));
    nameController.dispose();
  }

  void _saveName(
    BuildContext dialogContext,
    GlobalKey<FormState> formKey,
    String name,
  ) {
    if (formKey.currentState?.validate() != true) {
      return;
    }

    _timerController.updateProfileName(name);
    Navigator.of(dialogContext).pop();
  }

  void _showCompletionSummary(CompletionSummary summary) {
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
          bottom: false,
          child: Column(
            children: [
              HomeAppBar(
                title: _selectedDestination.title,
                profileName: progress.profileName,
                totalFocusSeconds: progress.totalFocusSeconds,
                gems: progress.gems,
                onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                onProfilePressed: () =>
                    _selectDestination(HomeDestination.settings),
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
      bottomNavigationBar: HomeBottomNavigation(
        selectedDestination: _selectedDestination,
        onSelected: _selectDestination,
      ),
    );
  }
}
