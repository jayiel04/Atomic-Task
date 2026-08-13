import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../home_destination.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    required this.selectedDestination,
    required this.onSelected,
    super.key,
  });

  final HomeDestination selectedDestination;
  final ValueChanged<HomeDestination> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        key: const Key('homeBottomNavigation'),
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Color(0x25513382),
              blurRadius: 18,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _HomeDestination(
                key: const Key('tasksTab'),
                icon: Icons.checklist_rounded,
                label: 'Tareas',
                selected: selectedDestination == HomeDestination.tasks,
                onPressed: () => onSelected(HomeDestination.tasks),
              ),
            ),
            Expanded(
              child: _HomeDestination(
                key: const Key('focusTab'),
                icon: Icons.center_focus_strong_rounded,
                label: 'Concentración',
                selected: selectedDestination == HomeDestination.focus,
                onPressed: () => onSelected(HomeDestination.focus),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeDestination extends StatelessWidget {
  const _HomeDestination({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected ? AppColors.primary : AppColors.muted,
                  size: 22,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? AppColors.primary : AppColors.muted,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 3,
                  width: selected ? 42 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(3),
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
