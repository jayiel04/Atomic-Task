import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/constants/timer_constants.dart';
import '../../domain/entities/timer_mode.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/usecases/clear_progress.dart';
import '../../domain/usecases/load_progress.dart';
import '../../domain/usecases/save_progress.dart';

class TimerController extends ChangeNotifier {
  TimerController({
    required LoadProgress loadProgress,
    required SaveProgress saveProgress,
    required ClearProgress clearProgress,
  })  : _loadProgress = loadProgress,
        _saveProgress = saveProgress,
        _clearProgress = clearProgress;

  final LoadProgress _loadProgress;
  final SaveProgress _saveProgress;
  final ClearProgress _clearProgress;

  Timer? _ticker;

  TimerMode _mode = TimerMode.focus;
  UserProgress _progress = UserProgress.empty;

  int _hours = 0;
  int _minutes = TimerConstants.defaultFocusMinutes;
  int _selectedSeconds = TimerConstants.defaultFocusMinutes * 60;
  int _remainingSeconds = TimerConstants.defaultFocusMinutes * 60;
  int _elapsedSeconds = 0;
  int _rewardedBlocks = 0;
  int _chargedMinutes = 0;

  bool _isInitialized = false;
  bool _isRunning = false;
  bool _sessionCompleted = false;
  bool _statusIsError = false;

  String _statusMessage =
      'Obtendrás 1 gema por cada 3 minutos completos de concentración.';

  TimerMode get mode => _mode;
  UserProgress get progress => _progress;
  int get hours => _hours;
  int get minutes => _minutes;
  int get remainingSeconds => _remainingSeconds;
  int get selectedSeconds => _selectedSeconds;
  bool get isInitialized => _isInitialized;
  bool get isRunning => _isRunning;
  bool get sessionCompleted => _sessionCompleted;
  bool get statusIsError => _statusIsError;
  String get statusMessage => _statusMessage;

  bool get controlsLocked => _isRunning || _elapsedSeconds > 0;

  Future<void> initialize() async {
    try {
      _progress = await _loadProgress();
    } catch (_) {
      _progress = UserProgress.empty;
      _setStatus(
        'No fue posible cargar el progreso guardado.',
        isError: true,
      );
    } finally {
      _isInitialized = true;
      _updateEstimate();
      notifyListeners();
    }
  }

  void setMode(TimerMode newMode) {
    if (controlsLocked || newMode == _mode) {
      return;
    }

    _mode = newMode;
    _hours = 0;
    _minutes = newMode.defaultMinutes;
    _prepareSelectedTime();
    _updateEstimate();
    notifyListeners();
  }

  void increaseHours() => _changeHours(1);

  void decreaseHours() => _changeHours(-1);

  void increaseMinutes() => _changeMinutes(1);

  void decreaseMinutes() => _changeMinutes(-1);

  void _changeHours(int change) {
    if (controlsLocked) {
      return;
    }

    _hours = (_hours + change)
        .clamp(0, TimerConstants.maximumHours)
        .toInt();

    _prepareSelectedTime();
    _updateEstimate();
    notifyListeners();
  }

  void _changeMinutes(int change) {
    if (controlsLocked) {
      return;
    }

    _minutes += change;

    if (_minutes > TimerConstants.maximumMinutes) {
      _minutes = 0;
      _hours = (_hours + 1)
          .clamp(0, TimerConstants.maximumHours)
          .toInt();
    } else if (_minutes < 0) {
      if (_hours > 0) {
        _hours -= 1;
        _minutes = TimerConstants.maximumMinutes;
      } else {
        _minutes = 0;
      }
    }

    _prepareSelectedTime();
    _updateEstimate();
    notifyListeners();
  }

  void updateProfileName(String value) {
    final normalizedName = value.trim().isEmpty ? 'NOMBRE' : value.trim();

    _progress = _progress.copyWith(profileName: normalizedName);
    _persistProgress();
    notifyListeners();
  }

  void startOrPause() {
    if (_isRunning) {
      pause();
      return;
    }

    if (!_validateStart()) {
      notifyListeners();
      return;
    }

    if (_remainingSeconds <= 0) {
      _remainingSeconds = _selectedSeconds;
    }

    _sessionCompleted = false;
    _isRunning = true;
    _setStatus(
      _mode == TimerMode.focus
          ? 'Sesión de concentración en curso.'
          : 'Descanso en curso.',
    );

    _ticker?.cancel();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tick(),
    );

