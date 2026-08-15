import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/atomic_task.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../controllers/task_controller.dart';
import '../task_date_formatter.dart';
import '../task_due_date_shortcuts.dart';

enum TaskEditScope { occurrence, series }

class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({
    required this.controller,
    this.task,
    this.editScope = TaskEditScope.occurrence,
    this.now,
    super.key,
  });

  final TaskController controller;
  final AtomicTask? task;
  final TaskEditScope editScope;
  final DateTime Function()? now;

  static Future<void> show(
    BuildContext context, {
    required TaskController controller,
    AtomicTask? task,
    TaskEditScope editScope = TaskEditScope.occurrence,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => TaskFormSheet(
        controller: controller,
        task: task,
        editScope: editScope,
      ),
    );
  }

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _intervalController;
  DateTime? _dueDate;
  late final DateTime _dueDateShortcutBase;
  late bool _recurrenceEnabled;
  late RecurrenceFrequency _frequency;
  late DateTime _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  bool get _isEditing => widget.task != null;
  bool get _isSeriesEdit =>
      widget.task?.isRecurring == true &&
      widget.editScope == TaskEditScope.series;
  bool get _canConfigureRecurrence => !_isEditing || _isSeriesEdit;
  DateTime _now() => widget.now?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    final rule = task?.recurrenceRule;
    final now = _now();
    _titleController = TextEditingController(text: task?.title ?? '');
    _intervalController = TextEditingController(
      text: (rule?.interval ?? 1).toString(),
    );
    _dueDate = task?.dueDate;
    _dueDateShortcutBase = now;
    _recurrenceEnabled = rule != null;
    _frequency = rule?.frequency ?? RecurrenceFrequency.daily;
    _startDate = rule?.startDate ?? DateTime(now.year, now.month, now.day);
    _endDate = rule?.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 22, 24, 24 + keyboardInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _sheetTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('taskTitleField'),
              controller: _titleController,
              autofocus: true,
              maxLength: 120,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              decoration: _inputDecoration(
                label: 'Título',
                hint: '¿Qué quieres completar?',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Escribe un título para la tarea'
                  : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 10),
            _DateField(
              label: 'Fecha límite',
              value: _dueDate,
              emptyLabel: 'Sin fecha límite',
              selectKey: const Key('selectTaskDueDateButton'),
              clearKey: const Key('clearTaskDueDateButton'),
              clearIcon: Icons.close_rounded,
              clearIconColor: AppColors.destructive,
              clearTooltip: 'Quitar fecha límite',
              onSelect: _isSaving ? null : _selectDueDate,
              onClear: _dueDate == null || _isSaving
                  ? null
                  : () => setState(() => _dueDate = null),
            ),
            if (!_isEditing) ...[
              const SizedBox(height: 10),
              _DueDateShortcutOptions(
                baseDate: _dueDateShortcutBase,
                value: _dueDate,
                enabled: !_isSaving,
                onSelected: (value) => setState(() => _dueDate = value),
              ),
            ],
            if (_canConfigureRecurrence || _recurrenceEnabled) ...[
              const SizedBox(height: 14),
              _buildRecurrenceSection(context),
            ],
            const SizedBox(height: 22),
            FilledButton.icon(
              key: const Key('saveTaskButton'),
              onPressed: _isSaving ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: _isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_isEditing ? Icons.save_rounded : Icons.add_rounded),
              label: Text(_isEditing ? 'Guardar cambios' : 'Crear tarea'),
            ),
          ],
        ),
      ),
    );
  }

  String get _sheetTitle {
    if (!_isEditing) {
      return 'Nueva tarea';
    }
    return _isSeriesEdit ? 'Editar serie' : 'Editar ocurrencia';
  }

  Widget _buildRecurrenceSection(BuildContext context) {
    return Material(
      key: const Key('taskRecurrenceSection'),
      color: AppColors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile.adaptive(
              key: const Key('repeatTaskSwitch'),
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Repetir',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                _canConfigureRecurrence
                    ? 'Crear ocurrencias automáticamente'
                    : 'Esta ocurrencia pertenece a una serie',
              ),
              value: _recurrenceEnabled,
              onChanged: _canConfigureRecurrence && !_isSaving
                  ? (value) => setState(() => _recurrenceEnabled = value)
                  : null,
            ),
            if (_recurrenceEnabled) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<RecurrenceFrequency>(
                key: const Key('recurrenceFrequencyField'),
                initialValue: _frequency,
                decoration: _inputDecoration(label: 'Frecuencia'),
                items: RecurrenceFrequency.values
                    .map(
                      (frequency) => DropdownMenuItem(
                        value: frequency,
                        child: Text(_frequencyLabel(frequency)),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _canConfigureRecurrence && !_isSaving
                    ? (value) {
                        if (value != null) {
                          setState(() => _frequency = value);
                        }
                      }
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('recurrenceIntervalField'),
                controller: _intervalController,
                enabled: _canConfigureRecurrence && !_isSaving,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration(
                  label: 'Intervalo',
                  hint: '1',
                ).copyWith(suffixText: _intervalSuffix),
                validator: (value) {
                  if (!_recurrenceEnabled) {
                    return null;
                  }
                  final interval = int.tryParse(value ?? '');
                  return interval == null || interval < 1
                      ? 'Usa un intervalo mayor que cero'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              _DateField(
                label: 'Fecha de inicio',
                value: _startDate,
                emptyLabel: '',
                selectKey: const Key('selectRecurrenceStartDateButton'),
                onSelect: _canConfigureRecurrence && !_isSaving
                    ? _selectStartDate
                    : null,
              ),
              const SizedBox(height: 10),
              _DateField(
                label: 'Fecha de finalización',
                value: _endDate,
                emptyLabel: 'Sin fecha de finalización',
                selectKey: const Key('selectRecurrenceEndDateButton'),
                clearKey: const Key('clearRecurrenceEndDateButton'),
                onSelect: _canConfigureRecurrence && !_isSaving
                    ? _selectEndDate
                    : null,
                onClear:
                    _endDate == null || !_canConfigureRecurrence || _isSaving
                    ? null
                    : () => setState(() => _endDate = null),
              ),
              if (_endDate != null && _endDate!.isBefore(_startDate)) ...[
                const SizedBox(height: 8),
                const Text(
                  'La fecha final no puede ser anterior a la fecha de inicio.',
                  style: TextStyle(color: AppColors.danger),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );
  }

  String _frequencyLabel(RecurrenceFrequency frequency) {
    return switch (frequency) {
      RecurrenceFrequency.daily => 'Diaria',
      RecurrenceFrequency.weekly => 'Semanal',
      RecurrenceFrequency.monthly => 'Mensual',
    };
  }

  String get _intervalSuffix {
    return switch (_frequency) {
      RecurrenceFrequency.daily => 'días',
      RecurrenceFrequency.weekly => 'semanas',
      RecurrenceFrequency.monthly => 'meses',
    };
  }

  Future<void> _selectDueDate() async {
    final selected = await _selectDate(
      initialDate: _dueDate ?? _now(),
      helpText: 'Selecciona la fecha límite',
    );
    if (selected != null && mounted) {
      setState(() => _dueDate = selected);
    }
  }

  Future<void> _selectStartDate() async {
    final selected = await _selectDate(
      initialDate: _startDate,
      helpText: 'Selecciona la fecha de inicio',
    );
    if (selected != null && mounted) {
      setState(() {
        _startDate = selected;
        if (_endDate != null && _endDate!.isBefore(selected)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final selected = await _selectDate(
      initialDate: _endDate ?? _startDate,
      helpText: 'Selecciona la fecha de finalización',
      firstDate: _startDate,
    );
    if (selected != null && mounted) {
      setState(() => _endDate = selected);
    }
  }

  Future<DateTime?> _selectDate({
    required DateTime initialDate,
    required String helpText,
    DateTime? firstDate,
  }) async {
    final now = _now();
    final minimum = firstDate ?? DateTime(2000);
    final safeInitial = initialDate.isBefore(minimum) ? minimum : initialDate;
    final selected = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: minimum,
      lastDate: DateTime(now.year + 100),
      helpText: helpText,
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    return selected == null
        ? null
        : DateTime(selected.year, selected.month, selected.day);
  }

  Future<void> _submit() async {
    if (_isSaving || _formKey.currentState?.validate() != true) {
      return;
    }
    if (_recurrenceEnabled &&
        _endDate != null &&
        _endDate!.isBefore(_startDate)) {
      return;
    }

    setState(() => _isSaving = true);
    final task = widget.task;
    final interval = int.tryParse(_intervalController.text) ?? 1;
    final bool saved;
    if (task == null) {
      saved = _recurrenceEnabled
          ? await widget.controller.createRecurring(
              title: _titleController.text,
              dueDate: _dueDate,
              frequency: _frequency,
              interval: interval,
              startDate: _startDate,
              endDate: _endDate,
            )
          : await widget.controller.create(
              title: _titleController.text,
              dueDate: _dueDate,
            );
    } else if (_isSeriesEdit) {
      saved = await widget.controller.updateSeries(
        task: task,
        title: _titleController.text,
        dueDate: _dueDate,
        frequency: _frequency,
        interval: interval,
        startDate: _startDate,
        endDate: _endDate,
      );
    } else if (task.isRecurring) {
      saved = await widget.controller.updateOccurrence(
        task: task,
        title: _titleController.text,
        dueDate: _dueDate,
      );
    } else {
      saved = await widget.controller.update(
        task: task,
        title: _titleController.text,
        dueDate: _dueDate,
      );
    }

    if (!mounted) {
      return;
    }
    if (saved) {
      Navigator.pop(context);
    } else {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.errorMessage ?? 'No fue posible guardar.',
          ),
        ),
      );
    }
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.emptyLabel,
    required this.selectKey,
    required this.onSelect,
    this.clearKey,
    this.onClear,
    this.clearIcon = Icons.event_busy_rounded,
    this.clearIconColor,
    this.clearTooltip = 'Quitar fecha',
  });

  final String label;
  final DateTime? value;
  final String emptyLabel;
  final Key selectKey;
  final VoidCallback? onSelect;
  final Key? clearKey;
  final VoidCallback? onClear;
  final IconData clearIcon;
  final Color? clearIconColor;
  final String clearTooltip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_rounded, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  value == null ? emptyLabel : TaskDateFormatter.format(value!),
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (value != null && clearKey != null)
            IconButton(
              key: clearKey,
              tooltip: clearTooltip,
              onPressed: onClear,
              icon: Icon(clearIcon, color: clearIconColor),
            ),
          IconButton(
            key: selectKey,
            tooltip: value == null ? 'Elegir fecha' : 'Cambiar fecha',
            onPressed: onSelect,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _DueDateShortcutOptions extends StatelessWidget {
  const _DueDateShortcutOptions({
    required this.baseDate,
    required this.value,
    required this.enabled,
    required this.onSelected,
  });

  final DateTime baseDate;
  final DateTime? value;
  final bool enabled;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key('dueDateShortcutOptions'),
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final shortcut in TaskDueDateShortcut.values)
          _shortcutChip(shortcut),
      ],
    );
  }

  Widget _shortcutChip(TaskDueDateShortcut shortcut) {
    final date = TaskDueDateShortcuts.calculate(shortcut, baseDate);
    final selected = TaskDueDateShortcuts.isSameDay(value, date);
    return SizedBox(
      height: 48,
      child: ChoiceChip(
        key: Key(_shortcutKey(shortcut)),
        label: Text(_shortcutLabel(shortcut)),
        selected: selected,
        onSelected: enabled ? (_) => onSelected(date) : null,
        selectedColor: AppColors.primarySoft,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
        ),
        labelStyle: TextStyle(
          color: selected ? AppColors.primaryDark : AppColors.text,
          fontWeight: FontWeight.w800,
        ),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }

  String _shortcutKey(TaskDueDateShortcut shortcut) => switch (shortcut) {
    TaskDueDateShortcut.tomorrow => 'dueDateTomorrowOption',
    TaskDueDateShortcut.oneWeek => 'dueDateOneWeekOption',
    TaskDueDateShortcut.oneMonth => 'dueDateOneMonthOption',
  };

  String _shortcutLabel(TaskDueDateShortcut shortcut) => switch (shortcut) {
    TaskDueDateShortcut.tomorrow => 'Mañana',
    TaskDueDateShortcut.oneWeek => 'Una semana',
    TaskDueDateShortcut.oneMonth => 'Un mes',
  };
}
