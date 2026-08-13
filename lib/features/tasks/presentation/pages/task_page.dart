import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/atomic_task.dart';
import '../controllers/task_controller.dart';
import '../widgets/focus_duration_sheet.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_sheet.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({
    required this.controller,
    required this.onStartFocus,
    super.key,
  });

  final TaskController controller;
  final Future<bool> Function(AtomicTask task, int minutes) onStartFocus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Tareas'),
        backgroundColor: AppColors.surface.withValues(alpha: 0.94),
        foregroundColor: AppColors.text,
        elevation: 0,
        actions: [
          IconButton(
            key: const Key('createTaskButton'),
            tooltip: 'Nueva tarea',
            onPressed: () =>
                TaskFormSheet.show(context, controller: controller),
            icon: const Icon(Icons.add_task_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          top: false,
          child: TasksView(controller: controller, onStartFocus: onStartFocus),
        ),
      ),
    );
  }
}

class TasksView extends StatelessWidget {
  const TasksView({
    required this.controller,
    required this.onStartFocus,
    this.onFocusPrepared,
    this.showCreateAction = false,
    super.key,
  });

  final TaskController controller;
  final Future<bool> Function(AtomicTask task, int minutes) onStartFocus;
  final VoidCallback? onFocusPrepared;
  final bool showCreateAction;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final pending = controller.pendingTasks;
    final completed = controller.completedTasks;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          key: const Key('taskList'),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
          children: [
            _SummaryCard(
              pendingCount: pending.length,
              completedCount: completed.length,
            ),
            if (controller.errorMessage != null) ...[
              const SizedBox(height: 14),
              _ErrorCard(
                message: controller.errorMessage!,
                onDismiss: controller.clearError,
              ),
            ],
            const SizedBox(height: 24),
            if (pending.isEmpty && completed.isEmpty) ...[
              const _EmptyTasks(),
              if (showCreateAction) ...[
                const SizedBox(height: 16),
                _CreateTaskButton(controller: controller),
              ],
            ] else ...[
              _TaskSection(
                title: 'Pendientes',
                count: pending.length,
                emptyMessage: 'No tienes tareas pendientes.',
                tasks: pending,
                controller: controller,
                onStartFocus: onStartFocus,
                onFocusPrepared: onFocusPrepared,
                showCreateAction: showCreateAction,
              ),
              if (completed.isNotEmpty) ...[
                const SizedBox(height: 22),
                _TaskSection(
                  title: 'Completadas',
                  count: completed.length,
                  tasks: completed,
                  controller: controller,
                  onStartFocus: onStartFocus,
                  onFocusPrepared: onFocusPrepared,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.pendingCount,
    required this.completedCount,
  });

  final int pendingCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 27,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.checklist_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Organiza tu día',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$pendingCount pendientes · $completedCount completadas',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskSection extends StatelessWidget {
  const _TaskSection({
    required this.title,
    required this.count,
    required this.tasks,
    required this.controller,
    required this.onStartFocus,
    this.onFocusPrepared,
    this.showCreateAction = false,
    this.emptyMessage,
  });

  final String title;
  final int count;
  final List<AtomicTask> tasks;
  final TaskController controller;
  final Future<bool> Function(AtomicTask task, int minutes) onStartFocus;
  final VoidCallback? onFocusPrepared;
  final bool showCreateAction;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
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
        if (tasks.isEmpty)
          Text(
            emptyMessage ?? '',
            style: const TextStyle(color: AppColors.muted),
          )
        else
          for (final task in tasks)
            TaskCard(
              task: task,
              now: DateTime.now(),
              onToggle: () => _handleCompletion(context, task),
              onEdit: () => TaskFormSheet.show(
                context,
                controller: controller,
                task: task,
              ),
              onDelete: () => _confirmDelete(context, task),
            ),
      ],
    );
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

    final started = await onStartFocus(task, minutes);
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

  Future<void> _confirmDelete(BuildContext context, AtomicTask task) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Quieres eliminar “${task.title}”?'),
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
      await controller.delete(task);
    }
  }
}

enum _CompletionChoice { completeNow, focusFirst }

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 42),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.task_alt_rounded, color: AppColors.primary, size: 52),
          SizedBox(height: 14),
          Text(
            'Todavía no hay tareas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Crea una tarea y empieza con un paso pequeño.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _CreateTaskButton extends StatelessWidget {
  const _CreateTaskButton({required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: OutlinedButton.icon(
        key: const Key('createTaskButton'),
        onPressed: () => TaskFormSheet.show(context, controller: controller),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Nueva tarea'),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onDismiss});

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
