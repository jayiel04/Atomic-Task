// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/audio/alarm_sound.dart';

class AlarmController extends ChangeNotifier {
  AlarmController({
    required AlarmSoundSettings settings,
    required AppAudioService audioService,
    Future<void> Function()? onSoundChanged,
  }) : _settings = settings,
       _audioService = audioService,
       _onSoundChanged = onSoundChanged;

  final AlarmSoundSettings _settings;
  final AppAudioService _audioService;
  final Future<void> Function()? _onSoundChanged;

  AlarmSound _selectedSound = AlarmSound.defaultSound;
  AlarmSound? _previewingSound;
  bool _isInitialized = false;
  bool _isSaving = false;
  bool _isDisposed = false;
  bool _selectionChangedByUser = false;
  String? _errorMessage;

  AlarmSound get selectedSound => _selectedSound;
  AlarmSound? get previewingSound => _previewingSound;
  bool get isInitialized => _isInitialized;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    if (_isDisposed || _isInitialized) {
      return;
    }

    // Render the default immediately. Loading preferences must not leave the
    // whole Home shell waiting for a platform channel response.
    _isInitialized = true;
    notifyListeners();
    unawaited(_loadSavedSound());
  }

  Future<void> _loadSavedSound() async {
    try {
      final savedSound = await _settings.loadSelected();
      if (!_selectionChangedByUser) {
        _selectedSound = savedSound;
      }
    } catch (error, stackTrace) {
      if (!_selectionChangedByUser) {
        _selectedSound = AlarmSound.defaultSound;
      }
      _errorMessage = 'No fue posible cargar la alarma guardada.';
      _reportError('cargar la alarma guardada', error, stackTrace);
    }

    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  Future<void> selectSound(AlarmSound sound) async {
    if (_isDisposed || _isSaving || sound == _selectedSound) {
      return;
    }

    final previousSound = _selectedSound;
    _selectionChangedByUser = true;
    _selectedSound = sound;
    _errorMessage = null;
    _isSaving = true;
    notifyListeners();

    try {
      await _settings.saveSelected(sound);
    } catch (error, stackTrace) {
      _selectedSound = previousSound;
      _errorMessage = 'No fue posible guardar la alarma seleccionada.';
      _reportError('guardar la alarma seleccionada', error, stackTrace);
      _finishSave();
      return;
    }

    try {
      await _onSoundChanged?.call();
    } catch (error, stackTrace) {
      _errorMessage =
          'La alarma se guardó, pero no se pudieron actualizar '
          'los avisos pendientes.';
      _reportError('actualizar los avisos pendientes', error, stackTrace);
    } finally {
      _finishSave();
    }
  }

  Future<void> previewAlarm(AlarmSound sound) async {
    if (_isDisposed) {
      return;
    }
    if (_previewingSound == sound) {
      await stopPreview();
      return;
    }
    _previewingSound = sound;
    if (!_isDisposed) {
      notifyListeners();
    }
    try {
      await _audioService.previewAlarm(
        sound,
        onCompleted: _handlePreviewCompleted,
      );
    } catch (error, stackTrace) {
      _previewingSound = null;
      _errorMessage = 'No fue posible reproducir la alarma.';
      _reportError('reproducir la alarma', error, stackTrace);
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  Future<void> stopPreview() async {
    if (_isDisposed) {
      return;
    }
    _previewingSound = null;
    notifyListeners();
    try {
      await _audioService.stop();
    } catch (error, stackTrace) {
      _reportError('detener la previsualización', error, stackTrace);
    }
  }

  void _handlePreviewCompleted() {
    if (_isDisposed || _previewingSound == null) {
      return;
    }
    _previewingSound = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null || _isDisposed) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  void _finishSave() {
    if (_isDisposed) {
      return;
    }
    _isSaving = false;
    notifyListeners();
  }

  void _reportError(String operation, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('No fue posible $operation: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_audioService.stop());
    unawaited(_audioService.dispose());
    super.dispose();
  }
}
