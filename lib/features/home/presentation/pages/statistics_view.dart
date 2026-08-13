import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_formatter.dart';

class StatisticsView extends StatelessWidget {
  const StatisticsView({
    required this.totalFocusSeconds,
    required this.gems,
    required this.pendingTasks,
    required this.completedTasks,
    super.key,
  });

  final int totalFocusSeconds;
  final int gems;
  final int pendingTasks;
  final int completedTasks;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 680 ? 4 : 2;

        return CustomScrollView(
          key: const Key('statisticsView'),
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(18, 20, 18, 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu progreso',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Un resumen de tu actividad guardada en este dispositivo.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  mainAxisExtent: 138,
                ),
                delegate: SliverChildListDelegate.fixed([
                  _StatisticCard(
                    key: const Key('totalFocusStatistic'),
                    icon: Icons.schedule_rounded,
                    value: TimeFormatter.totalFocus(totalFocusSeconds),
                    label: 'Concentración total',
                  ),
                  _StatisticCard(
                    key: const Key('gemsStatistic'),
                    icon: Icons.diamond_rounded,
                    value: gems.toString(),
                    label: 'Gemas disponibles',
                  ),
                  _StatisticCard(
                    key: const Key('pendingTasksStatistic'),
                    icon: Icons.pending_actions_rounded,
                    value: pendingTasks.toString(),
                    label: 'Tareas pendientes',
                  ),
                  _StatisticCard(
                    key: const Key('completedTasksStatistic'),
                    icon: Icons.task_alt_rounded,
                    value: completedTasks.toString(),
                    label: 'Tareas completadas',
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.icon,
    required this.value,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14513382),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
