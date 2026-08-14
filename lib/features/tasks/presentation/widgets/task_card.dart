import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/atomic_task.dart';
import '../task_date_formatter.dart';
import '../task_recurrence_formatter.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.now,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.onToggleRecurrence,
    super.key,
  });

  final AtomicTask task;
  final DateTime now;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onToggleRecurrence;

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdueAt(now);
    final deadline = task.dueDate;
    final metadata = task.isCompleted
        ? deadline == null
              ? 'Completada · Sin fecha límite'
              : 'Completada · ${TaskDateFormatter.format(deadline)}'
        : isOverdue
        ? 'Vencida · ${TaskDateFormatter.format(deadline!)}'
        : deadline == null
        ? 'Sin fecha límite'
        : 'Vence el ${TaskDateFormatter.format(deadline)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(8, 10, 6, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOverdue ? AppColors.danger : AppColors.border,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16513382),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            key: Key('taskToggle-${task.id}'),
            value: task.isCompleted,
            onChanged: (_) => onToggle(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: task.isCompleted ? AppColors.muted : AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isOverdue
                          ? Icons.warning_amber_rounded
                          : task.isCompleted
                          ? Icons.task_alt_rounded
                          : Icons.event_rounded,
                      size: 16,
                      color: isOverdue ? AppColors.danger : AppColors.muted,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        metadata,
                        style: TextStyle(
                          color: isOverdue ? AppColors.danger : AppColors.muted,
                          fontSize: 12,
                          fontWeight: isOverdue
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (task.focusMinutes != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.center_focus_strong_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${task.focusMinutes} min de concentración',
                          key: Key('taskFocusMinutes-${task.id}'),
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (task.recurrenceRule case final rule?) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        rule.isActive
                            ? Icons.repeat_rounded
                            : Icons.pause_circle_outline_rounded,
                        size: 16,
                        color: rule.isActive
                            ? AppColors.primary
                            : AppColors.muted,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${TaskRecurrenceFormatter.frequency(rule)} · '
                          '${rule.isActive ? 'Activa' : 'Pausada'}',
                          key: Key('taskRecurrence-${task.id}'),
                          style: TextStyle(
                            color: rule.isActive
                                ? AppColors.primaryDark
                                : AppColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (task.occurrenceDate case final occurrenceDate?)
                    Padding(
                      padding: const EdgeInsets.only(left: 21, top: 2),
                      child: Text(
                        TaskRecurrenceFormatter.occurrence(
                          occurrenceDate,
                          completed: task.isCompleted,
                        ),
                        key: Key('taskOccurrenceDate-${task.id}'),
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          if (task.isRecurring)
            IconButton(
              key: Key('toggleTaskRecurrence-${task.id}'),
              tooltip: task.recurrenceRule!.isActive
                  ? 'Pausar serie'
                  : 'Reactivar serie',
              onPressed: onToggleRecurrence,
              icon: Icon(
                task.recurrenceRule!.isActive
                    ? Icons.pause_circle_outline_rounded
                    : Icons.play_circle_outline_rounded,
              ),
            ),
          IconButton(
            key: Key('editTask-${task.id}'),
            tooltip: 'Editar tarea',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            key: Key('deleteTask-${task.id}'),
            tooltip: 'Eliminar tarea',
            color: AppColors.danger,
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}
