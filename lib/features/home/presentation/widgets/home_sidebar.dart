import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../home_destination.dart';

class HomeSidebar extends StatelessWidget {
  const HomeSidebar({
    required this.selectedDestination,
    required this.onDestinationSelected,
    required this.onResetProgress,
    super.key,
  });

  final HomeDestination selectedDestination;
  final ValueChanged<HomeDestination> onDestinationSelected;
  final VoidCallback onResetProgress;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      key: const Key('homeSidebar'),
      width: math.min(280, MediaQuery.sizeOf(context).width * 0.84),
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(26)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Row(
                      children: [
                        Container(
                          key: const Key('sidebarLogo'),
                          width: 44,
                          height: 44,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Image.asset(
                            'assets/images/logo_icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 11),
                        const Expanded(
                          child: Text(
                            'Atomic Task',
                            key: Key('sidebarTitle'),
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          key: const Key('closeSidebarButton'),
                          tooltip: 'Cerrar menú',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 18, bottom: 8, left: 12),
                      child: Text(
                        'NAVEGACIÓN',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    _SidebarDestination(
                      key: const Key('sidebarTasksDestination'),
                      destination: HomeDestination.tasks,
                      icon: Icons.checklist_rounded,
                      selected: selectedDestination == HomeDestination.tasks,
                      onPressed: () => _select(context, HomeDestination.tasks),
                    ),
                    _SidebarDestination(
                      key: const Key('sidebarFocusDestination'),
                      destination: HomeDestination.focus,
                      icon: Icons.center_focus_strong_rounded,
                      selected: selectedDestination == HomeDestination.focus,
                      onPressed: () => _select(context, HomeDestination.focus),
                    ),
                    _SidebarDestination(
                      key: const Key('sidebarSettingsDestination'),
                      destination: HomeDestination.settings,
                      icon: Icons.settings_rounded,
                      selected: selectedDestination == HomeDestination.settings,
                      onPressed: () =>
                          _select(context, HomeDestination.settings),
                    ),
                    _SidebarDestination(
                      key: const Key('sidebarStatisticsDestination'),
                      destination: HomeDestination.statistics,
                      icon: Icons.bar_chart_rounded,
                      selected:
                          selectedDestination == HomeDestination.statistics,
                      onPressed: () =>
                          _select(context, HomeDestination.statistics),
                    ),
                    const SizedBox(height: 6),
                    _SidebarLink(
                      key: const Key('sidebarReportIssueButton'),
                      label: 'Reportar errores o sugerencias',
                      icon: Icons.bug_report_rounded,
                      url: Uri.parse(
                        'https://docs.google.com/forms/d/e/1FAIpQLSdkwL6woIBLYTGpjQ16jQB8cENYjOajiu4kcGsjwCYACuGOSw/viewform',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('resetProgressSidebarButton'),
                onPressed: onResetProgress,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  backgroundColor: const Color(0xFFFFF3FA),
                  side: const BorderSide(color: Color(0x33B14C82)),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text(
                  'Restablecer progreso',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _select(BuildContext context, HomeDestination destination) {
    Navigator.of(context).pop();
    onDestinationSelected(destination);
  }
}

class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.destination,
    required this.icon,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final HomeDestination destination;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: ListTile(
          selected: selected,
          selectedColor: AppColors.primaryDark,
          selectedTileColor: AppColors.primarySoft,
          textColor: AppColors.muted,
          iconColor: AppColors.muted,
          leading: Icon(icon),
          title: Text(
            destination.title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onTap: onPressed,
        ),
      ),
    );
  }
}

class _SidebarLink extends StatelessWidget {
  const _SidebarLink({
    required this.label,
    required this.icon,
    required this.url,
    super.key,
  });

  final String label;
  final IconData icon;
  final Uri url;

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _showFallback(messenger);
      }
    } catch (_) {
      _showFallback(messenger);
    }
  }

  void _showFallback(ScaffoldMessengerState messenger) {
    messenger.showSnackBar(
      SnackBar(
        content: const Text(
          'No se pudo abrir el navegador. Abre este enlace:',
        ),
        action: SnackBarAction(
          label: 'Copiar',
          onPressed: () => Clipboard.setData(ClipboardData(text: '$url')),
        ),
        duration: const Duration(seconds: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      link: true,
      child: ListTile(
        textColor: AppColors.info,
        iconColor: AppColors.info,
        tileColor: AppColors.infoSoft,
        leading: Icon(icon),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        trailing: const Icon(Icons.open_in_new_rounded, size: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.infoBorder),
        ),
        onTap: () => _open(context),
      ),
    );
  }
}
