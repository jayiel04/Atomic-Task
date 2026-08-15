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
    required this.onFocusTimePressed,
    required this.onGemsPressed,
    super.key,
  });

  final String title;
  final String profileName;
  final int totalFocusSeconds;
  final int gems;
  final VoidCallback onMenuPressed;
  final VoidCallback onProfilePressed;
  final VoidCallback onFocusTimePressed;
  final VoidCallback onGemsPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final profile = _ProfileCard(
          profileName: profileName,
          onPressed: onProfilePressed,
        );
        final metrics = _ProgressMetrics(
          totalFocusSeconds: totalFocusSeconds,
          gems: gems,
          onFocusTimePressed: onFocusTimePressed,
          onGemsPressed: onGemsPressed,
        );
        return Container(
          key: Key(isCompact ? 'compactHomeHeader' : 'wideHomeHeader'),
          constraints: const BoxConstraints(minHeight: 104),
          padding: isCompact
              ? const EdgeInsets.fromLTRB(8, 4, 10, 5)
              : const EdgeInsets.fromLTRB(12, 6, 10, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                key: Key(
                  isCompact
                      ? 'compactHomeHeaderFirstRow'
                      : 'wideHomeHeaderFirstRow',
                ),
                children: [
                  _MenuButton(onPressed: onMenuPressed),
                  const SizedBox(width: 8),
                  Expanded(flex: 3, child: _HeaderTitle(title: title)),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 2,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 148),
                      child: profile,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                key: Key(
                  isCompact
                      ? 'compactHomeHeaderSummary'
                      : 'wideHomeHeaderSummary',
                ),
                alignment: Alignment.centerRight,
                child: SizedBox(width: 176, child: metrics),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Abrir menú de vistas',
      child: IconButton(
        key: const Key('homeMenuButton'),
        tooltip: 'Abrir menú',
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
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
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          key: const Key('homeTitle'),
          maxLines: 1,
          softWrap: false,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}

class _ProgressMetrics extends StatelessWidget {
  const _ProgressMetrics({
    required this.totalFocusSeconds,
    required this.gems,
    required this.onFocusTimePressed,
    required this.onGemsPressed,
  });

  final int totalFocusSeconds;
  final int gems;
  final VoidCallback onFocusTimePressed;
  final VoidCallback onGemsPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: _ProgressMetricChip(
              key: const Key('focusTimeStat'),
              icon: Icons.schedule_rounded,
              value: TimeFormatter.totalFocus(totalFocusSeconds),
              semanticLabel: 'Tiempo de concentración',
              tooltip: 'Ver detalle del tiempo de concentración',
              foregroundColor: AppColors.focusAccent,
              backgroundColor: AppColors.focusAccentSoft,
              borderColor: AppColors.focusAccentBorder,
              onPressed: onFocusTimePressed,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: _ProgressMetricChip(
              key: const Key('gemsStat'),
              icon: Icons.diamond_rounded,
              value: gems.toString(),
              semanticLabel: 'Gemas',
              tooltip: 'Ver detalle de las gemas',
              foregroundColor: AppColors.primaryDark,
              backgroundColor: AppColors.primarySoft,
              borderColor: AppColors.border,
              onPressed: onGemsPressed,
            ),
          ),
        ],
      ),
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
              constraints: const BoxConstraints(minHeight: 48),
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

class _ProgressMetricChip extends StatelessWidget {
  const _ProgressMetricChip({
    required this.icon,
    required this.value,
    required this.semanticLabel,
    required this.tooltip,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String value;
  final String semanticLabel;
  final String tooltip;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$semanticLabel: $value. Mostrar detalle',
      child: ExcludeSemantics(
        child: Tooltip(
          message: tooltip,
          child: Material(
            color: backgroundColor,
            shape: StadiumBorder(side: BorderSide(color: borderColor)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              customBorder: const StadiumBorder(),
              overlayColor: WidgetStatePropertyAll(
                foregroundColor.withValues(alpha: 0.12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: foregroundColor, size: 17),
                    const SizedBox(width: 5),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            color: foregroundColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
