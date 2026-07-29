import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/timer_controller.dart';

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    required this.controller,
    super.key,
  });

  final TimerController controller;

  @override
  Widget build(BuildContext context) {
    final label = controller.isRunning
        ? 'PAUSAR'
        : controller.remainingSeconds > 0 &&
                controller.remainingSeconds < controller.selectedSeconds
            ? 'CONTINUAR'
            : 'INICIAR';

    final icon =
        controller.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded;

    return SizedBox(
      width: double.infinity,
      height: 82,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Color(0x475F36B8),
              blurRadius: 24,
              offset: Offset(0, 13),
            ),
          ],
        ),
        child: FilledButton.icon(
          onPressed: controller.startOrPause,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          icon: Icon(
            icon,
            size: 35,
          ),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}
