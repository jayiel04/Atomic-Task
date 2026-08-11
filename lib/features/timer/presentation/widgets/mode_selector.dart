import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/timer_mode.dart';
import '../controllers/timer_controller.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({required this.controller, this.height = 56, super.key});

  final TimerController controller;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isFocus = controller.mode == TimerMode.focus;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useShortLabels = constraints.maxWidth < 420;

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: _ModeTab(
                    icon: Icons.center_focus_strong_rounded,
                    label: useShortLabels ? 'Enfoque' : 'Concentración',
                    selected: isFocus,
                    onPressed: controller.controlsLocked
                        ? null
                        : () => controller.setMode(TimerMode.focus),
                  ),
                ),
                Expanded(
                  child: _ModeTab(
                    icon: Icons.coffee_rounded,
                    label: 'Descanso',
                    selected: !isFocus,
                    onPressed: controller.controlsLocked
                        ? null
                        : () => controller.setMode(TimerMode.rest),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: selected ? Colors.white : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
