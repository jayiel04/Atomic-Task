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
  bool _dueDateEnabled = false;
  bool _dueAlarmEnabled = false;
  TimeOfDay? _dueAlarmTime;
  TaskReminderMode _dueAlarmMode = TaskReminderMode.alarm;
  late bool _recurrenceEnabled;
  late RecurrenceFrequency _frequency;
  late DateTime _startDate;
  DateTime? _endDate;
  bool _recurrenceAlarmEnabled = false;
  TimeOfDay? _recurrenceAlarmTime;
  TaskReminderMode _recurrenceAlarmMode = TaskReminderMode.alarm;
  bool _recurrenceAlarmAlways = true;
  String? _reminderError;
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
    final reminder = task?.reminderAt?.toLocal();
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

    if (_isSeriesEdit) {
      final minutes = rule?.reminderTimeMinutes;
      _recurrenceAlarmEnabled = minutes != null || reminder != null;
      _recurrenceAlarmTime = minutes != null
          ? TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60)
          : reminder != null
          ? TimeOfDay.fromDateTime(reminder)
          : null;
      _recurrenceAlarmAlways = minutes != null;
      _recurrenceAlarmMode = task?.reminderMode ?? TaskReminderMode.alarm;
    } else {
      _dueDateEnabled = _dueDate != null || reminder != null;
      _dueAlarmEnabled = reminder != null;
      _dueAlarmTime = reminder != null ? TimeOfDay.fromDateTime(reminder) : null;
      _dueAlarmMode = task?.reminderMode ?? TaskReminderMode.alarm;
    }
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
            _buildDueDateSection(),
            const SizedBox(height: 12),
            if (_canConfigureRecurrence || _recurrenceEnabled) ...[
              _buildRecurrenceSection(context),
              const SizedBox(height: 16),
            ],
            TextFormField(
              key: const Key('taskTitleField'),
              controller: _titleController,
              enabled: !_isSaving,
              autofocus: true,
              maxLength: 120,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              decoration: _inputDecoration(hint: 'Escribe una tarea...'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Escribe un título para la tarea'
                  : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
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

  String get _dueDateSubtitle {
    if (!_dueDateEnabled) {
      return 'Limita cuándo debe completarse';
    }
    if (_isSeriesEdit) {
      return 'Pertenece a una serie recurrente';
    }
    final date = _dueDate;
    return date == null ? 'Sin fecha límite' : TaskDateFormatter.format(date);
  }

  Widget _buildDueDateSection() {
    return _OptionCard(
      cardKey: const Key('taskDueDateSection'),
      switchKey: const Key('dueDateOptionSwitch'),
      icon: Icons.event_rounded,
      title: 'Fecha límite',
      subtitle: _dueDateSubtitle,
      value: _dueDateEnabled,
      onChanged: _isSaving || _isSeriesEdit
          ? null
          : (value) => setState(() {
              _dueDateEnabled = value;
              if (value) {
                // Fecha límite y repetir son excluyentes.
                _recurrenceEnabled = false;
                _recurrenceAlarmEnabled = false;
                _recurrenceAlarmTime = null;
              } else {
                _dueDate = null;
                _dueAlarmEnabled = false;
                _dueAlarmTime = null;
                _reminderError = null;
              }
            }),
      child: _dueDateEnabled
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_isEditing) ...[
                  _DueDateShortcutOptions(
                    baseDate: _dueDateShortcutBase,
                    value: _dueDate,
                    enabled: !_isSaving,
                    onSelected: (value) => setState(() => _dueDate = value),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('selectTaskDueDateButton'),
                        onPressed: _isSaving ? null : _selectDueDate,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        icon: const Icon(Icons.calendar_month_rounded),
                        label: const Text('Elegir en el calendario'),
                      ),
                    ),
                    if (_dueDate != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        key: const Key('clearTaskDueDateButton'),
                        tooltip: 'Quitar fecha límite',
                        onPressed: _isSaving
                            ? null
                            : () => setState(() => _dueDate = null),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.destructive,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                _AlarmSubOption(
                  sectionKey: const Key('dueAlarmSection'),
                  switchKey: const Key('dueAlarmSwitch'),
                  addKey: const Key('addTaskReminderButton'),
                  changeKey: const Key('selectDueAlarmTimeButton'),
                  clearKey: const Key('clearTaskReminderButton'),
                  modeKey: const Key('dueAlarmModeSelector'),
                  alarmEnabled: _dueAlarmEnabled,
                  timeLabel: _dueAlarmTime == null
                      ? null
                      : _formatTime(_dueAlarmTime!),
                  mode: _dueAlarmMode,
                  enabled: !_isSaving,
                  showScope: false,
                  alwaysRepeat: true,
                  onSwitch: (value) => setState(() {
                    _dueAlarmEnabled = value;
                    if (!value) {
                      _dueAlarmTime = null;
                      _reminderError = null;
                    }
                  }),
                  onSetTime: _selectDueAlarmTime,
                  onChangeTime: _selectDueAlarmTime,
                  onModeChanged: (mode) =>
                      setState(() => _dueAlarmMode = mode),
                  onClear: () => setState(() {
                    _dueAlarmEnabled = false;
                    _dueAlarmTime = null;
                    _reminderError = null;
                  }),
                  error: _recurrenceEnabled ? null : _reminderError,
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildRecurrenceSection(BuildContext context) {
    return _OptionCard(
      cardKey: const Key('taskRecurrenceSection'),
      switchKey: const Key('repeatTaskSwitch'),
      icon: Icons.repeat_rounded,
      title: 'Repetir',
      subtitle: _recurrenceSubtitle,
      value: _recurrenceEnabled,
      onChanged: _canConfigureRecurrence && !_isSaving
          ? (value) => setState(() {
              _recurrenceEnabled = value;
              if (value) {
                // Fecha límite y repetir son excluyentes.
                _dueDateEnabled = false;
                _dueAlarmEnabled = false;
                _dueAlarmTime = null;
                _reminderError = null;
              } else {
                _recurrenceAlarmEnabled = false;
                _recurrenceAlarmTime = null;
                _reminderError = null;
              }
            })
          : null,
      child: _recurrenceEnabled ? _buildRecurrenceFields() : null,
    );
  }

  String get _recurrenceSubtitle {
    return _canConfigureRecurrence
        ? 'Crear ocurrencias automáticamente'
        : 'Esta ocurrencia pertenece a una serie';
  }

  Widget _buildRecurrenceFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
          onClear: _endDate == null || !_canConfigureRecurrence || _isSaving
              ? null
              : () => setState(() => _endDate = null),
        ),
        if (_endDate != null && _endDate!.isBefore(_startDate))
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'La fecha final no puede ser anterior a la fecha de inicio.',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        const SizedBox(height: 12),
        _AlarmSubOption(
          sectionKey: const Key('repeatAlarmSection'),
          switchKey: const Key('repeatAlarmSwitch'),
          addKey: const Key('addRepeatAlarmTimeButton'),
          changeKey: const Key('selectRepeatAlarmTimeButton'),
          clearKey: const Key('clearRepeatAlarmButton'),
          modeKey: const Key('repeatAlarmModeSelector'),
          scopeKey: const Key('repeatAlarmScopeSelector'),
          alarmEnabled: _recurrenceAlarmEnabled,
          timeLabel: _recurrenceAlarmTime == null
              ? null
              : _formatTime(_recurrenceAlarmTime!),
          mode: _recurrenceAlarmMode,
          enabled: _canConfigureRecurrence && !_isSaving,
          showScope: true,
          alwaysRepeat: _recurrenceAlarmAlways,
          onSwitch: (value) => setState(() {
            _recurrenceAlarmEnabled = value;
            if (!value) {
              _recurrenceAlarmTime = null;
              _reminderError = null;
            }
          }),
          onSetTime: _selectRecurrenceAlarmTime,
          onChangeTime: _selectRecurrenceAlarmTime,
          onModeChanged: (mode) =>
              setState(() => _recurrenceAlarmMode = mode),
          onScopeChanged: (always) =>
              setState(() => _recurrenceAlarmAlways = always),
          onClear: () => setState(() {
            _recurrenceAlarmEnabled = false;
            _recurrenceAlarmTime = null;
            _reminderError = null;
          }),
          error: _reminderError,
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      time,
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
  }

  InputDecoration _inputDecoration({String? label, String? hint}) {
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

  Future<void> _selectDueAlarmTime() async {
    final selectedTime = await _selectTime(
      initialTime:
          _dueAlarmTime ?? TimeOfDay.fromDateTime(_defaultReminderDateTime),
      helpText: 'Selecciona la hora de inicio de la tarea',
    );
    if (selectedTime == null || !mounted) {
      return;
    }
    setState(() {
      _dueAlarmTime = selectedTime;
      _reminderError = _reminderValidationError(_dueReminderAt);
    });
  }

  Future<void> _selectRecurrenceAlarmTime() async {
    final selectedTime = await _selectTime(
      initialTime: _recurrenceAlarmTime ??
          TimeOfDay.fromDateTime(_defaultReminderDateTime),
      helpText: 'Selecciona la hora de inicio de la tarea',
    );
    if (selectedTime == null || !mounted) {
      return;
    }
    setState(() {
      _recurrenceAlarmTime = selectedTime;
      _reminderError = _reminderValidationError(_recurrenceReminderAt);
    });
  }

  Future<TimeOfDay?> _selectTime({
    required TimeOfDay initialTime,
    required String helpText,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: helpText,
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
  }

  DateTime get _today {
    final now = _now().toLocal();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _defaultReminderDateTime =>
      _now().toLocal().add(const Duration(hours: 1));

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  DateTime _alarmStartBaseDate(TimeOfDay time) {
    final now = _now().toLocal();
    final today = _today;
    final candidate = _combineDateAndTime(today, time);
    return candidate.isAfter(now)
        ? today
        : today.add(const Duration(days: 1));
  }

  DateTime? get _dueReminderAt {
    final time = _dueAlarmTime;
    if (!_dueDateEnabled || !_dueAlarmEnabled || time == null) {
      return null;
    }
    final base = _dueDate ?? _alarmStartBaseDate(time);
    return _combineDateAndTime(base, time);
  }

  DateTime? get _recurrenceReminderAt {
    final time = _recurrenceAlarmTime;
    if (!_recurrenceEnabled || !_recurrenceAlarmEnabled || time == null) {
      return null;
    }
    return _combineDateAndTime(_startDate, time);
  }

  String? _reminderValidationError(DateTime? reminderAt) {
    if (reminderAt != null && !reminderAt.isAfter(_now().toLocal())) {
      return 'La alarma debe programarse para una fecha y hora futuras.';
    }
    return null;
  }

  Future<void> _selectDueDate() async {
    final selected = await _selectDate(
      initialDate: _dueDate ?? _now(),
      helpText: 'Selecciona la fecha límite',
    );
    if (selected != null && mounted) {
      setState(() {
        _dueDate = selected;
        _reminderError = _reminderValidationError(_dueReminderAt);
      });
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
        _reminderError = _reminderValidationError(_recurrenceReminderAt);
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
    final now = _now().toLocal();
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

    final usesRecurrence = _recurrenceEnabled;
    final reminderAt = usesRecurrence
        ? _recurrenceReminderAt
        : _dueReminderAt;
    final reminderMode = usesRecurrence
        ? _recurrenceAlarmMode
        : _dueAlarmMode;
    final reminderError = _reminderValidationError(reminderAt);
    if (reminderError != null) {
      setState(() => _reminderError = reminderError);
      return;
    }

    setState(() => _isSaving = true);
    final task = widget.task;
    final interval = int.tryParse(_intervalController.text) ?? 1;
    final dueDate = _dueDateEnabled ? _dueDate : null;
    final clearReminder = task?.reminderAt != null && reminderAt == null;
    final bool saved;
    if (task == null) {
      saved = usesRecurrence
          ? await widget.controller.createRecurring(
              title: _titleController.text,
              dueDate: dueDate,
              frequency: _frequency,
              interval: interval,
              startDate: _startDate,
              endDate: _endDate,
              reminderAt: reminderAt,
              reminderMode: reminderMode,
              reminderEveryOccurrence: _recurrenceAlarmAlways,
            )
          : await widget.controller.create(
              title: _titleController.text,
              dueDate: dueDate,
              reminderAt: reminderAt,
              reminderMode: reminderMode,
            );
    } else if (_isSeriesEdit) {
      saved = await widget.controller.updateSeries(
        task: task,
        title: _titleController.text,
        dueDate: dueDate,
        frequency: _frequency,
        interval: interval,
        startDate: _startDate,
        endDate: _endDate,
        reminderAt: reminderAt,
        clearReminder: clearReminder,
        reminderMode: reminderMode,
        reminderEveryOccurrence: _recurrenceAlarmAlways,
      );
    } else if (task.isRecurring) {
      saved = await widget.controller.updateOccurrence(
        task: task,
        title: _titleController.text,
        dueDate: dueDate,
        reminderAt: reminderAt,
        clearReminder: clearReminder,
        reminderMode: reminderMode,
      );
    } else {
      saved = await widget.controller.update(
        task: task,
        title: _titleController.text,
        dueDate: dueDate,
        reminderAt: reminderAt,
        clearReminder: clearReminder,
        reminderMode: reminderMode,
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

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.switchKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.cardKey,
    this.child,
  });

  final Key? cardKey;
  final Key switchKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: cardKey,
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
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(key: switchKey, value: value, onChanged: onChanged),
              ],
            ),
            if (child != null) ...[const SizedBox(height: 12), child!],
          ],
        ),
      ),
    );
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
  });

  final String label;
  final DateTime? value;
  final String emptyLabel;
  final Key selectKey;
  final VoidCallback? onSelect;
  final Key? clearKey;
  final VoidCallback? onClear;

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
              tooltip: 'Quitar fecha',
              onPressed: onClear,
              icon: const Icon(
                Icons.event_busy_rounded,
                color: AppColors.destructive,
              ),
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
    TaskDueDateShortcut.today => 'dueDateTodayOption',
    TaskDueDateShortcut.tomorrow => 'dueDateTomorrowOption',
  };

  String _shortcutLabel(TaskDueDateShortcut shortcut) => switch (shortcut) {
    TaskDueDateShortcut.today => 'Hoy',
    TaskDueDateShortcut.tomorrow => 'Mañana',
  };
}

