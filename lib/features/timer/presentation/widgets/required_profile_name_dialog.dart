import 'package:flutter/material.dart';

import '../../domain/entities/user_progress.dart';

Future<void> showRequiredProfileNameDialog(
  BuildContext context, {
  required ValueChanged<String> onSubmitted,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _RequiredProfileNameDialog(onSubmitted: onSubmitted),
  );
}

class _RequiredProfileNameDialog extends StatefulWidget {
  const _RequiredProfileNameDialog({required this.onSubmitted});

  final ValueChanged<String> onSubmitted;

  @override
  State<_RequiredProfileNameDialog> createState() =>
      _RequiredProfileNameDialogState();
}

class _RequiredProfileNameDialogState
    extends State<_RequiredProfileNameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    widget.onSubmitted(_nameController.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('¡Bienvenido!'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Cómo te llamas? Usaremos tu nombre para personalizar '
                'tu experiencia.',
              ),
              const SizedBox(height: 18),
              TextFormField(
                key: const Key('firstLaunchNameField'),
                controller: _nameController,
                autofocus: true,
                maxLength: UserProgress.maxProfileNameLength,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Tu nombre',
                  hintText: 'Escribe tu nombre',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa tu nombre para continuar';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            key: const Key('saveFirstLaunchName'),
            onPressed: _submit,
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}
