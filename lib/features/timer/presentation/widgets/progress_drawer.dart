import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/timer_controller.dart';

class ProgressDrawer extends StatelessWidget {
  const ProgressDrawer({
    required this.controller,
    required this.onOpenTasks,
    super.key,
  });

  final TimerController controller;
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 88,
                height: 88,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2B513382),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo_launcher.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mi progreso',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tus gemas, minutos de concentración y nombre se guardan '
                'automáticamente en este dispositivo.',
                style: TextStyle(color: AppColors.muted, height: 1.5),
              ),
              const SizedBox(height: 24),
              ListTile(
                key: const Key('openTasksMenuItem'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: const Icon(
                  Icons.checklist_rounded,
                  color: AppColors.primary,
                ),
                title: const Text(
                  'Tareas',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                tileColor: AppColors.surfaceVariant,
                onTap: () {
                  Navigator.pop(context);
                  onOpenTasks();
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmReset(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text(
                    'Restablecer progreso',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Restablecer progreso'),
          content: const Text(
            'Se borrarán las gemas, el tiempo acumulado y el nombre guardado.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Restablecer'),
            ),
          ],
        );
      },
    );

    if (accepted != true || !context.mounted) {
      return;
    }

    await controller.resetProgress();

    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
