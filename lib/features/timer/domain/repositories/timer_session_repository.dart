import '../entities/timer_session.dart';
import '../entities/user_progress.dart';

abstract interface class TimerSessionRepository {
  Future<ActiveTimerSession?> loadActiveSession();

  Future<void> saveActiveSession(ActiveTimerSession session);

  Future<void> clearActiveSession();

  Future<CompletionSummary?> loadPendingSummary();

  Future<void> savePendingSummary(CompletionSummary summary);

  Future<void> clearPendingSummary();
}

/// Optional stronger contract used by the Drift implementation to make
/// progress, active-session removal and pending-summary creation atomic.
abstract interface class TransactionalTimerSessionRepository
    implements TimerSessionRepository {
  Future<void> finalizeSession(
    CompletionSummary summary,
    UserProgress progress,
  );
}
