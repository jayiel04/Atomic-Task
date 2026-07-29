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
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          drawer: ProgressDrawer(controller: controller),
          body: SafeArea(
            child: controller.isInitialized
                ? LayoutBuilder(
                    builder: (context, constraints) {
                      final horizontalPadding = constraints.maxWidth < 380
                          ? 16.0
                          : 24.0;

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
                                  HeaderSection(controller: controller),
                                  const SizedBox(height: 26),
                                  ModeSelector(controller: controller),
                                  const SizedBox(height: 26),
                                  TimerDial(controller: controller),
                                  const SizedBox(height: 18),
                                  _StatusCard(controller: controller),
                                  const SizedBox(height: 16),
                                  PrimaryActionButton(controller: controller),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      onPressed: controller.resetTimer,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.muted,
                                        side: const BorderSide(
                                          color: AppColors.border,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Reiniciar temporizador',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
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
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
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
