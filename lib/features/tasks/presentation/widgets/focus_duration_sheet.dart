import 'package:flutter/material.dart';

import '../../../../core/constants/timer_constants.dart';
import '../../../../core/theme/app_colors.dart';

class FocusDurationSheet extends StatefulWidget {
  const FocusDurationSheet({required this.initialMinutes, super.key});

  final int initialMinutes;

  static Future<int?> show(
    BuildContext context, {
    required int initialMinutes,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => FocusDurationSheet(initialMinutes: initialMinutes),
    );
  }

  @override
  State<FocusDurationSheet> createState() => _FocusDurationSheetState();
}

class _FocusDurationSheetState extends State<FocusDurationSheet> {
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialMinutes
        .clamp(1, TimerConstants.maximumMinutes)
        .toInt();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tiempo de concentración',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Cerrar',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'La tarea se completará cuando termine esta sesión.',
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 22),
          Semantics(
            liveRegion: true,
            child: Text(
              '$_minutes minutos',
              key: const Key('selectedFocusMinutes'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Slider(
            key: const Key('focusMinutesSlider'),
            value: _minutes.toDouble(),
            min: 1,
            max: TimerConstants.maximumMinutes.toDouble(),
            divisions: TimerConstants.maximumMinutes - 1,
            label: '$_minutes minutos',
            onChanged: (value) => setState(() => _minutes = value.round()),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final minutes in const [15, 25, 45, 60])
                ChoiceChip(
                  key: Key('focusMinutes-$minutes'),
                  label: Text('$minutes min'),
                  selected: _minutes == minutes,
                  onSelected: (_) => setState(() => _minutes = minutes),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const Key('startTaskFocusButton'),
            onPressed: () => Navigator.pop(context, _minutes),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Preparar concentración'),
          ),
        ],
      ),
    );
  }
}