    notifyListeners();
  }

  void pause() {
    _ticker?.cancel();
    _ticker = null;
    _isRunning = false;
    _setStatus('Sesión pausada. Puedes continuar o reiniciarla.');
    notifyListeners();
  }

  void resetTimer() {
    _ticker?.cancel();
    _ticker = null;

    _isRunning = false;
    _sessionCompleted = false;
    _elapsedSeconds = 0;
    _rewardedBlocks = 0;
    _chargedMinutes = 0;
    _remainingSeconds = _selectedSeconds;

    _updateEstimate();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    _ticker?.cancel();
    _ticker = null;

    await _clearProgress();

    _progress = UserProgress.empty;
    _mode = TimerMode.focus;
    _hours = 0;
    _minutes = TimerConstants.defaultFocusMinutes;
    _isRunning = false;
    _sessionCompleted = false;
    _elapsedSeconds = 0;
    _rewardedBlocks = 0;
    _chargedMinutes = 0;

    _prepareSelectedTime();
    _updateEstimate();
    notifyListeners();
  }

  void _tick() {
    if (!_isRunning) {
      return;
    }

    _remainingSeconds -= 1;
    _elapsedSeconds += 1;

    if (_mode == TimerMode.focus) {
      _applyFocusRules();
    } else {
      _applyRestRules();
    }

    if (_remainingSeconds <= 0) {
      _finishSession();
      return;
    }

    notifyListeners();
  }

  void _applyFocusRules() {
    _progress = _progress.copyWith(
      totalFocusSeconds: _progress.totalFocusSeconds + 1,
    );

    final completedBlocks =
        _elapsedSeconds ~/ TimerConstants.secondsPerFocusGem;

    if (completedBlocks > _rewardedBlocks) {
      final newGems = completedBlocks - _rewardedBlocks;

      _rewardedBlocks = completedBlocks;
      _progress = _progress.copyWith(
        gems: _progress.gems + newGems,
      );

      _setStatus(
        '¡Ganaste $newGems ${newGems == 1 ? 'gema' : 'gemas'} por tu concentración!',
      );
    }

    _persistProgress();
  }

  void _applyRestRules() {
    final completedPaidMinutes =
        _elapsedSeconds ~/ TimerConstants.secondsPerRestGem;

    if (completedPaidMinutes <= _chargedMinutes) {
      return;
    }

    final minutesToCharge = completedPaidMinutes - _chargedMinutes;

    if (_progress.gems < minutesToCharge) {
      _stopBecauseNoGems();
      return;
    }

    _chargedMinutes = completedPaidMinutes;
    _progress = _progress.copyWith(
      gems: _progress.gems - minutesToCharge,
    );

    _setStatus(
      'Se descontó $minutesToCharge ${minutesToCharge == 1 ? 'gema' : 'gemas'} por el descanso.',
    );

    _persistProgress();
  }

  void _finishSession() {
    _ticker?.cancel();
    _ticker = null;
    _isRunning = false;
    _sessionCompleted = true;
    _remainingSeconds = 0;

    if (_mode == TimerMode.focus) {
      _setStatus(
        '¡Sesión completada! Ganaste $_rewardedBlocks '
        '${_rewardedBlocks == 1 ? 'gema' : 'gemas'}.',
      );
    } else {
      _setStatus(
        'Descanso completado. Gastaste $_chargedMinutes '
        '${_chargedMinutes == 1 ? 'gema' : 'gemas'}.',
      );
    }

    _elapsedSeconds = 0;
    _rewardedBlocks = 0;
    _chargedMinutes = 0;
    _persistProgress();
    notifyListeners();
  }

  void _stopBecauseNoGems() {
    _ticker?.cancel();
    _ticker = null;
    _isRunning = false;
    _sessionCompleted = true;
    _elapsedSeconds = 0;
    _rewardedBlocks = 0;
    _chargedMinutes = 0;

    _setStatus(
      'El descanso terminó porque ya no quedan gemas.',
      isError: true,
    );

    notifyListeners();
  }

  bool _validateStart() {
    if (_selectedSeconds <= 0) {
      _setStatus(
        'Selecciona una duración mayor que cero.',
        isError: true,
      );
      return false;
    }

    if (_mode == TimerMode.rest && _elapsedSeconds == 0) {
      final requiredGems =
          (_selectedSeconds / TimerConstants.secondsPerRestGem).ceil();

      if (_progress.gems < requiredGems) {
        _setStatus(
          'No tienes suficientes gemas. Necesitas $requiredGems '
          'y tienes ${_progress.gems}.',
          isError: true,
        );
        return false;
      }
    }

    return true;
  }

  void _prepareSelectedTime() {
    _selectedSeconds = (_hours * 3600) + (_minutes * 60);
    _remainingSeconds = _selectedSeconds;
    _sessionCompleted = false;
  }

  void _updateEstimate() {
    final selectedMinutes = _selectedSeconds ~/ 60;

    if (_mode == TimerMode.focus) {
      final reward = selectedMinutes ~/ 3;

      if (reward > 0) {
        _setStatus(
          'Esta sesión puede darte $reward '
          '${reward == 1 ? 'gema' : 'gemas'}.',
        );
      } else {
        _setStatus('Necesitas al menos 3 minutos para ganar una gema.');
      }

      return;
    }

    _setStatus(
      'Este descanso cuesta $selectedMinutes '
      '${selectedMinutes == 1 ? 'gema' : 'gemas'}. '
      'Tienes ${_progress.gems}.',
      isError: selectedMinutes > _progress.gems,
    );
  }

  void _setStatus(
    String message, {
    bool isError = false,
  }) {
    _statusMessage = message;
    _statusIsError = isError;
  }

  void _persistProgress() {
    unawaited(_saveProgress(_progress));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
