import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class FocusCompletionSummarySheet extends StatelessWidget {
  const FocusCompletionSummarySheet({
    required this.gemsGenerated,
    required this.completedSeconds,
    required this.onClose,
    this.completedTaskTitle,
    this.awaySecondsAfterCompletion,
    super.key,
  });

  final int gemsGenerated;
  final int completedSeconds;
  final String? completedTaskTitle;
  final int? awaySecondsAfterCompletion;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final taskTitle = completedTaskTitle?.trim();
    final awaySeconds = awaySecondsAfterCompletion;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          key: const Key('focusCompletionSummarySheet'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Resumen de la sesión',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            _SummaryItem(
              key: const Key('completionSummaryGems'),
              icon: Icons.diamond_rounded,
              label: 'Gemas generadas',
              value: '+$gemsGenerated',
              accent: AppColors.primaryDark,
              surface: AppColors.primarySoft,
            ),
            const SizedBox(height: 10),
            _SummaryItem(
              key: const Key('completionSummaryDuration'),
              icon: Icons.schedule_rounded,
              label: 'Concentración',
              value: _formatDuration(completedSeconds),
              accent: AppColors.focusAccent,
              surface: AppColors.focusAccentSoft,
            ),
            if (taskTitle != null && taskTitle.isNotEmpty) ...[
              const SizedBox(height: 10),
              _SummaryItem(
                key: const Key('completionSummaryTask'),
                icon: Icons.task_alt_rounded,
                label: 'Tarea finalizada',
                value: taskTitle,
                accent: AppColors.primaryDark,
                surface: AppColors.surfaceVariant,
              ),
            ],
            if (awaySeconds != null && awaySeconds > 0) ...[
              const SizedBox(height: 10),
              _SummaryItem(
                key: const Key('completionSummaryAwayTime'),
                icon: Icons.exit_to_app_rounded,
                label: 'Tiempo fuera',
                value: _formatDuration(awaySeconds),
                accent: AppColors.text,
                surface: AppColors.surfaceVariant,
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              key: const Key('closeFocusCompletionSummaryButton'),
              onPressed: onClose,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
    final hours = safeSeconds ~/ 3600;
    final minutes = (safeSeconds % 3600) ~/ 60;
    final seconds = safeSeconds % 60;
    final parts = <String>[];
    if (hours > 0) {
      parts.add('$hours h');
    }
    if (minutes > 0) {
      parts.add('$minutes min');
    }
    if (seconds > 0 || parts.isEmpty) {
      parts.add('$seconds s');
    }
    return parts.join(' ');
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.surface,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.24)),
          ),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(color: accent, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
