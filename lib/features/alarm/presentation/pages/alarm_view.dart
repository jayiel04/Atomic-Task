import 'package:flutter/material.dart';

import '../../../../core/audio/alarm_sound.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/alarm_controller.dart';

class AlarmView extends StatelessWidget {
  const AlarmView({required this.controller, super.key});

  final AlarmController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.isInitialized) {
          return const Center(
            key: Key('alarmLoading'),
            child: CircularProgressIndicator(),
          );
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              key: const Key('alarmView'),
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
              children: [
                _AlarmHeader(selectedSound: controller.selectedSound),
                const SizedBox(height: 16),
                if (controller.errorMessage != null)
                  _AlarmError(
                    message: controller.errorMessage!,
                    onDismiss: controller.clearError,
                  ),
                if (controller.errorMessage != null) const SizedBox(height: 12),
                _AlarmOptions(controller: controller),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AlarmHeader extends StatelessWidget {
  const _AlarmHeader({required this.selectedSound});

  final AlarmSound selectedSound;

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
            child: Icon(Icons.alarm_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personaliza tu alarma',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seleccionada: ${selectedSound.label}',
                  key: const Key('selectedAlarmLabel'),
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

class _AlarmOptions extends StatelessWidget {
  const _AlarmOptions({required this.controller});

  final AlarmController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16513382),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: RadioGroup<AlarmSound>(
        groupValue: controller.selectedSound,
        onChanged: (value) {
          if (!controller.isSaving && value != null) {
            controller.selectSound(value);
          }
        },
        child: Column(
          children: [
            for (var index = 0; index < AlarmSound.values.length; index++) ...[
              _AlarmOption(
                sound: AlarmSound.values[index],
                controller: controller,
              ),
              if (index != AlarmSound.values.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _AlarmOption extends StatelessWidget {
  const _AlarmOption({required this.sound, required this.controller});

  final AlarmSound sound;
  final AlarmController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedSound == sound;
    final previewing = controller.previewingSound == sound;

    return Semantics(
      container: true,
      label: sound.label,
      selected: selected,
      child: Material(
        color: previewing ? AppColors.primary : Colors.transparent,
        child: ListTile(
          key: Key('alarmOption-${sound.storageKey}'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Radio<AlarmSound>(
            value: sound,
            enabled: !controller.isSaving,
          ),
          title: Text(
            sound.label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: previewing ? Colors.white : null,
            ),
          ),
          subtitle: Text(
            selected ? 'Alarma seleccionada' : 'Toca para elegirla',
            style: TextStyle(color: previewing ? Colors.white70 : null),
          ),
          trailing: IconButton(
            key: Key('previewAlarm-${sound.storageKey}'),
            tooltip: previewing
                ? 'Detener previsualización de ${sound.label}'
                : 'Previsualizar ${sound.label}',
            onPressed: () => controller.previewAlarm(sound),
            icon: Icon(
              previewing
                  ? Icons.pause_circle_outline_rounded
                  : Icons.play_circle_outline_rounded,
              color: previewing ? Colors.white : null,
            ),
          ),
          onTap: controller.isSaving
              ? null
              : () => controller.selectSound(sound),
        ),
      ),
    );
  }
}

class _AlarmError extends StatelessWidget {
  const _AlarmError({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Material(
        key: const Key('alarmError'),
        color: const Color(0xFFF5DCE9),
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.danger,
          ),
          title: Text(message),
          trailing: IconButton(
            tooltip: 'Cerrar aviso',
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded),
          ),
        ),
      ),
    );
  }
}
