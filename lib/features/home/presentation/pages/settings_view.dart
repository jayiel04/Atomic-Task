import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../timer/domain/entities/user_progress.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    required this.profileName,
    required this.onProfileNameChanged,
    super.key,
  });

  final String profileName;
  final ValueChanged<String> onProfileNameChanged;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profileName);
    _nameFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant SettingsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_nameFocusNode.hasFocus &&
        _nameController.text != widget.profileName) {
      _nameController.text = widget.profileName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          key: const Key('settingsView'),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: AppColors.primarySoft,
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tu perfil',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'El nombre se guarda en este dispositivo.',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const Key('settingsNameField'),
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      maxLength: UserProgress.maxProfileNameLength,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Escribe tu nombre',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa un nombre';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _save(),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      key: const Key('saveSettingsNameButton'),
                      onPressed: _save,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Guardar nombre'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final name = _nameController.text.trim();
    _nameController.text = name;
    _nameController.selection = TextSelection.collapsed(offset: name.length);
    widget.onProfileNameChanged(name);
    _nameFocusNode.unfocus();
  }
}