class _AlarmSubOption extends StatelessWidget {
  const _AlarmSubOption({
    required this.sectionKey,
    required this.switchKey,
    required this.addKey,
    required this.changeKey,
    required this.clearKey,
    required this.modeKey,
    required this.alarmEnabled,
    required this.timeLabel,
    required this.mode,
    required this.enabled,
    required this.showScope,
    required this.alwaysRepeat,
    required this.onSwitch,
    required this.onSetTime,
    required this.onChangeTime,
    required this.onModeChanged,
    required this.onClear,
    this.scopeKey,
    this.onScopeChanged,
    this.error,
  });

  final Key sectionKey;
  final Key switchKey;
  final Key addKey;
  final Key changeKey;
  final Key clearKey;
  final Key modeKey;
  final Key? scopeKey;
  final bool alarmEnabled;
  final String? timeLabel;
  final TaskReminderMode mode;
  final bool enabled;
  final bool showScope;
  final bool alwaysRepeat;
  final ValueChanged<bool> onSwitch;
  final VoidCallback onSetTime;
  final VoidCallback onChangeTime;
  final ValueChanged<TaskReminderMode> onModeChanged;
  final VoidCallback onClear;
  final ValueChanged<bool>? onScopeChanged;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.alarm_rounded, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alarma',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      !alarmEnabled
                          ? 'Opcional: elige cómo avisarte'
                          : timeLabel == null
                          ? 'Sin hora configurada'
                          : 'A las $timeLabel',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                key: switchKey,
                value: alarmEnabled,
                onChanged: enabled ? onSwitch : null,
              ),
            ],
          ),
          if (alarmEnabled) ...[
            const SizedBox(height: 12),
            if (timeLabel == null)
              FilledButton.icon(
                key: addKey,
                onPressed: enabled ? onSetTime : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                icon: const Icon(Icons.alarm_add_rounded),
                label: const Text('Fijar hora de inicio'),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: changeKey,
                      onPressed: enabled ? onChangeTime : null,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      icon: const Icon(Icons.schedule_rounded),
                      label: const Text('Cambiar hora'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    key: clearKey,
                    tooltip: 'Quitar alarma',
                    onPressed: enabled ? onClear : null,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.destructive,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            SegmentedButton<TaskReminderMode>(
              key: modeKey,
              segments: const [
                ButtonSegment(
                  value: TaskReminderMode.alarm,
                  icon: Icon(Icons.alarm_rounded),
                  label: Text('Alarma'),
                ),
                ButtonSegment(
                  value: TaskReminderMode.notification,
                  icon: Icon(Icons.notifications_rounded),
                  label: Text('Notificación'),
                ),
              ],
              selected: {mode},
              onSelectionChanged: enabled
                  ? (selection) => onModeChanged(selection.first)
                  : null,
            ),
            if (showScope) ...[
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                key: scopeKey,
                segments: const [
                  ButtonSegment(value: true, label: Text('Siempre')),
                  ButtonSegment(value: false, label: Text('Solo la primera vez')),
                ],
                selected: {alwaysRepeat},
                onSelectionChanged:
                    enabled && onScopeChanged != null
                    ? (selection) => onScopeChanged!(selection.first)
                    : null,
              ),
            ],
          ],
          if (error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.destructive.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.destructive.withValues(alpha: 0.32),
                ),
              ),
              child: Text(
                error!,
                style: const TextStyle(color: AppColors.destructive),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
