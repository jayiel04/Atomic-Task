import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/timer_controller.dart';
import '../layout/timer_layout_spec.dart';
import '../widgets/header_section.dart';
import '../widgets/mode_selector.dart';
import '../widgets/primary_action_button.dart';
import '../widgets/progress_drawer.dart';
import '../widgets/timer_dial.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({
    required this.controller,
    required this.onOpenTasks,
    super.key,
  });

  final TimerController controller;
  final VoidCallback onOpenTasks;

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  bool _nameRequestScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_requestNameWhenReady);
    _requestNameWhenReady();
  }

  @override
  void didUpdateWidget(covariant TimerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_requestNameWhenReady);
      widget.controller.addListener(_requestNameWhenReady);
      _nameRequestScheduled = false;
      _requestNameWhenReady();
    }
  }

  void _requestNameWhenReady() {
    if (_nameRequestScheduled ||
        !widget.controller.isInitialized ||
        widget.controller.progress.profileName != 'NOMBRE') {
      return;
    }

    _nameRequestScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _showNameDialog();
    });
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
                    maxLength: 18,
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

    widget.controller.updateProfileName(name);
    Navigator.of(dialogContext).pop();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_requestNameWhenReady);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: ProgressDrawer(
        controller: widget.controller,
        onOpenTasks: widget.onOpenTasks,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _ControllerSelector<bool>(
            controller: widget.controller,
            select: (controller) => controller.isInitialized,
            builder: (context, isInitialized) {
              return isInitialized
                  ? FocusView(controller: widget.controller, showHeader: true)
                  : const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}

class FocusView extends StatelessWidget {
  const FocusView({
    required this.controller,
    this.showHeader = false,
    this.compactReset = false,
    super.key,
  });

  final TimerController controller;
  final bool showHeader;
  final bool compactReset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spec = TimerLayoutSpec.from(constraints);
        final contentWidth = math.min(
          spec.maxContentWidth,
          constraints.maxWidth - (spec.horizontalPadding * 2),
        );
        final contentHeight = math.max(
          0.0,
          constraints.maxHeight - spec.topPadding - spec.bottomPadding,
        );

        return Padding(
          padding: EdgeInsets.fromLTRB(
            spec.horizontalPadding,
            spec.topPadding,
            spec.horizontalPadding,
            spec.bottomPadding,
          ),
          child: SizedBox.expand(
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                height: contentHeight,
                child: spec.isLandscape
                    ? _LandscapeTimerLayout(
                        spec: spec,
                        header: _buildHeader(spec),
                        modeSelector: _buildModeSelector(spec),
                        linkedTask: _buildLinkedTask(),
                        dial: _buildDial(spec),
                        status: _buildStatus(spec),
                        primaryAction: _buildPrimaryAction(spec),
                        resetAction: _buildResetAction(spec),
                        compactReset: compactReset,
                      )
                    : spec.isTablet
                    ? _TabletTimerLayout(
                        spec: spec,
                        header: _buildHeader(spec),
                        modeSelector: _buildModeSelector(spec),
                        linkedTask: _buildLinkedTask(),
                        dial: _buildDial(spec),
                        status: _buildStatus(spec),
                        primaryAction: _buildPrimaryAction(spec),
                        resetAction: _buildResetAction(spec),
                        compactReset: compactReset,
                      )
                    : _PortraitTimerLayout(
                        spec: spec,
                        header: _buildHeader(spec),
                        modeSelector: _buildModeSelector(spec),
                        linkedTask: _buildLinkedTask(),
                        dial: _buildDial(spec),
                        status: _buildStatus(spec),
                        primaryAction: _buildPrimaryAction(spec),
                        resetAction: _buildResetAction(spec),
                        compactReset: compactReset,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(TimerLayoutSpec spec) {
    if (!showHeader) {
      return const SizedBox.shrink();
    }

    return _ControllerSelector(
      controller: controller,
      select: (controller) => (
        controller.progress.profileName,
        controller.progress.gems,
        controller.progress.totalFocusSeconds ~/ 60,
      ),
      builder: (context, _) {
        return RepaintBoundary(
          child: HeaderSection(controller: controller, spec: spec),
        );
      },
    );
  }

  Widget _buildModeSelector(TimerLayoutSpec spec) {
    return _ControllerSelector(
      controller: controller,
      select: (controller) => (controller.mode, controller.controlsLocked),
      builder: (context, _) {
        return RepaintBoundary(
          child: ModeSelector(controller: controller, height: spec.modeHeight),
        );
      },
    );
  }

  Widget _buildDial(TimerLayoutSpec spec) {
    return _ControllerSelector(
      controller: controller,
      select: (controller) => (
        controller.mode,
        controller.minutes,
        controller.remainingSeconds,
        controller.selectedSeconds,
        controller.isRunning,
        controller.sessionCompleted,
        controller.controlsLocked,
      ),
      builder: (context, _) {
        return RepaintBoundary(
          child: TimerDial(controller: controller, spec: spec),
        );
      },
    );
  }

  Widget _buildLinkedTask() {
    return _ControllerSelector<String?>(
      controller: controller,
      select: (controller) => controller.linkedTaskTitle,
      builder: (context, title) {
        if (title == null || title.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          key: const Key('linkedTaskSection'),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/tarea icon.png',
                key: const Key('linkedTaskAssetIcon'),
                width: 46,
                height: 46,
                fit: BoxFit.contain,
                semanticLabel: 'Tarea vinculada',
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TAREA ACTUAL',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatus(TimerLayoutSpec spec) {
    return _ControllerSelector(
      controller: controller,
      select: (controller) =>
          (controller.statusMessage, controller.statusIsError),
      builder: (context, _) {
        return _StatusCard(
          controller: controller,
          minHeight: spec.statusMinHeight,
        );
      },
    );
  }

  Widget _buildPrimaryAction(TimerLayoutSpec spec) {
    return _ControllerSelector(
      controller: controller,
      select: (controller) => (
        controller.isRunning,
        controller.remainingSeconds > 0 &&
            controller.remainingSeconds < controller.selectedSeconds,
      ),
      builder: (context, _) {
        return RepaintBoundary(
          child: PrimaryActionButton(
            controller: controller,
            height: spec.primaryButtonHeight,
            iconSize: spec.primaryIconSize,
            fontSize: spec.primaryFontSize,
          ),
        );
      },
    );
  }

  Widget _buildResetAction(TimerLayoutSpec spec) {
    if (compactReset) {
      final resetSize = math.max(48.0, spec.resetButtonHeight);
      return SizedBox(
        width: resetSize,
        height: resetSize,
        child: IconButton(
          key: const Key('resetTimerButton'),
          tooltip: 'Reiniciar temporizador',
          onPressed: controller.resetTimer,
          style: IconButton.styleFrom(
            foregroundColor: AppColors.muted,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.restart_alt_rounded),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: spec.resetButtonHeight,
      child: OutlinedButton(
        onPressed: controller.resetTimer,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.muted,
          side: const BorderSide(color: AppColors.border),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Reiniciar temporizador',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _PortraitTimerLayout extends StatelessWidget {
  const _PortraitTimerLayout({
    required this.spec,
    required this.header,
    required this.modeSelector,
    required this.linkedTask,
    required this.dial,
    required this.status,
    required this.primaryAction,
    required this.resetAction,
    required this.compactReset,
  });

  final TimerLayoutSpec spec;
  final Widget header;
  final Widget modeSelector;
  final Widget linkedTask;
  final Widget dial;
  final Widget status;
  final Widget primaryAction;
  final Widget resetAction;
  final bool compactReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header,
        SizedBox(height: spec.sectionGap),
        modeSelector,
        linkedTask,
        SizedBox(height: spec.sectionGap),
        Expanded(child: Center(child: dial)),
        SizedBox(height: spec.controlGap),
        status,
        SizedBox(height: spec.controlGap),
        if (compactReset)
          Row(
            children: [
              Expanded(child: primaryAction),
              SizedBox(width: spec.controlGap),
              resetAction,
            ],
          )
        else ...[
          primaryAction,
          SizedBox(height: spec.controlGap),
          resetAction,
        ],
      ],
    );
  }
}

class _TabletTimerLayout extends StatelessWidget {
  const _TabletTimerLayout({
    required this.spec,
    required this.header,
    required this.modeSelector,
    required this.linkedTask,
    required this.dial,
    required this.status,
    required this.primaryAction,
    required this.resetAction,
    required this.compactReset,
  });

  final TimerLayoutSpec spec;
  final Widget header;
  final Widget modeSelector;
  final Widget linkedTask;
  final Widget dial;
  final Widget status;
  final Widget primaryAction;
  final Widget resetAction;
  final bool compactReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header,
        SizedBox(height: spec.sectionGap),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  modeSelector,
                  linkedTask,
                  SizedBox(height: spec.sectionGap),
                  dial,
                  SizedBox(height: spec.controlGap),
                  status,
                  SizedBox(height: spec.controlGap),
                  if (compactReset)
                    Row(
                      children: [
                        Expanded(child: primaryAction),
                        SizedBox(width: spec.controlGap),
                        resetAction,
                      ],
                    )
                  else ...[
                    primaryAction,
                    SizedBox(height: spec.controlGap),
                    resetAction,
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LandscapeTimerLayout extends StatelessWidget {
  const _LandscapeTimerLayout({
    required this.spec,
    required this.header,
    required this.modeSelector,
    required this.linkedTask,
    required this.dial,
    required this.status,
    required this.primaryAction,
    required this.resetAction,
    required this.compactReset,
  });

  final TimerLayoutSpec spec;
  final Widget header;
  final Widget modeSelector;
  final Widget linkedTask;
  final Widget dial;
  final Widget status;
  final Widget primaryAction;
  final Widget resetAction;
  final bool compactReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header,
        SizedBox(height: spec.sectionGap),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: Center(child: dial)),
              SizedBox(width: spec.sectionGap),
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 360,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -30),
                            child: modeSelector,
                          ),
                          linkedTask,
                          SizedBox(height: spec.controlGap),
                          status,
                          SizedBox(height: spec.controlGap),
                          if (compactReset)
                            Row(
                              children: [
                                Expanded(child: primaryAction),
                                SizedBox(width: spec.controlGap),
                                resetAction,
                              ],
                            )
                          else ...[
                            primaryAction,
                            SizedBox(height: spec.controlGap),
                            resetAction,
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControllerSelector<T> extends StatefulWidget {
  const _ControllerSelector({
    required this.controller,
    required this.select,
    required this.builder,
  });

  final TimerController controller;
  final T Function(TimerController controller) select;
  final Widget Function(BuildContext context, T value) builder;

  @override
  State<_ControllerSelector<T>> createState() => _ControllerSelectorState<T>();
}

class _ControllerSelectorState<T> extends State<_ControllerSelector<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.select(widget.controller);
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant _ControllerSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
    }

    _value = widget.select(widget.controller);
  }

  void _handleControllerChanged() {
    final nextValue = widget.select(widget.controller);
    if (nextValue == _value) {
      return;
    }

    setState(() => _value = nextValue);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _value);
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.controller, required this.minHeight});

  final TimerController controller;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final background = controller.statusIsError
        ? const Color(0xFFF5DCE9)
        : AppColors.primarySoft;

    final foreground = controller.statusIsError
        ? AppColors.danger
        : AppColors.primaryDark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Center(
        child: Text(
          controller.statusMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: foreground,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
