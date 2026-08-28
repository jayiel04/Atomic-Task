import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/atomic_task.dart';
import '../controllers/task_controller.dart';
import '../task_date_group.dart';
import '../widgets/task_form_sheet.dart';
import '../widgets/task_section.dart';

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
      floatingActionButton: TaskCreateFab(controller: controller),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class TasksView extends StatelessWidget {
  const TasksView({
    required this.controller,
    required this.onStartFocus,
    this.onFocusPrepared,
    super.key,
  });

  final TaskController controller;
  final Future<bool> Function(AtomicTask task, int minutes) onStartFocus;
  final VoidCallback? onFocusPrepared;

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
    final pendingGroups = groupPendingTasksByDate(pending, DateTime.now());

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          key: const Key('taskList'),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 112),
          children: [
            _SummaryCard(
              pendingCount: pending.length,
              completedTodayCount: controller.completedTodayCount,
            ),
            if (controller.errorMessage != null) ...[
              const SizedBox(height: 14),
              TaskControllerErrorCard(
                message: controller.errorMessage!,
                onDismiss: controller.clearError,
              ),
            ],
            const SizedBox(height: 24),
            if (pending.isEmpty) ...[
              const _EmptyTasks(),
            ] else ...[
              _PendingTasksHeader(count: pending.length),
              const SizedBox(height: 12),
              for (final group in TaskDateGroup.values)
                if (pendingGroups[group]!.isNotEmpty) ...[
                  TaskSection(
                    key: PageStorageKey<String>('pending-${group.name}'),
                    title: group.label,
                    count: pendingGroups[group]!.length,
                    tasks: pendingGroups[group]!,
                    controller: controller,
                    onStartFocus: onStartFocus,
                    onFocusPrepared: onFocusPrepared,
                    collapsible: true,
                    initiallyExpanded: group == TaskDateGroup.today,
                    icon: _groupIcon(group),
                  ),
                  const SizedBox(height: 10),
                ],
            ],
          ],
        ),
      ),
    );
  }
}

class _PendingTasksHeader extends StatelessWidget {
  const _PendingTasksHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Pendientes ($count)',
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

IconData _groupIcon(TaskDateGroup group) => switch (group) {
  TaskDateGroup.overdue => Icons.warning_amber_rounded,
  TaskDateGroup.noDate => Icons.event_busy_rounded,
  TaskDateGroup.today => Icons.today_rounded,
  TaskDateGroup.tomorrow => Icons.event_available_rounded,
  TaskDateGroup.future => Icons.date_range_rounded,
};

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.pendingCount,
    required this.completedTodayCount,
  });

  final int pendingCount;
  final int completedTodayCount;

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
                  '${_taskLabel(pendingCount, 'pendiente', 'pendientes')} · '
                  '${_taskLabel(completedTodayCount, 'completada hoy', 'completadas hoy')}',
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

  static String _taskLabel(int count, String singular, String plural) {
    return '$count ${count == 1 ? singular : plural}';
  }
}

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
            'No tienes tareas pendientes',
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

class TaskCreateFab extends StatelessWidget {
  const TaskCreateFab({required this.controller, super.key});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: const Key('createTaskButton'),
      tooltip: 'Nueva tarea',
      onPressed: () => TaskFormSheet.show(context, controller: controller),
      child: const Icon(Icons.add_rounded),
    );
  }
}
