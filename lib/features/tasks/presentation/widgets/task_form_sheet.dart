import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/alarm_sound.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/atomic_task.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../controllers/task_controller.dart';
import '../task_date_formatter.dart';
import '../task_due_date_shortcuts.dart';

enum TaskEditScope { occurrence, series }

enum _FormView { principal, dueDate, recurrence }

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
  String? _dueAlarmSoundKey;
  late bool _recurrenceEnabled;
  late RecurrenceFrequency _frequency;
  late DateTime _startDate;
  DateTime? _endDate;
  bool _recurrenceAlarmEnabled = false;
  TimeOfDay? _recurrenceAlarmTime;
  TaskReminderMode _recurrenceAlarmMode = TaskReminderMode.alarm;
  String? _recurrenceAlarmSoundKey;
  bool _recurrenceAlarmAlways = true;
  String? _dueDateError;
  String? _reminderError;
  bool _isSaving = false;
  _FormView _view = _FormView.principal;
  _FormSnapshot? _viewSnapshot;

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
      _recurrenceAlarmSoundKey = task?.reminderSoundKey;
    } else {
      _dueDateEnabled = _dueDate != null || reminder != null;
      _dueAlarmEnabled = reminder != null;
      _dueAlarmTime = reminder != null
          ? TimeOfDay.fromDateTime(reminder)
          : null;
      _dueAlarmMode = task?.reminderMode ?? TaskReminderMode.alarm;
      _dueAlarmSoundKey = task?.reminderSoundKey;
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
                if (_view != _FormView.principal) ...[
                  IconButton(
                    key: const Key('formBackButton'),
                    tooltip: 'Volver',
                    onPressed: _isSaving ? null : _handleBack,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.destructive,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
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
            _buildBody(),
            const SizedBox(height: 16),
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
    if (_view == _FormView.dueDate) {
      return 'Tarea con fecha límite';
    }
    if (_view == _FormView.recurrence) {
      return 'Tarea cíclica';
    }
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
    final base = date == null
        ? 'Sin fecha límite'
        : TaskDateFormatter.format(date);
    final alarmSummary = _alarmSummary(_dueAlarmEnabled, _dueAlarmTime);
    return alarmSummary == null ? base : '$base · $alarmSummary';
  }

  String? _alarmSummary(bool alarmEnabled, TimeOfDay? time) {
    if (!alarmEnabled || time == null) {
      return null;
    }
    return 'Alarma ${_formatTime(time)}';
  }

  Widget _buildBody() {
    return switch (_view) {
      _FormView.dueDate => _buildDueDateView(),
      _FormView.recurrence => _buildRecurrenceView(),
      _FormView.principal => _buildPrincipalView(),
    };
  }

  Widget _buildPrincipalView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDueDateCard(),
        if (_canConfigureRecurrence || _recurrenceEnabled) ...[
          const SizedBox(height: 12),
          _buildRecurrenceCard(),
        ],
        if (_dueDateError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _dueDateError!,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        if (_reminderError != null && !_recurrenceEnabled && !_isSeriesEdit)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _reminderError!,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
      ],
    );
  }

  Widget _buildDueDateCard() {
    return _OptionEntryCard(
      cardKey: const Key('taskDueDateSection'),
      icon: Icons.event_rounded,
      title: 'Tarea con fecha límite',
      subtitle: _dueDateSubtitle,
      onTap: _isSaving || _isSeriesEdit ? null : _openDueDateView,
    );
  }

  Widget _buildRecurrenceCard() {
    return _OptionEntryCard(
      cardKey: const Key('taskRecurrenceSection'),
      icon: Icons.repeat_rounded,
      title: 'Tarea cíclica',
      subtitle: _recurrenceSubtitle,
      onTap: _canConfigureRecurrence && !_isSaving ? _openRecurrenceView : null,
    );
  }

  Widget _buildDueDateView() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _dueDate == null
                ? 'Sin fecha límite'
                : TaskDateFormatter.format(_dueDate!),
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          if (!_isEditing) ...[
            _DueDateShortcutOptions(
              baseDate: _dueDateShortcutBase,
              value: _dueDate,
              enabled: !_isSaving,
              onSelected: (value) => setState(() {
                _dueDate = value;
                _dueDateError = null;
              }),
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
                  onPressed: _isSaving ? null : _clearDueDate,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.destructive,
                  ),
                ),
              ],
            ],
          ),
          if (_dueDateError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _dueDateError!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          const SizedBox(height: 12),
          if (_reminderError != null && !_recurrenceEnabled && !_isSeriesEdit)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                _reminderError!,
                style: const TextStyle(color: AppColors.danger),
              ),
            ),
          if (!_isSeriesEdit) _buildDueAlarmIcon(),
        ],
      ),
    );
  }

  void _clearDueDate() {
    setState(() {
      _dueDateEnabled = false;
      _dueDate = null;
      _dueDateError = null;
      _dueAlarmEnabled = false;
      _dueAlarmTime = null;
      _dueAlarmSoundKey = null;
      _reminderError = null;
      _view = _FormView.principal;
    });
  }

  Widget _buildDueAlarmIcon() {
    return _buildAlarmCard(
      cardKey: const Key('dueAlarmIcon'),
      enabled: _dueAlarmEnabled,
      time: _dueAlarmTime,
      onTap: _isSaving ? null : _editDueAlarm,
    );
  }

  Widget _buildRecurrenceAlarmIcon() {
    return _buildAlarmCard(
      cardKey: const Key('repeatAlarmIcon'),
      enabled: _recurrenceAlarmEnabled,
      time: _recurrenceAlarmTime,
      onTap: _canConfigureRecurrence && !_isSaving
          ? _editRecurrenceAlarm
          : null,
    );
  }

  Widget _buildAlarmCard({
    required Key cardKey,
    required bool enabled,
    required TimeOfDay? time,
    required VoidCallback? onTap,
  }) {
    final subtitle = !enabled
        ? 'Configurar alarma'
        : time == null
        ? 'Editar alarma'
        : 'Editar alarma · ${_formatTime(time)}';
    return Tooltip(
      message: enabled ? 'Editar alarma' : 'Configurar alarma',
      child: InkWell(
        key: cardKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                enabled ? Icons.alarm_on_rounded : Icons.alarm_add_rounded,
                color: enabled ? AppColors.primary : AppColors.muted,
              ),
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
                      subtitle,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecurrenceView() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildRecurrenceFields(),
      ),
    );
  }

  String get _recurrenceSubtitle {
    if (!_canConfigureRecurrence) {
      return 'Esta ocurrencia pertenece a una serie';
    }
    final alarmSummary = _alarmSummary(
      _recurrenceAlarmEnabled,
      _recurrenceAlarmTime,
    );
    final base = _recurrenceEnabled
        ? _frequencyLabel(_frequency)
        : 'Crear ocurrencias automáticamente';
    return alarmSummary == null ? base : '$base · $alarmSummary';
  }

  List<Widget> _buildRecurrenceFields() {
    return [
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
        onSelect: _canConfigureRecurrence && !_isSaving ? _selectEndDate : null,
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
      if (_reminderError != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _reminderError!,
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
      _buildRecurrenceAlarmIcon(),
    ];
  }

  Future<void> _editDueAlarm() async {
    final result = await _showAlarmEditor(
      context,
      prefix: 'due',
      showScope: false,
      suggestedTime: TimeOfDay.fromDateTime(_defaultReminderDateTime),
      initial: _AlarmEditorValue(
        alarmEnabled: _dueAlarmEnabled,
        time: _dueAlarmTime,
        mode: _dueAlarmMode,
        soundKey: _dueAlarmSoundKey,
        alwaysRepeat: true,
      ),
      validateTime: (time) => _reminderValidationError(
        _combineDateAndTime(_dueDate ?? _alarmStartBaseDate(time), time),
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _dueAlarmEnabled = result.alarmEnabled;
      _dueAlarmTime = result.time;
      _dueAlarmMode = result.mode;
      _dueAlarmSoundKey = result.soundKey;
      _reminderError = _reminderValidationError(_dueReminderAt);
    });
  }

  Future<void> _editRecurrenceAlarm() async {
    final result = await _showAlarmEditor(
      context,
      prefix: 'repeat',
      showScope: true,
      suggestedTime: TimeOfDay.fromDateTime(_defaultReminderDateTime),
      initial: _AlarmEditorValue(
        alarmEnabled: _recurrenceAlarmEnabled,
        time: _recurrenceAlarmTime,
        mode: _recurrenceAlarmMode,
        soundKey: _recurrenceAlarmSoundKey,
        alwaysRepeat: _recurrenceAlarmAlways,
      ),
      validateTime: (time) =>
          _reminderValidationError(_combineDateAndTime(_startDate, time)),
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _recurrenceAlarmEnabled = result.alarmEnabled;
      _recurrenceAlarmTime = result.time;
      _recurrenceAlarmMode = result.mode;
      _recurrenceAlarmSoundKey = result.soundKey;
      _recurrenceAlarmAlways = result.alwaysRepeat;
      _reminderError = _reminderValidationError(_recurrenceReminderAt);
    });
  }

  void _openDueDateView() {
    if (_isSaving || _isSeriesEdit) {
      return;
    }
    setState(() {
      _viewSnapshot = _captureSnapshot();
      _view = _FormView.dueDate;
      if (!_dueDateEnabled) {
        _dueDateEnabled = true;
        _dueDate ??= _today;
        _dueDateError = null;
        // Fecha límite y tarea cíclica son excluyentes.
        _recurrenceEnabled = false;
        _recurrenceAlarmEnabled = false;
        _recurrenceAlarmTime = null;
        _recurrenceAlarmSoundKey = null;
      }
    });
  }

  void _openRecurrenceView() {
    if (!_canConfigureRecurrence || _isSaving) {
      return;
    }
    setState(() {
      _viewSnapshot = _captureSnapshot();
      _view = _FormView.recurrence;
      if (!_recurrenceEnabled) {
        _recurrenceEnabled = true;
        // Fecha límite y tarea cíclica son excluyentes.
        _dueDateEnabled = false;
        _dueAlarmEnabled = false;
        _dueAlarmTime = null;
        _dueAlarmSoundKey = null;
        _reminderError = null;
      }
    });
  }

  Future<void> _handleBack() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Descartar cambios?'),
        content: const Text(
          'Se perderán los cambios realizados en esta sección.',
        ),
        actions: [
          TextButton(
            key: const Key('formKeepChangesButton'),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Conservar'),
          ),
          TextButton(
            key: const Key('formDiscardButton'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Descartar',
              style: TextStyle(color: AppColors.destructive),
            ),
          ),
        ],
      ),
    );
    if (!mounted || discard == null) {
      return;
    }
    setState(() {
      if (discard) {
        _restoreSnapshot(_viewSnapshot);
      }
      _viewSnapshot = null;
      _view = _FormView.principal;
    });
  }

  _FormSnapshot _captureSnapshot() {
    return _FormSnapshot(
      dueDateEnabled: _dueDateEnabled,
      dueDate: _dueDate,
      dueAlarmEnabled: _dueAlarmEnabled,
      dueAlarmTime: _dueAlarmTime,
      dueAlarmMode: _dueAlarmMode,
      dueAlarmSoundKey: _dueAlarmSoundKey,
      recurrenceEnabled: _recurrenceEnabled,
      frequency: _frequency,
      startDate: _startDate,
      endDate: _endDate,
      recurrenceAlarmEnabled: _recurrenceAlarmEnabled,
      recurrenceAlarmTime: _recurrenceAlarmTime,
      recurrenceAlarmMode: _recurrenceAlarmMode,
      recurrenceAlarmSoundKey: _recurrenceAlarmSoundKey,
      recurrenceAlarmAlways: _recurrenceAlarmAlways,
      intervalText: _intervalController.text,
      dueDateError: _dueDateError,
      reminderError: _reminderError,
    );
  }

  void _restoreSnapshot(_FormSnapshot? snapshot) {
    if (snapshot == null) {
      return;
    }
    _dueDateEnabled = snapshot.dueDateEnabled;
    _dueDate = snapshot.dueDate;
    _dueAlarmEnabled = snapshot.dueAlarmEnabled;
    _dueAlarmTime = snapshot.dueAlarmTime;
    _dueAlarmMode = snapshot.dueAlarmMode;
    _dueAlarmSoundKey = snapshot.dueAlarmSoundKey;
    _recurrenceEnabled = snapshot.recurrenceEnabled;
    _frequency = snapshot.frequency;
    _startDate = snapshot.startDate;
    _endDate = snapshot.endDate;
    _recurrenceAlarmEnabled = snapshot.recurrenceAlarmEnabled;
    _recurrenceAlarmTime = snapshot.recurrenceAlarmTime;
    _recurrenceAlarmMode = snapshot.recurrenceAlarmMode;
    _recurrenceAlarmSoundKey = snapshot.recurrenceAlarmSoundKey;
    _recurrenceAlarmAlways = snapshot.recurrenceAlarmAlways;
    _intervalController.text = snapshot.intervalText;
    _dueDateError = snapshot.dueDateError;
    _reminderError = snapshot.reminderError;
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
    return candidate.isAfter(now) ? today : today.add(const Duration(days: 1));
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
      firstDate: _today,
    );
    if (selected != null && mounted) {
      setState(() {
        _dueDate = selected;
        _dueDateError = null;
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
    if (_dueDateEnabled && _dueDate == null) {
      setState(() => _dueDateError = 'Selecciona una fecha límite.');
      return;
    }

    final usesRecurrence = _recurrenceEnabled;
    final reminderAt = usesRecurrence ? _recurrenceReminderAt : _dueReminderAt;
    final reminderMode = usesRecurrence ? _recurrenceAlarmMode : _dueAlarmMode;
    final reminderSoundKey = usesRecurrence
        ? (_recurrenceAlarmEnabled ? _recurrenceAlarmSoundKey : null)
        : (_dueAlarmEnabled ? _dueAlarmSoundKey : null);
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
              reminderSoundKey: reminderSoundKey,
              reminderEveryOccurrence: _recurrenceAlarmAlways,
            )
          : await widget.controller.create(
              title: _titleController.text,
              dueDate: dueDate,
              reminderAt: reminderAt,
              reminderMode: reminderMode,
              reminderSoundKey: reminderSoundKey,
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
        reminderSoundKey: reminderSoundKey,
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
        reminderSoundKey: reminderSoundKey,
      );
    } else {
      saved = await widget.controller.update(
        task: task,
        title: _titleController.text,
        dueDate: dueDate,
        reminderAt: reminderAt,
        clearReminder: clearReminder,
        reminderMode: reminderMode,
        reminderSoundKey: reminderSoundKey,
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

class _OptionEntryCard extends StatelessWidget {
  const _OptionEntryCard({
    this.cardKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Key? cardKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: cardKey,
      color: AppColors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
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
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

class _FormSnapshot {
  const _FormSnapshot({
    required this.dueDateEnabled,
    required this.dueDate,
    required this.dueAlarmEnabled,
    required this.dueAlarmTime,
    required this.dueAlarmMode,
    required this.dueAlarmSoundKey,
    required this.recurrenceEnabled,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    required this.recurrenceAlarmEnabled,
    required this.recurrenceAlarmTime,
    required this.recurrenceAlarmMode,
    required this.recurrenceAlarmSoundKey,
    required this.recurrenceAlarmAlways,
    required this.intervalText,
    required this.dueDateError,
    required this.reminderError,
  });

  final bool dueDateEnabled;
  final DateTime? dueDate;
  final bool dueAlarmEnabled;
  final TimeOfDay? dueAlarmTime;
  final TaskReminderMode dueAlarmMode;
  final String? dueAlarmSoundKey;
  final bool recurrenceEnabled;
  final RecurrenceFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final bool recurrenceAlarmEnabled;
  final TimeOfDay? recurrenceAlarmTime;
  final TaskReminderMode recurrenceAlarmMode;
  final String? recurrenceAlarmSoundKey;
  final bool recurrenceAlarmAlways;
  final String intervalText;
  final String? dueDateError;
  final String? reminderError;
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
    return InkWell(
      key: selectKey,
      onTap: onSelect,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                    value == null
                        ? emptyLabel
                        : TaskDateFormatter.format(value!),
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
          ],
        ),
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

class _AlarmEditorValue {
  const _AlarmEditorValue({
    required this.alarmEnabled,
    required this.time,
    required this.mode,
    required this.soundKey,
    required this.alwaysRepeat,
  });

  final bool alarmEnabled;
  final TimeOfDay? time;
  final TaskReminderMode mode;
  final String? soundKey;
  final bool alwaysRepeat;
}

Future<_AlarmEditorValue?> _showAlarmEditor(
  BuildContext context, {
  required String prefix,
  required bool showScope,
  required TimeOfDay suggestedTime,
  required String? Function(TimeOfDay time) validateTime,
  required _AlarmEditorValue initial,
}) {
  return showGeneralDialog<_AlarmEditorValue>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (dialogContext, animation, _, _) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return AnimatedBuilder(
        animation: curved,
        builder: (dialogContext, _) {
          final progress = curved.value;
          final blur = 10.0 * progress;
          final slideDistance = MediaQuery.sizeOf(dialogContext).height * 0.35;
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.35 * progress),
                    ),
                  ),
                ),
              ),
              Center(
                child: Transform.translate(
                  offset: Offset(0, (1 - progress) * slideDistance),
                  child: Opacity(
                    opacity: progress,
                    child: _AlarmEditorSheet(
                      prefix: prefix,
                      showScope: showScope,
                      suggestedTime: suggestedTime,
                      validateTime: validateTime,
                      initial: initial,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class _AlarmEditorSheet extends StatefulWidget {
  const _AlarmEditorSheet({
    required this.prefix,
    required this.showScope,
    required this.suggestedTime,
    required this.validateTime,
    required this.initial,
  });

  final String prefix;
  final bool showScope;
  final TimeOfDay suggestedTime;
  final String? Function(TimeOfDay time) validateTime;
  final _AlarmEditorValue initial;

  @override
  State<_AlarmEditorSheet> createState() => _AlarmEditorSheetState();
}

class _AlarmEditorSheetState extends State<_AlarmEditorSheet> {
  late bool _alarmEnabled = widget.initial.alarmEnabled;
  late TimeOfDay? _time = widget.initial.time;
  late TaskReminderMode _mode = widget.initial.mode;
  late String? _soundKey = widget.initial.soundKey;
  late bool _alwaysRepeat = widget.initial.alwaysRepeat;
  String? _error;

  bool get _controlsEnabled => _alarmEnabled;
  bool get _soundEnabled => _controlsEnabled && _mode == TaskReminderMode.alarm;

  void _close() => Navigator.of(context).pop();

  Future<void> _selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _time ?? widget.suggestedTime,
      helpText: 'Selecciona la hora de inicio de la tarea',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (selectedTime == null || !mounted) {
      return;
    }
    setState(() {
      _time = selectedTime;
      _error = null;
    });
  }

  void _save() {
    if (_alarmEnabled && _time != null) {
      final error = widget.validateTime(_time!);
      if (error != null) {
        setState(() => _error = error);
        return;
      }
    }
    Navigator.of(context).pop(
      _AlarmEditorValue(
        alarmEnabled: _alarmEnabled,
        time: _alarmEnabled ? _time : null,
        mode: _mode,
        soundKey: _alarmEnabled ? _soundKey : null,
        alwaysRepeat: _alwaysRepeat,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildToggleRow(),
              const SizedBox(height: 8),
              _buildTimeRow(),
              const SizedBox(height: 8),
              _buildModeRows(),
              _buildSoundSection(),
              if (widget.showScope) ...[
                const SizedBox(height: 8),
                _buildScopeRows(),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              const SizedBox(height: 16),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final configured = widget.initial.alarmEnabled;
    return Row(
      children: [
        const Icon(Icons.alarm_rounded, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            configured ? 'Editar alarma' : 'Configurar alarma',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          tooltip: 'Cerrar',
          onPressed: _close,
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  Widget _buildToggleRow() {
    return Row(
      children: [
        const Icon(
          Icons.notifications_active_rounded,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        const Expanded(child: Text('Alarma')),
        Switch.adaptive(
          key: Key('${widget.prefix}AlarmToggleItem'),
          value: _alarmEnabled,
          onChanged: (value) => setState(() {
            _alarmEnabled = value;
            if (!value) {
              _time = null;
              _soundKey = null;
              _error = null;
            }
          }),
        ),
      ],
    );
  }

  Widget _buildTimeRow() {
    return OutlinedButton.icon(
      key: Key('${widget.prefix}AlarmTimeItem'),
      onPressed: _controlsEnabled ? _selectTime : null,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      icon: const Icon(Icons.schedule_rounded),
      label: Text(
        _time == null ? 'Elegir hora' : 'Hora: ${_formatTime(_time!)}',
      ),
    );
  }

  Widget _buildModeRows() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _selectRow(
          itemKey: Key('${widget.prefix}AlarmModeAlarmItem'),
          icon: Icons.alarm_rounded,
          label: 'Modo: Alarma',
          selected: _mode == TaskReminderMode.alarm,
          enabled: _controlsEnabled,
          onTap: () => setState(() => _mode = TaskReminderMode.alarm),
        ),
        _selectRow(
          itemKey: Key('${widget.prefix}AlarmModeNotificationItem'),
          icon: Icons.notifications_rounded,
          label: 'Modo: Notificación',
          selected: _mode == TaskReminderMode.notification,
          enabled: _controlsEnabled,
          onTap: () => setState(() => _mode = TaskReminderMode.notification),
        ),
      ],
    );
  }

  Widget _buildSoundSection() {
    return Opacity(
      opacity: _soundEnabled ? 1 : 0.5,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.music_note_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text('Sonido'),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              key: Key('${widget.prefix}AlarmSoundItem'),
              spacing: 8,
              runSpacing: 8,
              children: [
                _soundChip(
                  storageKey: null,
                  label: 'Predeterminada',
                  selected: _soundKey == null,
                ),
                for (final sound in AlarmSound.values)
                  _soundChip(
                    storageKey: sound.storageKey,
                    label: sound.label,
                    selected: _soundKey == sound.storageKey,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeRows() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _selectRow(
          itemKey: Key('${widget.prefix}AlarmScopeAlwaysItem'),
          icon: Icons.repeat_rounded,
          label: 'Alcance: Siempre',
          selected: _alwaysRepeat,
          enabled: _controlsEnabled,
          onTap: () => setState(() => _alwaysRepeat = true),
        ),
        _selectRow(
          itemKey: Key('${widget.prefix}AlarmScopeFirstItem'),
          icon: Icons.looks_one_rounded,
          label: 'Alcance: Solo la primera vez',
          selected: !_alwaysRepeat,
          enabled: _controlsEnabled,
          onTap: () => setState(() => _alwaysRepeat = false),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            key: Key('${widget.prefix}AlarmCancelButton'),
            onPressed: _close,
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            key: Key('${widget.prefix}AlarmSaveButton'),
            onPressed: _save,
            child: const Text('Guardar'),
          ),
        ),
      ],
    );
  }

  Widget _selectRow({
    required Key itemKey,
    required IconData icon,
    required String label,
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: itemKey,
      borderRadius: BorderRadius.circular(12),
      onTap: enabled ? onTap : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
            if (selected)
              const Icon(Icons.check_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _soundChip({
    required String? storageKey,
    required String label,
    required bool selected,
  }) {
    return ChoiceChip(
      key: Key(
        storageKey == null
            ? '${widget.prefix}AlarmSoundDefaultOption'
            : '${widget.prefix}AlarmSoundOption_$storageKey',
      ),
      label: Text(label),
      selected: selected,
      onSelected: _soundEnabled
          ? (_) => setState(() => _soundKey = storageKey)
          : null,
      selectedColor: AppColors.primarySoft,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      labelStyle: TextStyle(
        color: selected ? AppColors.primaryDark : AppColors.text,
        fontWeight: FontWeight.w800,
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  String _formatTime(TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      time,
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
  }
}
