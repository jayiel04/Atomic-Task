import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/timer_mode.dart';
import '../../domain/entities/timer_session.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/repositories/timer_session_repository.dart';

class DriftTimerSessionRepository
    implements TransactionalTimerSessionRepository {
  const DriftTimerSessionRepository(this._database);

  final AppDatabase _database;

  @override
  Future<ActiveTimerSession?> loadActiveSession() async {
    final row = await _database.readActiveTimerSession();
    if (row == null) {
      return null;
    }

    return ActiveTimerSession(
      sessionId: row.sessionId,
      mode: _modeFromStorage(row.mode),
      state: _stateFromStorage(row.state),
      selectedSeconds: row.selectedSeconds,
      remainingSeconds: row.remainingSeconds,
      elapsedSeconds: row.elapsedSeconds,
      rewardedBlocks: row.rewardedBlocks,
      chargedMinutes: row.chargedMinutes,
      lastCheckpointAt: row.lastCheckpointAt,
      endsAt: row.endsAt,
      linkedTaskId: row.linkedTaskId,
      linkedTaskTitle: row.linkedTaskTitle,
    );
  }

  @override
  Future<void> saveActiveSession(ActiveTimerSession session) {
    return _database.writeActiveTimerSession(
      ActiveTimerSessionsCompanion.insert(
        id: const Value(1),
        sessionId: session.sessionId,
        mode: _modeToStorage(session.mode),
        state: _stateToStorage(session.state),
        selectedSeconds: session.selectedSeconds,
        remainingSeconds: session.remainingSeconds,
        elapsedSeconds: session.elapsedSeconds,
        rewardedBlocks: session.rewardedBlocks,
        chargedMinutes: session.chargedMinutes,
        lastCheckpointAt: session.lastCheckpointAt,
        endsAt: Value(session.endsAt),
        linkedTaskId: Value(session.linkedTaskId),
        linkedTaskTitle: Value(session.linkedTaskTitle),
      ),
    );
  }

  @override
  Future<void> clearActiveSession() => _database.deleteActiveTimerSession();

  @override
  Future<CompletionSummary?> loadPendingSummary() async {
    final row = await _database.readPendingTimerSummary();
    if (row == null) {
      return null;
    }

    return CompletionSummary(
      sessionId: row.sessionId,
      mode: _modeFromStorage(row.mode),
      completedSeconds: row.completedSeconds,
      gemDelta: row.gemDelta,
      completedAt: row.completedAt,
      taskId: row.taskId,
      taskTitle: row.taskTitle,
      inAppPending: row.inAppPending,
      notificationPending: row.notificationPending,
      adPending: row.adPending,
      taskCompletionPending: row.taskCompletionPending,
    );
  }

  @override
  Future<void> savePendingSummary(CompletionSummary summary) {
    return _database.writePendingTimerSummary(
      PendingTimerSummariesCompanion.insert(
        sessionId: summary.sessionId,
        mode: _modeToStorage(summary.mode),
        completedSeconds: summary.completedSeconds,
        gemDelta: summary.gemDelta,
        completedAt: summary.completedAt,
        taskId: Value(summary.taskId),
        taskTitle: Value(summary.taskTitle),
        inAppPending: Value(summary.inAppPending),
        notificationPending: Value(summary.notificationPending),
        adPending: Value(summary.adPending),
        taskCompletionPending: Value(summary.taskCompletionPending),
      ),
    );
  }

  @override
  Future<void> clearPendingSummary() => _database.deletePendingTimerSummary();

  @override
  Future<void> finalizeSession(
    CompletionSummary summary,
    UserProgress progress,
  ) {
    return _database.finalizeTimerSession(
      progress: TimerProgressCompanion.insert(
        id: const Value(1),
        gems: Value(progress.gems),
        totalFocusSeconds: Value(progress.totalFocusSeconds),
        profileName: Value(progress.profileName),
      ),
      summary: PendingTimerSummariesCompanion.insert(
        sessionId: summary.sessionId,
        mode: _modeToStorage(summary.mode),
        completedSeconds: summary.completedSeconds,
        gemDelta: summary.gemDelta,
        completedAt: summary.completedAt,
        taskId: Value(summary.taskId),
        taskTitle: Value(summary.taskTitle),
        inAppPending: Value(summary.inAppPending),
        notificationPending: Value(summary.notificationPending),
        adPending: Value(summary.adPending),
        taskCompletionPending: Value(summary.taskCompletionPending),
      ),
    );
  }

  TimerMode _modeFromStorage(String value) {
    return value == TimerMode.rest.name ? TimerMode.rest : TimerMode.focus;
  }

  String _modeToStorage(TimerMode mode) => mode.name;

  TimerSessionState _stateFromStorage(String value) {
    return TimerSessionState.values.firstWhere(
      (state) => state.name == value,
      orElse: () => TimerSessionState.prepared,
    );
  }

  String _stateToStorage(TimerSessionState state) => state.name;
}
