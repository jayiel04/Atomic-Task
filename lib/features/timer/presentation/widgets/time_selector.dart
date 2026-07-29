import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TimeSelector extends StatelessWidget {
  const TimeSelector({
    required this.label,
    required this.value,
    required this.onIncrease,
    required this.onDecrease,
    required this.enabled,
    super.key,
  });

  final String label;
  final int value;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.88),
            border: Border.all(
              color: AppColors.border,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _ArrowButton(
                icon: Icons.keyboard_arrow_up_rounded,
                onPressed: enabled ? onIncrease : null,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    value.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              _ArrowButton(
                icon: Icons.keyboard_arrow_down_rounded,
                onPressed: enabled ? onDecrease : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      width: double.infinity,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 20,
        icon: Icon(
          icon,
          color: onPressed == null
              ? AppColors.muted.withOpacity(0.35)
              : AppColors.primary,
          size: 28,
        ),
      ),
    );
  }
}
