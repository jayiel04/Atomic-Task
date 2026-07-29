import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/timer_mode.dart';
import '../controllers/timer_controller.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({
    required this.controller,
    super.key,
  });

  final TimerController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeButton(
            icon: Icons.center_focus_strong_rounded,
            label: 'MODO\nCONCENTRACIÓN',
            selected: controller.mode == TimerMode.focus,
            onPressed: controller.controlsLocked
                ? null
                : () => controller.setMode(TimerMode.focus),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _ModeButton(
            icon: Icons.bed_rounded,
            label: 'MODO\nDESCANSO',
            selected: controller.mode == TimerMode.rest,
            onPressed: controller.controlsLocked
                ? null
                : () => controller.setMode(TimerMode.rest),
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppColors.primaryDark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 128,
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
              )
            : null,
        color: selected ? null : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.border,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x425F36B8),
                  blurRadius: 26,
                  offset: Offset(0, 14),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: foreground,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foreground,
                  height: 1.06,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
