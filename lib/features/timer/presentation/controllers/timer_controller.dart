import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/constants/timer_constants.dart';
import '../../domain/entities/timer_mode.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/services/timer_notification_service.dart';
import '../../domain/usecases/clear_progress.dart';
import '../../domain/usecases/load_progress.dart';
import '../../domain/usecases/save_progress.dart';

class TimerController extends ChangeNotifier {
  TimerController({
    required LoadProgress loadProgress,
    required SaveProgress saveProgress,
    required ClearProgress clearProgress,
    required TimerNotificationService notificationService,
    DateTime Function()? now,
  }) : _loadProgress = loadProgress,
       _saveProgress = saveProgress,
       _clearProgress = clearProgress,
       _notificationService = notificationService,
       _now = now ?? DateTime.now;

  final LoadProgress _loadProgress;
  final SaveProgress _saveProgress;
  final ClearProgress _clearProgress;
  final TimerNotificationService _notificationService;
  final DateTime Function() _now;

  Timer? _ticker;
  Timer? _progressSaveTimer;
  DateTime? _endsAt;
  bool _progressIsDirty = false;

  static const _progressSaveInterval = Duration(seconds: 30);

  TimerMode _mode = TimerMode.focus;
  UserProgress _progress = UserProgress.empty;

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
    await _notificationService.initialize();

    try {
      _progress = await _loadProgress();
    } catch (_) {
      _progress = UserProgress.empty;
      _setStatus('No fue posible cargar el progreso guardado.', isError: true);
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
    _minutes = newMode.defaultMinutes;
    _prepareSelectedTime();
    _updateEstimate();
    notifyListeners();
  }

  void setMinutes(int value) {
    if (controlsLocked) {
      return;
    }

    final newValue = value.clamp(0, TimerConstants.maximumMinutes).toInt();
    if (newValue == _minutes) {
      return;
    }

    _minutes = newValue;
    _prepareSelectedTime();
    _updateEstimate();
    notifyListeners();
  }

  void updateProfileName(String value) {
    final normalizedName = value.trim().isEmpty ? 'NOMBRE' : value.trim();

    _progress = _progress.copyWith(profileName: normalizedName);
    _persistProgress(immediately: true);
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
    _endsAt = _now().add(Duration(seconds: _remainingSeconds));
    _setStatus(
      _mode == TimerMode.focus
          ? 'Sesión de concentración en curso.'
          : 'Descanso en curso.',
    );

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());

    unawaited(
      _notificationService.showRunningTimer(
        timerName: _mode.notificationName,
        remainingSeconds: _remainingSeconds,
        endsAt: _endsAt!,
        completionTitle: _mode.completionNotificationTitle,
        completionBody: _mode.completionNotificationBody,
      ),
    );

