import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/atomic_task.dart';
import '../controllers/task_controller.dart';
import 'focus_duration_sheet.dart';
import 'task_card.dart';
import 'task_form_sheet.dart';

class TaskSection extends StatelessWidget {
  const TaskSection({
    required this.title,
    required this.count,
    required this.tasks,
    required this.controller,
    this.onStartFocus,
    this.onFocusPrepared,
    this.showCreateAction = false,
    this.emptyMessage,
    this.collapsible = false,
    this.initiallyExpanded = false,
    this.icon,
    super.key,
  });

  final String title;
  final int count;
  final List<AtomicTask> tasks;
  final TaskController controller;
  final Future<bool> Function(AtomicTask task, int minutes)? onStartFocus;
  final VoidCallback? onFocusPrepared;
  final bool showCreateAction;
  final String? emptyMessage;
  final bool collapsible;
  final bool initiallyExpanded;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    if (collapsible) {
      return _buildCollapsible(context, now);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$title ($count)',
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (showCreateAction)
              IconButton(
                key: const Key('createTaskButton'),
                tooltip: 'Nueva tarea',
                onPressed: () =>
                    TaskFormSheet.show(context, controller: controller),
                icon: const Icon(Icons.add_task_rounded),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ..._buildTaskChildren(context, now),
      ],
    );
  }

  Widget _buildCollapsible(BuildContext context, DateTime now) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.95),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<String>('taskSection-$title'),
          initiallyExpanded: initiallyExpanded,
          maintainState: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          leading: icon == null
              ? null
              : Icon(icon, color: AppColors.primaryDark),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                key: Key('taskSectionCount-$title'),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          children: _buildTaskChildren(context, now),
        ),
      ),
    );
  }

  List<Widget> _buildTaskChildren(BuildContext context, DateTime now) {
    if (tasks.isEmpty) {
      return [
        Text(
          emptyMessage ?? '',
          style: const TextStyle(color: AppColors.muted),
        ),
      ];
    }
    return [
      for (final task in tasks)
        TaskCard(
          task: task,
          now: now,
          onToggle: () => _handleCompletion(context, task),
          onEdit: () => _handleEdit(context, task),
          onDelete: () => _confirmDelete(context, task),
          onToggleRecurrence: task.isRecurring
              ? () => controller.setRecurrenceActive(
                  task,
                  isActive: !task.recurrenceRule!.isActive,
                )
              : null,
        ),
    ];
  }

  Future<void> _handleCompletion(BuildContext context, AtomicTask task) async {
    if (task.isCompleted) {
      await controller.toggleCompletion(task);
      return;
    }

    final choice = await showDialog<_CompletionChoice>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('¿Cómo quieres continuar?'),
        children: [
          SimpleDialogOption(
            key: const Key('completeTaskNowOption'),
            onPressed: () =>
                Navigator.pop(dialogContext, _CompletionChoice.completeNow),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.task_alt_rounded),
              title: Text('Completar ahora'),
              subtitle: Text('Marcar la tarea como completada.'),
            ),
          ),
          SimpleDialogOption(
            key: const Key('associateTaskFocusOption'),
            onPressed: () =>
                Navigator.pop(dialogContext, _CompletionChoice.focusFirst),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.center_focus_strong_rounded),
              title: Text('Usar modo concentración'),
              subtitle: Text('Completar al finalizar el temporizador.'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancelar',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ),
        ],
      ),
    );

    if (!context.mounted || choice == null) {
      return;
    }

    if (choice == _CompletionChoice.completeNow) {
      await controller.toggleCompletion(task);
      return;
    }

    final startFocus = onStartFocus;
    if (startFocus == null) {
      return;
    }
    final minutes = await FocusDurationSheet.show(
      context,
      initialMinutes: task.focusMinutes ?? 25,
    );
    if (!context.mounted || minutes == null) {
      return;
    }

    final assigned = await controller.assignFocus(task, minutes);
    if (!context.mounted) {
      return;
    }
    if (!assigned) {
      _showMessage(context, 'No fue posible asociar la tarea.');
      return;
    }

    final started = await startFocus(task, minutes);
    if (!context.mounted) {
      return;
    }
    if (!started) {
      _showMessage(
        context,
        'El tiempo quedó guardado. Reinicia la sesión actual para usarlo.',
      );
      return;
    }

    if (onFocusPrepared != null) {
      onFocusPrepared!.call();
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleEdit(BuildContext context, AtomicTask task) async {
    if (!task.isRecurring) {
      await TaskFormSheet.show(context, controller: controller, task: task);
      return;
    }

    final scope = await showDialog<TaskEditScope>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Editar tarea recurrente'),
        children: [
          SimpleDialogOption(
            key: const Key('editOccurrenceOption'),
            onPressed: () =>
                Navigator.pop(dialogContext, TaskEditScope.occurrence),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.event_note_rounded),
              title: Text('Solo esta ocurrencia'),
            ),
          ),
          SimpleDialogOption(
            key: const Key('editSeriesOption'),
            onPressed: () => Navigator.pop(dialogContext, TaskEditScope.series),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.repeat_rounded),
              title: Text('Toda la serie'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancelar',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
    if (!context.mounted || scope == null) {
      return;
    }
    await TaskFormSheet.show(
      context,
      controller: controller,
      task: task,
      editScope: scope,
    );
  }

  Future<void> _confirmDelete(BuildContext context, AtomicTask task) async {
    var deleteSeries = false;
    if (task.isRecurring) {
      final scope = await showDialog<_DeleteScope>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          title: const Text('Eliminar tarea recurrente'),
          children: [
            SimpleDialogOption(
              key: const Key('deleteOccurrenceOption'),
              onPressed: () =>
                  Navigator.pop(dialogContext, _DeleteScope.occurrence),
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.event_busy_rounded),
                title: Text('Solo esta ocurrencia'),
              ),
            ),
            SimpleDialogOption(
              key: const Key('deleteSeriesOption'),
              onPressed: () =>
                  Navigator.pop(dialogContext, _DeleteScope.series),
              child: const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.delete_sweep_rounded),
                title: Text('Toda la serie'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancelar',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          ],
        ),
      );
      if (!context.mounted || scope == null) {
        return;
      }
      deleteSeries = scope == _DeleteScope.series;
    }

    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(deleteSeries ? 'Eliminar serie' : 'Eliminar tarea'),
        content: Text(
          deleteSeries
              ? '¿Quieres eliminar todas las ocurrencias de “${task.title}”?'
              : '¿Quieres eliminar “${task.title}”?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('confirmDeleteTaskButton'),
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (accepted == true) {
      if (deleteSeries) {
        await controller.deleteSeries(task);
      } else {
        await controller.delete(task);
      }
    }
  }
}

enum _CompletionChoice { completeNow, focusFirst }

enum _DeleteScope { occurrence, series }

class TaskControllerErrorCard extends StatelessWidget {
  const TaskControllerErrorCard({
    required this.message,
    required this.onDismiss,
    super.key,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5DCE9),
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        leading: const Icon(
          Icons.error_outline_rounded,
          color: AppColors.danger,
        ),
        title: Text(
          message,
          style: const TextStyle(
            color: AppColors.danger,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: IconButton(
          tooltip: 'Cerrar mensaje',
          onPressed: onDismiss,
          icon: const Icon(Icons.close_rounded),
        ),
      ),
    );
  }
}
