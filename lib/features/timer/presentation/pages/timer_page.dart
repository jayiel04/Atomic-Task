import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/timer_controller.dart';
import '../widgets/header_section.dart';
import '../widgets/mode_selector.dart';
import '../widgets/primary_action_button.dart';
import '../widgets/progress_drawer.dart';
import '../widgets/timer_dial.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({required this.controller, super.key});

  final TimerController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ProgressDrawer(controller: controller),
      body: SafeArea(
        child: _ControllerSelector<bool>(
          controller: controller,
          select: (controller) => controller.isInitialized,
          builder: (context, isInitialized) {
            return isInitialized
                ? _TimerContent(controller: controller)
                : const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _TimerContent extends StatelessWidget {
  const _TimerContent({required this.controller});

  final TimerController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 24.0;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            18,
            horizontalPadding,
            28,
          ),
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 520,
                child: Column(
                  children: [
                    _ControllerSelector(
                      controller: controller,
                      select: (controller) => (
                        controller.progress.profileName,
                        controller.progress.gems,
                        controller.progress.totalFocusSeconds ~/ 60,
                      ),
                      builder: (context, _) {
                        return RepaintBoundary(
                          child: HeaderSection(controller: controller),
                        );
                      },
                    ),
                    const SizedBox(height: 26),
                    _ControllerSelector(
                      controller: controller,
                      select: (controller) =>
                          (controller.mode, controller.controlsLocked),
                      builder: (context, _) {
                        return RepaintBoundary(
                          child: ModeSelector(controller: controller),
                        );
                      },
                    ),
                    const SizedBox(height: 26),
                    _ControllerSelector(
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
                          child: TimerDial(controller: controller),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    _ControllerSelector(
                      controller: controller,
                      select: (controller) =>
                          (controller.statusMessage, controller.statusIsError),
                      builder: (context, _) {
                        return _StatusCard(controller: controller);
                      },
                    ),
                    const SizedBox(height: 16),
                    _ControllerSelector(
                      controller: controller,
                      select: (controller) => (
                        controller.isRunning,
                        controller.remainingSeconds > 0 &&
                            controller.remainingSeconds <
                                controller.selectedSeconds,
                      ),
                      builder: (context, _) {
                        return RepaintBoundary(
                          child: PrimaryActionButton(controller: controller),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: controller.resetTimer,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.muted,
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Reiniciar temporizador',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
  const _StatusCard({required this.controller});

  final TimerController controller;

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
      constraints: const BoxConstraints(minHeight: 52),
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