    notifyListeners();
  }

  void pause() {
    syncWithClock();
    if (!_isRunning) {
      return;
    }

    _ticker?.cancel();
    _ticker = null;
    _endsAt = null;
    _isRunning = false;
    _persistProgress(immediately: true);
    unawaited(_notificationService.cancelTimerNotifications());
    _setStatus('Sesión pausada. Puedes continuar o reiniciarla.');
    notifyListeners();
  }

  void resetTimer() {
    _ticker?.cancel();
    _ticker = null;
    _endsAt = null;
    unawaited(_notificationService.cancelTimerNotifications());

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
    _endsAt = null;
    _progressSaveTimer?.cancel();
    _progressSaveTimer = null;
    _progressIsDirty = false;
    await _notificationService.cancelTimerNotifications();

    await _clearProgress();

    _progress = UserProgress.empty;
    _mode = TimerMode.focus;
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

  void syncWithClock() {
    final endsAt = _endsAt;
    if (!_isRunning || endsAt == null) {
      return;
    }

    final millisecondsLeft = endsAt.difference(_now()).inMilliseconds;
    final calculatedRemaining = millisecondsLeft <= 0
        ? 0
        : (millisecondsLeft + 999) ~/ 1000;
    final newRemaining = calculatedRemaining
        .clamp(0, _remainingSeconds)
        .toInt();
    final elapsedSinceLastTick = _remainingSeconds - newRemaining;

    if (elapsedSinceLastTick == 0) {
      return;
    }

    _remainingSeconds = newRemaining;
    _elapsedSeconds += elapsedSinceLastTick;

    if (_mode == TimerMode.focus) {
      _applyFocusRules(elapsedSinceLastTick);
    } else {
      _applyRestRules();
    }

    if (!_isRunning) {
      return;
    }

    if (_remainingSeconds <= 0) {
      _finishSession();
      return;
    }

    notifyListeners();
  }

  void _tick() => syncWithClock();

  void _applyFocusRules(int elapsedSeconds) {
    _progress = _progress.copyWith(
      totalFocusSeconds: _progress.totalFocusSeconds + elapsedSeconds,
    );

    final completedBlocks =
        _elapsedSeconds ~/ TimerConstants.secondsPerFocusGem;

    if (completedBlocks > _rewardedBlocks) {
      final newGems = completedBlocks - _rewardedBlocks;

      _rewardedBlocks = completedBlocks;
      _progress = _progress.copyWith(gems: _progress.gems + newGems);

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
    _progress = _progress.copyWith(gems: _progress.gems - minutesToCharge);

    _setStatus(
      'Se descontó $minutesToCharge ${minutesToCharge == 1 ? 'gema' : 'gemas'} por el descanso.',
    );

    _persistProgress(immediately: true);
  }

  void _finishSession() {
    _ticker?.cancel();
    _ticker = null;
    _endsAt = null;
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
    _persistProgress(immediately: true);
    unawaited(
      _notificationService.showTimerCompleted(
        title: _mode.completionNotificationTitle,
        body: _mode.completionNotificationBody,
      ),
    );
    notifyListeners();
  }

  void _stopBecauseNoGems() {
    _ticker?.cancel();
    _ticker = null;
    _endsAt = null;
    _isRunning = false;
    _sessionCompleted = true;
    _elapsedSeconds = 0;
    _rewardedBlocks = 0;
    _chargedMinutes = 0;

    _setStatus('El descanso terminó porque ya no quedan gemas.', isError: true);

    unawaited(
      _notificationService.showTimerCompleted(
        title: TimerMode.rest.completionNotificationTitle,
        body: TimerMode.rest.completionNotificationBody,
      ),
    );

    notifyListeners();
  }

  bool _validateStart() {
    if (_selectedSeconds <= 0) {
      _setStatus('Selecciona una duración mayor que cero.', isError: true);
      return false;
    }

    if (_mode == TimerMode.rest && _elapsedSeconds == 0) {
      final requiredGems = (_selectedSeconds / TimerConstants.secondsPerRestGem)
          .ceil();

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
    _selectedSeconds = _minutes * 60;
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

  void _setStatus(String message, {bool isError = false}) {
    _statusMessage = message;
    _statusIsError = isError;
  }

  void _persistProgress({bool immediately = false}) {
    _progressIsDirty = true;

    if (immediately) {
      _progressSaveTimer?.cancel();
      _progressSaveTimer = null;
      unawaited(_flushProgress());
      return;
    }

    _progressSaveTimer ??= Timer(_progressSaveInterval, _flushProgress);
  }

  Future<void> _flushProgress() async {
    _progressSaveTimer?.cancel();
    _progressSaveTimer = null;

    if (!_progressIsDirty) {
      return;
    }

    _progressIsDirty = false;
    await _saveProgress(_progress);
  }

  void flushProgress() {
    if (_progressIsDirty) {
      unawaited(_flushProgress());
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _progressSaveTimer?.cancel();
    flushProgress();
    super.dispose();
  }
}
