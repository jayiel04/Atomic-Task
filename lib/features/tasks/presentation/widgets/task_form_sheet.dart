import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/atomic_task.dart';
import '../controllers/task_controller.dart';
import '../task_date_formatter.dart';

class TaskFormSheet extends StatefulWidget {
  const TaskFormSheet({required this.controller, this.task, super.key});

  final TaskController controller;
  final AtomicTask? task;

  static Future<void> show(
    BuildContext context, {
    required TaskController controller,
    AtomicTask? task,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => TaskFormSheet(controller: controller, task: task),
    );
  }

  @override
  State<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends State<TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  DateTime? _dueDate;
  bool _isSaving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
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
                    _isEditing ? 'Editar tarea' : 'Nueva tarea',
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
              decoration: InputDecoration(
                labelText: 'Título',
                hintText: '¿Qué quieres completar?',
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
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Escribe un título para la tarea'
                  : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 10),
            Container(
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
                        const Text(
                          'Fecha límite',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          _dueDate == null
                              ? 'Sin fecha límite'
                              : TaskDateFormatter.format(_dueDate!),
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  if (_dueDate != null)
                    IconButton(
                      key: const Key('clearTaskDueDateButton'),
                      tooltip: 'Quitar fecha',
                      onPressed: _isSaving
                          ? null
                          : () => setState(() => _dueDate = null),
                      icon: const Icon(Icons.event_busy_rounded),
                    ),
                  IconButton(
                    key: const Key('selectTaskDueDateButton'),
                    tooltip: _dueDate == null
                        ? 'Elegir fecha'
                        : 'Cambiar fecha',
                    onPressed: _isSaving ? null : _selectDueDate,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
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

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 100),
      helpText: 'Selecciona la fecha límite',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (selected != null && mounted) {
      setState(() {
        _dueDate = DateTime(selected.year, selected.month, selected.day);
      });
    }
  }

  Future<void> _submit() async {
    if (_isSaving || _formKey.currentState?.validate() != true) {
      return;
    }

    setState(() => _isSaving = true);
    final task = widget.task;
    final saved = task == null
        ? await widget.controller.create(
            title: _titleController.text,
            dueDate: _dueDate,
          )
        : await widget.controller.update(
            task: task,
            title: _titleController.text,
            dueDate: _dueDate,
          );

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
