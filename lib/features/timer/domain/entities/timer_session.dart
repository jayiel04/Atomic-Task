import 'timer_mode.dart';

enum TimerSessionState { prepared, running, paused }

class ActiveTimerSession {
  const ActiveTimerSession({
    required this.sessionId,
    required this.mode,
    required this.state,
    required this.selectedSeconds,
    required this.remainingSeconds,
    required this.elapsedSeconds,
    required this.rewardedBlocks,
    required this.chargedMinutes,
    required this.lastCheckpointAt,
    this.endsAt,
    this.linkedTaskId,
    this.linkedTaskTitle,
  });

  final String sessionId;
  final TimerMode mode;
  final TimerSessionState state;
  final int selectedSeconds;
  final int remainingSeconds;
  final int elapsedSeconds;
  final int rewardedBlocks;
  final int chargedMinutes;
  final DateTime lastCheckpointAt;
  final DateTime? endsAt;
  final int? linkedTaskId;
  final String? linkedTaskTitle;
}

class CompletionSummary {
  const CompletionSummary({
    required this.sessionId,
    required this.mode,
    required this.completedSeconds,
    required this.gemDelta,
    required this.completedAt,
    this.taskId,
    this.taskTitle,
    this.inAppPending = true,
    this.notificationPending = true,
    this.adPending = false,
    this.taskCompletionPending = false,
    this.completedWhileAppWasAway = false,
    this.awaySecondsAfterCompletion,
  });

  final String sessionId;
  final TimerMode mode;
  final int completedSeconds;
  final int gemDelta;
  final DateTime completedAt;
  final int? taskId;
  final String? taskTitle;
  final bool inAppPending;
  final bool notificationPending;
  final bool adPending;
  final bool taskCompletionPending;
  final bool completedWhileAppWasAway;
  final int? awaySecondsAfterCompletion;

  CompletionSummary copyWith({
    bool? inAppPending,
    bool? notificationPending,
    bool? adPending,
    bool? taskCompletionPending,
    bool? completedWhileAppWasAway,
    int? awaySecondsAfterCompletion,
  }) {
    return CompletionSummary(
      sessionId: sessionId,
      mode: mode,
      completedSeconds: completedSeconds,
      gemDelta: gemDelta,
      completedAt: completedAt,
      taskId: taskId,
      taskTitle: taskTitle,
      inAppPending: inAppPending ?? this.inAppPending,
      notificationPending: notificationPending ?? this.notificationPending,
      adPending: adPending ?? this.adPending,
      taskCompletionPending:
          taskCompletionPending ?? this.taskCompletionPending,
      completedWhileAppWasAway:
          completedWhileAppWasAway ?? this.completedWhileAppWasAway,
      awaySecondsAfterCompletion:
          awaySecondsAfterCompletion ?? this.awaySecondsAfterCompletion,
    );
  }
}
