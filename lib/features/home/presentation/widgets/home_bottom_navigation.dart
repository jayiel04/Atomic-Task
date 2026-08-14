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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/textura.png'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              key: const Key('homeBottomNavigationSurface'),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x25513382),
                    blurRadius: 18,
                    offset: Offset(0, 6),
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
                  const SizedBox(width: 6),
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
          ),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: selected ? AppColors.primary : AppColors.muted,
                  size: 22,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      color: selected ? AppColors.primary : AppColors.muted,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
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
