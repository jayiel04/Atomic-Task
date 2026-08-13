// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/constants/timer_constants.dart';
import '../../domain/entities/timer_mode.dart';
import '../../domain/entities/timer_session.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/repositories/timer_session_repository.dart';
import '../../domain/services/focus_completion_ad_service.dart';
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
    required FocusCompletionAdService focusCompletionAdService,
    this.onLinkedTaskFocusCompleted,
    this.onLinkedTaskFocusCompletedAsync,
    this.onCompletionSummary,
    TimerSessionRepository? sessionRepository,
    DateTime Function()? now,
  }) : _loadProgress = loadProgress,
       _saveProgress = saveProgress,
       _clearProgress = clearProgress,
       _notificationService = notificationService,
       _focusCompletionAdService = focusCompletionAdService,
       _sessionRepository = sessionRepository,
       _now = now ?? DateTime.now;

  final LoadProgress _loadProgress;
  final SaveProgress _saveProgress;
  final ClearProgress _clearProgress;
  final TimerNotificationService _notificationService;
  final FocusCompletionAdService _focusCompletionAdService;
  final TimerSessionRepository? _sessionRepository;
  final DateTime Function() _now;
  final ValueChanged<int>? onLinkedTaskFocusCompleted;
  final Future<bool> Function(int taskId)? onLinkedTaskFocusCompletedAsync;
  final ValueChanged<CompletionSummary>? onCompletionSummary;

  Timer? _ticker;
  Timer? _progressSaveTimer;
  Future<void> _sessionWriteQueue = Future<void>.value();
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
  bool _isDisposed = false;
  bool _isRunning = false;
  bool _sessionCompleted = false;
  bool _statusIsError = false;
  int? _linkedTaskId;
  String? _linkedTaskTitle;
  String _sessionId = _newSessionId();
  CompletionSummary? _pendingCompletionSummary;
  bool _pendingSummaryDeliveryInProgress = false;

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
  int? get linkedTaskId => _linkedTaskId;
  String? get linkedTaskTitle => _linkedTaskTitle;
  CompletionSummary? get pendingCompletionSummary =>
      _pendingSummaryDeliveryInProgress ? null : _pendingCompletionSummary;
  bool get hasRestorableSession =>
      _hasRestoredSession || _linkedTaskTitle != null || _elapsedSeconds > 0;

  bool get controlsLocked => _isRunning || _elapsedSeconds > 0;

  bool prepareFocusForTask({
    required int taskId,
    required String taskTitle,
    required int minutes,
  }) {
    if (!_isInitialized || controlsLocked) {
      return false;
    }

    _mode = TimerMode.focus;
    _minutes = minutes.clamp(1, TimerConstants.maximumMinutes).toInt();
    _linkedTaskId = taskId;
    _linkedTaskTitle = taskTitle;
    _sessionId = _newSessionId();
    _prepareSelectedTime();
    _setStatus(
      'Concentración preparada para “$taskTitle”. Inicia cuando estés listo.',
    );
    _persistActiveSession();
    _notifyListeners();
    return true;
  }

  Future<void> initialize() async {
    unawaited(_runAdOperation(_focusCompletionAdService.initialize));
    await _notificationService.initialize();

    try {
      final loadedProgress = await _loadProgress();
      _progress = loadedProgress.copyWith(
        profileName: UserProgress.normalizeProfileName(
          loadedProgress.profileName,
        ),
      );
      await _restoreActiveSession();
      await _restorePendingSummary();
    } catch (_) {
      _progress = UserProgress.empty;
      _setStatus('No fue posible cargar el progreso guardado.', isError: true);
    } finally {
      _isInitialized = true;
      if (!_hasRestoredSession) {
        _updateEstimate();
      }
      _notifyListeners();
    }

    if (_hasRestoredRunningSession) {
      syncWithClock();
    }
    if (_pendingCompletionSummary != null) {
      unawaited(_deliverPendingSummary(_pendingCompletionSummary!));
    }
  }

  bool _hasRestoredSession = false;
  bool _hasRestoredRunningSession = false;

  Future<void> _restoreActiveSession() async {
    final repository = _sessionRepository;
    if (repository == null) {
      return;
    }

    final session = await repository.loadActiveSession();
    if (session == null) {
      return;
    }

    _hasRestoredSession = true;
    _sessionId = session.sessionId;
    _mode = session.mode;
    _minutes = (session.selectedSeconds ~/ 60).clamp(
      0,
      TimerConstants.maximumMinutes,
    );
    _selectedSeconds = session.selectedSeconds;
    _remainingSeconds = session.remainingSeconds;
    _elapsedSeconds = session.elapsedSeconds;
    _rewardedBlocks = session.rewardedBlocks;
    _chargedMinutes = session.chargedMinutes;
    _linkedTaskId = session.linkedTaskId;
    _linkedTaskTitle = session.linkedTaskTitle;
    _sessionCompleted = false;

    if (session.state == TimerSessionState.running && session.endsAt != null) {
      _endsAt = session.endsAt;
      _isRunning = true;
      _hasRestoredRunningSession = true;
      _setStatus(
        _mode == TimerMode.focus
            ? 'Sesión de concentración en curso.'
            : 'Descanso en curso.',
      );
      _startTicker();
    } else {
      _isRunning = false;
      _endsAt = null;
      _setStatus(
        session.state == TimerSessionState.paused
            ? 'Sesión pausada. Puedes continuar o reiniciarla.'
            : _linkedTaskTitle == null
            ? 'Sesión preparada. Inicia cuando estés listo.'
            : 'Concentración preparada para “$_linkedTaskTitle”. '
                  'Inicia cuando estés listo.',
      );
    }
  }

  Future<void> _restorePendingSummary() async {
    final repository = _sessionRepository;
    if (repository == null) {
      return;
    }
    _pendingCompletionSummary = await repository.loadPendingSummary();
    _pendingSummaryDeliveryInProgress = _pendingCompletionSummary != null;
  }

  void setMode(TimerMode newMode) {
    if (controlsLocked || newMode == _mode) {
      return;
    }

    _mode = newMode;
    _clearLinkedTask();
    _sessionId = _newSessionId();
    _minutes = newMode.defaultMinutes;
    _prepareSelectedTime();
    _updateEstimate();
    _notifyListeners();
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
    _clearLinkedTask();
    _sessionId = _newSessionId();
    _prepareSelectedTime();
    _updateEstimate();
    _notifyListeners();
  }

  void updateProfileName(String value) {
    final normalizedName = UserProgress.normalizeProfileName(value);

    _progress = _progress.copyWith(profileName: normalizedName);
    _persistProgress(immediately: true);
    _notifyListeners();
  }

  void startOrPause() {
    if (_isRunning) {
      pause();
      return;
    }

    if (!_validateStart()) {
      _notifyListeners();
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
          ? _linkedTaskTitle == null
                ? 'Sesión de concentración en curso.'
                : 'Concentración para “$_linkedTaskTitle” en curso.'
          : 'Descanso en curso.',
    );

    _startTicker();
    _persistActiveSession();

    unawaited(
      _notificationService.showRunningTimer(
        timerName: _mode.notificationName,
        remainingSeconds: _remainingSeconds,
        endsAt: _endsAt!,
        completionTitle: _mode.completionNotificationTitle,
        completionBody: _mode.completionNotificationBody,
      ),
    );

    _notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
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
    _persistActiveSession();
    unawaited(_notificationService.cancelTimerNotifications());
    _setStatus('Sesión pausada. Puedes continuar o reiniciarla.');
    _notifyListeners();
  }

  void resetTimer() {
    _ticker?.cancel();
    _ticker = null;
    _endsAt = null;
    unawaited(_notificationService.cancelTimerNotifications());
    unawaited(
      _enqueueSessionWrite(() async {
        await _sessionRepository?.clearActiveSession();
      }),
    );

    _isRunning = false;
    _sessionCompleted = false;
    _elapsedSeconds = 0;
    _rewardedBlocks = 0;
    _chargedMinutes = 0;
    _remainingSeconds = _selectedSeconds;
    _clearLinkedTask();
    _sessionId = _newSessionId();

    _updateEstimate();
    _notifyListeners();
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
    await _enqueueSessionWrite(() async {
      await _sessionRepository?.clearActiveSession();
      await _sessionRepository?.clearPendingSummary();
    });

    _pendingCompletionSummary = null;
    _pendingSummaryDeliveryInProgress = false;
    _progress = UserProgress.empty;
    _mode = TimerMode.focus;
    _minutes = TimerConstants.defaultFocusMinutes;
    _isRunning = false;
    _sessionCompleted = false;
    _elapsedSeconds = 0;
    _rewardedBlocks = 0;
    _chargedMinutes = 0;
    _clearLinkedTask();
    _sessionId = _newSessionId();

    _prepareSelectedTime();
    _updateEstimate();
    _notifyListeners();
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

    _persistActiveSession();
    _notifyListeners();
  }

  void handleAppResumed() {
    syncWithClock();
    final pending = _pendingCompletionSummary;
    if (pending != null && pending.adPending) {
      unawaited(_deliverPendingSummary(pending));
    }
  }

  void persistSession() {
    _persistProgress(immediately: true);
    _persistActiveSession();
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
    _persistProgress(immediately: true);
  }

  void _finishSession() {
    final mode = _mode;
    final completedTaskId = mode == TimerMode.focus ? _linkedTaskId : null;
    final completedTaskTitle = _linkedTaskTitle;
    final completedSeconds = _elapsedSeconds;
    final gemDelta = mode == TimerMode.focus
        ? _rewardedBlocks
        : -_chargedMinutes;
    final summary = CompletionSummary(
      sessionId: _sessionId,
      mode: mode,
      completedSeconds: completedSeconds,
      gemDelta: gemDelta,
      completedAt: _now(),
      taskId: completedTaskId,
      taskTitle: completedTaskTitle,
      adPending: mode == TimerMode.focus,
      taskCompletionPending: completedTaskId != null,
    );

    _ticker?.cancel();
    _ticker = null;
    _endsAt = null;
    _isRunning = false;
    _sessionCompleted = true;
    _remainingSeconds = 0;
    _setStatus(
      mode == TimerMode.focus
          ? completedTaskTitle == null
                ? 'Sesión completada.'
                : 'Concentración completada para “$completedTaskTitle”.'
          : 'Descanso completado.',
    );

    _elapsedSeconds = 0;
    _rewardedBlocks = 0;
    _chargedMinutes = 0;
    _clearLinkedTask();
    _persistProgress(immediately: true);
    unawaited(_completeAndPresentSummary(summary));
    _notifyListeners();
  }

  Future<void> _completeAndPresentSummary(CompletionSummary summary) async {
    final sessionRepository = _sessionRepository;
    if (sessionRepository is TransactionalTimerSessionRepository) {
      await _enqueueSessionWrite(
        () => sessionRepository.finalizeSession(summary, _progress),
      );
    } else {
      await _flushProgress();
      await _enqueueSessionWrite(() async {
        await sessionRepository?.clearActiveSession();
        await sessionRepository?.savePendingSummary(summary);
      });
    }
    await _notificationService.showTimerCompleted(
      title: _summaryTitle(summary),
      body: _summaryBody(summary),
    );

    final taskCompleted = summary.taskId == null
        ? true
        : await _completeLinkedTask(summary.taskId!);

    final adResult = summary.mode != TimerMode.focus
        ? FocusCompletionAdResult.unsupported
        : await _tryShowCompletionAd();
    final delivered = summary.copyWith(
      notificationPending: false,
      adPending: adResult == FocusCompletionAdResult.retry,
      taskCompletionPending: summary.taskId != null && !taskCompleted,
    );
    await _storePendingSummary(delivered);
    _notifyListeners();
    onCompletionSummary?.call(delivered);
  }

  Future<void> _deliverPendingSummary(CompletionSummary summary) async {
    var current = summary;
    if (current.notificationPending) {
      await _notificationService.showTimerCompleted(
        title: _summaryTitle(current),
        body: _summaryBody(current),
      );
      current = current.copyWith(notificationPending: false);
    }

    if (current.taskCompletionPending && current.taskId != null) {
      final taskCompleted = await _completeLinkedTask(current.taskId!);
      if (taskCompleted) {
        current = current.copyWith(taskCompletionPending: false);
      }
    }

    if (current.adPending && current.mode == TimerMode.focus) {
      final adResult = await _tryShowCompletionAd();
      current = current.copyWith(
        adPending: adResult == FocusCompletionAdResult.retry,
      );
    }

    await _storePendingSummary(current);
    _pendingSummaryDeliveryInProgress = false;
    _notifyListeners();
    onCompletionSummary?.call(current);
  }

  String _summaryTitle(CompletionSummary summary) {
    return summary.mode == TimerMode.focus
        ? 'Sesión completada'
        : 'Descanso completado';
  }

  String _summaryBody(CompletionSummary summary) {
    final duration = _formatMinutes(summary);
    final gemText = summary.gemDelta >= 0
        ? '+${summary.gemDelta} ${summary.gemDelta == 1 ? 'gema' : 'gemas'}'
        : '−${summary.gemDelta.abs()} '
              '${summary.gemDelta.abs() == 1 ? 'gema' : 'gemas'}';
    final task = summary.taskTitle == null
        ? ''
        : '\nTarea: ${summary.taskTitle}';
    return '$duration · $gemText$task';
  }

  String _formatMinutes(CompletionSummary summary) {
    final minutes = summary.completedSeconds ~/ 60;
    return '$minutes min '
        '${summary.mode == TimerMode.focus ? 'de concentración' : 'de descanso'}';
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
      _enqueueSessionWrite(() async {
        await _sessionRepository?.clearActiveSession();
      }),
    );
    unawaited(
      _notificationService.showTimerCompleted(
        title: TimerMode.rest.completionNotificationTitle,
        body: TimerMode.rest.completionNotificationBody,
      ),
    );
    _notifyListeners();
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

  void _clearLinkedTask() {
    _linkedTaskId = null;
    _linkedTaskTitle = null;
  }

  void _updateEstimate() {
    final selectedMinutes = _selectedSeconds ~/ 60;

    if (_mode == TimerMode.focus) {
      final reward = selectedMinutes ~/ 3;

      _setStatus(
        reward > 0
            ? 'Esta sesión puede darte $reward '
                  '${reward == 1 ? 'gema' : 'gemas'}. '
                  'Inicia cuando estés listo.'
            : 'No generará gemas. Inicia cuando estés listo.',
      );
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

  void _persistActiveSession() {
    final repository = _sessionRepository;
    if (repository == null || !_isInitialized) {
      return;
    }

    final session = ActiveTimerSession(
      sessionId: _sessionId,
      mode: _mode,
      state: _isRunning
          ? TimerSessionState.running
          : _elapsedSeconds > 0
          ? TimerSessionState.paused
          : TimerSessionState.prepared,
      selectedSeconds: _selectedSeconds,
      remainingSeconds: _remainingSeconds,
      elapsedSeconds: _elapsedSeconds,
      rewardedBlocks: _rewardedBlocks,
      chargedMinutes: _chargedMinutes,
      lastCheckpointAt: _now(),
      endsAt: _endsAt,
      linkedTaskId: _linkedTaskId,
      linkedTaskTitle: _linkedTaskTitle,
    );
    unawaited(
      _enqueueSessionWrite(() => repository.saveActiveSession(session)),
    );
  }

  void consumePendingCompletionSummary() {
    final summary = _pendingCompletionSummary;
    if (summary == null) {
      return;
    }

    final consumed = summary.copyWith(inAppPending: false);
    unawaited(_storePendingSummary(consumed));
    _notifyListeners();
  }

  Future<void> _storePendingSummary(CompletionSummary summary) async {
    final hasPendingWork =
        summary.inAppPending ||
        summary.notificationPending ||
        summary.adPending ||
        summary.taskCompletionPending;
    if (!hasPendingWork) {
      _pendingCompletionSummary = null;
      await _enqueueSessionWrite(() async {
        await _sessionRepository?.clearPendingSummary();
      });
      return;
    }

    _pendingCompletionSummary = summary;
    await _enqueueSessionWrite(() async {
      await _sessionRepository?.savePendingSummary(summary);
    });
  }

  Future<void> _enqueueSessionWrite(Future<void> Function() operation) {
    final queued = _sessionWriteQueue.then<void>((_) => operation());
    _sessionWriteQueue = queued.catchError((_) {});
    return queued;
  }

  Future<FocusCompletionAdResult> _tryShowCompletionAd() async {
    try {
      return await _focusCompletionAdService.showAfterFocusCompletionResult();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('No fue posible mostrar el anuncio de prueba: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      return FocusCompletionAdResult.retry;
    }
  }

  Future<bool> _completeLinkedTask(int taskId) async {
    try {
      final asyncCallback = onLinkedTaskFocusCompletedAsync;
      if (asyncCallback != null) {
        return await asyncCallback(taskId);
      }
      onLinkedTaskFocusCompleted?.call(taskId);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _notifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> _runAdOperation(Future<void> Function() operation) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('No fue posible completar la operación de AdMob: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  static String _newSessionId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _ticker?.cancel();
    _progressSaveTimer?.cancel();
    flushProgress();
    _persistActiveSession();
    unawaited(_runAdOperation(_focusCompletionAdService.dispose));
    super.dispose();
  }

  void flushProgress() {
    if (_progressIsDirty) {
      unawaited(_flushProgress());
    }
  }
}
