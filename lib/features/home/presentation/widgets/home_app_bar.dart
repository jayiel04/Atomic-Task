import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_formatter.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    required this.title,
    required this.profileName,
    required this.totalFocusSeconds,
    required this.gems,
    required this.onMenuPressed,
    required this.onProfilePressed,
    super.key,
  });

  final String title;
  final String profileName;
  final int totalFocusSeconds;
  final int gems;
  final VoidCallback onMenuPressed;
  final VoidCallback onProfilePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        final profileWidth = isNarrow ? 164.0 : 196.0;

        return Container(
          constraints: const BoxConstraints(minHeight: 82),
          padding: EdgeInsets.fromLTRB(isNarrow ? 8 : 12, 6, 10, 6),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: 'Abrir menú de vistas',
                child: IconButton(
                  key: const Key('homeMenuButton'),
                  tooltip: 'Abrir menú',
                  onPressed: onMenuPressed,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surface.withValues(alpha: 0.94),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.menu_rounded, size: 22),
                ),
              ),
              SizedBox(width: isNarrow ? 4 : 8),
              Expanded(
                child: Text(
                  title,
                  key: const Key('homeTitle'),
                  maxLines: isNarrow ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: isNarrow ? 16 : 20,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
              ),
              SizedBox(width: isNarrow ? 4 : 8),
              SizedBox(
                width: profileWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ProfileCard(
                      profileName: profileName,
                      onPressed: onProfilePressed,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _HomeStat(
                          key: const Key('focusTimeStat'),
                          icon: Icons.schedule_rounded,
                          value: TimeFormatter.totalFocus(totalFocusSeconds),
                          semanticLabel: 'Tiempo de concentración',
                          maxValueWidth: 60,
                        ),
                        const SizedBox(width: 7),
                        _HomeStat(
                          key: const Key('gemsStat'),
                          icon: Icons.diamond_rounded,
                          value: gems.toString(),
                          semanticLabel: 'Gemas',
                          maxValueWidth: 38,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profileName, required this.onPressed});

  final String profileName;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Abrir ajustes del perfil',
      child: Material(
        color: AppColors.surface.withValues(alpha: 0.94),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        elevation: 2,
        shadowColor: const Color(0x24513382),
        child: Tooltip(
          message: 'Abrir ajustes',
          child: InkWell(
            key: const Key('profileButton'),
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              key: const Key('profileCard'),
              constraints: const BoxConstraints(minHeight: 43),
              padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      profileName,
                      key: const Key('profileName'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
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

class _HomeStat extends StatelessWidget {
  const _HomeStat({
    required this.icon,
    required this.value,
    required this.semanticLabel,
    required this.maxValueWidth,
    super.key,
  });

  final IconData icon;
  final String value;
  final String semanticLabel;
  final double maxValueWidth;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$semanticLabel: $value',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 15),
          const SizedBox(width: 4),
          Container(
            constraints: BoxConstraints(
              minWidth: 28,
              maxWidth: maxValueWidth,
              minHeight: 19,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primarySoft.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(7),
              border: const Border.fromBorderSide(
                BorderSide(color: AppColors.border),
              ),
            ),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
