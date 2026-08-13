import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_progress.dart';
import '../controllers/timer_controller.dart';

class ProgressDrawer extends StatefulWidget {
  const ProgressDrawer({required this.controller, this.onOpenTasks, super.key});

  final TimerController controller;
  final VoidCallback? onOpenTasks;

  @override
  State<ProgressDrawer> createState() => _ProgressDrawerState();
}

class _ProgressDrawerState extends State<ProgressDrawer> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.controller.progress.profileName,
    );
    widget.controller.addListener(_syncName);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncName);
    _nameController.dispose();
    super.dispose();
  }

  void _syncName() {
    final name = widget.controller.progress.profileName;
    if (_nameController.text != name) {
      _nameController.text = name;
    }
    if (mounted) {
      setState(() {});
    }
  }

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
              const SizedBox(height: 18),
              TextField(
                key: const Key('profileNameField'),
                controller: _nameController,
                maxLength: UserProgress.maxProfileNameLength,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Escribe tu nombre',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                onSubmitted: widget.controller.updateProfileName,
              ),
              const SizedBox(height: 4),
              if (widget.onOpenTasks != null)
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
                    widget.onOpenTasks!();
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

    await widget.controller.resetProgress();

    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
